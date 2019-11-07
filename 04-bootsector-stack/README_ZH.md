*基础知识储备:  栈内存 stack*

* 栈内存 Stack memory 
* 堆内存 heap memory

**Goal: 如何使用 stack**

栈/stack的使用十分重要,所以我们写一个新启动扇区的例子

`bp` 寄存器存储栈基址，位置在下 （the base address (i.e. bottom) of the stack）,

`sp` 寄存器存储位置在上

堆地址从上向着 `bp`移动 ，sp逐次递减(i.e. `sp` gets decremented)

这一段没什么可说的，直接看代码吧还是

在代码的不同地方，建议尝试自己访问堆栈中的内存地址，看看会发生什么。
