[org 0x7c00] ; bootloader offset
    mov bp, 0x9000 ; set the stack
    mov sp, bp

    mov bx, MSG_REAL_MODE
    call print ; This will be written after the BIOS messages
    call print_nl

    call switch_to_pm
    jmp $ ; 上一句调用方法中包含 jmp $ 所以这句不会执行到；this will actually never be executed

%include "../05-bootsector-functions-strings/boot_sect_print.asm"
%include "../09-32bit-gdt/32bit-gdt.asm"
%include "../08-32bit-print/32bit-print.asm"
%include "32bit-switch.asm"

[bits 32]
BEGIN_PM: ; after the switch we will get here
    mov ebx, MSG_PROT_MODE
    call print_string_pm ; Note that this will be written at the top left corner
    jmp $ ;这里需要开启循环，否则从调用位置继续执行

MSG_REAL_MODE db "Started in 16-bit real mode", 0
MSG_PROT_MODE db "**Loaded 32-bit protected mode**", 0
MSG_SWITCHING db "switching 16 to 32", 0

; bootsector
times 510-($-$$) db 0
dw 0xaa55

; # 编译
; nasm -fbin 32bit-main.asm -o 32bit-main.bin
# 运行
; qemu-system-x86_64 32bit-main.bin --nographic