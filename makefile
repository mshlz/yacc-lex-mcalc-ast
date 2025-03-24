NAME = mcalc


all: parser lexer build

parser:
	yacc -d $(NAME).y 

lexer:
	lex $(NAME).l

build:
	gcc lex.yy.c y.tab.c -o "$(NAME).app"

run:
	"./$(NAME).app"

clean:
	rm *.app y.tab* lex.yy*