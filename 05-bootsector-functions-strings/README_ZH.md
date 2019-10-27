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

- We will store the return address so that it may vary
- We will save the current registers to allow subfunctions to modify them
  without any side effects

To store the return address, the CPU will help us. Instead of using a couple of
`jmp` to call subroutines, use `call` and `ret`.

To save the register data, there is also a special command which uses the stack: `pusha`
and its brother `popa`, which pushes all registers to the stack automatically and
recovers them afterwards.


倒入外部文件 / Including external files
------------------------

I assume you are a programmer and don't need to convince you why this is
a good idea.

The syntax is
```nasm
%include "file.asm"
```


打印16进制数居 / Printing hex values
-------------------

In the next lesson we will start reading from disk, so we need some way
to make sure that we are reading the correct data. File `boot_sect_print_hex.asm`
extends `boot_sect_print.asm` to print hex bytes, not just ASCII chars.


Code! 
-----

Let's jump to the code. File `boot_sect_print.asm` is the subroutine which will
get `%include`d in the main file. It uses a loop to print bytes on screen.
It also includes a function to print a newline. The familiar `'\n'` is
actually two bytes, the newline char `0x0A` and a carriage return `0x0D`. Please
experiment by removing the carriage return char and see its effect.

As stated above, `boot_sect_print_hex.asm` allows for printing of bytes.

The main file `boot_sect_main.asm` loads a couple strings and bytes,
calls `print` and `print_hex` and hangs. If you understood
the previous sections, it's quite straightforward.
