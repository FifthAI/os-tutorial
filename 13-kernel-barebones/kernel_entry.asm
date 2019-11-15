[bits 32]
[extern main] ; 定义外部标签 Define calling point. Must have same name as kernel.c 'main' function
call main ; 调用这个标签 (然后把c代码链起来,就能调用过去了)Calls the C function. The linker will know where it is placed in memory
jmp $
