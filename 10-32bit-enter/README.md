*Concepts you may want to Google beforehand: 中断/interrupts, 流水线pipelining*

**Goal: 进入32位保护模式并测试以前课程中的代码**

要跳到32位模式：

1. 禁用中断
2. 加载我们的GDT
3. 在CPU控制寄存器“ cr0”上设置一个位
4. 通过发出精心制作的远跳来刷新CPU管道
5. 更新所有段寄存器
6. 更新堆栈
7. 调用一个众所周知的标签，其中包含第32位的第一个有用代码

我们将把这个过程封装在`32bit-switch.asm`文件中。 打开它，看一下代码。

进入32位模式后，我们将调用`BEGIN_PM`，这是我们实际有用代码（例如内核代码等）的入口。 
您可以在 `32bit-main.asm` 上阅读代码。 编译并运行最后一个文件，您将在屏幕上看到两条消息。

恭喜你！ 我们的下一步将是编写一个简单的内核

# 坑 
我的机器是Mac； 使用 `qemu-system-x86_64 32bit-main.bin --nographic` 并没有正常切换32位模式。32位模式下没有打印。

`nasm -fbin 32bit-main.asm -o 32bit-main.bin` 编译应该是正确的

使用： `qemu-system-x86_64 32bit-main.bin -curses`
```text
-curses 
通常，如果QEMU是在图形窗口支持下编译的，则它将在一个窗口中显示输出，例如来宾图形，来宾控制台和QEMU监视器。 

使用此选项，QEMU可以在文本模式下使用curses / ncurses界面显示VGA输出。 在图形模式下不显示任何内容。
```

> 注意： 32位模式后，打印就在界面第一行。那个不是qume的打印

# More 其他翻译
这一课，不能简单的翻译课文，因为作者并没有写什么内容，一切都在代码里。
那就让我们把代码拆开，看看16位实模式是如何跳转到32位保护模式的。

分析代码前，先想象为什么会有16位实模式呢？

很久以前，大概1985年左右，那时的intel的CPU只有16位，16位就是代表CPU有16根电线接收数据(其实是16根电线发送数据，另外CPU还有32根电线分两组，每组16根各自接受一组数据)，DOS就是那个时代的操作系统，很多年过去了，intel的cpu进化成为32位，但intel为了保证硬件的向前兼容，统一计算机启动的第一步是进入16位模式，然后由引导区决定下一步的动作，这样如果是必须16位模式的DOS系统，一样可以在32位机器上工作。如果你玩树莓派，就会发现完全没有16位实模式这个说法，不过树莓派的启动也是很奇怪的，它先启动GPU，让GPU先读两个配置文件，然后才让ARMcpu工作，这是后话，以后讲到树莓派的时候再说。

32位保护模式与16位实模式是有本质区别的，cpu一次可以寻址32位的地址，也就是最大能够寻址到4G，怎么算的？
```text
2^16 = 65536  约等于65K
2^20=1048575  约等于1M
2^32=4294967295  约等于4G
```
现在咱们都用64位的操作系统，还记得当年换64位操作系统的原因吗？大概2010年后，电脑内存越来越大，很快超过了8G，可尴尬的是32位操作系统无法寻址超过4G的内存地址，因为就算给CPU的32根电线
都传递高电平，也只有0XFFFF FFFF 这么几个F，内存是有8G，多出4G的空间，CPU的指头都不够数。64位操作系统是可以调动CPU所有64根电线的，如果让64根电线都是高电平，那么可以寻址到160亿G的内存地址。

16位与32位的区别就在于寻址的方式，也就是CPU如何把自己要什么地址告诉内存，16位是用段地址*16+偏移地址的方式寻址，能够寻址20位。到了32位CPU，做了另外的选择，更加安全也更加复杂，上一节课已经说过。同一个32位CPU在执行16位模式时，通过调整一个开关，就能进入32位寻址能力的模式，这个开关就是代码中的cr0，当cr0的最低位的bit被置为1时，CPU进入32位保护模式。
```nasm
switch_to_pm:
    cli ;                       1. 关闭中断
    lgdt [gdt_descriptor] ;     2. 加载 GDT descriptor
    mov eax, cr0
    or eax, 0x1 ;               3. 将cr0设置为32位模式
    mov cr0, eax
    jmp CODE_SEG:init_pm ;      4. far jump 
```
lgdt 加载 gdt_descriptor 的作用就是把GDT载入到GDTR寄存器中，其实就是载入了一个地址。
16位时CS寄存器里存的的段地址，进入32位保护模式后，CS中存的是GDT这个结构中的偏移量，比如本例中的GDT代码为：
```nasm
gdt_start: ; don't remove the labels, they're needed to compute sizes and jumps
    ; the GDT starts with a null 8-byte
    dd 0x0 ; 4 byte
    dd 0x0 ; 4 byte

; GDT for code segment. base = 0x00000000, length = 0xfffff
; for flags, refer to os-dev.pdf document, page 36
gdt_code: 
    dw 0xffff    ; segment length, bits 0-15
    dw 0x0       ; segment base, bits 0-15
    db 0x0       ; segment base, bits 16-23
    db 10011010b ; flags (8 bits)
    db 11001111b ; flags (4 bits) + segment length, bits 16-19
    db 0x0       ; segment base, bits 24-31

; GDT for data segment. base and length identical to code segment
; some flags changed, again, refer to os-dev.pdf
gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

; GDT descriptor
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; size (16 bit), always one less of its true size
    dd gdt_start ; address (32 bit)

; define some constants for later use
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
```
可以看到 CODE_SEG 的值是0x08 (gdt-code -gdt_start),所以此时的CS寄存器中就存着0x08，
在保护模式下，CS:IP取指令地址的流程就成为了, CPU计算GDTR+CS 得到code段的真实base地址，然后以IP作为offset，得到最终指令的地址。当然在载入指令前会判断code段的limit是否小于IP，如果小于，则报告段错误，写C语言的人谁没碰到过段错误？当然C语言中的段错误，应该都是超出了LDTR的limit，LDTR中的L是local，GDTR中的G是global。

一旦进入到32位保护模式，一瞬间便天高地阔，不过首先要初始化所有的寄存器，因为寄存器在实模式时，只用了16位，现在可以让寄存器所有32位的能力都能发挥出来。由far jump 到BEGIN_PM lable执行32位下初始化寄存器的指令。下面就该进入kernel了！
```text
作者：半步江南
链接：https://www.jianshu.com/p/d39839179848
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```