#!/bin/bash

set -e

usage()
{
cat << EOF

usage: $(basename $0) options

This script runs vimide in a screen environment

OPTIONS:
   -n --name                  name of the screen environment
   -d --dir                   working directory (if none the directory from which $(basename $0) is launched)
   -h --help                  show this help

EOF
}

NAME=
CWD=$(realpath .)
CDIR=$CWD

# getopt
GOTEMP="$(getopt -o "n:d:h" -l "name:,dir:,help"  -n '' -- "$@")"

if ! [ "$(echo -n $GOTEMP |sed -e"s/\-\-.*$//")" ]; then
    usage; exit;
fi

eval set -- "$GOTEMP"


while true ;
do
    case "$1" in
        -n | --name) 
            NAME="$2"
            shift 2;;
        -d | --dir) 
            CWD="$2"
            shift 2;;
        -h | --help)
            echo "on help"
            usage; exit;
            shift;
            break;;
        --) shift ; 
            break ;;
    esac
done

if [[ -z "$NAME" ]]; then
    echo "Must give a name to the session"
    exit 1
fi

cd $CWD

[[ -z "$(screen -ls | grep "$NAME")" ]] && screen -T rxvt-color -dmS $NAME
SCREEN_PID=$(screen -ls| grep $NAME| sed -e"s/\s*\([0-9]\+\)\.$NAME\s*.*/\1/")

winstr="$(screen -S $NAME -Q windows | sed -e"s/\(^\| \)\([0-9]\+\)\s\+\([[:alnum:]]\+\)/\2 \3\n/g")"
ids=($(echo "$winstr" | sed -e's/\s*\([0-9]\+\)[\$]*\s*\s\+\([[:alnum:]]\+\)/\1/'))
windows=($(echo "$winstr" | sed -e's/\s*\([0-9]\+\)[\$]*\s*\s\+\([[:alnum:]]\+\)/\2/'))


[[ ! "$( echo "${ids[@]}" | grep 0)" ]] && screen -S $NAME -X screen
[[ "${windows[0]}" != "code" ]] && screen -S $NAME -p 0 -X title code 

[[ ! "$( echo "${ids[@]}" | grep 1)" ]] && screen -S $NAME -X screen
[[ "${windows[1]}" != "console" ]] && screen -S $NAME -p 1 -X title console 


winstr="$(screen -S $NAME -Q windows | sed -e"s/\(^\| \)\([0-9]\+\)\s\+\([[:alnum:]]\+\)/\2 \3\n/g")"
ids=($(echo "$winstr" | sed -e's/\s*\([0-9]\+\)[\$]*\s*\s\+\([[:alnum:]]\+\)/\1/'))
windows=($(echo "$winstr" | sed -e's/\s*\([0-9]\+\)[\$]*\s*\s\+\([[:alnum:]]\+\)/\2/'))

if [[ -z "$(pstree $SCREEN_PID| grep vim)" ]]; then
    screen -S $NAME -p code -X stuff "vim .\n"
    screen -S $NAME -p code -X stuff ":call RunPyIDE()\n"
    sleep 1
    screen -S $NAME -p code -X stuff ":redraw!\n"
fi

bash -c "
sleep 1
screen -S $NAME -X select code
screen -S $NAME -X split
screen -S $NAME -X focus
screen -S $NAME -X select console
screen -S $NAME -X focus
screen -S $NAME -X resize 25
" &

screen -rdS $NAME

