;磁盘头参数
    BS_OEMNAME          db  'bopzjy01'  ;厂商名（8 bytes）
    BPB_BytesPerSec     dw  0x200
    BPB_SecPerClus      db  0x1 
    BPB_RsvdSecCnt      dw  0x1         ;boot记录占用多少扇区
    BPB_NumFATs         db  0x2         ;FAT表有几个
    BPB_RootEntCnt      dw  0xe0        ;根目录最大文件数
    BPB_TotSec16        dw  0xb40       ;扇区总数
    BPB_Media           db  0xf0        ;介质描述符
    BPB_FATSz16         dw  0x9         ;每个fat扇区数
    BPB_SecPerTrk       dw  0x12        ;每磁道扇区数
    BPB_NumHeads        dw  0x2         ;磁头（面）数
    BPB_HiddSec         dd  0           ;隐藏的扇区数目
    BPB_TotSec32        dd  0           ;如果BPB_TotSec16=0,则此处记录总扇区数
    BS_DrvNum           db  0           ;中断13的驱动器号
    BS_Reserved1        db  1           ;未使用
    BS_BootSig          db  0x29        ;扩展引导标记（29h）
    BS_VolID            dw  0           ;卷序列号
    BS_VolLab           db  'bopzjy3.141'   ;卷标（11 bytes）
    BS_FileSysType      db  'FAT12   '  ;文件系统类型（8 bytes）

RootDirSectors      equ     14          ;根目录区占据的空间
SectorNoOfRootDir   equ     19          ;根目录区的第一个扇区号（2×9+`1）
SectorNoOfFAT1      equ     1                                                                                                                  
DeltaSectorNo       equ     31  
;RootDirSectors     equ     14

