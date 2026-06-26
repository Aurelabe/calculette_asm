# Calculatrice confidentielle — Étape 1 : le mot de passe

## C'est quoi ?

Un programme en assembleur qui demande un mot de passe. Pour l'instant il fait
que ça : tu tapes "asm42", il te dit "=== Calculatrice ===" et il s'arrête.
Tu te trompes 3 fois, il se verrouille. Plus tard on ajoutera les calculs.

## Compiler et tester

```sh
cd /home/kali/calculette
nasm -f elf64 calc.asm -o calc.o
ld calc.o -o calc
```

Ajoute ici la capture d'écran de la compilation :

![capture](screenshot.png)

Tests :

```sh
# Mot de passe correct
echo "asm42" | ./calc

# 3 mauvais mots de passe
printf 'aaa\nbbb\nccc\n' | ./calc
```

## Comment ça marche

### Les variables

- **prompt** : le texte "Code : " qu'on affiche pour demander le mot de passe
- **prompt_l** : la longueur de ce texte (calculée automatiquement avec `$ - prompt`)
- **ok_msg** : "=== Calculatrice ===\n" si le mot de passe est bon
- **fail1 et fail2** : "Code incorrect. Plus que " et " tentatives.\n" pour l'erreur
- **block** : "Programme verrouille.\n" après 3 échecs
- **secret** : le mot de passe "asm42"
- **input** : un buffer de 64 octets où on stocke ce que l'utilisateur tape

J'ai utilisé `equ $ - label` pour les longueurs. Ça permet de pas avoir à
compter les caractères à la main. Si je change le texte, la longueur se met
automatiquement à jour.

### Le déroulement

1. On met `rcx = 3` (le nombre de tentatives)
2. On affiche "Code : " avec `syscall` (write, numéro 1)
3. On lit ce que l'utilisateur tape avec `syscall` (read, numéro 0)
4. On enlève le `\n` de la fin (`dec rax`)
5. On compare la longueur : si c'est pas 5, c'est forcément pas "asm42"
6. On compare caractère par caractère avec une boucle
7. Si tout correspond : message de bienvenue et fin
8. Sinon : on décrémente le compteur, on affiche l'erreur, on recommence
9. Si compteur = 0 : "Programme verrouille."

### Pourquoi 64 bits ?

Le `syscall` c'est l'équivalent 64 bits de `int 0x80`. La différence c'est
que les numéros de syscall sont pas les mêmes (write=1 en 64 bits, write=4
en 32 bits) et les registres changent (rdi/rsi/rdx au lieu de ebx/ecx/edx).
J'ai utilisé la version 64 bits parce que sur un système moderne c'est ce
qu'il faut utiliser :
[https://stackoverflow.com/questions/2535989/what-are-the-calling-conventions-for-unix-linux-system-calls-on-x86-64](https://stackoverflow.com/questions/2535989/what-are-the-calling-conventions-for-unix-linux-system-calls-on-x86-64)

### Pourquoi vérifier la longueur avant de comparer ?

Deux raisons. Déjà, si la longueur est différente, ça sert à rien de
comparer caractère par caractère, on va plus vite. Et en plus ça évite de
lire trop loin dans le buffer si quelqu'un tape un truc trop long. C'est
un petit réflexe de sécurité qu'on prend :
[https://stackoverflow.com/questions/32848990/how-do-i-compare-two-strings-in-assembly-nasm](https://stackoverflow.com/questions/32848990/how-do-i-compare-two-strings-in-assembly-nasm)

### Le default rel

NASM a sorti un warning "implicit DEFAULT ABS is deprecated". J'ai mis
`default rel` en haut pour que les adresses mémoire soient relatives au
compteur de programme (RIP). C'est mieux pour les exécutables modernes :
[https://stackoverflow.com/questions/61240856/what-does-default-rel-do-in-nasm](https://stackoverflow.com/questions/61240856/what-does-default-rel-do-in-nasm)

## Structure du code

Le code est linéaire : pas de fonctions séparées, tout est dans `_start`.
C'est fait exprès pour que ce soit simple à comprendre. Chaque bloc fait
une chose :

1. Configuration (rcx = 3)
2. Affichage du prompt et lecture de la saisie
3. Vérification de la longueur
4. Comparaison caractère par caractère
5. Succès → message de bienvenue
6. Erreur → message d'erreur + compteur
7. Blocage → message de verrouillage

Les `equ` en haut permettent de changer le mot de passe facilement : tu
modifies `secret` et `secret_len`, tout suit.

## Prochaine étape

Là on va passer à la v2 : on va garder le mot de passe, mais au lieu de
finir après "=== Calculatrice ===", on va afficher un menu avec des choix
(addition, soustraction, etc.) et demander des nombres à l'utilisateur.
