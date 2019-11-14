[bits 16]
switch_to_pm:
    mov bx, MSG_SWITCHING
    call print ; 为了debug打印的msg
    call print_nl
    cli ; 1. 取消中断信号 / disable interrupts
    lgdt [gdt_descriptor] ; 2. 加载GDT表 / load the GDT descriptor
    mov eax, cr0
    or eax, 0x1 ; 3. 设置32位模式 / set 32-bit mode bit in cr0
    mov cr0, eax
    jmp CODE_SEG:init_pm ; 4. 远端调用，使用不同的内存段 / far jump by using a different segment

[bits 32]
init_pm: ; 现在开始使用32位指令集 / we are now using 32-bit instructions
    mov ax, DATA_SEG ; 5. 更新段寄存器 / update the segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000 ; 6. 在可用空间的顶部更新堆栈 / update the stack right at the top of the free space
    mov esp, ebp
    call BEGIN_PM ; 7. 调用带有有用代码的知名标签 / Call a well-known label with useful code
