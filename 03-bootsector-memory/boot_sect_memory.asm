mov ah, 0x0e

; attempt 1
; 失败，因为the_secret是内存地址 (i.e. pointer)
; not its actual contents
mov al, "1"
int 0x10
mov al, the_secret
int 0x10

; attempt 2
; 通过正确的方法尝试打印内存地址上的内容
; 然后BIOS把我们的启动扇区填充到了 0x7c00 这个位置
; 所以我们需要添加一些偏移. 查看attempt 3
mov al, "2"
int 0x10
mov al, [the_secret]
int 0x10

; attempt 3
; BIOS的偏移地址 0x7c00 加上 X的内存地址，不要使用取值，要地址相加
; 我们需要通过'bx'寄存器帮我们存着指针，直接 'mov al, [ax]' 是不行的，非法操作（大约就是硬件不支持）.
; 寄存器不能用作同一命令的源和目标。
mov al, "3"
int 0x10
mov bx, the_secret
add bx, 0x7c00
mov al, [bx]
int 0x10

; attempt 4
; 我们可以直接写明确的内存地址，找到X的位置，进行打印
; 这有效，但是没啥效率。我们不能每次都重新手动计算偏移地址啊
; （通过编译后，查看二进制文件，你能看见X在2d的位置）
;   Offset: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 	
; 00000000: B4 0E B0 31 CD 10 B0 2D CD 10 B0 32 CD 10 A0 2D    4.01M.0-M.02M..-
; 00000010: 00 CD 10 B0 33 CD 10 BB 2D 00 81 C3 00 7C 8A 07    .M.03M.;-..C.|..
; 00000020: CD 10 B0 34 CD 10 A0 2D 7C CD 10 EB FE 58 00 00    M.04M..-|M.k~X..
; 00000030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
; 第二行58，ASCII对应为X -> 二进制: 0101 1000	十进制: 88	十六进制: 58	ASCII: X
mov al, "4"
int 0x10
mov al, [0x7c2d]
int 0x10


jmp $ ; 循环

the_secret:
    ; ASCII code 0x58 ('X') is stored just before the zero-padding.
    ; On this code that is at byte 0x2d (check it out using 'xxd file.bin')
    db "X"

; 充0，写入魔术字 0xaa55；
times 510-($-$$) db 0
dw 0xaa55
