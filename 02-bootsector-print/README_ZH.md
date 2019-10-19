*基础知识储备: 中断, CPU寄存器*

**Goal: 让我们之前的启动盘打点字儿**

我们将要改进一下无限循环的启动程序，让它打印点字符到屏幕上（控制台）。我们将为此抛出一个中断

本例会逐字将"Hello"这个单词写入寄存器 `al` (`ax`的低位), 

将 `0x0e`写入 `ah` (`ax`高位) 并且抛出一个 `0x10` 常用视频调用中断.

`0x0e` 在 `ah` 中告诉视频中断，程序要 '将 `al` 中的内容写入到 tty'.

> TTY设备包括虚拟控制台，串口以及伪终端设备。 TTY是TeleTYpe的一个老缩写。 Teletypes，或者teletypewriters，原来指的是电传打字机，是通过串行线用打印机键盘通过阅读和发送信息的东西，和古老的电报机区别并不是很大。

真实的情况下，我们需要设置一次tty模式.因为不能确定 `ah` 是稳定常驻的，其他进程会在我们休眠时执行，不能确定`ah`中是否正确擦除或者留下垃圾数据.

对于本例无需担心这些，这个程序是唯一运行的程序。

Our new boot sector looks like this:
```nasm
mov ah, 0x0e ; tty mode
mov al, 'H'
int 0x10
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
int 0x10 ; 'l' is still on al, remember?
mov al, 'o'
int 0x10

jmp $ ; jump to current address = infinite loop

; padding and magic number
times 510 - ($-$$) db 0
dw 0xaa55 
```

可以用xxd查看二进制数据 `xxd file.bin`
> xxd 命令用于用二进制或十六进制显示文件的内容，如果没有指定outfile参数，则把结果显示在屏幕上，如果指定了outfile则把结果输出到 outfile中；如果infile参数为 – 或则没有指定infile参数，则默认从标准输入读入。

编译 `nasm -fbin boot_sect_hello.asm -o boot_sect_hello.bin`

运行 `qemu-system-x86_64 boot_sect_hello.bin --nographic`

打印出Hello后，进入循环
