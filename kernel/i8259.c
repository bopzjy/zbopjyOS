#include "const.h"
#include "type.h"
#include "protect.h"
#include "proto.h"

PUBLIC void init_8259A(){
    //master 8259,ICW1.
    out_byte(INT_M_CTL, 0x11);

    //slave 8259,ICW1.
    out_byte(INT_S_CTL, 0x11);

    //master 8259,ICW2. 设置'主8259'的中断入口地址0x20
    out_byte(INT_M_CTLMASK, INT_VECTOR_IRQ0);

    //master 8259,ICW2. 设置'从8259'的中断入口地址0x28
    out_byte(INT_S_CTLMASK, INT_VECTOR_IRQ8);

    out_byte(INT_M_CTLMASK, 0x4);

    out_byte(INT_S_CTLMASK, 0x2);
    
    out_byte(INT_M_CTLMASK, 0x1);

    out_byte(INT_S_CTLMASK, 0x1);

    out_byte(INT_M_CTLMASK, 0xFE);

    out_byte(INT_S_CTLMASK, 0xFF);
}

PUBLIC void spurious_irq(int irq){
    disp_str("spurious_irq: ");
    disp_int(irq);
    disp_str("\n");
}
