CC=gcc

FILENAME=add
FLEX_IN=ANSI-C.l
YACC_IN=miniC.y
FILE_OUT=try
YACC_C=y.tab.c
YACC_H=y.tab.h
DOT_FILE=$(FILENAME).dot
DOT_OUT_PDF=$(FILENAME).pdf
C_FILE=Tests/$(FILENAME).c

YACC_GENS=$(YACC_C) $(YACC_H)
LEX_GENS=lex.yy.c

C_FLAGS=librairie.c $(YACC_C) $(LEX_GENS) -o $(FILE_OUT) -w -Wall -pedantic -lfl
DOT_FLAGS=-Tpdf $(DOT_FILE) -o $(DOT_OUT_PDF)
YACC_FLAGS=-d $(YACC_IN)

DOT_CC=dot
FLEX_CC=flex
YACC_CC=yacc

# test-all:
# 	./test.sh

all: clean compile graph test
test: clean compile
	./try < $(C_FILE)
install:
	sudo apt install -y graphviz flex bison
graph:
	$(DOT_CC) $(DOT_FLAGS)
flex_compile:
	$(FLEX_CC) $(FLEX_IN)
yacc_compile:
	$(YACC_CC) $(YACC_FLAGS)
compile: yacc_compile flex_compile
	$(CC) $(C_FLAGS)
clean:
	rm -rf $(LEX_GENS) $(YACC_GENS) *.o
.PHONY: clean