#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>

#include "y.tab.h" // tokens

typedef struct ASTNode {
    int type; // Token type (NUMBER, PLUS, MINUS, etc.)
    union {
        int num; // Used for NUMBER type
        struct { // binary op
            struct ASTNode *left;
            struct ASTNode *right;
        };
    };
} ASTNode;

ASTNode *ast_create_node(int type) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    return node;
}

ASTNode *ast_create_binary_op(int type, ASTNode *left, ASTNode *right) {
    ASTNode *node = ast_create_node(type);
    node->left = left;
    node->right = right;
    return node;
}

void ast_print_tree(ASTNode *node) {
    if (node == NULL) {
        return;
    }

    switch (node->type) {
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
        printf("Unknown token %d\n", node->type);
        break;
    }
}

int ast_evaluate_calc(ASTNode *node) {
    switch (node->type) {
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
        printf("Unknown token %d\n", node->type);
        return -1; // TODO: panic
    }
}

int ast_evaluate(ASTNode *node, int *result) {
    if (node == NULL) {
        return -1;
    }

    switch (node->type) {
    case PLUS:
    case MINUS:
    case MULTIPLY:
    case DIVIDE:
    case NUMBER:
        *result = ast_evaluate_calc(node);
        return 0;
    default:
        printf("Unknown token %d\n", node->type);
        return -1; // TODO: panic?
    }
}

#endif