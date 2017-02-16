#include "type.h"
#include "const.h"
#include "protect.h"
#include "proc.h"
#include "global.h"
#include "proto.h"

void schedule(){
//    MAGIC_BP
//    disp_int(p_proc_ready->ticks);
/*    if(p_proc_ready->ticks<=0){
//        MAGIC_BP
        p_proc_ready->ticks = p_proc_ready->priority;
        p_proc_ready++;
        if(p_proc_ready >= proc_table + NR_TASKS)
            p_proc_ready = proc_table;
    }*/

     PROCESS* p;                                                      
     int  greatest_ticks = 0;                                         
     
     while (!greatest_ticks) {                                        
         for (p = proc_table; p < proc_table+NR_TASKS; p++) {         
             if (p->ticks > greatest_ticks) {                         
                 greatest_ticks = p->ticks;
                 p_proc_ready = p;
             }   
         }       
             
         if (!greatest_ticks) {                                       
             for (p = proc_table; p < proc_table+NR_TASKS; p++) {     
                 p->ticks = p->priority;                              
             }
         }       
     }   
}

void clock_handler(int irq){
    ticks++;
    p_proc_ready->ticks--;

    if(k_reenter!=0){
//        disp_int(k_reenter);
        return;
    }
    disp_int(p_proc_ready->ticks);

    if(p_proc_ready->ticks > 0)
        return;
    
    schedule();
}

PUBLIC void milli_delay(int milli_sec)                               
{                                                                    
    int t = get_ticks();                                         
                                                                      
    while(((get_ticks() - t) * 1000 / HZ) < milli_sec) {}        
}   
