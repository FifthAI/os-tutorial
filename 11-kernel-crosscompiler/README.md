*Concepts you may want to Google beforehand: 交叉编译器 / cross-compiler*

**Goal: 创建一个开发环境来构建您的内核**


> 实际情况
> 
> * Mac XOS 10.15 gcc 装不上 v4.9 - v9 `brew install`都装不上，有bug，而且Xcode占了gcc的名字
>   * Mac不能进行了，需要Linux才能方便编译与构建 系统自带的`clang gcc` 不能编译 `交叉编译的gcc`
> * Windows 也不好弄,需要MingW64下一套gcc,而且binutils也编译失败,但是方案可行,可以走通懒得折腾
>
> 解决方案
>
> * 云系统编译,将可执行二进制移动回本地，使用qemu启动，涉及GUI.

If you're using a Mac, you will need to do this process right away. Otherwise, it could have waited
for a few more lessons. Anyway, you will need a cross-compiler once we jump to developing in a higher
language, that is, C. [Read why](http://wiki.osdev.org/Why_do_I_need_a_Cross_Compiler%3F)

I'll be adapting the instructions [at the OSDev wiki](http://wiki.osdev.org/GCC_Cross-Compiler). 


所需的包 / Required packages
-----------------

首先，安装所需的软件包。 
* 在Linux上，使用您的程序包分发。 
* 在Mac上，如果您在第00课上没有做过，请[安装brew]（http://brew.sh/），然后通过“ brew install”获取这些软件包。

- gmp / GNU multiple precision arithmetic library / GNU多精度算术库
- mpfr 
    - GNU MPFR (GNU Multiple Precision Floating-Point Reliably) 
    - GNU MPFR（可靠地GNU多精度浮点）
- libmpc
    - C library for the arithmetic of high precision complex numbers
    - C库，用于高精度复数运算
- gcc

是的，我们将需要`gcc`来构建交叉编译的`gcc`，尤其是在Mac上，其中不建议使用`clang`的gcc

安装完成后，找到打包的gcc所在的位置（请记住，不是clang）并导出。 例如：

```
export CC=/usr/local/bin/gcc-4.9
export LD=/usr/local/bin/gcc-4.9
```

我们将需要构建binutils和交叉编译的gcc，并将它们放入`/usr/local/i386elfgcc`中，所以现在让我们导出一些路径。 随时根据自己的喜好更改它们。

```
export PREFIX="/usr/local/i386elfgcc"
export TARGET=i386-elf
export PATH="$PREFIX/bin:$PATH"
```

binutils
--------
GNU Binary Utilities或binutils是一整套的编程语言工具程序，用来处理许多格式的目标文件。

Remember: always be careful before pasting walls of text from the internet. I recommend copying line by line.

```sh
mkdir /tmp/src
cd /tmp/src
curl -O http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz # If the link 404's, look for a more recent version
tar xf binutils-2.24.tar.gz
mkdir binutils-build
cd binutils-build
../binutils-2.24/configure --target=$TARGET --enable-interwork --enable-multilib --disable-nls --disable-werror --prefix=$PREFIX 2>&1 | tee configure.log
make all install 2>&1 | tee make.log
```

gcc
---
```sh
cd /tmp/src
curl -O https://ftp.gnu.org/gnu/gcc/gcc-4.9.1/gcc-4.9.1.tar.bz2
tar xf gcc-4.9.1.tar.bz2
mkdir gcc-build
cd gcc-build
../gcc-4.9.1/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --disable-libssp --enable-languages=c --without-headers
make all-gcc 
make all-target-libgcc 
make install-gcc 
make install-target-libgcc 
```

就这些！ 您应该将所有GNU binutils和编译器放在`/usr/local/i386elfgcc/bin`中，并以i386-elf-作为前缀，以避免与系统的编译器和binutils冲突。

您可能想将`$PATH`添加到您的`.bashrc`中。 从现在开始，在本教程中，我们将在使用交叉编译的gcc时显式使用前缀。
