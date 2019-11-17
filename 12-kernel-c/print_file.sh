#定义
build() {
    echo "file name is $*"
    echo 'i386-elf-gcc -ffreestanding -c "$*.c" -o "$*.o"'
    i386-elf-gcc -ffreestanding -c "$*.c" -o "$*.o"
    echo ""
    echo "---------------------------------------------------------------"
    echo 'i386-elf-objdump -d "$*.o"'
    i386-elf-objdump -d "$*.o"
    echo ""
    echo "---------------------------------------------------------------"
    echo 'i386-elf-ld -o "$*.bin" -Ttext 0x0 --oformat binary "$*.o"'
    i386-elf-ld -o "$*.bin" -Ttext 0x0 --oformat binary "$*.o"
    echo "---------------------------------------------------------------"
    echo 'xxd "$*.o"'
    xxd "$*.o"
    echo "---------------------------------------------------------------"
    echo 'xxd "$*.bin"'
    xxd "$*.bin"
    echo "---------------------------------------------------------------"
    echo 'ndisasm -b 32 "$*.bin"'
    ndisasm -b 32 "$*.bin"
    echo "---------------------------------------------------------------"
}
#调用
build localvars > ./bak/localvars.log 2>&1
build functioncalls > ./bak/functioncalls.log 2>&1
build pointers > ./bak/pointers.log 2>&1