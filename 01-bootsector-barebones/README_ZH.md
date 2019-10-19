*基础知识储备: assembler, BIOS*
* Assembler 汇编语言是面向机器的程序设计语言
* BIOS是英文"Basic Input Output System"的缩略词，直译过来后中文名称就是"基本输入输出系统"。
**Goal: 创建一个BIOS可识别的文件，作为启动盘**

我们就好制作一个属于自己的启动扇区了，想想就让人兴奋

理论基础
------

当电脑开机的时候，BIOS不知道怎么加载系统，所以它把这任务交给磁盘的启动扇区。启动扇区需要设定在一个标准，通用的位置。这个位置是磁盘的第一扇区[(cylinder 0, head 0, sector 0),0柱，0磁头，0扇区]，其大小为512 bytes.

> 磁盘
>
> 欠 磁盘知识、图
> 
> △磁头(Heads)：每张磁片的正反两面各有一个磁头，一个磁头对应一张磁片的一个面。因此，用第几磁头就可以表示数据在哪个磁面。
>
> △柱面(Cylinder)：所有磁片中半径相同的同心磁道构成“柱面"，意思是这一系列的磁道垂直叠在一起，就形成一个柱面的形状。简单地理解，柱面数=磁道数。
>
> △扇区(Sector)：将磁道划分为若干个小的区段，就是扇区。虽然很小，但实际是一个扇子的形状，故称为扇区。每个扇区的容量为512字节。


> bytes 
>
> 欠 大B，小b知识

为了确保这是一个启动盘，BIOS检查启动扇区的511 512位的bytes是否为 `0xAA55`.

这是一个极简的启动扇区:

```
e9 fd ff 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[ 29 more lines with sixteen zero-bytes each ]
00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 aa
```

It is basically all zeros, ending with the 16-bit value
`0xAA55` (beware of endianness, x86 is little-endian). 
The first three bytes perform an infinite jump

Simplest boot sector ever
-------------------------

You can either write the above 512 bytes
with a binary editor, or just write a very
simple assembler code:

```nasm
; Infinite loop (e9 fd ff)
loop:
    jmp loop 

; Fill with 510 zeros minus the size of the previous code
times 510-($-$$) db 0
; Magic number
dw 0xaa55 
```

To compile:
`nasm -f bin boot_sect_simple.asm -o boot_sect_simple.bin`

> OSX warning: if this drops an error, read chapter 00 again

I know you're anxious to try it out (I am!), so let's do it:

`qemu boot_sect_simple.bin`

> On some systems, you may have to run `qemu-system-x86_64 boot_sect_simple.bin` If this gives an SDL error, try passing the --nographic and/or --curses flag(s).

You will see a window open which says "Booting from Hard Disk..." and
nothing else. When was the last time you were so excited to see an infinite
loop? ;-)
