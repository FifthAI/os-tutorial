*您可能需要事先使用Google的概念：内核/kernel，ELF格式/ELF format, makefile*

**Goal: 创建一个简单的内核和一个能够引导它的引导程序**

The kernel
----------

我们的C内核只会在屏幕的左上角打印一个“ X”。 继续并打开`kernel.c`。

您会发现一个不执行任何操作的伪函数。 该函数将为我们创建一个内核进入点，
该程序不指向内核中的字节0x0，而是指向一个内存位置的标签，我们知道它会启动被执行。 
在我们的例子中就是函数`main（）`。

`i386-elf-gcc -ffreestanding -c kernel.c -o kernel.o`

该程序代码在`kernel_entry.asm`上。 阅读它，您将学习如何在汇编中使用`[extern]`声明。 
为了编译该文件，我们将生成一个`elf`格式的文件，而不是生成二进制文件，该文件将与`kernel.o`链接。

`nasm kernel_entry.asm -f elf -o kernel_entry.o`


链接器 / The linker
----------
链接器是一个非常强大的工具，我们才开始从中受益。

要将两个目标文件链接到单个二进制内核并解析标签引用，请运行：

`i386-elf-ld -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary`

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

