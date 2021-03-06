*新版MacOS 因为gcc被系统占据了，原文章再10.15上不能运行，Mac系统移步[xos版](./README_XOS.md)*

*您可能需要事先使用Google的概念: C，目标代码，链接器，反汇编 / C, object code, linker, disassemble*

**Goal: 学习编写与汇编程序相同的低级代码，但用C**

> 我已经打印log结果到[bak文件夹下](./bak)，并写了脚本[print_file.sh](./print_file.sh)

Compile
-------

让我们看看C编译器如何编译我们的代码，并将其与由汇编器生成的机器代码进行比较。

我们将开始编写一个包含函数`function.c`的简单程序。 打开文件并检查它。

要编译与*系统无关*的代码，我们需要标记`-ffreestanding`，因此以这种方式编译`function.c`：

`i386-elf-gcc -ffreestanding -c function.c -o function.o`

让我们检查一下由编译器生成的机器代码：

`i386-elf-objdump -d function.o`

现在，是我们认识的东西，不是吗？
```text
function.o:     file format elf32-i386


Disassembly of section .text:

00000000 <my_function>:
   0:   55                      push   %ebp
   1:   89 e5                   mov    %esp,%ebp
   3:   b8 ba ba 00 00          mov    $0xbaba,%eax
   8:   5d                      pop    %ebp
   9:   c3                      ret    
```
> 我使用Mac下 gcc objdump 测试
```text
fd@fifthdimensiondeMacBook-Pro 12-kernel-c % objdump -d function.o 

function.o:     file format Mach-O 64-bit x86-64

Disassembly of section __TEXT,__text:
_my_function:
       0:       55              pushq   %rbp
       1:       48 89 e5        movq    %rsp, %rbp
       4:       b8 ba ba 00 00  movl    $47802, %eax
       9:       5d              popq    %rbp
       a:       c3              retq
```

Link
----

最后，要生成一个二进制文件，我们将使用链接器。 此步骤的重要部分是学习高级语言如何调用函数标签。 我们的函数将在内存中的偏移量是多少？ 我们实际上不知道。 在此示例中，我们将偏移量放置在`0x0`处，并使用`binary`“二进制”格式，该格式生成没有任何标签和/或元数据的机器代码

`i386-elf-ld -o function.bin -Ttext 0x0 --oformat binary function.o`

*注意：链接时可能会出现警告，请忽略它*
```text
root@iZ8vbarsyb2qlmewr4m3dhZ:~/os/os-tutorial/12-kernel-c# i386-elf-ld -o function.bin -Ttext 0x0 --oformat binary function.o
i386-elf-ld: warning: cannot find entry symbol _start; defaulting to 0000000000000000
```
现在，使用`xxd`检查两个“二进制”文件，即`function.o`和`function.bin`。 

> xxd - 二进制查看加反编译工具/make a hexdump or do the reverse.

你会看到`.bin`文件是机器代码，而`.o`文件具有很多调试信息，标签等。

> 其中 `--oformat=binary` 告诉ld生成二进制文件
>  --oformat TARGET            Specify target of output file
>  -Ttext ADDRESS              Set address of .text section


Decompile
---------
出于好奇，我们将检查机器代码。

`ndisasm -b 32 function.bin`

> ndisasm 是 nasm一起安装，Debain上，apt-get install nasm -y

More
----
我鼓励您编写更多的小型程序，这些程序具有以下特点：

I encourage you to write more small programs, which feature:

- 局部变量 Local variables `localvars.c`
- 函数调用 Function calls `functioncalls.c`
- 指针 Pointers `pointers.c`

然后编译并反汇编它们，并检查生成的机器代码。 请按照os-guide.pdf进行说明。 尝试回答这个问题：为什么`pointers.c`的反汇编与您期望的不一样？ “Hello”的ASCII`0x48656c6c6f`在哪里？

```bash
i386-elf-gcc -ffreestanding -c function.c -o function.o
i386-elf-objdump -d function.o
i386-elf-ld -o function.bin -Ttext 0x0 --oformat binary function.o
xxd function.o 
xxd function.bin
ndisasm -b 32 function.bin
```