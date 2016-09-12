#ifndef _OS_PROTO_H_
#define _OS_PROTO_H_

// kliba.asm
PUBLIC void out_byte(u16 port, u8 value);
PUBLIC u8 in_byte(u16 port);
PUBLIC void disp_str(char* info);
PUBLIC void init8259A();
PUBLIC void disp_color_str(char * info, int color);

//klib.c
//PUBLIC void disp_int(int num);
#endif
