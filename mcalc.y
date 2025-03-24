%{
void yyerror(char *str);
int yylex();

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

typedef struct ASTNode {
    int type;               // Token type (e.g., NUMBER, PLUS, etc.)
    union {
        int num;            // Used for NUMBER type
        struct {
            struct ASTNode* left;
            struct ASTNode* right;
        };
    };
} ASTNode;

ASTNode *ast_root = NULL;

// Function to create a new AST node
ASTNode* create_node(int type) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = type;
    node->left = NULL;
    node->right = NULL;
    return node;
}
%}

%union {
    struct ASTNode *node;
    int num; 
}

%type <node> factor term expr root

%token <num> NUMBER
%token PLUS MINUS MULTIPLY DIVIDE LPAREN RPAREN

%left PLUS MINUS
%left MULTIPLY DIVIDE

%%

root:
    expr {
        $$ =$1;
        ast_root = $$;
    }

// Grammar rules with correct precedence handling
expr:
    expr PLUS term     { 
        $$ = create_node(PLUS);
        $$->left = $1;
        $$->right = $3;
        printf("PLUS (%p) + (%p) @ %p\n", $1, $3, $$);
    }
    | expr MINUS term  { 
        $$ = create_node(MINUS);
        $$->left = $1;
        $$->right = $3;
        printf("MINUS (%p) - (%p) @ %p\n", $1, $3, $$);
    }
    | term { 
        $$ = $1; 
        printf("EXPR->term @ %p\n", ast_root);
    }
    ;

term:
    term MULTIPLY factor { 
        $$ = create_node(MULTIPLY);
        $$->left = $1;
        $$->right = $3;
        printf("MULTIPLY (%p) * (%p) @ %p\n", $1, $3, $$);
    }
    | term DIVIDE factor   { 
        $$ = create_node(DIVIDE);
        $$->left = $1;
        $$->right = $3;
        printf("DIVISION (%p) / (%p) @ %p\n", $1, $3, $$);
    }
    | factor { $$=$1;
    
        printf("TERM->factor @ %p\n", $$);
    
    }
    ;

factor:
    NUMBER               { 
        $$ = create_node(NUMBER);
        $$->num = $1; 
        printf("NUMBER(%d) @ %p\n", $1, $$);
    }
    | LPAREN expr RPAREN  { $$ = $2;
    
        printf("expr (expr) ... %p\n", $$);
    }
    ;

%%

void print_ast(ASTNode* node) {
    if (node == NULL) {
        return;
    }

    // Print the current node's type or value
    switch (node->type) {
        case PLUS:
        print_ast(node->left);
        printf("+ ");
        print_ast(node->right);
            break;
        case MINUS:
        print_ast(node->left);
        printf("- ");
        print_ast(node->right);
            break;
        case MULTIPLY:
        printf("( ");
        print_ast(node->left);
        printf("* ");
        print_ast(node->right);
        printf(") ");
            break;
        case DIVIDE:
        printf("( ");
        print_ast(node->left);
        printf("/ ");
        print_ast(node->right);
        printf(") ");
            break;
        case NUMBER:
            printf("%d ", node->num);
            break;
        default:
            printf("Unknown ");
            break;
    }
}

int main() {
    printf("Enter an expression: ");
    yyparse();
    printf("after yyparse\n");
    print_ast(ast_root); // Print the AST (assuming ast_root is the root node)
    return 0;
}

void yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
    