CC=g++
CFLAGS=-Wall -Wextra -Wpedantic

all: yakety-yak.y FlexicalAnalysis.l
	bison -d yakety-yak.y
	flex FlexicalAnalysis.l
	gcc yakety-yak.tab.c lex.yy.c -o jsgc

clean:
	rm -f lex.yy.c flexer output*.txt yakety-yak.tab.* jsgc