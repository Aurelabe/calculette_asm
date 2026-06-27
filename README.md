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
Le programme demande 2 nombres et les affiche (les vrais calculs arrivent dans les versions suivantes).

Pour l'instant on gère que les entiers, c'est plus simple. Les flottants viendront plus tard avec les registres XMM et les instructions SSE2.

### 2.1. Pourquoi R8 et pas RCX dans read_line ?

`syscall` utilise RCX et R11 pour sauvegarder RIP et RFLAGS, donc si on se sert de RCX comme compteur, sa valeur est perdue à chaque `syscall` alors que R8, R9, R10, R12-R15 ne sont pas touchés par `syscall`.

### 2.2. Tests

<img width="387" height="607" alt="image" src="https://github.com/user-attachments/assets/dce1f99c-ffa4-4aeb-92c9-c3d75d4f9816" />

## 3. v3 : addition

L'addition prend les 2 nombres entrés, les additionne et affiche le résultat avec `add rax, [nb2]`.
Les autres opérations (soustraction, multiplication, division) arrivent dans les versions suivantes.

### 3.1. Tests

<img width="377" height="622" alt="image" src="https://github.com/user-attachments/assets/1b9b28e1-1b69-4cd3-9c5a-ca569ae2a1f6" />
