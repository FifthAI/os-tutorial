[bits 32] ; 使用32位保护模式 using 32-bit protected mode

; this is how constants are defined
; 常量的定义方式
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f ; 每个字符的颜色字节 the color byte for each character 

print_string_pm:
    pusha
    mov edx, VIDEO_MEMORY

print_string_pm_loop:
    mov al, [ebx] ; [ebx]是你字符所在的地址 [ebx] is the address of our character
    mov ah, WHITE_ON_BLACK

    cmp al, 0 ; 检查字符串的结尾 check if end of string
    je print_string_pm_done

    mov [edx], ax ; 将字符+属性存储在视频存储器中 store character + attribute in video memory
    add ebx, 1 ; next char
    add edx, 2 ; next video memory position

    jmp print_string_pm_loop

print_string_pm_done:
    popa
    ret

; 本例不能运行，了解原理就可以了