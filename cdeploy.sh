#!/bin/bash

rm -rf lib_enc
cp -r lib lib_enc
cd lib_enc
find . -type f -print0 | while IFS= read -r -d $'\0' line; do
    echo -n 'R"D1AM0ND(' | cat - "$line" > cdiamond_tmp
    echo ')D1AM0ND"' >> cdiamond_tmp
    mv cdiamond_tmp "$line"
done
