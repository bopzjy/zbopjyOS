#include "type.h"
#include "const.h"
#include "protect.h"
#include "string.h"
#include "proc.h"
#include "tty.h"
#include "keyboard.h"
#include "console.h"
#include "proto.h"
#include "global.h"

PRIVATE void init_tty(TTY* p_tty);
PRIVATE void tty_do_read(TTY* p_tty);
PRIVATE void tty_do_write(TTY* p_tty);
/* P */

PUBLIC void task_tty(){
    TTY* p_tty;
    init_keyboard();
    for(p_tty = tty_table; p_tty < tty_table + NR_CONSOLE; p_tty++){
        init_tty(p_tty);
    }

    nr_current_console = 0;
    while(1){
        
        for(p_tty = tty_table; p_tty < tty_table + NR_CONSOLE; p_tty++){
            tty_do_read(p_tty);
            tty_do_write(p_tty);
        }
    }
}

PRIVATE void init_tty(TTY* p_tty){
    p_tty->p_inbuf_head = p_tty->p_inbuf_tail = p_tty->in_buf;
    p_tty->inbuf_count = 0;

    int nr_tty = p_tty - tty_table;
    p_tty->p_console = console_table + nr_tty;
}

PRIVATE void tty_do_read(TTY* p_tty){
    if(is_current_console(p_tty->p_console))
        keyboard_read(p_tty);
}

PRIVATE void tty_do_write(TTY* p_tty){

}

PUBLIC int is_current_console(CONSOLE* p_con){
    return (p_con == &console_table[nr_current_console]);
}

PUBLIC void in_process(TTY* p_tty, u32 key){
    char output[2] = {'\0', '\0'};

    // FLAG_EXT = 0x0100
    // 判断为真时表示这是个可打印的字符
    if(!(key & FLAG_EXT)) {
        output[0] = key & 0xFF;
        disp_str(output);

        // let cursor follow the printed letter
        disable_int();
        out_byte(CRTC_ADDR_REG, CURSOR_H);
        out_byte(CRTC_DATA_REG, ((disp_pos/2)>>8)&0xFF);                                  
        out_byte(CRTC_ADDR_REG, CURSOR_L);                                                
        out_byte(CRTC_DATA_REG, (disp_pos/2)&0xFF);
        enable_int();

    }else{
        int raw_code = key & MASK_RAW; 
        switch(raw_code){
            // 用key的高位保存是否有一个或多个alt、shift、ctrl等按下
            // 用key的地位（即raw_code）保存原来的字符值
            case UP:
                if((key & FLAG_SHIFT_L) || (key & FLAG_SHIFT_R)) {
                    disable_int();
                    out_byte(CRTC_ADDR_REG, START_ADDR_H);
                    out_byte(CRTC_DATA_REG, ((80*15) >> 8) & 0xFF);           
                    out_byte(CRTC_ADDR_REG, START_ADDR_L);                    
                    out_byte(CRTC_DATA_REG, (80*15) & 0xFF);   
                    enable_int();
                }
                break;
            case DOWN:
                if((key & FLAG_SHIFT_L) || (key & FLAG_SHIFT_R)) {
                }
                break;
            default:
                break;
       }
    }
    
}
