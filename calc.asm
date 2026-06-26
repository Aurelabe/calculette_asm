; calc.asm - Calculatrice confidentielle (v1: mot de passe)
; nasm -f elf64 calc.asm -o calc.o && ld calc.o -o calc
default rel
section .data
    prompt   db 'Code : '
    prompt_l equ $ - prompt
    ok_msg   db '=== Calculatrice ===', 10
    ok_l     equ $ - ok_msg
    fail1    db 'Code incorrect. Plus que '
    fail1_l  equ $ - fail1
    fail2    db ' tentatives.', 10
    fail2_l  equ $ - fail2
    block    db 'Programme verrouille.', 10
    block_l  equ $ - block
    secret   db 'asm42'             ; mot de passe secret
section .bss
    input    resb 64                ; buffer pour la saisie
section .text
    global _start

_start:
    mov rcx, 3                      ; 3 tentatives max
.debut:
    push rcx
    ; --- afficher le prompt et lire la saisie ---
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_l
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 64
    syscall
    dec rax
    mov rdx, rax
    cmp rdx, 5
    jne .erreur
    ; --- verifier le mot de passe ---
    mov rsi, secret
    mov rdi, input
    mov rcx, 5
.comparer:
    mov al, [rsi]
    mov bl, [rdi]
    cmp al, bl
    jne .erreur
    inc rsi
    inc rdi
    dec rcx
    jnz .comparer
    pop rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, ok_msg
    mov rdx, ok_l
    syscall
    jmp fin
.erreur:
    pop rcx
    dec rcx
    jz .bloque
    push rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, fail1
    mov rdx, fail1_l
    syscall
    pop rcx
    push rcx
    add rcx, '0'
    mov [input], cl
    mov byte [input+1], 0
    mov rax, 1
    mov rdi, 1
    mov rsi, input
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, fail2
    mov rdx, fail2_l
    syscall
    pop rcx
    jmp .debut
.bloque:
    mov rax, 1
    mov rdi, 1
    mov rsi, block
    mov rdx, block_l
    syscall
fin:
    mov rax, 60
    xor rdi, rdi
    syscall
