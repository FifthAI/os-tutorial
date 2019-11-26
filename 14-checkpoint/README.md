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
# 云编译的环境，linux下不能直接make debug；需要把编译后的文件拿回来。
```

Check out the Makefile target `make debug`. This target uses builds `kernel.elf`, which
is an object file (not binary) with all the symbols we generated on the kernel, thanks to
the `-g` flag on gcc. Please examine it with `xxd` and you'll see some strings. Actually,
the correct way to examine the strings in an object file is by `strings kernel.elf`

We can take advantage of this cool qemu feature. Type `make debug` and, on the gdb shell:

- Set up a breakpoint in `kernel.c:main()`: `b main`
- Run the OS: `continue`
- Run two steps into the code: `next` then `next`. You will see that we are just about to set
  the 'X' on the screen, but it isn't there yet (check out the qemu screen)
- Let's see what's in the video memory: `print *video_memory`. There is the 'L' from "Landed in
  32-bit Protected Mode"
- Hmmm, let's make sure that `video_memory` points to the correct address: `print video_memory`
- `next` to put there our 'X'
- Let's make sure: `print *video_memory` and look at the qemu screen. It's definitely there.

Now is a good time to read some tutorial on `gdb` and learn super useful things like `info registers`
which will save us a lot of time in the future!


You may notice that, since this is a tutorial, we haven't yet discussed which kind
of kernel we will write. It will probably be a monolithic one since they are easier
to design and implement, and after all this is our first OS. Maybe in the future
we'll add a lesson "15-b" with a microkernel design. Who knows.
