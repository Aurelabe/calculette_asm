; calc.asm - Calculatrice (v4: + soustraction)
; nasm -f elf64 calc.asm -o calc.o && ld calc.o -o calc
default rel

section .data
    ; --- messages du mot de passe ---
    prompt   db 'Entrez le mot de passe : ', 0
    ok_msg   db '=== Calculatrice ===', 10, 0
    fail1    db 'Mot de passe incorrect. Plus que ', 0
    fail2    db ' tentatives.', 10, 0
    block    db 'Programme verrouillé.', 10, 0
    ; --- menu ---
    menu_txt db 10, 'Menu :', 10
             db '  1. Addition (+)', 10
             db '  2. Soustraction (-)', 10
             db '  3. Multiplication (*)', 10
             db '  4. Division (/)', 10
             db '  5. Quitter', 10
             db 'Choix : ', 0
    prompt_a db 'Premier nombre : ', 0
    prompt_b db 'Deuxieme nombre : ', 0
    res_txt  db 'Resultat : ', 0
    err_inv  db 'Saisie invalide.', 10, 0
    virgule  db ', ', 0
    secret   db 'asm42'             ; mot de passe secret
    secret_len equ 5                ; longueur secret
    max_att  equ 3                  ; tentatives max

section .bss
    buf      resb 64                ; buffer saisie + affichage
    choix    resb 1                 ; choix menu
    nb1      resq 1                 ; 1er nombre
    nb2      resq 1                 ; 2e nombre

section .text
    global _start

; Point d'entrée : vérifie le mot de passe, puis boucle menu + saisie
_start:
    call check_pass
.boucle:
    call afficher_menu
    cmp byte [choix], '5'
    je fin
    call lire_deux_nombres
    jmp .boucle

; Vérification du mot de passe : 3 tentatives, comparaison longueur puis caractères
check_pass:
    mov rcx, max_att
.l:
    push rcx
    mov rsi, prompt
    call print
    call read_line
    cmp rax, secret_len
    jne .e
    mov rsi, buf
    mov rdi, secret
    mov rcx, secret_len
.c:
    mov al, [rsi]
    mov bl, [rdi]
    cmp al, bl
    jne .e
    inc rsi
    inc rdi
    dec rcx
    jnz .c
    pop rcx
    mov rsi, ok_msg
    call print
    ret
.e:
    pop rcx
    dec rcx
    jz .b
    push rcx
    mov rsi, fail1
    call print
    pop rcx
    push rcx
    add rcx, '0'
    mov [buf], cl
    mov byte [buf+1], 0
    mov rsi, buf
    call print
    mov rsi, fail2
    call print
    pop rcx
    jmp .l
.b:
    mov rsi, block
    call print
    mov rax, 60
    xor rdi, rdi
    syscall

; Affiche le menu et lit le choix (1-5), redemande si invalide
afficher_menu:
    mov rsi, menu_txt
    call print
.l:
    call read_line
    cmp rax, 0
    je fin
    cmp rax, 1
    jne .inv
    mov al, [buf]
    cmp al, '1'
    jb .inv
    cmp al, '5'
    ja .inv
    mov [choix], al
    ret
.inv:
    mov rsi, err_inv
    call print
    mov rsi, menu_txt
    call print
    jmp .l

; Demande 2 nombres, effectue l'opération et affiche le résultat
lire_deux_nombres:
    mov rsi, prompt_a
    call lire_entier
    mov [nb1], rax
    mov rsi, prompt_b
    call lire_entier
    mov [nb2], rax
    mov rsi, res_txt
    call print
    cmp byte [choix], '1'
    je .addition
    cmp byte [choix], '2'
    je .soustraction
    mov rax, [nb1]
    call afficher_entier
    mov rsi, virgule
    call print
    mov rax, [nb2]
    call afficher_entier
    jmp .fin
.addition:
    mov rax, [nb1]
    add rax, [nb2]
    call afficher_entier
    jmp .fin
.soustraction:
    mov rax, [nb1]
    sub rax, [nb2]
    call afficher_entier
.fin:
    mov rsi, newline
    call print
    ret

; Convertit une chaîne en entier (atoi), gère le signe - et les erreurs
; RSI = pointeur vers le message à afficher avant la saisie
lire_entier:
    push rbx
    push rcx
    push rsi
    call print
.lire:
    call read_line
    cmp rax, 0
    je .eof
    mov rsi, buf
    xor rax, rax
    xor rcx, rcx
    cmp byte [rsi], '-'
    jne .p
    mov rcx, 1
    inc rsi
.p:
    movzx rdx, byte [rsi]
    cmp rdx, 0
    je .fin
    cmp rdx, '0'
    jb .inv
    cmp rdx, '9'
    ja .inv
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rsi
    jmp .p
.fin:
    cmp rcx, 0
    je .ok
    neg rax
.ok:
    pop rsi
    pop rcx
    pop rbx
    ret
.inv:
    mov rsi, err_inv
    call print
    mov rsi, [rsp]
    call print
    jmp .lire
.eof:
    pop rsi
    pop rcx
    pop rbx
    mov rax, 60
    xor rdi, rdi
    syscall

; Convertit un entier en chaîne (itoa) en empilant/dépilant les chiffres
afficher_entier:
    push rbx
    push rcx
    push rdx
    mov rdi, buf
    xor rcx, rcx
    cmp rax, 0
    jge .pos
    mov byte [rdi], '-'
    inc rdi
    inc rcx
    neg rax
.pos:
    mov rbx, 10
    push 0
.l:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    cmp rax, 0
    jne .l
.w:
    pop rax
    cmp rax, 0
    je .fin
    mov [rdi], al
    inc rdi
    inc rcx
    jmp .w
.fin:
    mov byte [rdi], 0
    mov rsi, buf
    call print
    mov rax, rcx
    pop rdx
    pop rcx
    pop rbx
    ret

; Lit une ligne depuis stdin, caractère par caractère, jusqu'à \n
read_line:
    push r8
    xor r8, r8
.l:
    mov rax, 0
    mov rdi, 0
    lea rsi, [r8 + buf]
    mov rdx, 1
    syscall
    cmp rax, 1
    jne .eof
    cmp byte [buf + r8], 10
    je .fin
    inc r8
    cmp r8, 62
    jb .l
.fin:
    mov byte [buf + r8], 0
    mov rax, r8
    pop r8
    ret
.eof:
    mov byte [buf + r8], 0
    mov rax, r8
    pop r8
    ret

newline db 10, 0

; Affiche une chaîne terminée par 0 via syscall write
print:
    push rdi
    push rdx
    push rsi
    call strlen
    mov rdx, rax
    pop rsi
    mov rax, 1
    mov rdi, 1
    syscall
    pop rdx
    pop rdi
    ret

; Retourne dans rax la longueur d'une chaîne terminée par 0
strlen:
    xor rax, rax
.l:
    cmp byte [rsi + rax], 0
    je .fin
    inc rax
    jmp .l
.fin:
    ret

; Sortie du programme
fin:
    mov rax, 60
    xor rdi, rdi
    syscall
