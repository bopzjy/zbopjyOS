#include "type.h"
#include "const.h"
#include "protect.h"
#include "proto.h"
#include "string.h"
#include "proc.h"
#include "global.h"

PUBLIC void cstart(){
    //将loader中的GDT复制到新的GDT中
    memcpy( &gdt,                               //new GDT
            (void*)(*((u32*)(&gdt_ptr[2]))),    //base of old gdt
            *((u16*)(&gdt_ptr[0])) + 1           //limit of old gdt
            );
	// 初始化gdt_ptr
    u16* p_gdt_limit    = (u16*)(&gdt_ptr[0]);
    u32* p_gdt_base     = (u32*)(&gdt_ptr[2]);
    *p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR) - 1;
    *p_gdt_base  = (u32)&gdt;

	// 初始化idt_ptr
	u16* p_idt_limit = (u16*)(&idt_ptr[0]);
	u32* p_idt_base = (u32*)(&idt_ptr[2]);
	*p_idt_limit = IDT_SIZE * sizeof(GATE) - 1;
	*p_idt_base = (u32)&idt;

    init_prot();

    disp_str("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n-----test end-----\n");

}
