#include "const.h"
#include "type.h"
#include "protect.h"
#include "proto.h"
#include "proc.h"
#include "string.h"
#include "global.h"

hehedada

PUBLIC int kernel_main(){
    disp_str("--------\"kernel_main\" begins--------\n");

    int i = 0;
    u16 selector_ldt = SELECTOR_LDT_FIRST;
    PROCESS* p_proc = proc_table;
    TASK* p_task = task_table;
    char* off_stack = task_stack;

    for(i = 0; i<NR_TASKS; i++){
        off_stack += p_task->stacksize;

        p_proc->pid = i;
        strcpy(p_proc->p_name, p_task->name);
        p_proc->ldt_sel = selector_ldt;
        memcpy(&p_proc->ldts[0], &gdt[SELECTOR_KERNEL_CS>>3], sizeof(DESCRIPTOR));
        p_proc->ldts[0].attr1 = DA_C | PRIVILEGE_TASK << 5; // change the DPL
        memcpy(&p_proc->ldts[1], &gdt[SELECTOR_KERNEL_DS>>3], sizeof(DESCRIPTOR));
        p_proc->ldts[1].attr1 = DA_DRW | PRIVILEGE_TASK << 5;   // change the DPL
    
        p_proc->regs.cs = (0 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
        p_proc->regs.ds = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
        p_proc->regs.es = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
        p_proc->regs.fs = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
        p_proc->regs.ss = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
        p_proc->regs.gs = (SELECTOR_KERNEL_GS & SA_RPL_MASK) | RPL_TASK; 
        p_proc->regs.eip= (u32) p_task->initial_eip;
        p_proc->regs.esp= (u32) off_stack; 
        p_proc->regs.eflags = 0x1202;   // IF=1, IOPL=1, bit 2 is always 1.

        p_proc++;
        p_task++;
        selector_ldt += 8;
    }

    k_reenter = -1;

    p_proc_ready    = proc_table;
    //p_proc_ready    = &proc_table[1];
    restart();

    while(1);
}

void TestA(){
    int i = 0;
    while(1){
        disp_str("A");
        disp_int(i++);
        disp_str(".");
        delay(1);
    }
}

void TestB(){
    int i = 0x100;
    while(1){
        disp_str("B");
        disp_int(i++);
        disp_str(".");
        delay(1);
    }
}

void TestC(){
    int i = 0x2000;
    while(1){
        disp_str("C");
        disp_int(i++);
        disp_str(".");
        delay(1);
    }
}
