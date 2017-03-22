#ifdef GLOBAL_VARIABLES_HERE
#undef EXTERN
#define EXTERN
#endif

EXTERN int 			disp_pos;
// 0~15: Limit      16~47: Base
EXTERN u8 			gdt_ptr[6];
EXTERN DESCRIPTOR	gdt[GDT_SIZE];
// 0~15: Limit      16~47: Base
EXTERN u8			idt_ptr[6];
EXTERN GATE			idt[IDT_SIZE];

EXTERN TSS          tss;
EXTERN PROCESS*     p_proc_ready;

// 避免中断重入
EXTERN u32          k_reenter;

// 时钟中断计数器
EXTERN int          ticks;

// 当前终端
EXTERN int          nr_current_console;

// 进程表
extern PROCESS      proc_table[];

// 任务栈
extern char         task_stack[];

extern TASK         task_table[];

extern TASK         user_proc_table[];

// 中断处理程序表
extern irq_handler irq_table[];     // global.c

// 终端表
extern TTY tty_table[];
extern CONSOLE console_table[];
