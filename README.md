# Calculatrice confidentielle 

## 1. v1 : mot de passe

On demande au user de rentrer un mot de passe. Pour la v1 il n'y a que ça. 
Le mot de passe est "asm42", si le mot de passe entré est bon le programme affiche
"=== Calculatrice ===" et il s'arrête.
Si à 3 tentatives le mot de passe est faux, il se verrouille. Pour les autres version, on ajoutera les calculs.

### 1.1. Pourquoi vérifier la longueur avant de comparer ?

Dans le code, je vérifie la longueur du mot de passe avant comparer parce que déja, si la longueur est différente, 
ça sert à rien de comparer caractère par caractère et on gagne en temps. Et en plus ça évite de
lire trop loin dans le buffer si quelqu'un tape un truc trop long.

### 1.2. Tests
<img width="572" height="360" alt="image" src="https://github.com/user-attachments/assets/0f70b2ea-6204-4e49-a878-44bd74720841" />

## 2. v2 : menu + saisie de 2 nombres

On ajoute un menu avec 5 choix (addition, soustraction, multiplication, division, quitter).
Le programme demande 2 nombres et les affiche (les vrais calculs arrivent aux versions suivantes).

Pour l'instant on gère que les entiers, c'est plus simple. Les flottants viendront plus tard avec les registres XMM et les instructions SSE2.

### 2.1. read_line : lire une ligne caractère par caractère

Je lis la saisie un byte à la fois avec `syscall read` au lieu d'utiliser `fgets` ou autre.
Pourquoi ? Parce qu'en assembleur on a rien de tout prêt, il faut tout faire soi-même.
Je stocke chaque caractère dans un buffer jusqu'au `\n` (newline), je remplace le `\n` par `\0` (null terminator), et je retourne la longueur dans `rax`.

https://stackoverflow.com/questions/8194141/how-to-read-a-line-from-stdin-in-assembly

J'utilise R8 comme compteur de boucle. Pourquoi pas RCX ? Parce que `syscall` écrase RCX (et R11). Si j'utilisais RCX, la valeur serait perdue à chaque appel système.

### 2.2. atoi (lire_entier)

Je convertis la chaîne en entier : je boucle sur chaque caractère, je soustrais '0', et je construis le nombre avec `imul rax, 10` + `add`. Si le premier caractère est '-', je mets un flag et à la fin je fais `neg rax`.

https://stackoverflow.com/questions/19309749/nasm-assembly-convert-input-to-integer

Gestion d'erreur : si un caractère n'est pas un chiffre, ça affiche "Saisie invalide." et on recommence.

### 2.3. itoa (afficher_entier)

Je divise le nombre par 10 en boucle, je récupère le reste (chiffre) avec `div rbx`, j'empile les chiffres, puis je dépile pour écrire dans le buffer. Comme ça les chiffres sont dans le bon ordre.

https://stackoverflow.com/questions/13166064/how-do-i-print-an-integer-in-assembly-level-programming-without-printf-from-the

Pour les nombres négatifs, j'écris un '-' au début et je rends le nombre positif avant la boucle.

### 2.4. Pourquoi default rel ?

NASM affichait un warning : "indirect address displacements cannot be RIP-relative" sur les lignes avec `lea rsi, [rel buf + r8]`. En mettant `default rel` en haut du fichier et en écrivant `lea rsi, [r8 + buf]`, le warning disparaît.

### 2.5. Pourquoi R8 et pas RCX dans read_line ?

`syscall` clobbe RCX et R11 (il les utilise pour sauvegarder RIP et RFLAGS). Donc si on se sert de RCX comme compteur, sa valeur est perdue à chaque `syscall`. R8, R9, R10, R12-R15 ne sont pas touchés par `syscall`.

https://stackoverflow.com/questions/55691159/why-argc-is-stored-in-stack-but-not-rdi-register-in-x86-64-on-linux

### 2.6. Tests
<!-- screenshot placeholder v2 -->
