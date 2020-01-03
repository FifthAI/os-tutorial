XOS系统下工具链

* gcc （苹果用clang占据了gcc这个名字）`gcc -v`
* objdump objdump工具用来显示二进制文件的信息 `objdump -version`
* ld 连接器，将目标文件连接为可执行程序。`ld -v`
* xxd 二进制查看加反编译工具 `xxd -v`

1. 编译 `gcc -ffreestanding -c function.c -o function.o`
2. 查看 `objdump -d function.o`
3. 链接 `ld -r -o function.bin function.o` // 这里应该还是不对
4. 比较 `xxd function.o` `xxd function.bin`
5. 反汇编 `ndisasm -b 32 function.bin`