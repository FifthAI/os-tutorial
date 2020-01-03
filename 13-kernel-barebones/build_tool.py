#!python3
import lief
import os

# # ELF
# binary = lief.parse("/usr/bin/ls")
# print(binary)

# # PE
# binary = lief.parse("C:\\Windows\\explorer.exe")
# print(binary)

# Mach-O
# binary = lief.parse("/bin/ls")
# print(binary)
print(os.getcwd())
bin: lief.Binary = lief.parse("kernel.bin")
print(bin.format)

print(bin.header)
print(bin.header.entrypoint)
# bin.header.entrypoint = 0x123
# bin.header.machine_type = lief.ELF.ARCH.AARCH64

for sec in bin.sections:
    sec: lief.Section
    print(sec.name)
    print(sec.size)
    print(len(sec.content))

for sym in bin.symbols:
    sym: lief.Symbol
    print(sym.name, sym.size, sym.value)
# print(bin)
