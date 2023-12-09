#!/usr/bin/bash

f () {
    directions=$(head -n 1 <<<"$1")

    declare -A map
    while IFS= read -r line
    do
        punctless=$(tr -d '[:punct:]' <<<"$line")

        key=$(cut -d' ' -f1 <<<"$punctless")
        left=$(cut -d' ' -f3 <<<"$punctless")
        right=$(cut -d' ' -f4 <<<"$punctless")

        map[$key]="$left $right"
    done < <(tail -n +3 <<<"$1")

    place=AAA
    steps=0

    while [ ZZZ != "$place" ]
    do
        index=$((steps % ${#directions}))

        direction="${directions:index:1}"
        entry=${map[$place]}
        case $direction in
            L)
                place=$(cut -d' ' -f1 <<<"$entry")
                ;;
            R)
                place=$(cut -d' ' -f2 <<<"$entry")
                ;;
            *)
                return 1
                ;;
        esac
        steps=$((steps + 1))
    done

    echo $steps
}
