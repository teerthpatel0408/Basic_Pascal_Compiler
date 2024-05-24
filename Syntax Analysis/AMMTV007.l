%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>
    #include "y.tab.h"
    int line = 1;
%}

alp [a-zA-Z]
digit [0-9]
us [_]
newline [\n]
space [ ]
tab [\t]

%x string
%%

{newline} {line++;}
{space} {;}
{tab} {;}
"//".* {;}

[pP][rR][oO][gG][rR][aA][mM] {insertIntoTable(line, yytext, "KEYWORD"); return PROGRAM;}
[vV][aA][rR] {insertIntoTable(line, yytext, "KEYWORD"); return VAR;}
[iI][nN][tT][eE][gG][eE][rR] {insertIntoTable(line, yytext, "KEYWORD"); return INT;}
[cC][hH][aA][rR] {insertIntoTable(line, yytext, "KEYWORD"); return CHAR;}
[rR][eE][aA][lL] {insertIntoTable(line, yytext, "KEYWORD"); return REAL;}
[iI][fF] {insertIntoTable(line, yytext, "KEYWORD"); return IF;}
[tT][hH][eE][nN] {insertIntoTable(line, yytext, "KEYWORD"); return THEN;}
[eE][lL][sS][eE] {insertIntoTable(line, yytext, "KEYWORD"); return ELSE;}
[fF][oO][rR] {insertIntoTable(line, yytext, "KEYWORD"); return FOR;}
[wW][hH][iI][lL][eE] {insertIntoTable(line, yytext, "KEYWORD"); return WHILE;}
[dD][oO] {insertIntoTable(line, yytext, "KEYWORD"); return DO;}
[bB][oO][oO][lL][eE][aA][nN] {insertIntoTable(line, yytext, "KEYWORD"); return BOOLEAN;}
[aA][rR][rR][aA][yY] {insertIntoTable(line, yytext, "KEYWORD"); return ARRAY;}
[aA][nN][dD] {insertIntoTable(line, yytext, "KEYWORD"); return AND;}
[oO][rR] {insertIntoTable(line, yytext, "KEYWORD"); return OR;}
[nN][oO][tT] {insertIntoTable(line, yytext, "KEYWORD"); return NOT;}
[bB][eE][gG][iI][nN] {insertIntoTable(line, yytext, "KEYWORD"); return START;}
[eE][nN][dD] {insertIntoTable(line, yytext, "KEYWORD"); return END;}
[rR][eE][aA][dD] {insertIntoTable(line, yytext, "KEYWORD"); return READ;}
[wW][rR][iI][tT][eE] {insertIntoTable(line, yytext, "KEYWORD"); return WRITE;}
[tT][oO] {insertIntoTable(line, yytext, "KEYWORD"); return TO;}
[oO][fF] {insertIntoTable(line, yytext, "KEYWORD"); return OF;}
[dD][oO][wW][nN][tT][oO] {insertIntoTable(line, yytext, "KEYWORD"); return DOWNTO;}

[tT][rR][uU][eE] {insertIntoTable(line, yytext, "BOOLEAN_CONST"); return BOOLEAN_CONST;}
[fF][aA][lL][sS][eE] {insertIntoTable(line, yytext, "BOOLEAN_CONST"); return BOOLEAN_CONST;}

{alp}({alp}|{digit}|{us})* {insertIntoTable(line, yytext, "IDENTIFIER"); return IDENTIFIER;}
"-"?{digit}+ {insertIntoTable(line, yytext, "INT_CONST"); return INT_CONST;}
"-"?{digit}+\.{digit}+ {insertIntoTable(line, yytext, "REAL_CONST"); return REAL_CONST;}
\'.\' {insertIntoTable(line, yytext, "CHAR_CONST"); return CHAR_CONST;}
\\n {return NEWLINE;}
"+" {insertIntoTable(line, yytext, "OPERATOR"); return PLUS;}
"-" {insertIntoTable(line, yytext, "OPERATOR"); return MINUS;}
"*" {insertIntoTable(line, yytext, "OPERATOR"); return MUL;}
"/" {insertIntoTable(line, yytext, "OPERATOR"); return DIV;}
"\%" {insertIntoTable(line, yytext, "OPERATOR"); return MOD;}
">" {insertIntoTable(line, yytext, "OPERATOR"); return GTR;}
"<" {insertIntoTable(line, yytext, "OPERATOR"); return LESS;}
">=" {insertIntoTable(line, yytext, "OPERATOR"); return GTR_EQ;}
"<=" {insertIntoTable(line, yytext, "OPERATOR"); return LESS_EQ;}
"=" {insertIntoTable(line, yytext, "OPERATOR"); return EQ;}
"<>" {insertIntoTable(line, yytext, "OPERATOR"); return NOT_EQ;}
":=" {insertIntoTable(line, yytext, "OPERATOR"); return ASS;}

";" {insertIntoTable(line, yytext, "SYMBOL"); return SEMICOLON;}
":" {insertIntoTable(line, yytext, "SYMBOL"); return COLON;}
"," {insertIntoTable(line, yytext, "SYMBOL"); return COMMA;}
"\(" {insertIntoTable(line, yytext, "SYMBOL"); return LPAREN;}
"\)" {insertIntoTable(line, yytext, "SYMBOL"); return RPAREN;}
"\{" {insertIntoTable(line, yytext, "SYMBOL"); return LBRACE;}
"\}" {insertIntoTable(line, yytext, "SYMBOL"); return RBRACE;}
"\[" {insertIntoTable(line, yytext, "SYMBOL"); return LBRACKET;}
"\]" {insertIntoTable(line, yytext, "SYMBOL"); return RBRACKET;}
\' {insertIntoTable(line, yytext, "SYMBOL"); return SQT;}
\" {insertIntoTable(line, yytext, "SYMBOL"); BEGIN(string); return DQT;}
\. {insertIntoTable(line, yytext, "SYMBOL"); return DOT;}
. {insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
"/*" {insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
"*/" {insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
({digit})+({alp}|{digit}|{us})* {insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
({us})+({alp}|{digit}|{us})* {insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}

<string>\" {insertIntoTable(line, yytext, "SYMBOL"); BEGIN(INITIAL); return DQT;}
<string>.*/\" {return STRING;}

%%
typedef struct node {
    char *lexeme;
    char *token;
    struct node *next;
} node;

node *sym_table[2000];

node *createNode(char *lexeme, char *token){
    node *temp = (node*)malloc(sizeof(node));
    temp->lexeme = (char*)malloc(sizeof(char)*strlen(lexeme));
    temp->token = (char*)malloc(sizeof(char)*strlen(token));
    strcpy(temp->lexeme, lexeme);
    strcpy(temp->token, token);
    temp->next = NULL;
    return temp;
}

void insertIntoTable(int line, char *yytext, char *token){
    node *temp = createNode(yytext, token);
    if(sym_table[line] == NULL){
        sym_table[line] = temp;
        return;
    }

    node *ptr = sym_table[line];
    while(ptr->next != NULL){
        ptr = ptr->next;
    }
    ptr->next = temp;
}

void printTable(){
    printf("\nSYMBOL TABLE----------------------\n");
    printf("\nLine\tLexeme\tToken\n\n");
    for(int i=0; i<2000; i++){
        if(sym_table[i] != NULL){
            node *ptr = sym_table[i];
            while(ptr != NULL){
                printf("%d\t%s\t%s\n", i, ptr->lexeme, ptr->token);
                ptr = ptr->next;
            }
        }
    }
}

int yywrap()
{
	return 1;
}
