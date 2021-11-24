#!/usr/bin/fish
find (pwd) -type f  -not -path '*/.*' | sort | xargs -d'\n' -P0 -n1 sha512sum | sort | sha512sum | cut -d " " -f 1