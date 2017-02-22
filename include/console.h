#ifndef _OS_CONSOLE_H_
#define _OS_CONSOLE_H_

typedef struct s_console{
    unsigned int    current_start_addr;     // 当前显示到什么位置
    unsigned int    original_addr;          // 当前控制台对应显存位置
    unsigned int    v_mem_limit;            // 当前控制台占的显存大小
    unsigned int    cursor;                 // 当前光标位置
}CONSOLE;

#endif
