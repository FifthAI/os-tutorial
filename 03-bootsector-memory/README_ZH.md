*基础知识储备: memory offsets(内存偏移), pointers(指针)*

**Goal: 计算机如何组织内存结构**

文档14页，查看内存结构，对内存结构有一个认知 [of this document](
http://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf)<sup>1</sup>

## 手工采摘
简单的16bit模式下的启动扇区，内存大致结构
```text
+-----------+---------------------------------+
|           | Free                            |
+-----------+                                 |
|           |                                 |
+-0x1000000-+---------------------------------+
|           | BIOS 256KB                      |
+-0xc0000---+---------------------------------+
|           | Video Memory 128KB              |
+-0xa0000---+---------------------------------+
|           | Extended BIOS Data Area 639KB   |
+           +                                 |
|           |                                 |
+-0x9fc00---+---------------------------------+
|           | Free 638KB                      |
+-0x7e00----+                                 |
|           | // Loaded Boot Sector 512bytes  |
+-0x7c00----+                                 |
|           |                                 |
+-0x500-----+---------------------------------+
|           | BIOS Data Area 256bytes         |
+-0x400-----+---------------------------------+
|           | Interrupt Vertor Table 1KB      |
+-0x0-------+---------------------------------+
```

本节的唯一目标就是搞懂启动扇区存在那。

我可以直接指出它在BIOS的 `0x7C00`，但是举一个可以造成错误的例子可以让理解更清晰

我们打算打印X到屏幕上，我们将尝试4种不同的策略。然后看看那个才能正确工作，并思考其原因

> 0x7C00这个地址来自Intel的第一代个人电脑芯片8088，以后的CPU为了保持兼容，一直使用这个地址。
> 
> 1. 通电
> 2. 读取ROM里面的BIOS，用来检查硬件
> 3. 硬件检查通过
> 4. BIOS根据指定的顺序，检查引导设备的第一个扇区（即主引导记录），加载在内存地址 0x7C00
> 5. 主引导记录把操作权交给操作系统
> 
> 8088芯片本身需要占用0x0000～0x03FF，用来保存各种中断处理程序的储存位置。（主引导记录本身就是中断信号INT 19h的处理程序。）所以，内存只剩下0x0400～0x7FFF可以使用。
> 
> 为了把尽量多的连续内存留给操作系统，主引导记录就被放到了内存地址的尾部。由于一个扇区是512字节，主引导记录本身也会产生数据，需要另外留出512字节保存。所以，它的预留位置就变成了：
> 
>   0x7FFF - 512 - 512 + 1 = 0x7C00 

**打开文件 `boot_sect_memory.asm`**

首先，我们定义数据x，加上Lable：
```nasm
the_secret:
    db "X"
```
然后我们采用不同方式获取`the_secret`标签：

1. `mov al, the_secret`
2. `mov al, [the_secret]`
3. `mov al, the_secret + 0x7C00`
4. `mov al, 2d + 0x7C00`,  `2d` 是X的实际地址

查看汇编文件中的代码，阅读注释

编译运行，将能得到一个类如 `1[2¢3X4X` 的打印, 1，2后面的乱码来自于随机的内存

如果你添加或者移除指令，记得把新的偏移给X算进去，并且修改 `0x2d` 到合适的位置

不要盲目的进入下一环节，除非你100%理解了启动扇区偏移跟内存地址


全局偏移
-----------------
现在，鉴于`0x7c00`遍布整个程序，非常不方便。编译器给我们一个定义全局偏移的方法。

`org` 命令:

```nasm
[org 0x7c00]
```
前往文件 **`boot_sect_memory_org.asm`**，这是一个典型的启动扇区打印程序，编译运行它，查看`org`命令对之前程序的影响

阅读注释以获取有关使用和不使用`org`的造成影响的完整说明。

-----
1. 第二段代码注释不翻译了；就是因为有了org，已经默认偏移了；所以程序不大对了；
2. 如果修改了汇编程序，编译后的二进制可执行文件的X位置，不一定在2d这个位置上，需要查看二进制文件，才能正确输出X
-----
[关于 0x7c00](http://www.ruanyifeng.com/blog/2015/09/0x7c00.html)

[1] This whole tutorial is heavily inspired on that document. Please read the
root-level README for more information on that.