*您可能需要事先使用Google的概念： 宏内核/monolithic kernel, 微内核/microkernel, 调试器/debugger, gdb*

**Goal: 暂停进度并整理我们的代码。 然后学习如何使用gdb调试内核**

也许您没有意识到，但是您已经在运行自己的内核！

但是，它的作用很小，只打印一个“X”。 现在是时候停下来，将代码组织到文件夹中，为将来的代码创建可伸缩的Makefile，并考虑策略。

此外，由于从现在开始，我们将主要使用C语言进行编码，因此我们将利用qemu打开与gdb的连接的功能。

首先，由于OSX使用与ELF文件格式不兼容的`lldb`，因此我们安装了交叉编译的`gdb`（Homebrew仓库中没有`gdb`）。

```sh
# linux 下需要安装 
apt-get install texinfo -y

# 编译交叉工具gdb
cd /tmp/src
curl -O http://ftp.rediris.es/mirror/GNU/gdb/gdb-7.8.tar.gz
tar xf gdb-7.8.tar.gz
mkdir gdb-build
cd gdb-build
export PREFIX="/usr/local/i386elfgcc"
export TARGET=i386-elf
../gdb-7.8/configure --target="$TARGET" --prefix="$PREFIX" --program-prefix=i386-elf-
make
make install
```

查看Makefile中的`make debug`。 这个命令build `kernel.elf`，这是一个目标文件（不是二进制文件），
其中包含我们在内核上生成的所有标记，这要感谢gcc上的-g参数。 
用xxd检查它，您将看到一些字符串。 实际上，检查目标文件中字符串的正确方法是使用`strings kernel.elf`。

```bash
# 因为安装的x86_64-elf版程序，根据自身需求更改Makefile。
# 没找到x86_64-elf的gdb、安装的i386-elf-gdb
brew install i386-elf-gdb
```
我们可以利用qemu中很酷的功能。使用`make debug`。进入*gdb shell*：

> 原项目这里有坑, 没有写-S，大写S参数；qemu会直接执行，没法调试
```bash
# -S 表示guest虚拟机一启动就会暂停
# -s 表示监听tcp:1234端口等待GDB的连接
debug: os-image.bin kernel.elf
	qemu-system-i386 -s -S -fda os-image.bin &
	${GDB} -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"
```

- 给kernel.c加断点 `kernel.c:main()`: `b main`
- 启动系统: `continue`
- 继续进行调试: `next` 然后 `next`. 然后会看到在屏幕上输出“X”，但尚不存在（请查看qemu屏幕）
- 到此，我们先来查看“显存”中的内容：`print *video_memory`。 “在32位保护模式下”现存这个位置是“L”
- 嗯……，我们再确认下 `video_memory` 的指针地址: `print video_memory`
- 再次输入`next` 将该部分内存变为'X'
- 让我们来确定: `print *video_memory` 并且查看 qemu 的屏幕. X就显示在哪里

现在是阅读有关gdb的一些教程并学习超级有用的信息（如`info registers` 信息寄存器）的好时机，这将为我们节省很多时间！

你或许发现了，到本教程为止，我们还没讨论我们要实现那种类型的内核。它或许是个单调而简单的系统。

或许将来我们增加有关微内核的设计。
