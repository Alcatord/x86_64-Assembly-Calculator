# 🧮 x86_64 Assembly Calculator

A tiny **command-line calculator** written in pure **x86_64 Assembly** (NASM, Intel syntax) for **Linux**.  

No dependencies, no libraries — just raw Linux syscalls.  
Perfect for learning **Assembly programming** and **low-level Linux syscalls**.

---

## 🚀 Demo


Enter first number: 12
Enter second number: 4
Enter operator (+,-,*,/): /
Result: 3


Supports addition, subtraction, multiplication, and integer division — even with negative numbers.

---

## ✨ Features

- ➕ Addition  
- ➖ Subtraction  
- ✖️ Multiplication (signed)  
- ➗ Integer division (signed, with divide-by-zero check)  
- Handles negative numbers (e.g., `-8 * 3 → -24`)  
- Zero external dependencies — compiles and runs directly with `NASM + ld`  
- Heavily commented source — great for learning Assembly  

---

## 🛠 Requirements

- Linux on **x86_64** architecture  
- [NASM](https://www.nasm.us/) (e.g., `sudo apt install nasm`)  
- `ld` linker (from `binutils`)  

> macOS or Windows will not work directly — syscall conventions are different.

---

## ⚡ Build & Run

Clone or download the repository, then:


# Assemble and link
nasm -f elf64 calculator.asm -o calculator.o
ld   calculator.o -o calculator

# Run the calculator
./calculator

Or as a one-liner:

nasm -f elf64 calculator.asm -o calculator.o && ld calculator.o -o calculator && ./calculator
💡 Examples
First	Operator	Second	Output
7	+	5	Result: 12
20	-	30	Result: -10
6	*	9	Result: 54
17	/	4	Result: 4 (integer divide)
10	/	0	Error: division by zero!
-8	*	3	Result: -24
🧩 How it Works
.data — prompt strings and error messages
.bss — uninitialized buffers for input parsing and number conversion
.text — entry point _start plus helper routines:
print — writes text to stdout
read_int — reads a signed integer from stdin
read_char — reads a single character (operator)
print_int — prints a signed integer
exit — clean program exit
--- 

The program uses Linux x86_64 syscalls. Signed division uses cqo to extend rax into rdx:rax before idiv.
---
📁 Project Structure
.
├── calculator.asm   # full Assembly source code
└── README.md        # this file
⚠ Troubleshooting
nasm: command not found — install NASM.
ld: cannot find ... — install binutils.
No output / hangs — press Enter after each input; the program reads line-by-line.
Wrong results for huge numbers — inputs must fit in 64-bit signed integers.
📜 License
---
Honestly it's just a cheep calculator toke me 3 hours to make take it if need ;).
---
