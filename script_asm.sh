#!/bin/bash
cd "project_files/Files/";
./assembler.bin/dlxasm.pl ./asm_example/test.asm ;
./assembler.bin/conv2memory ./asm_example/test.asm.exe > ./asm_example/test.asm.mem;
mv asm_example/test.asm.mem ../../.;
cp asm_example/test.asm .
cd ../../ 
