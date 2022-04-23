@echo off
if %1.==. goto ed
flex -o tokenizer.yy.c tokenizer.l
bison -o parser.tab.c -d parser.y
gcc -o compiler.exe tokenizer.yy.c parser.tab.c
:ed
echo.
.\compiler.exe input.txt
