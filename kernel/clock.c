#include "type.h"
#include "const.h"
#include "protect.h"
#include "proc.h"
#include "global.h"
#include "proto.h"

PUBLIC void init_clock(){
    /* 初始化 8253 PIT, 该芯片每隔一定时间会输出一个信号，以便触发时钟中断*/
    out_byte(TIMER_MODE, RATE_GENERATOR);
    out_byte(TIMER0, (u8) (TIMER_FREQ/HZ) );
    out_byte(TIMER0, (u8) ((TIMER_FREQ/HZ) >> 8));

    put_irq_handler(CLOCK_IRQ, clock_handler); /* 设定时钟中断处理程序 */  
    enable_irq(CLOCK_IRQ);                     /* 让8259A可以接收时钟中断 */

}

void clock_handler(int irq){
    ticks++;
    p_proc_ready->ticks--;

    if(k_reenter!=0){
        //disp_str("!");
        return;
    }

    if(p_proc_ready->ticks > 0)
        return;
    
    schedule();
}

PUBLIC void milli_delay(int milli_sec)                               
{                                                                    
    int t = get_ticks();                                         
                                                                      
    while(((get_ticks() - t) * 1000 / HZ) < milli_sec) {}        
}   
