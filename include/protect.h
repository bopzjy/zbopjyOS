#ifndef _OS_PROTECT_H_
#define _OS_PROTECT_H_

// GDT
// Selector
#define SELECTOR_FLAT_C     0x08
#define SELECTOR_FLAT_RW    0x10
#define SELECTOR_VIDEO      0x18 + 0x03     //RPL<---3

#define SELECTOR_KERNEL_CS  SELECTOR_FLAT_C
#define SELECTOR_KERNEL_DS  SELECTOR_FLAT_RW



typedef struct s_descriptor{
    u16 limit_low;
    u16 base_low;
    u8  base_mid;
    u8  attr1;
    u8  limit_high_attr2;       // P(1) DPL(2) DT(1) TYPE(4)
    u8  base_high;              // G(1) D(1) 0(1) AVL(1) LimitHigh(4)
}DESCRIPTOR;

typedef struct s_gate{
	u16 offset_low;
	u16 selector;
	u8	dcount;		/* 只在调用门描述符中有效。*/
	u8	attr;
	u16 offset_high;
}GATE;

// 中断向量
#define INT_VECTOR_DIVIDE           0x0                                      
#define INT_VECTOR_DEBUG            0x1                                      
#define INT_VECTOR_NMI              0x2                                      
#define INT_VECTOR_BREAKPOINT       0x3                                  
#define INT_VECTOR_OVERFLOW         0x4                                      
#define INT_VECTOR_BOUNDS           0x5                                      
#define INT_VECTOR_INVAL_OP         0x6                                      
#define INT_VECTOR_COPROC_NOT       0x7                                  
#define INT_VECTOR_DOUBLE_FAULT     0x8                                  
#define INT_VECTOR_COPROC_SEG       0x9                                  
#define INT_VECTOR_INVAL_TSS        0xA                                  
#define INT_VECTOR_SEG_NOT          0xB                                      
#define INT_VECTOR_STACK_FAULT      0xC                                  
#define INT_VECTOR_PROTECTION       0xD                                  
#define INT_VECTOR_PAGE_FAULT       0xE                                  
#define INT_VECTOR_COPROC_ERR       0x10 

// 中断向量 
#define INT_VECTOR_IRQ0             0x20
#define INT_VECTOR_IRQ8             0x28

// 段描述符类型值
#define DA_LDT          0x82
#define DA_TaskGate     0x85
#define DA_386TSS       0x89        // 386 任务状态段
#define DA_386CGate     0x8C        // 386 调用门
#define DA_386IGate     0x8E        // 386 中断门
#define DA_386TGate     0x8F        // 386 陷阱门

#endif

