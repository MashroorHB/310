yacc -d -y 1905069.y
g++ -w -c -o y.o y.tab.c
flex 1905069.l
g++ -w -c -o l.o lex.yy.c
g++ y.o l.o -o 1905069
./1905069 input.c
