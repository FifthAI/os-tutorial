/**
 * Read a byte from the specified port
 * 从特定端口读取1B
 */
unsigned char port_byte_in (unsigned short port) {
    unsigned char result;
    /* Inline assembler syntax
     * !! Notice how the source and destination registers are switched from NASM !!
     * !! 注意源寄存器和目标地址寄存器在汇编中是如何交换的 !!
     *
     * '"=a" (result)'; set '=' the C variable '(result)' to the value of register e'a'x
     * '"d" (port)': 将C变量'（port）'映射到e'd'x寄存器
     *
     * 输入和输出之间用冒号分隔
     */
    __asm__("in %%dx, %%al" : "=a" (result) : "d" (port));
    return result;
}

void port_byte_out (unsigned short port, unsigned char data) {
    /* 注意这里两个寄存器如何映射到C变量
     * 并且，没有返回值；因此，在asm语法中没有等号'='
     * 但是我们看到一个逗号，因为输入区域中有两个变量
     * 并且，没有任何东西在返回区域
     * __asm__("out %%al, %%dx" : 【这里其实是返回值的位置，下面的句子是空】 : 【这里是映射的位置，也就是输入，可以多于1个value】);
     */
    __asm__("out %%al, %%dx" : : "a" (data), "d" (port));
}

unsigned short port_word_in (unsigned short port) {
    unsigned short result;
    __asm__("in %%dx, %%ax" : "=a" (result) : "d" (port));
    return result;
}

void port_word_out (unsigned short port, unsigned short data) {
    __asm__("out %%ax, %%dx" : : "a" (data), "d" (port));
}
