#ifndef _OS_PROTO_H_
#define _OS_PROTO_H_

// main.c
//PUBLIC void restart();

// lib/kliba.asm
PUBLIC void out_byte(u16 port, u8 value);
PUBLIC u8 in_byte(u16 port);
PUBLIC void disp_str(char* info);
PUBLIC void init8259A();
PUBLIC void disp_color_str(char * info, int color);
PUBLIC void strcpy(char* p_dst, char* p_src);
PUBLIC void disable_irq(int irq);
PUBLIC void enable_irq(int irq);

// lib/klib.c
PUBLIC void disp_int(int num);
PUBLIC void delay(int time);

// kernel/i8259.c
PUBLIC void init_8259A();
PUBLIC void spurious_irq(int irq);

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

// kernel/proc.c
PUBLIC int sys_get_ticks();

// syscall.asm
PUBLIC int get_ticks();
PUBLIC void sys_call();

#endif
