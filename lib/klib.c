#include "const.h"
#include "type.h"
#include "proto.h"
PUBLIC char * itoa(char * str, int num){
    char *p = str;
    int flag = 0;
    int i;
    *p++ = '0';
    *p++ = 'x';
    for(i = 28;i>=0;i-=4){
        char t = (num >> i) & 0xf;
        if(flag || t>0){
            flag = 1;
            if(t>9)
                t += 'A' - 10;
            else
                t += '0';
            *p++ = t;
        }
    }
    *p = '\0';
    return str;
}

PUBLIC void disp_int(int num){
    char str[16];
    itoa(str,num);
    disp_str(str);
}
