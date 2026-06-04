
# Software Engineering for HPC and AI

Document de révision complet orienté , construit à partir des supports de cours fournis sur l’introduction à l’environnement de développement HPC/AI, le C haute performance, la mémoire, la compilation, le parallélisme, le shell, la gestion de paquets, Git, la construction logicielle, le débogage, les tests et les bases de l’analyse de performance  .

## 1. Vue d’ensemble du module

### 1.1 Ce que couvre la matière
Le cours présente un enchaînement logique : environnement de développement, architecture matérielle, programmation C performante, gestion mémoire, compilation, debugging, testing, profiling et collaboration logicielle  . L’idée centrale est qu’en HPC et en IA, la qualité du logiciel ne se limite pas à « faire marcher le code » : il faut aussi comprendre la machine, écrire du code correct, reproductible, mesurable et performant  .

### 1.2 Logique générale de l’examen
D’après ta description, l’examen porte surtout sur du code C, avec des questions de culture outillage autour de Git, du shell, des fichiers, des matrices et des représentations mémoire comme AoS/SoA. Cette fiche est donc organisée autour de ce qui tombe le plus facilement en exercice : écrire, lire, expliquer, corriger et optimiser un programme C dans un contexte scientifique  .

### 1.3 Philosophie 
il faut maîtriser trois niveaux :
- le niveau **syntaxe** : savoir écrire un code C correct sans hésitation ;
- le niveau **raisonnement** : expliquer pourquoi une solution fonctionne ;
- le niveau **performance / ingénierie** : justifier une structure de données, une stratégie mémoire, un outil Git ou une méthode de test  .

## 2. Introduction HPC et motivation

### 2.1 Pourquoi simuler ?
Le cours prend l’exemple du problème à deux corps, qui possède une solution analytique, puis explique que pour le problème à **n corps** avec trois particules ou plus, il n’existe pas de solution analytique pratique pour un usage courant  . C’est précisément là que la simulation numérique devient indispensable : le calcul remplace la solution fermée.

### 2.2 Exemple n-body
Le support montre une version naïve d’un calcul gravitationnel en C : pour chaque particule, on parcourt toutes les autres afin de calculer les accélérations, puis on met à jour les vitesses et positions avec un pas de temps `dt`  . Cet algorithme est simple à écrire mais coûteux, car sa complexité est de l’ordre de \(O(n^2)\) quand chaque particule interagit avec toutes les autres  .

Exemple simplifié :
```c
for (int i = 0; i < n; i++) {
    double ax = 0.0;
    for (int j = 0; j < n; j++) {
        if (i == j) continue;
        // contribution de j sur i
    }
    p[i].ax = ax;
}
```

### 2.3 Pourquoi le HPC ?
Le cours rappelle que de très grandes machines comme Fugaku atteignent des performances immenses, notamment sur ce type de calcul, grâce à plusieurs leviers combinés : amélioration algorithmique, parallélisation, vectorisation et optimisation de la localité mémoire  . Il faut donc retenir qu’en HPC, la performance vient rarement d’une seule idée ; elle vient presque toujours d’un **empilement** d’optimisations cohérentes  .

## 3. Architecture machine et performance

### 3.1 CPU, ISA et registres
Un cœur CPU exécute des instructions définies par un **jeu d’instructions** (ISA), et son état repose notamment sur les registres, le compteur ordinal et les drapeaux  . L’assembleur est la représentation bas niveau de ces instructions, et le compilateur traduit le C vers cette ISA  .

À retenir :
- les registres sont le stockage le plus rapide ;
- la mémoire principale est beaucoup plus lente ;
- plus une donnée reste “près” du CPU, mieux c’est pour la performance  .

### 3.2 Pipeline
Le cours présente le pipeline classique en 5 étapes : **Fetch → Decode → Execute → Memory → Write-back**  . Le pipeline augmente le débit d’instructions, mais il peut être perturbé par :
- des dépendances de données ;
- des branchements mal prédits ;
- des conflits de ressources  .

Explication simple : même si le CPU est rapide, il perd du temps si une instruction attend une valeur non encore calculée, ou si un accès mémoire prend trop longtemps.

### 3.3 Hiérarchie mémoire
Le cours insiste sur la hiérarchie : registres → cache L1/L2/L3 → DRAM → stockage persistant  . Les notions à connaître absolument sont :
- **localité temporelle** : on réutilise bientôt une donnée déjà utilisée ;
- **localité spatiale** : on accède à des données proches en mémoire  .

Conséquence d’examen : un parcours mémoire contigu sera souvent plus rapide qu’un parcours avec grands sauts d’adresses.

### 3.4 NUMA, cohérence, bande passante
Le cours mentionne que les accès mémoire inter-socket sont plus coûteux, que la cohérence des caches a un coût, et que la bande passante mémoire limite souvent le passage à l’échelle  . Même si l’examen ne te demande pas de détailler NUMA, tu dois savoir dire que toutes les mémoires ne coûtent pas pareil en temps d’accès.

### 3.5 Interconnexions et stockage
En HPC, le réseau entre nœuds se juge surtout par sa **latence** et sa **bande passante**, et les systèmes de fichiers parallèles servent à l’I/O massif  . Un code très rapide en calcul peut malgré tout devenir lent s’il écrit trop souvent ou mal ses données sur disque  .

## 4. Bases du C

### 4.1 Pourquoi le C en HPC ?
Le cours explique que les couches logicielles proches du matériel sont plus difficiles à programmer, mais qu’elles offrent davantage de contrôle et de performance  . En pratique, le C est utilisé pour les sections critiques en performance, souvent combiné avec des langages plus haut niveau comme Python pour l’orchestration  .

### 4.2 Structure minimale d’un programme
```c
#include <stdio.h>

int main(void) {
    printf("Bonjour\n");
    return 0;
}
```
À connaître :
- `main` est le point d’entrée du programme   ;
- `#include <stdio.h>` permet d’utiliser `printf`   ;
- `return 0;` signale une fin normale.

### 4.3 Types fondamentaux
Le cours présente des types comme `int`, `float`, `double`, `char` et des variantes signées/non signées  . Il faut savoir choisir un type selon :
- la nature de la donnée ;
- la précision nécessaire ;
- la taille mémoire ;
- le risque de dépassement.

Exemple :
```c
int a = 5;
double x = 3.14;
char c = 'A';
unsigned int n = 10;
```

### 4.4 Opérations et affectations
Le C est un langage impératif fortement typé, et le cours montre des affectations simples et des expressions arithmétiques  . Il faut être à l’aise avec `+`, `-`, `*`, `/`, `%`, les comparaisons et les opérateurs logiques.

Exemple :
```c
int a = 5;
int b = 10;
int c = a + b;
```

### 4.5 Conditions
Exemple type :
```c
if (x > 0) {
    printf("positif\n");
} else if (x < 0) {
    printf("negatif\n");
} else {
    printf("nul\n");
}
```
Les conditions tombent souvent dans des exercices simples de filtrage, de comptage ou de contrôle de flux.

### 4.6 Boucles
Le support utilise surtout `for`, par exemple pour sommer une plage entière ou compter des multiples de 3  . Les trois formes à maîtriser sont `for`, `while` et `do ... while`.

Exemple :
```c
int sum = 0;
for (int i = 1; i <= 100; i++) {
    sum += i;
}
```

### 4.7 Fonctions
Le cours montre des fonctions avec paramètres et valeur de retour  . Une fonction sert à factoriser du code, clarifier l’intention et éviter les répétitions.

Exemple :
```c
int square(int x) {
    return x * x;
}
```

Points d’attention :
- déclarer le bon type de retour ;
- respecter les types des paramètres ;
- ne pas oublier `return` si la fonction n’est pas `void`.

## 5. Pointeurs et adressage

### 5.1 Définition
Le support présente explicitement l’idée qu’un pointeur contient une **adresse mémoire**  . C’est l’un des concepts centraux du C.

Exemple :
```c
int a = 5;
int *p = &a;
printf("%d\n", *p);
```

À retenir :
- `&a` donne l’adresse de `a` ;
- `p` stocke cette adresse ;
- `*p` accède à la valeur pointée.

### 5.2 Pointeurs et fonctions
Si une fonction doit modifier une variable du programme appelant, il faut généralement passer son adresse.

Exemple :
```c
void increment(int *x) {
    (*x)++;
}
```

### 5.3 Pièges classiques
- utiliser un pointeur non initialisé ;
- déréférencer `NULL` ;
- confondre adresse et valeur ;
- faire un `free` invalide  .

## 6. Tableaux

### 6.1 Tableaux statiques
Le cours montre des tableaux comme des zones contiguës de mémoire  .

Exemple :
```c
int t[5] = {1, 2, 3, 4, 5};
printf("%d\n", t[2]);
```

### 6.2 Tableaux et pointeurs
Le nom du tableau peut être utilisé comme adresse du premier élément dans beaucoup de contextes. C’est pourquoi `t[i]` et `*(t + i)` sont liés conceptuellement.

Exemple :
```c
printf("%d\n", *(t + 2));
```

### 6.3 Parcours correct
```c
for (int i = 0; i < 5; i++) {
    printf("%d\n", t[i]);
}
```
Erreur fréquente : aller jusqu’à `i <= 5`, ce qui déborde le tableau.

## 7. Structures

### 7.1 Définition
Le cours présente les structures comme des types composites définis par l’utilisateur  . Elles servent à regrouper plusieurs champs liés.

Exemple :
```c
typedef struct {
    char firstname[32];
    char lastname[32];
    int age;
    float mean_grade;
} Student;
```

### 7.2 Accès aux champs
- avec une variable : `s.age`
- avec un pointeur : `p->age`

Exemple :
```c
Student s;
s.age = 22;
```

### 7.3 Intérêt en calcul scientifique
Une structure est très utile pour représenter une entité complexe : particule, point 3D, étudiant, nœud de liste chaînée, etc. C’est un thème qui mène directement au couple AoS / SoA vu dans le cours  .

## 8. Matrices et tableaux 2D

### 8.1 Matrice statique
```c
int M[3][4];
M[1][2] = 7;
```
Une matrice en C est souvent stockée en mémoire par lignes (**row-major**), ce qui influence la performance des parcours  .

### 8.2 Parcours d’une matrice
```c
for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
        sum += M[i][j];
    }
}
```
Le parcours par lignes est généralement plus naturel et meilleur pour la localité mémoire dans le modèle de stockage du C.

### 8.3 Allocation dynamique d’une matrice
Deux grandes approches :

#### Approche 1 : tableau de pointeurs
```c
double **A = malloc(n * sizeof(double *));
for (int i = 0; i < n; i++) {
    A[i] = malloc(m * sizeof(double));
}
```

#### Approche 2 : bloc contigu
```c
double *A = malloc(n * m * sizeof(double));
A[i * m + j] = 1.0;
```

Pour les performances, la version en bloc contigu est souvent préférable car elle améliore la localité et simplifie certains parcours.

### 8.4 Exercices classiques sur matrices
Les sujets typiques sont :
- somme de tous les éléments ;
- somme d’une ligne ou d’une colonne ;
- maximum / minimum ;
- transposition ;
- produit matrice-vecteur ;
- produit matrice-matrice.

### 8.5 Exemple : somme d’une ligne
```c
int somme_ligne(int M[][4], int ligne) {
    int s = 0;
    for (int j = 0; j < 4; j++) {
        s += M[ligne][j];
    }
    return s;
}
```

### 8.6 Exemple : multiplication naïve
```c
for (int i = 0; i < n; i++) {
    for (int j = 0; j < p; j++) {
        C[i][j] = 0;
        for (int k = 0; k < m; k++) {
            C[i][j] += A[i][k] * B[k][j];
        }
    }
}
```
Ce code est correct fonctionnellement, mais peut être mauvais en cache selon la façon dont `B` est parcourue.

## 9. Gestion mémoire

### 9.1 Stack vs heap
Le cours distingue clairement :
- la **stack** : mémoire automatique allouée par le compilateur pour les variables locales et arguments ;
- le **heap** : mémoire dynamique gérée manuellement par le programmeur  .

La stack est rapide mais limitée ; le heap est plus flexible mais demande `malloc` / `free`  .

### 9.2 Allocation dynamique
```c
float *numbers = malloc(n * sizeof(float));
if (numbers == NULL) {
    return 1;
}
```
Le support montre ce schéma classique et rappelle qu’après usage, il faut libérer la mémoire  .

### 9.3 Libération
```c
free(numbers);
```
Le cours insiste sur le fait qu’oublier `free` crée une fuite mémoire, et qu’une accumulation de fuites peut faire échouer un programme ou le système  .

### 9.4 Fuites mémoire et erreurs graves
À connaître :
- **memory leak** : mémoire allouée mais jamais libérée   ;
- **use-after-free** : accès à une zone déjà libérée   ;
- lecture/écriture hors bornes ;
- pointeur sauvage.

### 9.5 Mémoire virtuelle
Le cours explique la séparation entre adresses virtuelles et physiques, les pages mémoire, la MMU et les tables de pages  . Pour l’examen, retiens surtout qu’un programme croit voir un grand espace mémoire continu, alors que le système traduit cela en pages physiques isolées  .

## 10. AoS et SoA

### 10.1 Définition de AoS
**AoS** signifie *Array of Structures* : un tableau d’objets complets  .

Exemple :
```c
typedef struct {
    float x, y, z;
} Particle;

Particle *p = malloc(n * sizeof(Particle));
```

### 10.2 Définition de SoA
**SoA** signifie *Structure of Arrays* : chaque champ est stocké dans un tableau séparé  .

Exemple :
```c
float *x = malloc(n * sizeof(float));
float *y = malloc(n * sizeof(float));
float *z = malloc(n * sizeof(float));
```

### 10.3 Pourquoi le cours en parle
Le support compare explicitement AoS et SoA sur un traitement où l’on veut seulement lire une coordonnée `x` de nombreuses particules  . Dans ce cas, SoA est souvent plus efficace car il charge uniquement les données utiles.

### 10.4 Interprétation performance
Le cours donne un exemple de comptage de particules vérifiant `x < 0.5` et montre que SoA réduit les défauts de cache par rapport à AoS  . L’idée fondamentale est la suivante :
- AoS est pratique pour manipuler un objet complet ;
- SoA est souvent meilleur pour des calculs vectoriels ou des scans massifs sur un seul attribut  .

### 10.5 Formulation d’examen attendue
Si la question est : « quelle représentation est meilleure pour traiter `x` sur toutes les particules ? », la bonne explication est : **SoA**, car les accès sont contigus sur `x`, avec une meilleure localité et souvent une meilleure vectorisation  .

### 10.6 Exemple comparatif
```c
// AoS
for (int i = 0; i < n; i++) {
    if (p[i].x > 0.5f) count++;
}

// SoA
for (int i = 0; i < n; i++) {
    if (x[i] > 0.5f) count++;
}
```

## 11. Fichiers en C

### 11.1 Ouverture de fichier
Le cours mentionne les exercices sur les fichiers ; en C, on utilise `FILE *` et `fopen`.

Exemple :
```c
FILE *f = fopen("data.txt", "r");
if (f == NULL) {
    perror("fopen");
    return 1;
}
```

### 11.2 Modes d’ouverture
À connaître absolument :
- `"r"` : lecture ;
- `"w"` : écriture en écrasant ;
- `"a"` : écriture en ajout ;
- `"rb"`, `"wb"` : versions binaires selon le contexte.

### 11.3 Fermeture
```c
fclose(f);
```
Toujours fermer le fichier après usage.

### 11.4 Lecture texte
```c
char buffer[256];
while (fgets(buffer, sizeof(buffer), f) != NULL) {
    printf("%s", buffer);
}
```

### 11.5 Écriture texte
```c
FILE *f = fopen("out.txt", "w");
fprintf(f, "resultat = %d\n", 42);
fclose(f);
```

### 11.6 Lecture/écriture binaire
```c
fread(&x, sizeof(double), 1, f);
fwrite(&x, sizeof(double), 1, f);
```

### 11.7 Exercices classiques
- compter les lignes d’un fichier ;
- copier un fichier ;
- lire une liste d’entiers et calculer leur somme ;
- enregistrer une matrice dans un fichier texte ;
- recharger des données dans un tableau.

### 11.8 Pièges classiques
- ne pas vérifier `f == NULL` ;
- oublier `fclose` ;
- lire avec un mauvais format ;
- supposer que le fichier contient des données valides.

## 12. Compilation et assembleur

### 12.1 Langage compilé
Le cours rappelle que le C est compilé, contrairement à Python qui est interprété, et que cette proximité avec le matériel explique une grande partie de ses performances  .

### 12.2 Chaîne de compilation
Commande simple :
```bash
gcc main.c -o main
```
Le compilateur peut produire du code assembleur dépendant de l’architecture  .

### 12.3 Options importantes
Le cours mentionne notamment :
- `-O1`, `-O2`, `-O3` pour activer des optimisations   ;
- `-march=native` pour cibler la machine locale   ;
- `-g` pour le debug  .

Exemple :
```bash
gcc -O3 -march=native -g main.c -o main
```

### 12.4 Idée clé sur le compilateur
Le compilateur n’est pas qu’un traducteur : il effectue aussi des optimisations comme la propagation de constantes, l’élimination de code mort, l’inlining et parfois la vectorisation  . C’est une phrase importante à connaître pour les questions théoriques.

## 13. Makefiles

### 13.1 Pourquoi utiliser make ?
Le cours explique que `make` automatise la compilation et évite de tout recompiler à chaque changement  . Il s’appuie sur les dépendances et les timestamps  .

### 13.2 Structure d’une règle
```make
prog: main.o lib.o
	gcc -o prog main.o lib.o -lm
```
- `prog` : la cible ;
- `main.o lib.o` : les dépendances ;
- la ligne tabulée : la recette.

### 13.3 Compilation séparée
Le support insiste sur le découpage source → objets → exécutable  . C’est fondamental à comprendre.

Exemple :
```make
main.o: main.c lib.h
	gcc -c main.c -o main.o

lib.o: lib.c lib.h
	gcc -c lib.c -o lib.o
```

### 13.4 Cibles phony
Le cours présente `.PHONY` pour des règles qui ne produisent pas de fichier, comme `clean`  .

Exemple :
```make
.PHONY: clean
clean:
	rm -f *.o prog
```

### 13.5 Variables Makefile
```make
CC = gcc
CFLAGS = -O2 -g
```
Le cours montre que cela permet de rendre le Makefile plus modulaire et plus maintenable  .

## 14. CMake

### 14.1 Pourquoi CMake ?
Le cours présente CMake comme un méta-système de build capable de générer différents systèmes de construction comme Make ou Ninja, avec un meilleur support multiplateforme  .

### 14.2 Structure minimale
```cmake
cmake_minimum_required(VERSION 3.15)
project(MyProject LANGUAGES C)
add_executable(prog main.c)
```

### 14.3 Notions importantes
À connaître :
- `target_link_libraries` ;
- `target_include_directories` ;
- différence Debug / Release ;
- builds hors répertoire source (*out-of-source*)  .

### 14.4 Exemples de builds
Le cours indique :
```bash
cmake -B build
cmake --build build
```
C’est la séquence standard à mémoriser  .

## 15. Shell et scripting

### 15.1 Définition
Le shell est l’interface en ligne de commande permettant d’exécuter des programmes, manipuler des fichiers et automatiser des tâches  . C’est un outil central en HPC  .

### 15.2 Commandes de base
Le cours liste : `ls`, `cd`, `pwd`, `mkdir`, `rm`, `cat`, `less`, `head`, `tail`  .

Exemples :
```bash
ls
pwd
cd src
mkdir results
```

### 15.3 Redirections
Le support explique :
- `<` pour rediriger l’entrée ;
- `>` pour écrire en écrasant ;
- `>>` pour ajouter à la fin  .

Exemple :
```bash
grep "error" log.txt >> errors.txt
```

### 15.4 Pipes
Le cours donne l’idée qu’un pipe `|` connecte la sortie d’une commande à l’entrée d’une autre  .

Exemples :
```bash
ls | grep ".txt"
cat file.txt | wc -l
```

### 15.5 Variables shell
Exemple du cours :
```bash
NODES=4
PROGRAM="my_hpc_program"
echo "Running $PROGRAM on $NODES MPI nodes..."
mpirun -np $NODES ./$PROGRAM
```
Ce point est très classique en question de compréhension de script  .

### 15.6 Script shell simple
```bash
#!/bin/bash
echo "Hello, World!"
```
Puis :
```bash
chmod +x script.sh
./script.sh
```
Le support rappelle explicitement cette séquence  .

### 15.7 Conditions et boucles
Condition :
```bash
if [ -f "config.json" ]; then
    echo "exists"
else
    echo "missing"
fi
```
Boucle :
```bash
for i in {1..5}; do
    echo "$i"
done
```
Le cours montre ces constructions comme base de l’automatisation  .

### 15.8 Fonctions shell
```bash
run_simulation() {
    echo "Config: $1"
    mpirun -np $2 ./simulation_program --config=$1
}
```

### 15.9 Bonnes pratiques shell
Le support cite notamment :
- `bash -x script.sh` pour tracer l’exécution ;
- `set -e` pour arrêter au premier échec ;
- écrire des fonctions réutilisables ;
- tester d’abord sur petits cas  .

## 16. Gestion de paquets et environnements

### 16.1 Pourquoi un gestionnaire de paquets ?
Le cours explique que les gestionnaires de paquets servent à installer, mettre à jour et gérer les dépendances logicielles  . Ils contribuent aussi à la compatibilité et à la reproductibilité  .

### 16.2 Outils généraux
Exemples donnés : `apt` pour Debian/Ubuntu, `dnf` pour Fedora/RHEL  .

### 16.3 Outils HPC
Le support cite `spack` et `guix` comme outils particulièrement utiles en environnement HPC, notamment quand l’utilisateur n’a pas les droits administrateur  .

### 16.4 Gestionnaires spécifiques et conteneurs
Le cours mentionne aussi `pip`, `cargo`, ainsi que les conteneurs comme Docker ou Singularity pour encapsuler l’environnement logiciel et améliorer la portabilité  .

## 17. Git — concepts fondamentaux

### 17.1 Qu’est-ce que le version control ?
Le support définit le version control comme le suivi et la gestion des modifications d’un projet, chaque version étant liée à une date, un auteur et un message  . En pratique, cela permet de revenir en arrière, de collaborer et d’isoler des développements  .

### 17.2 Objectifs de Git
Le cours liste plusieurs objectifs :
- améliorer la communication entre développeurs ;
- isoler les développements expérimentaux ;
- garantir une base stable ;
- gérer les releases via des tags  .

### 17.3 Vocabulaire indispensable
À savoir définir :
- **version** ;
- **commit** ;
- **branch** ;
- **tag** ;
- **diff / patch** ;
- **conflict**  .

### 17.4 Vocabulaire de stockage
Le cours distingue :
- **repository** ;
- **clone** ;
- **working copy / working directory** ;
- **index / staging area** ;
- **remote**  .

### 17.5 Git est distribué
Le support rappelle que Git est un DVCS : plusieurs dépôts peuvent exister, le travail peut se faire localement et même sans réseau  . C’est une idée théorique très importante.

## 18. Git — fonctionnement interne

### 18.1 Historique rapide
Le cours indique que Git a été créé en 2005 pour le noyau Linux, en remplacement de BitKeeper  .

### 18.2 Snapshots et non simple suite de diff
Le point central du cours est que Git stocke des **snapshots** de la hiérarchie de fichiers, et non seulement des différences comme d’autres systèmes  . C’est une phrase à absolument retenir telle quelle.

### 18.3 Objets Git
Le support présente :
- **blob** : contenu fichier ;
- **tree** : structure de répertoire ;
- **commit** : snapshot + métadonnées ;
- **tag** : étiquette vers un commit  .

### 18.4 Hash SHA1
Chaque objet Git est identifié par un hash SHA1, et le même contenu aura le même hash même dans des dépôts différents  . L’idée à retenir est : Git identifie et compare le contenu via des hash.

### 18.5 Répertoire `.git`
Le cours montre que `.git` contient notamment `HEAD`, `config`, `hooks`, `index`, `logs`, `objects`, `refs`  . Même si on ne te demande pas de réciter tout cela, il faut savoir que l’historique n’est pas dans les fichiers visibles du projet mais dans ce répertoire caché  .

## 19. Git — commandes de base

### 19.1 Commandes essentielles
Le cours donne :
```bash
git init
git clone <repository>
git status
git add <file>
git commit
git pull
git push
git log
git checkout <hash>
git branch <branchName>
```
 

### 19.2 Différence fondamentale à savoir expliquer
- `git add` place les modifications dans la zone de staging ;
- `git commit` enregistre ce qui est dans la zone de staging  .

### 19.3 Exemple de séquence typique
```bash
git status
git add main.c
git commit -m "Fix matrix initialization"
git push
```

## 20. Git — branches, merge, conflits

### 20.1 Pourquoi une branche ?
Une branche permet de travailler sur une évolution sans perturber la branche principale  . Elle sert à isoler une fonctionnalité, une correction ou une expérimentation  .

### 20.2 Commandes liées aux branches
```bash
git checkout -b feature
git checkout feature
git merge feature
git branch -d feature
git branch
```
 

### 20.3 Conflits
Le cours détaille les étapes de résolution de conflit : le merge est interrompu, Git marque les zones problématiques, l’utilisateur édite le fichier, valide, puis commit la résolution  .

### 20.4 Commandes de correction
Le support mentionne :
- `git reset` pour annuler ;
- `git commit --amend` pour modifier le dernier commit ;
- `git rebase` pour réécrire l’historique avec prudence  .

### 20.5 Bonnes pratiques collaboratives
Le cours conseille notamment :
- un commit = un changement cohérent ;
- des messages de commit concis ;
- des conventions de nommage ;
- mettre à jour régulièrement sa copie locale  .

## 21. Débogage

### 21.1 Pourquoi debugger ?
Le support présente un exemple de liste chaînée boguée conduisant à un `Segmentation fault`  . En pratique, savoir expliquer une faute mémoire ou une erreur de pointeur est un vrai plus en examen  .

### 21.2 GDB
Le cours décrit GDB comme un outil pour :
- inspecter l’état du programme au crash ;
- exécuter pas à pas ;
- inspecter mémoire et variables ;
- poser des points d’arrêt  .

Commande typique :
```bash
gdb ./buggy
```

### 21.3 Valgrind
Le support indique que Valgrind détecte :
- fuites mémoire ;
- accès mémoire invalides ;
- usage de mémoire non initialisée  .

Commande type :
```bash
valgrind --leak-check=full ./buggy
```

### 21.4 ASAN / UBSAN
Le cours cite AddressSanitizer et UndefinedBehaviorSanitizer comme outils modernes à plus faible surcoût que Valgrind sur certains cas, et capables de détecter respectivement des erreurs mémoire et des comportements indéfinis  .

Compilation type :
```bash
gcc -fsanitize=address -g -O0 buggy.c -o buggy_asan
```

## 22. Tests logiciels

### 22.1 Pourquoi tester ?
Le cours rappelle plusieurs catastrophes logicielles historiques pour montrer que les bugs peuvent avoir un coût énorme, financier ou humain  . Le message à retenir est que tester n’est pas un luxe ; c’est une exigence d’ingénierie  .

### 22.2 Vérification et validation
Le support distingue :
- **validation** : construit-on le bon produit ? ;
- **vérification** : construit-on correctement le produit ?  .

### 22.3 Types de tests
Le cours présente :
- tests unitaires ;
- tests d’intégration ;
- tests de validation ;
- tests d’acceptation ;
- tests de régression  .

### 22.4 Black-box et white-box
- **Black-box** : tests basés sur les spécifications ;
- **White-box** : tests basés sur la structure du code  .
Les deux approches sont complémentaires  .

### 22.5 Que tester ?
Le support insiste sur les classes d’équivalence, les cas limites, les cas invalides et la couverture des branches  . C’est exactement le type de réponse attendue si on te demande “comment choisir des tests ?”.

## 23. Framework Unity

### 23.1 Rôle
Le cours présente Unity comme un framework léger de tests unitaires pour C  . Il permet d’écrire des fonctions de test et d’utiliser des macros d’assertion  .

### 23.2 Exemples d’assertions
Le support cite des macros comme :
- `TEST_ASSERT_EQUAL_INT`
- `TEST_ASSERT_NOT_NULL`
- `TEST_ASSERT_TRUE`  

### 23.3 Exemple simple
```c
void test_sum(void) {
    TEST_ASSERT_EQUAL_INT(5, sum(2, 3));
}
```

### 23.4 Runner de tests
Le cours montre qu’il faut un exécutable de test avec `UNITY_BEGIN()`, `RUN_TEST(...)` et `UNITY_END()`  .

## 24. Parallélisme de base

### 24.1 Pourquoi paralléliser ?
Le support rappelle qu’un processeur moderne possède plusieurs cœurs, et qu’un seul thread n’exploite pas toute la machine  . En découpant le travail, on peut augmenter le débit de calcul  .

### 24.2 Types de parallélisme
Le cours distingue :
- **SIMD / vectorisation** ;
- **mémoire partagée** (threads) ;
- **mémoire distribuée** (processus)  .

### 24.3 OpenMP
Le support donne l’exemple d’une réduction parallèle :
```c
int sum = 0;
#pragma omp parallel for reduction(+:sum)
for (int i = 0; i < 100; i++) {
    sum += i;
}
```
Cette directive répartit les itérations et combine les sommes partielles de façon sûre  .

### 24.4 Clauses importantes
Le cours explique qu’OpenMP repose sur des clauses comme `parallel`, `for`, `reduction`, `schedule`, `critical`, `nowait`  . Même si l’examen reste simple, savoir expliquer `reduction` est très utile.

## 25. Méthodologie expérimentale et profiling

### 25.1 Mesurer correctement
Le support insiste sur le bruit expérimental : caches froids, fréquence CPU variable, température, ordonnanceur, hétérogénéité matérielle  . Une mesure unique ne suffit donc pas  .

### 25.2 Bonnes pratiques de benchmark
Le cours recommande :
- warm-up ;
- plusieurs répétitions ;
- stabiliser la fréquence CPU ;
- éviter les autres charges ;
- épingler les threads si nécessaire  .

### 25.3 Statistiques utiles
Le support cite :
- moyenne ;
- médiane ;
- variance / écart type ;
- coefficient de variation  .
Il faut savoir expliquer pourquoi une moyenne seule peut être trompeuse.

### 25.4 Profiling
Le cours rappelle la règle d’or : **profile first**  . Avant d’optimiser, il faut identifier les hotspots, comprendre pourquoi ils coûtent cher, puis choisir un objectif : vitesse, énergie, mémoire, etc.  .

### 25.5 Loi d’Amdahl
Le support donne explicitement la loi d’Amdahl pour rappeler qu’optimiser une partie du programme ne change pas magiquement le temps total si le reste reste dominant  . C’est une formule classique à connaître conceptuellement.

## 26. Questions types d’examen et réponses attendues

### 26.1 “Explique la différence entre stack et heap”
Réponse attendue : la stack contient les variables locales et est gérée automatiquement ; le heap contient la mémoire dynamique demandée via `malloc` et qui doit être libérée avec `free`  .

### 26.2 “Explique AoS vs SoA”
Réponse attendue : AoS regroupe tous les champs d’un objet dans une structure répétée, SoA sépare chaque champ dans un tableau ; SoA est souvent meilleur pour le cache et la vectorisation quand on traite un seul champ sur beaucoup d’éléments  .

### 26.3 “À quoi sert git add ?”
Réponse attendue : `git add` place les modifications dans l’index / staging area, c’est-à-dire dans la zone préparée pour le prochain commit  .

### 26.4 “Pourquoi un Makefile ?”
Réponse attendue : pour automatiser la compilation, exprimer les dépendances et ne reconstruire que ce qui doit l’être  .

### 26.5 “Pourquoi tester ?”
Réponse attendue : pour détecter les erreurs, éviter les régressions, valider les spécifications et rendre le logiciel fiable  .

## 27. Pièges fréquents en examen C

### 27.1 Erreurs de bornes
- utiliser `<=` au lieu de `<` dans un tableau ;
- confondre nombre d’éléments et dernier indice.

### 27.2 Erreurs mémoire
- oublier `free` ;
- faire `free` deux fois ;
- utiliser un pointeur après `free` ;
- oublier de tester `malloc == NULL`  .

### 27.3 Erreurs de fichiers
- oublier de vérifier `fopen` ;
- oublier `fclose` ;
- écrire dans un fichier ouvert en lecture.

### 27.4 Erreurs Git conceptuelles
- croire que `git commit` prend automatiquement tous les fichiers modifiés ;
- confondre branche et dépôt ;
- croire qu’un conflit est une erreur “grave” alors que c’est un mécanisme normal de collaboration  .

## 28. Mini check-list de révision finale

### 28.1 À savoir coder sans aide
- boucles `for` / `while` ;
- fonctions simples ;
- tableaux 1D / 2D ;
- structures ;
- `malloc` / `free` ;
- lecture / écriture de fichiers ;
- petit script shell ;
- commandes Git de base.

### 28.2 À savoir expliquer à l’oral ou à l’écrit
- stack vs heap   ;
- AoS vs SoA   ;
- cache et localité   ;
- staging area Git   ;
- pourquoi make / CMake   ;
- pourquoi profiler avant d’optimiser  .

### 28.3 À savoir reconnaître dans un sujet
- une boucle à paralléliser ;
- un tableau mal parcouru ;
- une fuite mémoire ;
- un mauvais schéma d’accès mémoire ;
- un mauvais usage de Git ou des branches.

## 29. Conseils de méthode pour viser 20/20

### 29.1 En code
Toujours écrire une version simple, correcte et propre avant de penser à “optimiser”. En HPC, un code faux mais rapide ne vaut rien  .

### 29.2 En rédaction de réponse
Quand une question théorique tombe, répondre selon ce schéma :
1. définition ;
2. idée centrale ;
3. conséquence pratique ;
4. petit exemple.

### 29.3 En exercice C
Toujours vérifier mentalement :
- types ;
- initialisation ;
- bornes des boucles ;
- cas vide ;
- gestion mémoire ;
- valeurs de retour.

### 29.4 En question performance
Ne jamais dire juste “c’est plus rapide”. Dire **pourquoi** : localité, cache, vecteur, bande passante, moins d’allocations, moins de branches, moins de trafic mémoire  .

## 30. Fiche ultra-courte de dernière minute

- Le C donne du contrôle fin donc de la performance, mais impose une gestion manuelle de nombreux détails  .
- La mémoire est hiérarchique ; la localité est essentielle pour être rapide  .
- `malloc` alloue, `free` libère ; oublier `free` provoque une fuite mémoire  .
- AoS = tableau de structures ; SoA = structure de tableaux ; SoA est souvent meilleur pour traiter un seul champ massivement  .
- Git suit l’historique du projet ; `add` prépare, `commit` enregistre, `push` envoie  .
- Make reconstruit selon les dépendances ; CMake génère un système de build plus moderne et portable  .
- Les tests détectent des bugs et évitent les régressions  .
- Il faut profiler avant d’optimiser  .
- En HPC, performance = algorithmes + mémoire + compilation + parallélisme + mesure rigoureuse  .
