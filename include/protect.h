#ifndef _OS_PROTECT_H_
#define _OS_PROTECT_H_

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
#define INT_VECTOR_IRQ0     0x20
#define INT_VECTOR_IRQ8     0x28

#endif

