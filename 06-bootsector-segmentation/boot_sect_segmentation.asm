mov ah, 0x0e ; tty

mov al, [the_secret]
int 0x10 ; we already saw this doesn't work, right?

mov bx, 0x7c0 ; 段地址会自动偏移4 （<<4）
mov ds, bx
; WARNING: 从现在开始ds会默认偏移。
mov al, [the_secret]
int 0x10

mov al, [es:the_secret]
int 0x10 ; 看起来不正确...'es'当前不是0x000吗？doesn't look right... isn't 'es' currently 0x000?

mov bx, 0x7c0
mov es, bx ; 手动设置一下地址
mov al, [es:the_secret]
int 0x10


jmp $

the_secret:
    db "X"

times 510 - ($-$$) db 0
dw 0xaa55

;# 编译
; nasm -fbin boot_sect_main.asm -o main
; # 运行
; qemu-system-x86_64 main --nographic