#/bin/sh

for file in $(ls ./Tests | grep ^.*c$)
do
    echo "TEST : $file"
    ./c2dot < "Tests/$file"
    mv test.dot dot-output/$file.dot
    make graph FILENAME=$file

    echo "\n-------------------------------------------------------"
done