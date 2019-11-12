*基础知识储备: 控制结构、流程控制（control structures）,方法调用（function calling）,字符串（strings）*

**Goal: 学习汇编基本代码块编写 (如：loops, functions)**

我们的启动扇区接近完成

在第7节课我们将完成读取硬盘装载内核之前的最后一步。但在这之前，需要写一点控制结构代码、函数调用、常量字符串。进入硬盘、内核环节之前我们的确需要适应一下这些概念。


字符串 / Strings
-------

以Bytes的方式定义字符串，并且使用一个空Byte终止此字符串读入。（是，很像C）

```nasm
mystring:
    db 'Hello, World', 0
```

注意，字符串被引号包裹。它将被编译器翻译成ASCII码，剩下的那个0被转换为 `0x00` Byte，也就是所说的终止字符串 (null byte)


流程控制 / Control structures
------------------

我们已经使用过一个 `jmp $` 来创建无限循环.

汇编跳转到上一个定义好的指令，例如：

```nasm
cmp ax, 4      ; if ax = 4
je ax_is_four  ; 其他定义好的代码（ax_is_four）
jmp else       ; 跳转else
jmp endif      ; 最终, 继续走流程

ax_is_four:
    .....
    jmp endif

else:
    .....
    jmp endif  ; 这里是非必须的，主要是为了程序完整性

endif:
```

在脑中思考代码以此种方式汇编，这里有很多种 `jmp` 条件：如，登陆，小于等等。这些条件都很直观，可以直接Google一下他们的含义

函数调用 / Calling functions
-----------------

你可能已经想到，函数调用就是使用jump，跳转到预先定义好的label上。
As you may suppose, calling a function is just a jump to a label.

比较费劲的问题在于参数，使用参数需要2个步骤： 

1. 程序知道去哪找共享的寄存器或者内存地址
2. 多写一点代码，让方法调用通用起来通用又无感。

Step 1 is easy. Let's just agree that we will use `al` (actually, `ax`) for the parameters.

```nasm
mov al, 'X'
jmp print
endprint:

...

print:
    mov ah, 0x0e  ; tty code
    int 0x10      ; I assume that 'al' already has the character
    jmp endprint  ; this label is also pre-agreed
```

You can see that this approach will quickly grow into spaghetti code. The current
`print` function will only return to `endprint`. What if some other function
wants to call it? We are killing code reusage.

The correct solution offers two improvements:

- 将存储返回地址，以便其可能有所不同

- We will store the return address so that it may vary
- We will save the current registers to allow subfunctions to modify them
  without any side effects

存储返回地址，CPU本身可以帮我，可以使用`call`和`ret`替代`jmp`回调子程序。

为了保存寄存器数据，还有一个使用堆栈的特殊命令：`pusha` 和它的兄弟`popa`，它会自动将所有寄存器推入堆栈，
之后恢复它们。


倒入外部文件 / Including external files
------------------------
我假设您是一名程序员，不需要说服您为什么这样做是一个好主意。

代码这么写
```nasm
%include "file.asm"
```


打印16进制数居 / Printing hex values
-------------------
在下一课中，我们将开始从磁盘读取数据，因此我们需要一些方法以确保我们正在读取正确的数据。

文件 `boot_sect_print_hex.asm` 扩展自 `boot_sect_print.asm` 来打印 hex bytes（十六进制数据）, 不仅仅是ASCII


Code! 
-----

让我们来看代码. `boot_sect_print.asm`文件是子程序，可以通过 `%include` 导入主文件. 

它使用循环打印bytes到屏幕。也包括导入新行打印。

我们熟悉的 `'\n'`实际上2个bytes（自己）, 换行字符 char `0x0A` 和 回车 `0x0D`. 

通过删除回车符char进行实验，并查看其效果。

删除这部分，
```nasm
    mov al, 0x0d ; carriage return
    int 0x10
```

如上所述，`boot_sect_print_hex.asm`就是允许打印字节。

主文件 `boot_sect_main.asm` 会加载几个字符串和字节，

调用 `print` 和 `print_hex` 并且挂断. 

如果你看明白了前面的几个小节，这块就没啥了


# 编译
`nasm -fbin boot_sect_main.asm -o main`
# 运行
`qemu-system-x86_64 main --nographic`
```text
Booting from Hard Disk...
Hello, World
Goodbye
0x12FE

删除换行符的执行结果；新行，但是位置没归0
Booting from Hard Disk...
Hello, World
            Goodbye
                   0x12FE
```