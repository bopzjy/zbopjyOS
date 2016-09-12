BaseOfLoader            equ     09000h
OffsetOfLoader          equ     0100h
BaseOfLoaderPhyAddr     equ     BaseOfLoader * 10h

BaseOfKernelFile        equ     0800h
OffsetOfKernelFile      equ     0h
BaseOfKernelFilePhyAddr equ     BaseOfKernelFile * 10h

KernelEntryPointPhyAddr equ     30400h

PageDirBase        equ     0200000H    ;   页目录开始地址: 2M
PageTblBase        equ     0201000H    ;   页表开始地址：  2M + 4K
