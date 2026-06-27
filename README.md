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

<img width="425" height="617" alt="image" src="https://github.com/user-attachments/assets/e6e62174-19ca-42b3-b0f7-ddb02c907a4a" />

## 4. v4 : soustraction

La soustraction utilise `sub rax, [nb2]` pour soustraire le deuxième nombre du premier.

### 4.1. Tests

<img width="431" height="617" alt="image" src="https://github.com/user-attachments/assets/ecaecff3-ddc3-41f6-bfac-6c88456cfdcc" />

## 5. v5 : multiplication

La multiplication utilise `imul rax, [nb2]` (multiplication signée).

### 5.1. Tests

<img width="397" height="617" alt="image" src="https://github.com/user-attachments/assets/f84fa921-7ac5-4354-8087-e12afb83895e" />

## 6. v6 : division

La division utilise `cqo` (sign-extension) puis `idiv qword [nb2]` (division signée).
Le résultat est la partie entière du quotient.
Avant de diviser, on vérifie si nb2 vaut 0 avec `cmp qword [nb2], 0` / `je .div_zero`.
Si oui, on affiche "Division par zéro impossible." au lieu de lancer l'instruction `idiv` qui ferait planter le programme (signal SIGFPE).

### 6.1. Pourquoi vérifier la division par zéro ?

`idiv` avec un diviseur à 0 provoque une interruption matérielle (erreur de division) et le système tue le programme. En vérifiant avant, on évite le crash.

### 6.2. Tests

<img width="402" height="631" alt="image" src="https://github.com/user-attachments/assets/063500ff-37a6-4729-a626-d803ed42d344" />

- 20 / 3 → 6 (division entière, pas de virgule)
- 10 / 0 → "Division par zéro impossible."

## 7. v7 : flottants

Maintenant la calculatrice gère les nombres à virgule (double précision, SSE2).
Les fonctions `lire_entier` et `afficher_entier` existent toujours, mais `lire_deux_nombres` utilise les versions flottantes.

### 7.1. lire_float

`lire_float` lit une chaîne, sépare la partie entière et la partie fractionnaire après le '.', et combine les deux en double avec `cvtsi2sd` + `divsd`.

### 7.2. afficher_float

`afficher_float` convertit un double en chaîne : partie entière avec la même technique que `afficher_entier` (divisions par 10), puis partie fractionnaire avec 6 décimales en multipliant par 10 à chaque étape.
Les zéros de fin sont supprimés, sauf si le nombre est un entier (ex: "10" au lieu de "10.000000").

### 7.3. Pourquoi -2.299999 au lieu de -2.3 ?

Certains nombres comme 3.2 ne tombent pas juste en binaire (comme 1/3 = 0.333... en décimal). Le processeur stocke l'approximation la plus proche, et quand on affiche, on voit parfois un tout petit écart.

### 7.4. Tests
<!-- screenshot placeholder v7 -->
