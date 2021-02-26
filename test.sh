#/bin/sh

for file in $(ls ./Tests | grep ^.*c$)
do
    make test C_FILE="Tests/$file"
done