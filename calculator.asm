; =============================================================================
; calculator.asm - Simple Integer Calculator
; -----------------------------------------------------------------------------
; A command-line calculator that performs +, -, *, / on two integers.
;
; Target  : x86_64 Linux
; Syntax  : Intel (NASM)
; Syscalls: Linux x86_64 ABI (rax = syscall #, args in rdi, rsi, rdx, ...)
;
; Build & run:
;   nasm -f elf64 calculator.asm -o calculator.o
;   ld   calculator.o -o calculator
;   ./calculator
;
; Sample session:
;   Enter first number:  12
;   Enter second number: 4
;   Enter operator (+,-,*,/): /
;   Result: 3
; =============================================================================

; -----------------------------------------------------------------------------
; .data : initialized, read-only-ish strings shown to the user
; -----------------------------------------------------------------------------
section .data
    msg1        db "Enter first number: ", 0
    msg1_len    equ $ - msg1

    msg2        db "Enter second number: ", 0
    msg2_len    equ $ - msg2

    msg3        db "Enter operator (+,-,*,/): ", 0
    msg3_len    equ $ - msg3

    msg_res     db "Result: ", 0
    msg_res_len equ $ - msg_res

    msg_err     db "Error: division by zero!", 10, 0
    msg_err_len equ $ - msg_err

    msg_bad     db "Error: unknown operator!", 10, 0
    msg_bad_len equ $ - msg_bad

    newline     db 10

; -----------------------------------------------------------------------------
; .bss  : uninitialized buffers used at runtime
; -----------------------------------------------------------------------------
section .bss
    buf     resb 32         ; input buffer for numbers / operator
    outbuf  resb 32         ; output buffer for printing the result

; -----------------------------------------------------------------------------
; .text : program code
; -----------------------------------------------------------------------------
section .text
    global _start

; -----------------------------------------------------------------------------
; _start - program entry point
; -----------------------------------------------------------------------------
_start:
    ; --- Prompt and read first number ---------------------------------------
    mov     rsi, msg1
    mov     rdx, msg1_len
    call    print
    call    read_int            ; result -> rax
    mov     r12, rax            ; save first number in r12

    ; --- Prompt and read second number --------------------------------------
    mov     rsi, msg2
    mov     rdx, msg2_len
    call    print
    call    read_int
    mov     r13, rax            ; save second number in r13

    ; --- Prompt and read operator -------------------------------------------
    mov     rsi, msg3
    mov     rdx, msg3_len
    call    print
    call    read_char           ; result -> al

    ; --- Dispatch on operator ------------------------------------------------
    cmp     al, '+'
    je      do_add
    cmp     al, '-'
    je      do_sub
    cmp     al, '*'
    je      do_mul
    cmp     al, '/'
    je      do_div

    ; Unknown operator -> print error and exit
    mov     rsi, msg_bad
    mov     rdx, msg_bad_len
    call    print
    jmp     exit

; -----------------------------------------------------------------------------
; Arithmetic handlers - each leaves the result in rax, then jumps to print_res
; -----------------------------------------------------------------------------
do_add:
    mov     rax, r12
    add     rax, r13
    jmp     print_res

do_sub:
    mov     rax, r12
    sub     rax, r13
    jmp     print_res

do_mul:
    mov     rax, r12
    imul    rax, r13            ; signed multiplication
    jmp     print_res

do_div:
    ; Guard against division by zero
    cmp     r13, 0
    jne     .ok
    mov     rsi, msg_err
    mov     rdx, msg_err_len
    call    print
    jmp     exit
.ok:
    mov     rax, r12
    cqo                         ; sign-extend rax into rdx:rax
    idiv    r13                 ; signed divide -> quotient in rax
    jmp     print_res

; -----------------------------------------------------------------------------
; print_res - print "Result: <number>\n" then exit
; -----------------------------------------------------------------------------
print_res:
    mov     r14, rax            ; preserve result across the print syscall
    mov     rsi, msg_res
    mov     rdx, msg_res_len
    call    print
    mov     rax, r14
    call    print_int
    jmp     exit

; =============================================================================
; Helper routines
; =============================================================================

; -----------------------------------------------------------------------------
; print - write rdx bytes from rsi to stdout (fd 1)
; -----------------------------------------------------------------------------
print:
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    syscall
    ret

; -----------------------------------------------------------------------------
; read_int - read a line from stdin, parse it as a signed decimal integer.
;            Returns the value in rax. Trailing newline is consumed.
; -----------------------------------------------------------------------------
read_int:
    ; sys_read(0, buf, 32)
    mov     rax, 0
    mov     rdi, 0
    mov     rsi, buf
    mov     rdx, 32
    syscall                     ; rax = number of bytes read

    xor     rcx, rcx            ; index = 0
    xor     rbx, rbx            ; accumulator = 0
    mov     r8,  1              ; sign = +1

    ; Check for leading '-'
    mov     dl, [buf]
    cmp     dl, '-'
    jne     .loop
    mov     r8, -1
    inc     rcx

.loop:
    mov     dl, [buf + rcx]
    cmp     dl, 10              ; newline ends the number
    je      .done
    cmp     dl, 0               ; safety: NUL also ends
    je      .done
    sub     dl, '0'             ; ASCII -> digit
    cmp     dl, 9
    ja      .done               ; non-digit -> stop
    imul    rbx, rbx, 10
    movzx   rdx, dl
    add     rbx, rdx
    inc     rcx
    jmp     .loop

.done:
    mov     rax, rbx
    cmp     r8, 0
    jge     .pos
    neg     rax
.pos:
    ret

; -----------------------------------------------------------------------------
; read_char - read a single non-whitespace character from stdin into al.
; -----------------------------------------------------------------------------
read_char:
    mov     rax, 0
    mov     rdi, 0
    mov     rsi, buf
    mov     rdx, 4
    syscall
    mov     al, [buf]           ; first byte of input
    ret

; -----------------------------------------------------------------------------
; print_int - print the signed integer in rax, followed by a newline.
; -----------------------------------------------------------------------------
print_int:
    mov     rcx, outbuf + 31    ; write digits backwards from end of buffer
    mov     byte [rcx], 10      ; trailing newline
    dec     rcx

    mov     r9, 0               ; negative flag
    cmp     rax, 0
    jge     .conv
    neg     rax
    mov     r9, 1

    ; Special case: value 0 -> print '0'
.conv:
    cmp     rax, 0
    jne     .loop
    mov     byte [rcx], '0'
    dec     rcx
    jmp     .sign

.loop:
    cmp     rax, 0
    je      .sign
    xor     rdx, rdx
    mov     rbx, 10
    div     rbx                 ; rax /= 10, rdx = digit
    add     dl, '0'
    mov     [rcx], dl
    dec     rcx
    jmp     .loop

.sign:
    cmp     r9, 0
    je      .write
    mov     byte [rcx], '-'
    dec     rcx

.write:
    inc     rcx                 ; rcx -> first character to print
    mov     rsi, rcx
    mov     rdx, outbuf + 32
    sub     rdx, rcx            ; length = end - start
    mov     rax, 1              ; sys_write
    mov     rdi, 1
    syscall
    ret

; -----------------------------------------------------------------------------
; exit - clean exit(0) via sys_exit
; -----------------------------------------------------------------------------
exit:
    mov     rax, 60             ; sys_exit
    xor     rdi, rdi            ; status 0
    syscall
