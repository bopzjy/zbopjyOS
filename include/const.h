#ifndef _OS_CONST_H_
#define _OS_CONST_H_

#define PUBLIC
#define PRIVATE static

// EXTERN is defined as extern except in global.c
#define EXTERN extern

// GDT和IDT中的描述符个数
#define GDT_SIZE        128
#define IDT_SIZE		256

// 8259A interrupt controller ports.
#define INT_M_CTL       0x20
#define INT_M_CTLMASK   0x21
#define INT_S_CTL       0xA0
#define INT_S_CTLMASK   0xA1

// privilege
#define PRIVILEGE_KRNL  0
#define PRIVILEGE_TASK  1
#define PRIVILEGE_USER  3

#endif
