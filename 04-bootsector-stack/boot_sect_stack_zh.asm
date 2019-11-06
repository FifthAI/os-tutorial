mov ah, 0x0e ; tty 模式

mov bp, 0x8000 ; 选0x8000这个地址距离 0x7c00 足够远了，不会被程序覆盖
mov sp, bp ; 如果堆是空的，把sp指向到bp的位置

push 'A'
push 'B'
push 'C'

; 查看堆是如何向下增长，查看0x8000-2的位置，打印输出
mov al, [0x7ffe] ; 0x8000 - 2
int 0x10

; 然而，不要现在使用[0x8000], 因为它还不能正常工作
; 您只能访问堆栈顶部，因此，此时只有0x7ffe（如上图所示）
mov al, [0x8000]
int 0x10


; 恢复字符的话，需要使用标准命令: 'pop'
; 我们可以pop出完整的words，所以我们需要一个寄存器协助操作地位byte
pop bx
mov al, bl
int 0x10 ; prints C

pop bx
mov al, bl
int 0x10 ; prints B

pop bx
mov al, bl
int 0x10 ; prints A

; 现在pop栈数据就是垃圾数据了
mov al, [0x8000]
int 0x10


jmp $
times 510-($-$$) db 0
dw 0xaa55
