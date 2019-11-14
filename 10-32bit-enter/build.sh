#!bash
nasm -fbin 32bit-main.asm -o 32bit-main.bin

qemu-system-x86_64 32bit-main.bin -curses