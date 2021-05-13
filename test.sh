#/bin/sh

for file in $(ls ./Tests | grep ^.*c$)
do
    echo "TEST : $file"
    ./c2dot < "Tests/$file"
    if [ $? -eq 0 ];
    then
        mv test.dot dot-output/$file.dot
        make -s graph FILENAME=$file
    fi
    echo "-------------------------------------------------------"
done