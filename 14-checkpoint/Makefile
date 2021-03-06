C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)
# Nice syntax for file extension replacement
OBJ = ${C_SOURCES:.c=.o}

# Change this if your cross-compiler is somewhere else
CC = /usr/local/bin/x86_64-elf-gcc
GDB = /usr/local/bin/i386-elf-gdb
# -g: Use debugging symbols in gcc
CFLAGS = -g

# First rule is run by default
os-image.bin: boot/bootsect.bin kernel.bin
	cat $^ > os-image.bin

# '--oformat binary' deletes all symbols as a collateral, so we don't need
# to 'strip' them manually on this case
kernel.bin: boot/kernel_entry.o ${OBJ}
	x86_64-elf-ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

# Used for debugging purposes
kernel.elf: boot/kernel_entry.o ${OBJ}
	x86_64-elf-ld -m elf_i386 -o $@ -Ttext 0x1000 $^ 

run: os-image.bin
	qemu-system-i386 -fda os-image.bin

# Open the connection to qemu and load our kernel-object file with symbols
# 打开qemu 并且加载带符号表的内核对象
# -S 表示guest虚拟机一启动就会暂停
# -s 表示监听tcp:1234端口等待GDB的连接
debug: os-image.bin kernel.elf
	qemu-system-i386 -s -S -fda os-image.bin &
	${GDB} -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"
# 其他参数
# -kernel 后面跟的是要调试的内核bzImage
# -initrd  后面跟的是文件系统
# -append 后面跟的是虚拟机的cmdline
# -nographic  表示启动的是非图形界面的
# -m  为此guest虚拟机预留的内存大小，如果不指定，默认大小是128M
# -smp  表示guest虚拟机的cpu的个数

# Generic rules for wildcards
# To make an object, always compile from its .c
%.o: %.c ${HEADERS}
	${CC} -m32 ${CFLAGS} -ffreestanding -c $< -o $@

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	rm -rf *.bin *.dis *.o os-image.bin *.elf
	rm -rf kernel/*.o boot/*.bin drivers/*.o boot/*.o
