#!/usr/bin/bash

f () {
    directions=$(head -n 1 <<<"$1")

    declare -A map
    declare -a places
    while IFS= read -r line
    do
        punctless=$(tr -d '[:punct:]' <<<"$line")

        key=$(cut -d' ' -f1 <<<"$punctless")
        left=$(cut -d' ' -f3 <<<"$punctless")
        right=$(cut -d' ' -f4 <<<"$punctless")

        map[$key]="$left $right"
        if [ A = "${key:2}" ]
        then
            places+=("$key")
        fi
    done < <(tail -n +3 <<<"$1")

    declare -a periods

    for place in "${places[@]}"
    do
        steps=0

        while [ Z != "${place:2}" ]
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

        periods+=("$steps")
    done

    # I don't even want to try to implement this in bash
    py -c "from math import lcm
print(lcm($(printf '%s,' "${periods[@]}")))"
}
