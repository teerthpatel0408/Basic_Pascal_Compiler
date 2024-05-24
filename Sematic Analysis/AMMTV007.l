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
[aA][nN][dD] {insertIntoTable(line, yytext, "KEYWORD"); yylval.t.lexeme = strdup("and"); return AND;}
[oO][rR] {insertIntoTable(line, yytext, "KEYWORD"); yylval.t.lexeme = strdup("or"); return OR;}
[nN][oO][tT] {insertIntoTable(line, yytext, "KEYWORD"); yylval.t.lexeme = strdup("not"); return NOT;}
[bB][eE][gG][iI][nN] {insertIntoTable(line, yytext, "KEYWORD"); return START;}
[eE][nN][dD] {insertIntoTable(line, yytext, "KEYWORD"); return END;}
[rR][eE][aA][dD] {insertIntoTable(line, yytext, "KEYWORD"); return READ;}
[wW][rR][iI][tT][eE] {insertIntoTable(line, yytext, "KEYWORD"); return WRITE;}
[tT][oO] {insertIntoTable(line, yytext, "KEYWORD"); return TO;}
[oO][fF] {insertIntoTable(line, yytext, "KEYWORD"); return OF;}
[dD][oO][wW][nN][tT][oO] {insertIntoTable(line, yytext, "KEYWORD"); return DOWNTO;}

[tT][rR][uU][eE] {insertIntoTable(line, yytext, "BOOLEAN_CONST"); yylval.t.lexeme = strdup("BOOLEAN"); yylval.t.val = 1; return BOOLEAN_CONST;}
[fF][aA][lL][sS][eE] {insertIntoTable(line, yytext, "BOOLEAN_CONST"); yylval.t.lexeme = strdup("BOOLEAN"); yylval.t.val = 0; return BOOLEAN_CONST;}

{alp}({alp}|{digit}|{us})* {insertIntoTable(line, yytext, "IDENTIFIER"); yylval.t.lexeme = strdup(yytext); return IDENTIFIER;}
"-"?{digit}+ {insertIntoTable(line, yytext, "INT_CONST"); yylval.t.lexeme = strdup("INT"); yylval.t.val = atoi(yytext); return INT_CONST;}
"-"?{digit}+\.{digit}+ {insertIntoTable(line, yytext, "REAL_CONST"); yylval.t.lexeme = strdup("REAL"); yylval.t.val = atof(yytext); return REAL_CONST;}
\'.\' {insertIntoTable(line, yytext, "CHAR_CONST"); yylval.t.lexeme = strdup("CHAR"); yylval.t.val = (float)(yytext[1]-'a'); return CHAR_CONST;}
\\n {return NEWLINE;}
"+" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return PLUS;}
"-" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return MINUS;}
"*" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return MUL;}
"/" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return DIV;}
"\%" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return MOD;}
">" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return GTR;}
"<" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return LESS;}
">=" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return GTR_EQ;}
"<=" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return LESS_EQ;}
"=" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return EQ;}
"<>" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return NOT_EQ;}
":=" {insertIntoTable(line, yytext, "OPERATOR"); yylval.t.lexeme = strdup(yytext); return ASS;}

";" {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); return SEMICOLON;}
":" {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); return COLON;}
"," {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); return COMMA;}
"\(" {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); return LPAREN;}
"\)" {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); return RPAREN;}
"\{" {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); return LBRACE;}
"\}" {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); return RBRACE;}
"\[" {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); return LBRACKET;}
"\]" {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); return RBRACKET;}
\' {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); return SQT;}
\" {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); BEGIN(string); return DQT;}
\. {insertIntoTable(line, yytext, "SYMBOL"); yylval.t.lexeme = strdup(yytext); return DOT;}
. {insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
"/*" {insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
"*/" {insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
({digit})+({alp}|{digit}|{us})* {insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}
({us})+({alp}|{digit}|{us})* {insertIntoTable(line, yytext, "UNKNOWN"); return UNK;}

<string>\" {insertIntoTable(line, yytext, "SYMBOL"); BEGIN(INITIAL); yylval.t.lexeme = strdup(yytext); return DQT;}
<string>.*/\" {yylval.t.lexeme = strdup(yytext); return STRING;}

%%
typedef struct node {
    char *lexeme;
    char *token;
    struct node *next;
} node;

node *sym_table[1000];

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
    for(int i=0; i<1000; i++){
        if(sym_table[i] != NULL){
            node *ptr = sym_table[i];
            while(ptr != NULL){
                printf("%d\t%s\t%s\n", i, ptr->lexeme, ptr->token);
                ptr = ptr->next;
            }
        }
    }
    printf("\n");
}

int yywrap()
{
	return 1;
}
