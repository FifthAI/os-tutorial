*您可能需要事先使用Google的概念：内核/kernel，ELF格式/ELF format, makefile*

**Goal: 创建一个简单的内核和一个能够引导它的引导程序**

> 这里我们主要区分二进制文件格式的问题
> 
> ELF - ELF64 ELF32 这是从系统角度看的*可执行文件*。通常用 *.o 的后缀来表示
>
> binary - 纯二进制文件，硬件可执行的的二进制机器码。通常用 *.bin 的后缀来表示
>
> 他们都是二进制，但是ELF机器不能直接执行、ELF中包含某种纯粹的机器码，
> 

本章的目的就是用：
1. 汇编程序、c程序编译成ELF；
2. ELF文件拼接抽提成纯粹二进制；
3. 再将纯粹二进制拼接的过程

The kernel
----------
> 要点，用gcc生成ELF32格式的二进制、nasm也是要生成ELF32

我们的C内核只会在屏幕的左上角打印一个“ X”。 继续并打开`kernel.c`。

您会发现一个不执行任何操作的伪函数。 该函数将为我们创建一个内核进入点，
该程序不指向内核中的字节0x0，而是指向一个内存位置的标签，我们知道它会启动被执行。 
在我们的例子中就是函数`main（）`。
```bash
# 使用原文自编译的gcc
i386-elf-gcc -ffreestanding -c kernel.c -o kernel.o
# Mac上
# 直接编译生成的是 ELF64 格式的
x86_64-elf-gcc -ffreestanding -c kernel.c -o kernel.o
# 这个是我们需要的ELF32格式
x86_64-elf-gcc -m32 -ffreestanding -c kernel.c -o kernel.o

# 查看结果
x86_64-elf-readelf -h kernel.o
```

该程序代码在`kernel_entry.asm`上。 阅读它，您将学习如何在汇编中使用`[extern]`声明。 
为了编译该文件，我们将生成一个`elf`格式的文件，而不是生成二进制文件，该文件将与`kernel.o`链接。

```bash
nasm kernel_entry.asm -f elf -o kernel_entry.o
# 查看结果
x86_64-elf-readelf -h kernel_entry.o
```

链接器 / The linker
----------
链接器是一个非常强大的工具，我们才开始从中受益。

要将两个目标文件链接到单个二进制内核并解析标签引用，请运行：

```bash
# 原文
i386-elf-ld -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary
# Mac上
# 因为是32的格式、所以需要 -m elf_i386 参数；输出ELF32的纯二进制
x86_64-elf-ld -m elf_i386 -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary
```

注意，我们的内核将不会放置在内存中的`0x0`上，而是会放置在 `0x1000`上。 引导程序也需要知道此地址。

启动扇区 / The bootsector
--------------
这与第10课中的非常相似。打开`bootsect.asm`并检查代码。 

实际上，如果删除屏幕上用于打印消息的所有行，也就几十行有效代码。

编译: `nasm bootsect.asm -f bin -o bootsect.bin`


Putting it all together
-----------------------
怎么办？ 我们有两个分别用于引导程序和内核的文件？

我们不能只是将它们“链接”到一个文件中吗？ 是的，我们可以并且很容易地将它们串联起来：

`cat bootsect.bin kernel.bin > os-image.bin`

> 到此总结以下。bootsect的汇编代码编译成机器码二进制。占据 512 bytes、占据了一个扇区，用于基本的程序引导。
其中有一点比较重要。bootsect的程序最终会跳转到内存的0x1000位置去执行程序。
而kernel.bin的汇编部分是去找Main标记，c程序提供了main的标记。所以用ld链接程序时，他们就合为一体，产生了机器码二进制文件。
~~并且在ld的链接过程中使用-Ttext 0x1000参数，将代码段加载到0x1000位置~~。

Run!
----
* qemu运行 `os-image.bin`.
* 如果磁盘查找错误,需要增加点qemu参数啥的,比如磁盘号 (floppy = `0x0`, hdd = `0x80`), 我通常使用`qemu-system-i386 -fda os-image.bin`

你将能看到如下打印:

- "Started in 16-bit Real Mode"
- "Loading kernel into memory"
- (Top left) "Landed in 32-bit Protected Mode"
- (Top left, overwriting previous message) "X"

Congratulations!


Makefile
--------

最后一步，我们将使用Makefile整理编译过程。 打开`Makefile`脚本并检查其内容。 

如果您不知道Makefile是什么，那么现在是Google学习的好时机，因为这会节省很多时间。


为什么是 0x1000 ？？？
------------------------

我是不能理解原文中的ld -Ttext 0x1000这里的。机器码二进制是如何确定自己的位置的？所以我做了以下观察。
```bash
# 链接0x00、0x2000的位置，用于二进制反汇编比较
x86_64-elf-ld -m elf_i386 -o kernel0.bin kernel_entry.o kernel.o --oformat binary
x86_64-elf-ld -m elf_i386 -o kernel2000.bin -Ttext 0x2000 kernel_entry.o kernel.o --oformat binary
x86_64-elf-ld -m elf_i386 -o kernel1001.bin -Ttext 0x1001 kernel_entry.o kernel.o --oformat binary

# 反汇编查询机器码
x86_64-elf-objdump -D -Mintel,i386 -b binary -m i386 -s -d kernel.bin
x86_64-elf-objdump -D -Mintel,i386 -b binary -m i386 -s -d kernel0.bin
x86_64-elf-objdump -D -Mintel,i386 -b binary -m i386 -s -d kernel2000.bin
x86_64-elf-objdump -D -Mintel,i386 -b binary -m i386 -s -d kernel1001.bin

# objdump使用例子
# objdump -D -Mintel,i8086 -b binary -m i386 mbr.bin
# objdump -D -Mintel,i386 -b binary -m i386 foo.bin    # for 32-bit code
# objdump -D -Mintel,x86-64 -b binary -m i386 foo.bin  # for 64-bit code
```
起始我只比较了0、1000、2000的机器码，然而并没有什么不同。着实费解。然后又通过md5比较查看了文件本身。
```bash
# 装软件
brew install md5sha1sum
# 查看文件md5
ls *.bin | xargs md5sum
```
发现这3个文件完全一致。是偏移无效么？我又比较了1001的文件，这次文件的md5不一样了。

仔细观察kernel1001.bin的机器码结果。会发现只是多了程序计数器+1的汇编代码。

经过一番研究，
1. 真正决定程序执行位置的，还是启动扇区的bootsect.bin
    * bootsect.bin将磁盘上的机器码二进制加载到1000这个位置的内存、并且调用了1000这个位置的内存。
2. 机器码二进制并不能指明自己所在的内存。
    * 整数倍的偏移其实无意义；根据1001产生的效果。我猜测。因为每16位后，就是一个新的循环
    * kernel1001.bin其实也能实现本章效果；
        * 根据kernel1001.bin的反汇编，只是增加了程序计数器。
        * 同时增加的位置同样是目标程序所在
```bash
# 测试
cat bootsect.bin kernel1001.bin > os-image1001.bin

qemu-system-i386 -fda os-image1001.bin
# 结果与基本课程一致。
```

