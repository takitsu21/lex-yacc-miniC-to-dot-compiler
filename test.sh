#/bin/sh

make compile
for file in $(ls ./Tests | grep ^.*c$)
do
    echo "TEST : $file"
    # make test C_FILE="Tests/$file"
    ./try < "Tests/$file"
    echo "\n-------------------------------------------------------"
done