*基础知识储备:  堆内存 stack*

**Goal: 如何使用 stack**

堆/stack的使用十分重要, so we'll write yet another boot sector
with an example.

`bp` 寄存器存储堆基址，位置在下 （the base address (i.e. bottom) of the stack）,

`sp` 寄存器存储位置在上

堆地址从上向着 `bp`移动 ，sp逐次递减(i.e. `sp` gets decremented)

这一段没什么可说的，直接看代码吧还是

I suggest that you try accessing in-stack memory addresses by yourself, 
at different points in the code, and see what happens.
