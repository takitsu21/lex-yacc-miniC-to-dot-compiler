CC=gcc

FILENAME=
FLEX_IN=ANSI-C.l
YACC_IN=miniC.y
FILE_OUT=c2dot
YACC_C=y.tab.c
YACC_H=y.tab.h
DOT_FILE=test.dot
DOT_OUT_PDF=pdf-output/$(FILENAME).pdf

TESTS_PATH=Tests/
C_FILE=$(TESTS_PATH)$(FILENAME)
YACC_GENS=$(YACC_C) $(YACC_H)
LEX_GENS=lex.yy.c

C_FLAGS=$(YACC_C) $(LEX_GENS) -o $(FILE_OUT) symboles.c -g -w -Wall -pedantic -lfl
DOT_FLAGS=-Tpdf dot-output/$(FILENAME).dot -o $(DOT_OUT_PDF)
YACC_FLAGS=-d $(YACC_IN)

DOT_CC=dot
FLEX_CC=flex
YACC_CC=yacc
mkdir_pdf=mkdir pdf-output
rename=mv $(DOT_FILE) dot-output/$(FILENAME).dot
mkdir_dot=mkdir dot-output


all: clean compile create-directories
	./test.sh
test: clean compile create-directories
	./$(FILE_OUT) < $(C_FILE)
	$(rename)
	make graph
create-directories:
	$(mkdir_pdf)
	$(mkdir_dot)
valgrind-debug: clean compile
	valgrind --tool=memcheck -s --leak-check=full --leak-resolution=high --show-reachable=yes ./$(FILE_OUT) < $(C_FILE)
install:
	sudo apt install -y graphviz flex bison valgrind --upgrade
graph:
	$(DOT_CC) $(DOT_FLAGS)
flex_compile:
	$(FLEX_CC) $(FLEX_IN)
yacc_compile:
	$(YACC_CC) $(YACC_FLAGS)
compile: yacc_compile flex_compile
	$(CC) $(C_FLAGS)
clean:
	rm -rf $(LEX_GENS) $(YACC_GENS) $(FILE_OUT) *.o $(DOT_FILE) pdf-output/ dot-output/
.PHONY: clean