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

我可以直接指出它在BIOS的 `0x7C00`，但是一个举个可以造成错误的例子可以让理解更清晰

我们打算打印X到屏幕上，我们将尝试4种不同的策略。然后看看那个才能正确工作，并思考其原因

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

If you add or remove instructions, remember to compute the new offset of the X
by counting the bytes, and replace `0x2d` with the new one.

不要盲目的进入下一环节，除非你100%理解了启动扇区偏移跟内存地址


The global offset
-----------------

Now, since offsetting `0x7c00` everywhere is very inconvenient, assemblers let
us define a "global offset" for every memory location, with the `org` command:

```nasm
[org 0x7c00]
```

Go ahead and **open `boot_sect_memory_org.asm`** and you will see the canonical
way to print data with the boot sector, which is now attempt 2. Compile the code
and run it, and you will see how the `org` command affects each previous solution.

Read the comments for a full explanation of the changes with and without `org`

-----

[1] This whole tutorial is heavily inspired on that document. Please read the
root-level README for more information on that.
