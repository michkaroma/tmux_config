#!/bin/sh
# Déplace le pane $2 vers le workspace $1 en appliquant la règle d'Alt+Q :
# on coupe le plus grand côté du pane qui accueille. Le workspace est créé
# s'il n'existe pas encore.
N="$1"
PANE="$2"

if ! tmux list-windows -F '#{window_index}' | grep -qx "$N"; then
    tmux break-pane -s "$PANE" -t ":$N"
    exit 0
fi

set -- $(tmux display-message -p -t ":$N" "#{pane_width} #{pane_height}")
if [ "$1" -gt "$(( $2 * 3 ))" ]; then
    tmux join-pane -h -s "$PANE" -t ":$N"
else
    tmux join-pane -v -s "$PANE" -t ":$N"
fi