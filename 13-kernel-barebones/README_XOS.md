**需要python3 + pip3 install lief 来修改macho文件**

原项目使用GNU 的gcc编译ELF格式，MacOS 10.15后占用了gcc，也就没法搞ELF。

原项目汇编部分是CPU的16位模式切32位模式启动Bios。这里我整体切换到 Mach-O 格式。尝试编译

> **放弃**。不瞎折腾。3.4的位置上，修改内存加载位置0x1000十分费劲
>
> Mach-O理论上可以生成机器可执行二进制文件。包括lief工具在内，很多方法是可以修改的。
>
> 1. 但因Mach-O的数据结构代码段__Text与其他符号表的位置都是相对的。整合纯二进制比较费劲。还需计算偏移等等
>
> 2. gcc 生成还有可能是 i386-long 格式。不是i386-generic，（就是汇编指令有可能是变长的）
>
> 如果非得死磕。
>
> [lief docs - 11 - Mach-O Modification](https://lief.quarkslab.com/doc/latest/tutorials/11_macho_modification.html) 可以查看lief修改方法与细节
>
> [./基于bochs的分时多任务调度器.pdf](基于bochs的分时多任务调度器.pdf) 18 - 19 页是理论基础。
>
> [Makefile](https://github.com/liuyang-kevin/os/blob/master/os2load/Makefile) cc命令附近，可以生成

1. ~~gcc -ffreestanding -c kernel.c -o kernel.o~~
    * file kernel.o 查看后，发现生成的文件为 kernel.o: Mach-O 64-bit object x86_64
    * gcc -ffreestanding -c -arch i386 kernel.c -o kernel.o
    * 再次查看，是386架构
2. nasm kernel_entry.asm -f macho -o kernel_entry.o
    * 原文这里编译的是 -f elf格式

> 再处理bug时发现。mac上编译有 macho macho64 格式
>
> nasm bootsect.asm -f macho -o bootsect.bin
> nasm bootsect.asm -f macho64 -o bootsect.bin
> 
> 它与ELF不同。-f elf 与 -f bin 是另一套格式

3. Mac上的Mach-O格式与ELF格式不同，也没有相应的直接链接方式。这里比较复杂
    1. 原文这里是 elf 版 ld 链接文件
        * ~~ld -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary~~
    2. 替换为 ld kernel_entry.o kernel.o -o kernel.bin -r -U start
        * The -r asks ld to just combine object files together without making a library,
        * -U tells ld to ignore the missing definition of _start (which would normally be provided by the C stdlib).
        * -r 让ld只是链接2个文件，不生成lib库
        * -U 让ld忽略_start标记定义
    3. otool -l kernel.bin 查看 __text段的输出
        1. otool -v -t  kernel.bin
        2. 因为苹果的ld只能link自己的macho格式，所以生成的文件是带符号表的
        ``` text
        Section
        sectname __text
        segname __TEXT
            addr 0x00000000
            size 0x00000037
            offset 256
            align 2^4 (16)
            reloff 312
            nreloc 1
            flags 0x80000400
        reserved1 0
        reserved2 0
        ```
        3. 使用复制2进制的方式，将offset偏移的大小复制到新文件 
            1. dd if=kernel.bin of=kernel_stripped.bin ibs=256 skip=1
            2. https://zh.wikipedia.org/wiki/Dd_(Unix)
        4. 现在还有一个问题，elf下的`-Ttext 0x1000`内存加载位置，怎么在kernel_stripped.bin修改。
        5. -segaddr name address
        6. ld kernel_entry.o kernel.o -o kernel1.bin -r -U start -segaddr __TEXT 1000
    


4. nasm bootsect.asm -f bin -o bootsect.bin
5. cat bootsect.bin kernel.bin > os-image.bin





