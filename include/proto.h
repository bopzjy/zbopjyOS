#ifndef _OS_PROTO_H_
#define _OS_PROTO_H_

// main.c
PUBLIC void restart();

// lib/kliba.asm
PUBLIC void out_byte(u16 port, u8 value);
PUBLIC u8 in_byte(u16 port);
PUBLIC void disp_str(char* info);
PUBLIC void init8259A();
PUBLIC void disp_color_str(char * info, int color);
PUBLIC void strcpy(char* p_dst, char* p_src);
PUBLIC void disable_irq(int irq);
PUBLIC void enable_irq(int irq);
PUBLIC void enable_int();
PUBLIC void disable_int();

// lib/klib.c
PUBLIC void disp_int(int num);
PUBLIC void delay(int time);

// kernel/i8259.c
PUBLIC void init_8259A();
PUBLIC void spurious_irq(int irq);
PUBLIC void put_irq_handler(int irq, irq_handler handler);

// kernel/protect.c
PUBLIC void init_prot();
PUBLIC u32 seg2phys(u16);

// kernel/main.c
PUBLIC void TestA();
PUBLIC void TestB();
PUBLIC void TestC();

// kernel/clock.c
PUBLIC void clock_handler();
PUBLIC void milli_delay(int milli_sec);
PUBLIC void init_clock();

// kernel/proc.c
PUBLIC int sys_get_ticks();
PUBLIC void schedule();

// syscall.asm
PUBLIC int get_ticks();
PUBLIC void sys_call();

// keyboard.c
PUBLIC void keyboard_handler(int irq);
PUBLIC void init_keyboard();
PUBLIC void keyboard_read(TTY* p_tty);

// tty.c
PUBLIC void task_tty();
PUBLIC void in_process(TTY* p_tty, u32 key);
PUBLIC int is_current_console(CONSOLE* p_con);

// console.c
PUBLIC void out_char(CONSOLE* p_con, char ch);
PUBLIC void select_console(int nr_console);
PUBLIC void scroll_screen(CONSOLE* p_con, int direction);
PUBLIC void init_screen(TTY* p_tty);

#endif
