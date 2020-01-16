> 本章主要实现了拦截中断的后续处理
> 1. 汇编级拦截中断保存寄存器状态
> 2. 拦截后调用中断请求方法，判断是否在handle范围，回调回主程序。

*Concepts you may want to Google beforehand: IRQs, PIC, polling*
> IRQ 为 Interrupt ReQuest的缩写，中文可译为中断请求。
>
> PIC(Programmable Interrupt Controller) 中断控制器
>
> polling 轮询
>
在一般的电脑系统里，当装备需要系统来服务时。有二种方法：
* 一是轮询，由CPU一直去问装备是否需要服务，如果需要时就去服务它，而很浪费CPU的时间，
* 另一种方法就是IRQ的方式，当设备需耍服务时就发出IRQ，当系统 收到这个IRQ讯号时才去服务它，这样可大大干涉系统的负担。

**目标: 完成中断实现、CPU时钟**
当CPU启动时，PIC将IRQ 0-7映射到INT 0x8-0xF，将IRQ 8-15映射到INT 0x70-0x77。 这与我们在上一课中编写的ISR冲突。 由于我们对ISR 0-31进行了编程，因此将IRQ重新映射到ISR 32-47是标准的。

PIC通过I/O端口进行通信（请参阅第15节）。 主PIC具有`命令0x20`和`数据0x21`，而从PIC具有`命令0xA0`和`数据0xA1`。

用于重新映射PIC的代码很奇怪，其中包含一些掩码，因此如果您感到好奇，请[查看本文](http://www.osdev.org/wiki/PIC)。

除此以外，查看`cpu/isr.c`，在给ISRs设置IDT门后附加了一些新代码，之后，我们为IRQ添加IDT门。

现在我们来到汇编部分。在 `interrupt.asm`中. 首要任务是添加全局IRQ符号给的C代码使用。注意查看底部的哪些全局定义 `global` statements.

然后，添加IRQ处理程序。 同样在`interrupt.asm`底部。 注意他们如何跳转到新的公用代码：`irq_common_stub`（下一步）

我们创建`irq_common_stub`这个方法，它跟`interrupt.asm`靠上部分那个ISR处理非常相似，并且它通用定义了一个外部引用 `[extern irq_handler]`

现在回到C代码，增加一个中断请求处理程序 `irq_handler()` 在 `isr.c`中。

它向PIC发送一些EOI，并调用适当的处理程序，该处理程序存储在文件顶部定义的`interrupt_handlers`的数组中。

> 中断结束命令 （End Of Interrupt -- EOI）

新的结构体在`isr.h`中定义。 我们还将使用一个简单的函数来注册（记录）中断处理程序。

经过这一番工作，现在我们可以定义第一个IRQ处理程序了！

`kernel.c`没有变化，因此没有新的运行和看到的内容。 请继续下一课，检查那些闪亮的新IRQ。