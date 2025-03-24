%{

#include "y.tab.h" // tokens

%}

%%

\-?[0-9]+   { 
    yylval.num = atoi(yytext);
    return NUMBER;
}
\+       { return PLUS; }
\-       { return MINUS; }
\*       { return MULTIPLY; }
\/       { return DIVIDE; }
\(       { return LPAREN; }
\)       { return RPAREN; }
[ \t\n]  { /* skip whitespace */ }
.        { return 0; }  // Error for invalid characters

%%

int yywrap () { 
    return 0; 
}