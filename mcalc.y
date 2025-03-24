%{

#include "ast.h"

// Root node of the AST
ASTNode *ast_root = NULL;

int yylex();

void yyerror(char *str) {
    fprintf(stderr, "Error: %s\n", str);
}

%}

%union {
    struct ASTNode *node;
    int num;
}

%type <node> root expr term factor

%token <num> NUMBER
%token PLUS MINUS MULTIPLY DIVIDE LPAREN RPAREN

// %left means that operators of the same precedence will be evaluated from left to right.
// 1 + 2 + 3 === (1 + 2) + 3
%left PLUS MINUS
%left MULTIPLY DIVIDE

%%

// Grammar
// more bellow => greater precedence

root:
    expr                     { ast_root = $$; } // copy ref of expr node to ast_root 

expr:
    expr PLUS term           { $$ = ast_create_binary_op(PLUS, $1, $3); }
    | expr MINUS term        { $$ = ast_create_binary_op(MINUS, $1, $3); }
    | term
    ;

term:
    term MULTIPLY factor     { $$ = ast_create_binary_op(MULTIPLY, $1, $3); }
    | term DIVIDE factor     { $$ = ast_create_binary_op(DIVIDE, $1, $3); }
    | factor
    ;

factor:
    NUMBER                   { $$ = ast_create_node(NUMBER); $$->num = $1; }
    | LPAREN expr RPAREN     { $$ = $2; }
    ;

%%



int main() {
    printf("Enter an expression: ");
    yyparse();
    printf("\n");
    
    ast_print_tree(ast_root);
    int result;
    int ec = ast_evaluate(ast_root, &result);

    if (ec) {
        printf("FAILED TO EVALUATE AST!\n");
        return 1;
    } else {
        printf("= %d\n", result);
        return 0;
    }
}
