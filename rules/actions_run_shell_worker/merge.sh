#!/bin/sh

# Loop until all parameters are used up
# while [ "$1" != "" ]; do
#     echo "Parameter 1 equals $1"
#     echo "You now have $# positional parameters"

#     # Shift all the parameters down by one
#     shift

# done

#exit

out=$1
shift
cat "$@" > $out
