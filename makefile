CC=gcc

FLEX_IN=ANSI-C.l
YACC_IN=miniC.y
FILE_OUT=try
DOT_FILE=exempleminiC.dot
DOT_OUT_PDF=exempleminiC.pdf
C_FILE=exempleminiC.c

C_FLAGS=$(C_FILE) -o $(FILE_OUT) -lfl
DOT_FLAGS=-Tpdf $(DOT_FILE) -o $(DOT_OUT_PDF)
YACC_FLAGS=-dy $(YACC_IN)

DOT_CC=dot
FLEX_CC=flex
YACC_CC=yacc

YACC_GENS=y.tab.c y.tab.h
LEX_GENS=lex.yy.c

all: compile graph
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