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
// RPL
#define RPL_KRNL    SA_RPL0            
#define RPL_TASK    SA_RPL1                                    
#define RPL_USER    SA_RPL3 

 /* 8253/8254 PIT (Programmable Interval Timer) */                    
 #define TIMER0         0x40 /* I/O port for timer channel 0 */       
 #define TIMER_MODE     0x43 /* I/O port for timer mode control */    
 #define RATE_GENERATOR 0x34 /* 00-11-010-0 :                         
                              * Counter0 - LSB then MSB - rate generator - binary 
                              */                                                  
 #define TIMER_FREQ     1193182L/* clock frequency for timer in PC and AT */
 #define HZ             100  /* clock freq (software settable on IBM-PC) */

 /* AT keyboard */
 /* 8042 ports */
 #define KB_DATA     0x60    /* I/O port for keyboard data
                     Read : Read Output Buffer
                     Write: Write Input Buffer(8042 Data&8048 Command) */
#define KB_CMD       0x64    /* I/O port for keyboard command
                     Read : Read Status Register
                     Write: Write Input Buffer(8042 Command) */

/* VGA */                                                                                 
#define CRTC_ADDR_REG   0x3D4   /* CRT Controller Registers - Addr Register */            
#define CRTC_DATA_REG   0x3D5   /* CRT Controller Registers - Data Register */            
#define START_ADDR_H    0xC /* reg index of video mem start addr (MSB) */                 
#define START_ADDR_L    0xD /* reg index of video mem start addr (LSB) */                 
#define CURSOR_H    0xE /* reg index of cursor position (MSB) */                          
#define CURSOR_L    0xF /* reg index of cursor position (LSB) */                          
#define V_MEM_BASE  0xB8000 /* base of color video memory */                              
#define V_MEM_SIZE  0x8000  /* 32K: B8000H -> BFFFFH */ 

/* TTY */
#define NR_CONSOLE  3


/* Hardware interrupts */
#define NR_IRQ          16  /* Number of IRQs */                         
#define CLOCK_IRQ       0
#define KEYBOARD_IRQ    1
#define CASCADE_IRQ     2   /* cascade enable for 2nd AT controller */   
#define ETHER_IRQ       3   /* default ethernet interrupt vector */      
#define SECONDARY_IRQ   3   /* RS232 interrupt vector for port 2 */  
#define RS232_IRQ       4   /* RS232 interrupt vector for port 1 */      
#define XT_WINI_IRQ     5   /* xt winchester */
#define FLOPPY_IRQ      6   /* floppy disk */
#define PRINTER_IRQ     7
#define AT_WINI_IRQ     14  /* at winchester */  

/* system call */
#define NR_SYS_CALL     1

#define MAGIC_BP    asm("xchg %bx,%bx");

#endif
