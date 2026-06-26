# Calculatrice confidentielle 

## v1 : mot de passe

On demande au user de rentrer un mot de passe. Pour la v1 il n'y a que ça. 
Le mot de passe est "asm42", si le mot de passe entré est bon le programme affiche
"=== Calculatrice ===" et il s'arrête.
Si à 3 tentatives le mot de passe est faux, il se verrouille. Pour les autres version, on ajoutera les calculs.

### Pourquoi vérifier la longueur avant de comparer ?

Dans le code, je vérifie la longueur du mot de passe avant comparer parce que déja, si la longueur est différente, 
ça sert à rien de comparer caractère par caractère et on gagne en temps. Et en plus ça évite de
lire trop loin dans le buffer si quelqu'un tape un truc trop long.

### debug
