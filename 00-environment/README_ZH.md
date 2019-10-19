*基础知识储备: linux, mac, terminal, compiler, emulator, nasm, qemu*
* 操作系统，运行环境，Linux，Mac
* terminal 终端，命令行，CLI
* compiler 编译器，
* emulator 模拟器
* qemu  qume是一个虚拟机软件
* nasm NASM全称The Netwide Assembler，是一款基于80x86和x86-64平台的汇编语言编译程序，其设计初衷是为了实现编译器程序跨平台和模块化的特性。

**目标: 安装必要软件**

本项目运行于mac，Linux更好些，它能提供标准工具集

Mac机[安装 Homebrew](http://brew.sh) 然后使用brew安装：`brew install qemu nasm`

如果你有xcode，不要使用xcode的工具集 `nasm` , 大多情况下他们不好使. 需要用brew安装的标准工具 `/usr/local/bin/nasm`

在某些系统上qemu是分割成多个二进制文件的，需要使用 `qemu-system-x86_64 binfile`

`which qemu`是没有的，因为是好多执行文件`which qemu-system-x86_64`
