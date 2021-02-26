#/bin/sh

for file in $(ls ./Tests | grep ^.*c$)
do
    echo "TEST : $file"
    make test C_FILE="Tests/$file"
    echo "-------------------------------------------------------"
done