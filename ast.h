#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>

#include "y.tab.h" // tokens

typedef struct ASTNode {
    int kind; // Token type (NUMBER, PLUS, MINUS, etc.)
    union {
        int num; // Used for NUMBER type
        struct { // binary op
            struct ASTNode *left;
            struct ASTNode *right;
        };
    };
} ASTNode;

ASTNode *ast_create_node(int kind) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->kind = kind;
    node->left = NULL;
    node->right = NULL;
    return node;
}

void ast_print_tree(ASTNode *node) {
    if (node == NULL) {
        return;
    }

    switch (node->kind) {
    case PLUS:
        ast_print_tree(node->left);
        printf("+ ");
        ast_print_tree(node->right);
        break;
    case MINUS:
        ast_print_tree(node->left);
        printf("- ");
        ast_print_tree(node->right);
        break;
    case MULTIPLY:
        printf("( ");
        ast_print_tree(node->left);
        printf("* ");
        ast_print_tree(node->right);
        printf(") ");
        break;
    case DIVIDE:
        printf("( ");
        ast_print_tree(node->left);
        printf("/ ");
        ast_print_tree(node->right);
        printf(") ");
        break;
    case NUMBER:
        printf("%d ", node->num);
        break;
    default:
        printf("Unknown token %d\n", node->kind);
        break;
    }
}

int ast_evaluate_calc(ASTNode *node) {
    switch (node->kind) {
    case PLUS:
        return (ast_evaluate_calc(node->left) +
                ast_evaluate_calc(node->right));
        break;
    case MINUS:
        return (ast_evaluate_calc(node->left) -
                ast_evaluate_calc(node->right));
        break;
    case MULTIPLY:
        return (ast_evaluate_calc(node->left) *
                ast_evaluate_calc(node->right));
        break;
    case DIVIDE:
        return (ast_evaluate_calc(node->left) /
                ast_evaluate_calc(node->right));
        break;
    case NUMBER:
        return node->num;
    default:
        printf("Unknown token %d\n", node->kind);
        return -1; // TODO: panic
    }
}

int ast_evaluate(ASTNode *node, int *result) {
    if (node == NULL) {
        return -1;
    }

    switch (node->kind) {
    case PLUS:
    case MINUS:
    case MULTIPLY:
    case DIVIDE:
    case NUMBER:
        *result = ast_evaluate_calc(node);
        return 0;
    default:
        printf("Unknown token %d\n", node->kind);
        return -1; // TODO: panic?
    }
}

#endif