CC=g++
CFLAGS=-Wall -Wextra -Wpedantic

all: YaketyYak.y Flexicution.l
	bison -d YaketyYak.y
	flex Flexicution.l
	gcc YaketyYak.tab.c lex.yy.c -o jsgc

clean:
	rm -f lex.yy.c flexer output*.txt YaketyYak.tab.* jsgc jsgc.c 1.c 2.c 3.c 4.c 5.c a.out failure.c

sample: 
	./jsgc programs/sample.txt jsgc.c

fail: 
	./jsgc programs/failure.txt failure.c

1: 
	./jsgc programs/1.txt 1.c

2: 
	./jsgc programs/2.txt 2.c

3: 
	./jsgc programs/3.txt 3.c

4: 
	./jsgc programs/4.txt 4.c

5:
	./jsgc programs/5.txt 5.c