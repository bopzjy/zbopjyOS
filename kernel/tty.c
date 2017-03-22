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
//PRIVATE void init_screen(TTY* p_tty);
PRIVATE void put_key(TTY* p_tty, u32 key);

PUBLIC void task_tty(){
    TTY* p_tty;
    init_keyboard();
    for(p_tty = tty_table; p_tty < tty_table + NR_CONSOLES; p_tty++){
        init_tty(p_tty);
    }

    select_console(0);
    while(1){
        
        for(p_tty = tty_table; p_tty < tty_table + NR_CONSOLES; p_tty++){
            tty_do_read(p_tty);
            tty_do_write(p_tty);
        }
    }
}

PRIVATE void init_tty(TTY* p_tty){
    p_tty->p_inbuf_head = p_tty->p_inbuf_tail = p_tty->in_buf;
    p_tty->inbuf_count = 0;

    init_screen(p_tty);
}

PRIVATE void tty_do_read(TTY* p_tty){
    if(is_current_console(p_tty->p_console))
        keyboard_read(p_tty);
}

PRIVATE void tty_do_write(TTY* p_tty){
    if(p_tty->inbuf_count>0){
        char ch = *(p_tty->p_inbuf_tail);
        p_tty->p_inbuf_tail++;
        if(p_tty->p_inbuf_tail == p_tty->in_buf + TTY_IN_BYTES)
            p_tty->p_inbuf_tail = p_tty->in_buf;
        p_tty->inbuf_count--;

        out_char(p_tty->p_console, ch);

    }
}

PRIVATE void put_key(TTY* p_tty, u32 key){
    if(p_tty->inbuf_count < TTY_IN_BYTES) {
        *(p_tty->p_inbuf_head) = key;
        p_tty->p_inbuf_head++;
        if(p_tty->p_inbuf_head == p_tty->in_buf + TTY_IN_BYTES)
        p_tty->p_inbuf_head = p_tty->in_buf;
        p_tty->inbuf_count++;
    }  
}

PUBLIC void in_process(TTY* p_tty, u32 key){
    char output[2] = {'\0', '\0'};

    // FLAG_EXT = 0x0100
    // 判断为真时表示这是个可打印的字符
    if(!(key & FLAG_EXT)) {
        put_key(p_tty, key);
    }else{
        int raw_code = key & MASK_RAW; 
        switch(raw_code){
            // 用key的高位保存是否有一个或多个alt、shift、ctrl等按下
            // 用key的地位（即raw_code）保存原来的字符值
            case ENTER:
                put_key(p_tty, '\n');
                break;
            case BACKSPACE:
                put_key(p_tty, '\b');
                break;
            case UP:
                if((key & FLAG_SHIFT_L) || (key & FLAG_SHIFT_R)) {
                    scroll_screen(p_tty->p_console, SCR_DN);
                }
                break;
            case DOWN:
                if((key & FLAG_SHIFT_L) || (key & FLAG_SHIFT_R)) {
                    scroll_screen(p_tty->p_console, SCR_UP);
                }
                break;
            case F1:
            case F2: 
            case F3: 
            case F4: 
            case F5: 
            case F6: 
            case F7: 
            case F8: 
            case F9: 
            case F10:
            case F11:
            case F12:
                if((key & FLAG_CTRL_L) || (key & FLAG_CTRL_R)) {
                    select_console(raw_code - F1);
                }
                break;
            default:
                break;
       }
    }
    
}
