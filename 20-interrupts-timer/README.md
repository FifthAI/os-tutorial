*Concepts you may want to Google beforehand: CPU timer, keyboard interrupts, scancode*
> CPU timer CPU时钟
>
> keyboard interrupts 键盘中断
>
> 扫码-scanCode
> 
> 键盘映射之ScanCode码 - 通过修改注册表的方法来更改按键间的映射关系时用得到。

**Goal: 实现第一个中断请求处理程序之CPU时钟与键盘输入**

现在一切就绪，可以测试我们的硬件中断。

Timer / 时钟
-----
时钟是比较简单配置的，首先我们定义一个新方法`init_timer()` 在 `cpu/timer.h`中；并且在 `cpu/timer.c` 中实现其方法. 

本方法就是计算时钟频率，并且发送bytes数据给其对应的端口。

现在我们将修复`kernel/utils.c int_to_ascii（`以正确的顺序打印数字。 为此，我们需要实现`reverse（）`和`strlen（）`。

最后，返回 `kernel/kernel.c` 作两件事 

启动中断，这很重要。然后初始化时钟中断。

去 `make run`一下，你就可以看到时钟循环了

> 查看代码后我发现这里的时钟是根据中断回调实现的。所以是先汇编调用中断，把间隔参数设定好；然后初始化时钟，开始递归时钟循环的。

Keyboard / 键盘
--------
键盘更加简单，但有一个问题。 PIC不会向我们发送按键的ASCII码，而是向我们发送按键按下和按键按下事件的扫描码（ScanCode码），因此我们将需要翻译这些扫码。

查看`drivers / keyboard.c`，其中有两个功能：回调和配置中断回调的初始化。 使用定义创建了一个新的 `keyboard.h`。

`keyboard.c`还有一个很长的表，可以将扫描代码转换为ASCII键值。 目前，我们将只实现美国键盘的一个简单子集。你可以查看[扫码](http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html)的更多信息

到此我不知道你们感觉如何，但是我是非常激动的，我们非常接近构造一个简单的Shell程序了。在下一章，我们将展开键盘输入上做文章。
