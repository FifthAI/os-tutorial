*先要Google以下学习的知识点: I/O ports（输入输出端口）*

**目标:了解如何使用VGA卡数据端口**

> 本章Makefile脚本貌似跟14章一致。copy过来就行

我们将使用C语言通过I/O寄存器和端口与设备进行通信。

打开`drivers/ports.c`并检查内联C汇编器语法。 它有一些区别，

例如源和目标操作数的顺序，以及将变量分配给操作数的有趣语法。

了解概念后，打开`kernel/kernel.c`研究示例。

在此示例中，我们将检查映射屏幕光标位置的I/O端口。 

具体来说，我们将使用值`14`来查询端口`0x3d4`以请求光标位置的高字节，而将其与`15`相同的端口请求低字节。

查询此端口时，会将结果保存在端口`0x3d5`中

在没有将他们输出到屏幕，不要忘记用 `gdb` 查看一下C的变量，为此，设置一个断点在`breakpoint kernel.c:21`行，并且用 `print` 命令来检查变量. 现在我们的gdb变派上了用场

最后，我们将使用查询的光标位置在该位置写入字符。

VGA 字符模式 与 0x3d4、0x3d5是什么
------------

根据开头提示，我们应该学习一下输入输出接口；IO包括0～65535个端口

其中0x03B0-0x03DF范围用于IBM VGA，它在传统模式下，现代的显卡都适用。

文章在下。我没有看。大约就是能直接操作端口输出的意思。

[I/O Ports](https://wiki.osdev.org/I/O_Ports)

[VGA_Hardware](https://wiki.osdev.org/VGA_Hardware)

1. VGA有字符模式。25*80,显存位置0xb8000
2. 0x3d4   // vga index register port
3. 0x3d5   // vga data register port

```c
#define VGA_CRT_IC  0x3d4   // vga index register port
#define VGA_CRT_DC  0x3d5   // vga data register port
struct vga_char *vga_mem;       /* vga[25][80] at 0xb8000 */
struct vga_char color;          /* use vag_char structure to store color */
```