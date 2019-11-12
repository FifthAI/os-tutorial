*Concepts you may want to Google beforehand: 硬盘，柱面，磁头，扇区，进位*

**Goal: 让引导扇区从磁盘加载数据以引导内核**

512字节的引导扇区无法容纳我们的操作系统，因此需要从磁盘中读取数据以运行内核。

幸运的是，我们不必关闭并打开磁盘重来，可以调用BIOS一些程序解决，就像之前的打印程序一样.

为此，我们将 `al` 设置为 `0x02`（以及其他具有所需柱面，头部和扇区的寄存器），并触发`int 0x13`中断

>  BIOS的INT 13中断服务程序，可以访问磁盘，参数是读取扇区的起始磁道号、磁头号、扇区号，读取的扇区个数，缓冲区位置等

[详细的int 13h指南在这里](http://stanislavs.org/helppc/int_13-2.html)
```text
粗翻：

INT 13,2-读取磁盘扇区

AH = 02
AL = 读取扇区数	(1-128 dec.)
CH = 磁道/柱面编号 / track/cylinder number  (0-1023 dec., see below)
CL = 扇区编号 / sector number  (1-17 dec.)
DH = 磁头号 / head number  (0-15 dec.)
DL = 驱动器号 / drive number (0=A:, 1=2nd floppy 软盘, 80h=drive 0 驱动器0, 81h=drive 1 驱动器1)
ES:BX = 缓冲区指针 / pointer to buffer


返回:
AH = status / 状态码（请参阅INT 13，STATUS）
AL = number of sectors read / 读取的扇区数
CF = 0 if successful / 0 成功
    = 1 if error / 1 失败


- BIOS磁盘读取应至少重试三次，并且在检测到错误时应重置控制器
- 确保ES：BX没有越过64K段边界，否则将发生DMA边界错误
- 许多编程参考仅列出软盘寄存器值
- 仅检查磁盘号的有效性
- CX中的参数根据柱面号而变化；磁道/柱面编号是一个10位值，取自CL的2个高位和CH的8位（磁道的低8位）:

    |F|E|D|C|B|A|9|8|7|6|5-0|  CX
    | | | | | | | | | |	`-----	扇区号 / sector number
    | | | | | | | | `---------  轨道/圆柱的高2位 / high order 2 bits of track/cylinder
    `------------------------  轨道/柱面编号的低8位 / low order 8 bits of track/cyl number

- see	INT 13,A
```
在本课程中，我们将首次使用*进位*，这是每个寄存器上存在的一个额外位，当操作超出其当前容量时会存储该位：

```nasm
mov ax, 0xFFFF
add ax, 1 ; ax = 0x0000 and carry = 1
```

进位不是直接访问的，而是由其他运算符用作控制结构，例如`jc`（如果运算产生了进位，则跳转）

BIOS还将“ al”设置为读取的扇区数，因此请始终将其与期望的数量进行比较。

Code
----
打开并练习`boot_sect_disk.asm`以获取从磁盘读取的完整程序。

`boot_sect_main.asm` 为磁盘读取准备参数并调用 `disk_load`。 注意，我们如何写入一些实际上不属于引导扇区的额外数据，因为它们在512位标记之外。

引导扇区实际上是硬盘0的磁头0的磁头0的扇区1（第一个扇区，从1开始）。

因此，字节512之后的任何字节都对应于hdd 0的磁头0的柱面0的扇区2

主程序将用示例数据填充它，然后让引导程序读取它。

**注意：如果您仍然遇到错误并且代码看起来没问题，请确保qemu从正确的驱动器引导，并将驱动器相应地设置在 `dl` 上**

BIOS在调用引导加载程序之前将 `dl` 设置为驱动器号。 但是，从硬盘启动时，我发现qemu有一些问题。

有两个快速选项：
1. 尝试使用标志 `-fda`，例如`qemu -fda boot_sect_main.bin`，它将`dl`设置为`0x00`，然后看起来工作正常。
2. 明确使用标志`-boot`，例如`qemu boot_sect_main.bin -boot c`会自动将`dl`设置为`0x80`并让引导程序读取数据
