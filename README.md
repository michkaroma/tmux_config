# tmux — portage de Hyprland-Michka

Quand je travaille en SSH depuis Windows je n'ai plus Hyprland, et je me suis
donc retrouvé sans aucun de mes raccourcis pour passer d'un terminal à l'autre.
Plutôt que d'apprendre les raccourcis par défaut de tmux, j'ai porté ma config
Hyprland dessus en gardant la même logique de touches.

La transposition tient en trois lignes :

- session tmux = la machine, le bureau
- window tmux = un workspace Hyprland
- pane tmux = une fenêtre Hyprland

## Pourquoi Alt et pas Super

SUPER ne peut pas servir de modificateur en SSH parce que Windows capte la
touche avant que le terminal la voie, elle n'arrive donc jamais jusqu'à tmux.
Alt est la seule touche libre qui passe telle quelle et qui permet de garder des
accords à une seule frappe, sans préfixe, comme dans Hyprland.

Les flèches ont d'abord semblé impossibles à utiliser, pour une raison qui n'a
rien à voir avec tmux : Windows Terminal a ses propres raccourcis Alt+flèches et
Alt+Shift+flèches pour naviguer entre ses panneaux, et il consommait les touches
avant qu'elles partent dans le SSH. Il faut donc les désactiver dans ses
réglages, après quoi tout fonctionne. hjkl reste branché en parallèle, à la fois
par habitude vim et comme repli si une combinaison venait à ne plus passer.

Les workspaces sont sur les touches nues de la rangée des chiffres en AZERTY
(& é " ' ( - è _ ç à) et Shift dessus y déplace le pane courant, ce qui
reproduit Super et Super+Shift de Hyprland. Alt+Shift+touche2 produit exactement
M-2 en AZERTY, les deux couches ne se croisent donc pas.

## Installation

tmux tourne côté serveur, pas côté Windows, c'est donc là qu'il faut
l'installer :

```bash
sudo pacman -S tmux     # Arch
sudo apt install tmux   # Debian, Ubuntu
sudo dnf install tmux   # Fedora
```

La config vise tmux 3.0 ou plus récent. Les options `display-popup`,
`pane-border-lines` et `allow-passthrough` demandent 3.2 voire 3.3 et sont
volontairement écartées, pour que le fichier charge sans erreur sur les serveurs
qui traînent une version plus ancienne.

Avec stow, depuis la racine du repo :

```bash
stow tmux
```

Cela pose deux fichiers : `~/.tmux.conf` et `~/.config/tmux/move-pane.sh`. Le
script est une dépendance des raccourcis Alt+chiffre, il ne faut donc pas
copier la config seule. Puis `tmux` pour lancer une session, et `tmux a` pour
rattacher la précédente.

## Raccourcis

| Hyprland | tmux | Action |
| --- | --- | --- |
| `Super+flèches` | `Alt+flèches` ou `Alt+h/j/k/l` | changer de pane |
| `Super+Shift+flèches` | `Alt+Shift+flèches` ou `Alt+H/J/K/L` | déplacer le pane, le focus suit |
| `Super+Ctrl+flèches` | `Ctrl+Alt+flèches` | redimensionner |
| `Super+Q` | `Alt+Q` | nouveau pane, split façon dwindle, même dossier |
| `Super+C` | `Alt+C` | fermer le pane |
| `Super+F` | `Alt+F` | zoom plein écran |
| `Super+D` | `Alt+D` | prompt `run:`, lance une commande dans un workspace |
| `Super+R` | `Alt+R` | recharger la config |
| `Super+Shift+M` | `Alt+Shift+M` | tuer la session, avec confirmation |
| `Super+&`, `Super+é`, etc. | `Alt+&`, `Alt+é`, etc. | aller au workspace, le créer au besoin |
| `Super+Shift+&`, etc. | `Alt+1`, `Alt+2`, etc. | y déplacer le pane courant |
| molette | molette sur la barre | workspace précédent/suivant |
| pas d'équivalent | `Alt+T` | nouveau workspace |
| pas d'équivalent | `Alt+S` | mode copie |
| pas d'équivalent | préfixe puis `h/j/k/l` | redimensionner, répétable |
| pas d'équivalent | préfixe puis `|` ou `-` | split en forçant la direction |
| pas d'équivalent | préfixe puis `Tab` | dernier workspace |
| pas d'équivalent | préfixe puis `d` | détacher la session |
| pas d'équivalent | préfixe puis `w` | sélecteur visuel des workspaces |

Le préfixe est `Ctrl+Espace` au lieu du `Ctrl+b` par défaut, parce que `Ctrl+b`
est déjà pris par readline pour reculer d'un caractère.

Le détachement est le seul raccourci qui n'a pas d'équivalent Hyprland et qui
vaut vraiment le coup : les workspaces continuent de tourner côté serveur, et
une coupure SSH ou un reboot de Windows ne fait donc plus perdre le travail en
cours.

## Mode copie

`Alt+S`, ou simplement la molette vers le haut. Ensuite c'est du vim : `h/j/k/l`
pour déplacer le curseur, `w` et `b` par mot, `g` et `G` aux extrémités, `/`
pour chercher avec `n` et `N`. `v` démarre la sélection, `V` prend la ligne,
`Ctrl+v` passe en rectangle, `y` copie et sort, `Échap` ou `q` sort sans copier.

Grâce à `set-clipboard on`, le `y` envoie la sélection jusqu'au presse-papier
Windows via OSC 52, à travers SSH. À la souris, glisser sélectionne et copie,
et `Shift` enfoncé bascule sur la sélection native du terminal, celle qui ignore
tmux.

## Les choix qui ont demandé un réglage

`Alt+Q` coupe le pane actif et pas le workspace, et la direction est décidée à
l'exécution en comparant la largeur à trois fois la hauteur. Le facteur vient de
ce qu'une cellule de terminal fait environ le double en hauteur qu'en largeur, un
facteur 2 correspond donc au point où le pane est carré à l'écran. Sur mon
écran de 261 colonnes sur 60 lignes le facteur 2 donnait deux colonnes d'affilée
avant d'empiler, parce que 130 dépasse 120 de dix colonnes seulement. Avec 3
l'alternance colonne/empilé est stricte : 130x60, puis 130x29, puis 64x29, puis
64x14. Sur un écran sensiblement plus large il faut donc remonter le facteur.

`Alt+chiffre` applique la même règle quand il déplace un pane vers un autre
workspace, mais mesurée sur le pane qui accueille et non sur celui d'où on part.
`join-pane` impose sinon sa direction par défaut sans jamais regarder la
géométrie de la cible, et le pane arrivait systématiquement empilé. Le calcul ne
tenant pas dans une ligne de config, il vit dans `move-pane.sh`, qui reçoit la
session, le workspace visé et l'identifiant du pane. La session et le pane sont
passés explicitement plutôt que laissés à la déduction de tmux : sans ça, avec
plusieurs sessions ouvertes, le déplacement partait parfois sur le mauvais pane.

`Alt+C` refuse de fermer le dernier pane. Sans ce garde-fou tmux tue la session
entière et renvoie dans bash, où les raccourcis Alt ne répondent évidemment plus
(la première fois ça m'a pris un moment avant de comprendre que le problème
n'était pas la config mais que je n'étais simplement plus dans tmux).

Les workspaces se créent à la demande, comme dans Hyprland : `Alt+"` sur un
workspace 3 qui n'existe pas encore le crée au lieu de renvoyer une erreur, ce
qui évite d'avoir à les ouvrir dans l'ordre. `renumber-windows` est pour cette
raison sur `off`, sinon fermer le workspace 3 renumérote le 5 en 2 et les
touches physiques ne pointent plus au bon endroit.

Le redimensionnement de secours est sur le préfixe et pas sur Ctrl+Alt+hjkl,
parce que Ctrl+h vaut 0x08 soit exactement Backspace, et Ctrl+j vaut 0x0A soit
Entrée : tmux ne peut pas les distinguer de ces deux touches.

## À savoir

Les binds Alt masquent des raccourcis readline de bash : `Alt+c`
capitalize-word, `Alt+d` kill-word, `Alt+f` forward-word, `Alt+l` downcase-word,
`Alt+r` revert-line ainsi que `Alt+t` transpose-words. `Alt+b` et
`Alt+Backspace` restent intacts. C'est le prix des accords sans préfixe, et pour
en récupérer un il suffit de commenter la ligne et de déplacer l'action sur le
préfixe.

La barre de statut reprend la palette de ma waybar (noir, blanc gras, accent
rouge) et utilise des icônes Nerd Font, il faut donc une CaskaydiaCove ou une
MesloLGS NF installée côté Windows, sinon elles s'affichent en carrés.

Si `tmux-256color` est absent côté serveur, remplacer par `xterm-256color` dans
la ligne `default-terminal`.

Après avoir modifié la config, `Alt+R` la recharge, mais `source-file` ajoute
sans jamais annuler : un raccourci supprimé du fichier reste actif jusqu'à un
`unbind` explicite ou un `tmux kill-server`.

## Adapter à un autre clavier

Les touches nues de la rangée des chiffres sont la partie la moins portable de
cette config. En QWERTY il suffit de remplacer les dix binds `M-&`, `M-é`, etc.
par `M-1` à `M-0`, et de déplacer le déplacement de pane ailleurs, sur le
préfixe par exemple.

Pour vérifier qu'une touche arrive bien modifiée jusqu'à tmux, `Ctrl+V` puis la
combinaison dans un pane affiche la séquence brute reçue : `^[[1;3D` pour
Alt+Gauche, `^[[1;4D` avec Shift, `^[[1;7D` avec Ctrl. Si seul `^[[D` apparaît,
le modificateur se perd en route et il reste un raccourci à désactiver côté
terminal.
