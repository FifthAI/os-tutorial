**先要Google以下学习的知识点: C types and structs（C类型与结构体）, include guards（导入保护，防止*.h重复导入）, type attributes: packed, extern, volatile, exceptions*

> 预习的知识点，目的是让我们知道这些计算机概念。不是C语言一定包含这些概念。

- Include guard
    - #ifndef的方式受C/C++语言标准支持。它不光可以保证同一个文件不会被包含多次，也能保证内容完全相同的两个文件（或者代码片段）不会被不小心同时包含。
- packed
    - 汇编上进行对齐，大约就是不足1Byte的地方的差位补0
    - __attribute__ ((packed)) 的作用就是告诉编译器取消结构在编译过程中的优化对齐,按照实际占用字节数进行对齐，是GCC特有的语法。
- volatile
    -  volatile的作用是： 作为指令关键字，确保本条指令不会因编译器的优化而省略，且要求每次直接读值.
- extern
    -  extern可置于变量或者函数前，以表示变量或者函数的定义在别的文件中，提示编译器遇到此变量或函数时，在其它模块中寻找其定义。另外，extern也可用来进行链接指定。
- exceptions
    - 异常，但是c上的异常。不是很理解。

**目标: 设置中断描述符表以处理CPU中断（Interrupt Descriptor Table/中断描述符表； interrupt/中断）**

本课及后续课程受到[JamesM's tutorial](https://web.archive.org/web/20160412174753/http://www.jamesmolloy.co.uk/tutorial_html/index.html)的大力启发

Data types / 数据类型
----------
首先，我们将在`cpu / types.h`中定义一些特殊的数据类型，这将有助于我们从chars和int分离原始字节的数据结构。

它已经被小心地放在`cpu/`文件夹中，从现在开始我们将在其中放置与机器相关的代码。

嗯。负责专门引导的x86代码，仍然在`boot/`上，现在先放在哪里不要管。

一些已经存在的文件已被更改为使用新的u8，u16和u32数据类型。

从现在开始，我们的C头文件还将包含头文件保护符（header guard）

### 概念：头文件保护符（header guard）
1. #ifdef   已定义时为真。（这句一般加在。.h文件的一开始）
2. #ifndef 未定义时为真，若为真，执行后续操作，直到遇到 #endif 为止。（这句加在.h文件的尾部）
```C++
#ifdef  tree    //如果没有定义 Tree 这个变量，就一直执行到 endif
#define tree    //我现在定义一个tree变量，下次 ifdef 便不会生效，但这次的仍然会执行到 endif
int b;
char* c;        //确保了代码是一次加载
#endif          //第一次执行的 ifdef 到这里停止                    
```

Interrupts / 中断
----------
中断是内核需要处理的主要内容之一。 我们现在将尽快实现它，以便在以后的课程中能够接收键盘输入。

中断的另一种是：除零，越界，无效的操作码，页错误等。

中断是在向量上处理的，其条目与GDT的条目相似（第9课）。 但是，我们将使用C语言代替在汇编中对IDT进行编程。

> GDT，即全局描述表（GDT Global Descriptor Table） --> 这个用于程序、进程并行，内存分割，可以让程序并行
> 
> IDT, Interrupt Descriptor Table，即中断描述符表  --> 用于IO切换造成的寄存器状态保留，可以让程序暂停

`cpu/idt.h`定义了一个idt条目的存储方式`idt_gate`（即使是null，也必须有256个，否则CPU可能会死机）

以及, BIOS将加载的实际idt结构`idt_register`，它只是内存地址和大小，类似于GDT寄存器。

最后，我们定义了几个变量以从汇编代码访问这些数据结构。

`cpu/idt.c`只是用处理程序填充每个结构。 如您所见，这些就是设置值、并调用`lidt`汇编程序命令而已。

ISRs
----
> Interrupt Service Routines（中断服务程序）：ISR

每当CPU检测到中断（通常是致命的）时，就会运行“中断服务程序”。

我们编写代码来处理它们，打印一些错误消息并停止CPU。

在`cpu/isr.h`中，我们手动定义了32个外部引用方法。 因为它们将在汇编器中的`cpu/interrupt.asm`中实现，所以将它们声明为`extern`。

在查看汇编代码之前，请检查`cpu/isr.c`。 如您所见，我们定义了一个函数来立即安装所有isrs并加载IDT，错误消息列表和高级处理程序，该函数会打印一些信息。 您可以自定义`isr_handler`以进行打印/执行任何操作。

现在需要将底层将每个`idt_gate`与其对应的高层处理程序对应到一起。

打开`cpu/interrupt.asm`。 在这里，我们定义一个通用的低级ISR代码，该代码基本上是保存/恢复状态并调用C代码，然后定义实际的ISR汇编器函数，这些函数在`cpu/isr.h`中引用。

注意`registers_t`结构体是如何表示我们在`interrupt.asm`中压栈的所有寄存器。

基本上逻辑大致如此。 现在，我们需要Makefile中添加引用`cpu/interrupt.asm`，并使内核安装ISR并启动。

注意，如何在中断发生之后让CPU不停止，并继续运行，是一个不错的思考题。


> 注意， Makefile的修改。本章加入了中断程序，编译顺序也有变。
