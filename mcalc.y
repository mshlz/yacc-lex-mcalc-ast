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
// more bellow => bigger precedence

root:
    expr {
        ast_root = $$; // copy ref of expr node to ast_root
    }

expr:
    expr PLUS term {
        $$ = ast_create_node(PLUS);
        $$->left = $1;                  // expr
        $$->right = $3;                 // term
    }
    | expr MINUS term {
        $$ = ast_create_node(MINUS);
        $$->left = $1;                  // expr
        $$->right = $3;                 // term
    }
    | term
    ;

term:
    term MULTIPLY factor {
        $$ = ast_create_node(MULTIPLY);
        $$->left = $1;                  // term
        $$->right = $3;                 // factor
    }
    | term DIVIDE factor {
        $$ = ast_create_node(DIVIDE);
        $$->left = $1;                  // term
        $$->right = $3;                 // factor
    }
    | factor
    ;

factor:
    NUMBER {
        $$ = ast_create_node(NUMBER);
        $$->num = $1;                   // integer
    }
    | LPAREN expr RPAREN {
        $$ = $2;                        // expr
    }
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
