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

## ⚡ Build & Run

Clone or download the repository, then:
## ⚡ Build & Run

Clone or download the repository, then:

```bash
# Assemble the program
nasm -f elf64 calculator.asm -o calculator.o

# Link to create executable
ld calculator.o -o calculator

# Run the calculator
./calculator

