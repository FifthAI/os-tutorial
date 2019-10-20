mov ah, 0x0e ; tty 模式

mov bp, 0x8000 ; 选0x8000这个地址距离 0x7c00 足够远了，不会被程序覆盖
mov sp, bp ; 如果堆是空的，把sp指向到bp的位置

push 'A'
push 'B'
push 'C'

; 查看堆是如何向下增长，查看0x8000-2的位置，打印输出
mov al, [0x7ffe] ; 0x8000 - 2
int 0x10

; however, don't try to access [0x8000] now, because it won't work
; you can only access the stack top so, at this point, only 0x7ffe (look above)
mov al, [0x8000]
int 0x10


; recover our characters using the standard procedure: 'pop'
; We can only pop full words so we need an auxiliary register to manipulate
; the lower byte
pop bx
mov al, bl
int 0x10 ; prints C

pop bx
mov al, bl
int 0x10 ; prints B

pop bx
mov al, bl
int 0x10 ; prints A

; data that has been pop'd from the stack is garbage now
mov al, [0x8000]
int 0x10


jmp $
times 510-($-$$) db 0
dw 0xaa55
