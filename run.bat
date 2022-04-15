@echo off
echo FLEX START
flex -o tokenizer.yy.c tokenizer.l
echo BISON START
bison -o parser.tab.c -d parser.y
echo COMPILING
gcc -o compiler.exe tokenizer.yy.c parser.tab.c
echo RUNNING
echo.
.\compiler input.txt
