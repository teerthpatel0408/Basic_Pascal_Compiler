#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include "header.h"
#include <stdbool.h>
#include "y.tab.h"
int del = 1; /* distance of graph columns */
int eps = 3; /* distance of graph lines */
int flag = 0; // flag to print main initially
/* interface for drawing (can be replaced by "real" graphic using GD or other) */
void graphInit (void);
void graphFinish();
void graphBox (char *s, int *w, int *h);
void graphDrawBox (char *s, int c, int l);
void graphDrawArrow (int c1, int l1, int c2, int l2);
bool brk_cnt = true;
bool cont_cnt = true;
struct type_check *exprEvaluate(nodeType *p,int index);
struct type_check *addEvaluate(nodeType *p1,nodeType *p2, int index);
struct type_check *subEvaluate(nodeType *p1,nodeType *p2, int index);
struct type_check *mulEvaluate(nodeType *p1,nodeType *p2, int index);
struct type_check *divEvaluate(nodeType *p1,nodeType *p2, int index);
struct type_check *modEvaluate(nodeType *p1,nodeType *p2, int index);
bool ltEvaluate(nodeType *p, int index);
bool gtrEvaluate(nodeType *p, int index);
bool gtreqEvaluate(nodeType *p, int index);
bool lteqEvaluate(nodeType *p, int index);
bool eqeqEvaluate(nodeType *p, int index);
bool neqEvaluate(nodeType *p, int index);
bool evaluate(nodeType *p,int index);
void printfEvaluate(nodeType *p, int index);
void writeCommaEvaluate(nodeType *p, int index);	
void scanfEvaluate(nodeType *p, int index);
void readCommaEvaluate(nodeType *p, int index);
void ifEvaluate(nodeType*p,int index);
void whileEvaluate(nodeType*p,int index);
void forEvaluate(nodeType *p,int index);
void funcEvaluate(nodeType *p,int index);
void eqEvaluate(nodeType* p,int index);
struct type_check *andEvaluate(nodeType *p1,nodeType *p2,int index);
struct type_check *orEvaluate(nodeType *p1,nodeType *p2,int index);
struct type_check *notEvaluate(nodeType *p, int index);
struct type_check *arrEvaluate(nodeType *p, int index);

struct dec{
        char *type;
        char *name;
        float val;
}dec[10];

typedef struct id_sym{
    char *type;
    char *name;
    float val;
}id_sym;

typedef struct arr_sym{
    char *type;
    char *name;
    int c1, c2;
    float val[100];
}arr_sym;

typedef struct type_check{
    char *type;
    char *val;
}type_check;

int id_count = 0;
int func_count = 0;
int arr_count = 0;

id_sym id_table[1000];
arr_sym arr_table[1000];


/* recursive drawing of the syntax tree */
void exNode (nodeType *p, int c, int l, int *ce, int *cm);
/***********************************************************/
/* main entry point of the manipulation of the syntax tree */
int ex (nodeType *p, int f)
{
	flag = f;
	int rte, rtm;
	graphInit ();
	exNode (p, 0, 0, &rte, &rtm);
	evaluate(p,0);
	graphFinish();
	//print_Id_Table();
	return 0;
}


void exNode( nodeType *p,  int c, int l, /* start column and line of node */  int *ce, int *cm /* resulting end column and mid of node */)
{
	int w, h; /* node width and height */
	char *s; /* node text */
	int cbar; /* "real" start column of node (centred above subnodes)
	*/
	int k; /* child number */
	int che, chm; /* end column and mid of children */
	int cs; /* start column of children */
	char word[20]; /* extended node text */
	if (!p) return;
	strcpy (word, "???"); /* should never appear */
	s = word;
	switch(p->type) 
	{
		case typeCon: sprintf (word, "c[%s]", p->con.value); break;
		case typeId: sprintf (word, "id[%s]", p->id.name); break;
		case typeOpr:
		switch(p->opr.oper)
		{
			case FOR: s = "for"; break;
			case WHILE: s = "while"; break;
			case IF: s = "if"; break;
			case NUL: s = "null"; break;
			case ELSE: s = "else"; break;
			case WRITE: s = "write"; break;
			case READ: s = "read"; break;
			case FUNC: s = "func"; break;
			case GLOBAL: s = "global"; break;
			case SEMICOLON: s = "[;]"; break;
			case ASS: s = "[:=]"; break;
			case COMMA : s = "[,]"; break;
			case PLUS: s = "[+]"; break;
			case MINUS: s = "[-]"; break;
			case MUL: s = "[*]"; break;
			case DIV: s = "[/]"; break;
			case LESS: s = "[<]"; break;
			case GTR: s = "[>]"; break;
			case COLON: s = "[:]"; break;
			case MOD: s = "[%]"; break;
			case GTR_EQ: s = "[>=]"; break;
			case LESS_EQ: s = "[<=]"; break;
			case NOT_EQ: s = "[<>]"; break;
			case EQ: s = "[=]"; break;
			case AND: s = "[and]"; break;
			case OR: s = "[or]"; break;
			case NOT: s = "[not]"; break;
			case ARR : s="arr";break;
		}
	break;
	}
 	/* construct node text box */
	graphBox (s, &w, &h);
	cbar = c;
	*ce = c + w;
	*cm = c + w / 2;
	/* node is leaf */
	if (p->type == typeCon || p->type == typeId || p->opr.nops == 0) 
	{
		graphDrawBox (s, cbar, l);
		return;
	}

 	/* node has children */
 	cs = c;
	for (k = 0; k < p->opr.nops; k++) 
	{
		exNode (p->opr.op[k], cs, l+h+eps, &che, &chm);
		cs = che;
	}
	/* total node width */
	if (w < che - c) 
	{
		cbar += (che - c - w) / 2;
		*ce = che;
		*cm = (c + che) / 2;
	}
	/* draw node */
	graphDrawBox (s, cbar, l);
	/* draw arrows (not optimal: children are drawn a second time) */
	cs = c;
	for (k = 0; k < p->opr.nops; k++)
	{
		exNode (p->opr.op[k], cs, l+h+eps, &che, &chm);
		graphDrawArrow (*cm, l+h, chm, l+h+eps-1);
		cs = che;
	}
	// if(s == "[=]")evaluate_assgn_3(p);
}

/* interface for drawing */
#define lmax 500
#define cmax 500
char graph[lmax][cmax]; /* array for ASCII-Graphic */
int graphNumber = 0;

void graphTest (int l, int c)
{ 
	int ok;
	ok = 1;
	if (l < 0) ok = 0;
	if (l >= lmax) ok = 0;
	if (c < 0) ok = 0;
	if (c >= cmax) ok = 0;
	if (ok) return;
	printf ("\n+++error: l=%d, c=%d not in drawing rectangle 0, 0 ... %d, %d", l, c, lmax, cmax);
	exit (1);
}


void graphInit (void) 
{
	int i, j;
	for (i = 0; i < lmax; i++)
	{
		for (j = 0; j < cmax; j++) 
		{
			graph[i][j] = ' ';
		}
	}
}


void graphFinish()
{
	int i, j;
	for (i = 0; i < lmax; i++)
	{
		for (j = cmax-1; j > 0 && graph[i][j] == ' '; j--);
		graph[i][cmax-1] = 0;
		if (j < cmax-1) 
			graph[i][j+1] = 0;
		if (graph[i][j] == ' ') 
			graph[i][j] = 0;
	}
	for (i = lmax-1; i > 0 && graph[i][0] == 0; i--);
	printf ("\n\nGraph %d:\n", graphNumber++);
	for (j = 0; j <= i; j++) printf ("\n%s", graph[j]);
	printf("\n");
}

void graphBox (char *s, int *w, int *h)
{
	*w = strlen (s) + del;
	*h = 1;
}
void graphDrawBox (char *s, int c, int l)
{
	int i;
	graphTest (l, c+strlen(s)-1+del);
	for (i = 0; i < strlen (s); i++) {
	graph[l][c+i+del] = s[i];
	}
}

void graphDrawArrow (int c1, int l1, int c2, int l2)
{
	int m;
	graphTest (l1, c1);
	graphTest (l2, c2);
	m = (l1 + l2) / 2;
	while (l1 != m)
	{
		graph[l1][c1] = '|'; if (l1 < l2) l1++; else l1--;
	}
	while (c1 != c2)
	{
		graph[l1][c1] = '-'; if (c1 < c2) c1++; else c1--;
	}
	while (l1 != l2)
	{
		graph[l1][c1] = '|'; if (l1 < l2) l1++; else l1--;
	}
	graph[l1][c1] = '|';
}


bool evaluate(nodeType* p,int index){
	if(!brk_cnt)return 0;
	if(!cont_cnt)return 0;
	if(p->type==typeOpr)
	{	switch (p->opr.oper)
	{
		case ASS: eqEvaluate(p,index);return 1;break;
		case GTR:return gtrEvaluate(p, index);break;
		case LESS:return ltEvaluate(p, index);break;
		case GTR_EQ:return gtreqEvaluate(p, index);break;
		case LESS_EQ:return lteqEvaluate(p, index);break;
		case NOT_EQ:return neqEvaluate(p, index);break;
		case EQ:return eqeqEvaluate(p, index);break;
		case IF: ifEvaluate(p,index);return 1; break;
		case WHILE: whileEvaluate(p,index);return 1; break;
		case FOR : forEvaluate(p,index);return 1; break;
		case READ: scanfEvaluate(p,index); return 1; break;
		case WRITE: printfEvaluate(p ,index);return 1; break;
		case FUNC: funcEvaluate(p, index); return 1;break;
		case AND: return andEvaluate(p->opr.op[0],p->opr.op[1],index); break;
		case OR: return orEvaluate(p->opr.op[0],p->opr.op[1],index); break;
		case NOT: return notEvaluate(p->opr.op[0], index); break;
		default:
			break;
	}

	}
	for(auto i=0;i<p->opr.nops;i++){
		evaluate(p->opr.op[i],index);
	}
}

struct type_check *arrEvaluate(nodeType *p, int index){
	char *arr_name = p->opr.op[0]->id.name;
	struct type_check *temp = exprEvaluate(p->opr.op[1], index);
	int row = atoi(temp->val);
	struct type_check *s = malloc(sizeof(struct type_check));
	s->val = malloc(100);
	s->type = malloc(100);
	int i = 0;
	while(i < arr_count){
		if(strcmp(arr_name, arr_table[i].name)==0){
			if(strcmp(arr_table[i].type,"boolean")==0){
				if(arr_table[i].val[row] == 1){
					strcpy(s->val, "true");
				}
				else{
					strcpy(s->val, "false");
				}
			}
			else{
				sprintf(s->val, "%g", arr_table[i].val[row]);
				strcpy(s->type, arr_table[i].type);
			}
			return s;
		}
		i++;
	}
}

void ifEvaluate(nodeType*p,int index){
	struct type_check *temp1 = exprEvaluate(p->opr.op[0], index);
	if(strcmp(temp1->val,"true")==0){
		evaluate(p->opr.op[1],index);
	}
	else{
		if(p->opr.op[2]->opr.oper != 318){
			evaluate(p->opr.op[2],index);
		}
	}	
}

void whileEvaluate(nodeType*p,int index){
	struct type_check *temp1 = exprEvaluate(p->opr.op[0], index);
	while(strcmp(temp1->val,"true")==0)
	{
		evaluate(p->opr.op[1],index);
		temp1 = exprEvaluate(p->opr.op[0], index);
	}
}

void forEvaluate(nodeType *p,int index){
	int i = 0;
	while(i < id_count){
		if(strcmp(id_table[i].name, p->opr.op[0]->id.name)==0){
			struct type_check *temp = exprEvaluate(p->opr.op[1], index);
			id_table[i].val = atof(temp->val);
			break;
		}
		i++;
	}
	
	char *temp1;
	if(strcmp(p->opr.op[2]->con.value, "to")==0){
		struct type_check *temp = exprEvaluate(p->opr.op[3], index);
		if(id_table[i].val <= atof(temp->val)){
			temp1 = "true";
		}
		else{
			temp1 = "false";
		}
		while(strcmp(temp1,"true")==0)
		{
			evaluate(p->opr.op[4],index);
			id_table[i].val++;
			temp = exprEvaluate(p->opr.op[3], index);
			if(id_table[i].val <= atof(temp->val)){
				temp1 = "true";
			}
			else{
				temp1 = "false";
			}
		}
		id_table[i].val--;
	}
	else{
		struct type_check *temp = exprEvaluate(p->opr.op[3], index);
		if(id_table[i].val >= atof(temp->val)){
			temp1 = "true";
		}
		else{
			temp1 = "false";
		}
		while(strcmp(temp1,"true")==0)
		{
			evaluate(p->opr.op[4],index);
			id_table[i].val--;
			temp = exprEvaluate(p->opr.op[3], index);
			if(id_table[i].val >= atof(temp->val)){
				temp1 = "true";
			}
			else{
				temp1 = "false";
			}
		}
		id_table[i].val++;
	}
}

void funcEvaluate(nodeType *p, int index){
	evaluate(p->opr.op[1], 0);
}

void scanfEvaluate(nodeType *p, int index){
	if(p->opr.op[0]->type == typeId){
		for(int i = 0;i<id_count;i++){
			if(strcmp(id_table[i].name, p->opr.op[0]->id.name)==0){
				if(strcmp(id_table[i].type,"boolean")==0){
					char temp[20];
   					scanf("%s",temp);
					if(strcmp(temp, "true")==0){
						id_table[i].val = 1;
					}
					else{
						id_table[i].val = 0;
					}
				}
				else{
					if(strcmp(id_table[i].type,"char")==0){
						char temp[1];
						scanf("%s",temp);
						id_table[i].val = (float)temp[0];
					}
					else{
						float temp;
						scanf("%f",&temp);
						id_table[i].val = temp;
					}
				}
				return ;
			}
		}
	}
	else if(p->opr.op[0]->type == typeOpr && p->opr.op[0]->opr.oper != 302){
		for(int i = 0;i<arr_count;i++){
			if(strcmp(arr_table[i].name, p->opr.op[0]->opr.op[0]->id.name)==0){
				struct type_check *temp1 = exprEvaluate(p->opr.op[0]->opr.op[1],index);
				int row = atoi(temp1->val);
				if(strcmp(arr_table[i].type,"boolean")==0){
					char temp[20];
   					scanf("%s",temp);
					if(strcmp(temp, "true")==0){
						arr_table[i].val[row] = 1;
					}
					else{
						arr_table[i].val[row] = 0;
					}
				}
				else{
					if(strcmp(arr_table[i].type,"char")==0){
						char temp[1];
						scanf("%s",temp);
						arr_table[i].val[row] = (float)temp[0];
					}
					else{
						float temp;
						scanf("%f", &temp);
						arr_table[i].val[row] = temp;
					}
				}
				return;
			}
		}
	}
	else{
		readCommaEvaluate(p->opr.op[0],index);
	}
	
}

void readCommaEvaluate(nodeType *p, int index){
	//BASE 
	if(p->type == typeId){
		for(int i = 0;i<id_count;i++){
			if(strcmp(id_table[i].name, p->id.name)==0){
				if(strcmp(id_table[i].type,"boolean")==0){
					char temp[20];
   					scanf("%s",temp);
					if(strcmp(temp, "true")==0){
						id_table[i].val = 1;
					}
					else{
						id_table[i].val = 0;
					}
				}
				else{
					if(strcmp(id_table[i].type,"char")==0){
						char temp[1];
						scanf("%s",temp);
						id_table[i].val = (float)temp[0];
					}
					else{
						float temp;
						scanf("%f",&temp);
						id_table[i].val = temp;
					}
				}
				return ;
			}
		}
	}
	else if(p->type == typeOpr && p->opr.oper != 302){
		for(int i = 0;i<arr_count;i++){
			if(strcmp(arr_table[i].name, p->opr.op[0]->id.name)==0){
				struct type_check *temp1 = exprEvaluate(p->opr.op[1],index);
				int row = atoi(temp1->val);
				if(strcmp(arr_table[i].type,"boolean")==0){
					char temp[20];
   					scanf("%s",temp);
					if(strcmp(temp, "true")==0){
						arr_table[i].val[row] = 1;
					}
					else{
						arr_table[i].val[row] = 0;
					}
				}
				else{
					if(strcmp(arr_table[i].type,"char")==0){
						char temp[1];
						scanf("%s", temp);
						arr_table[i].val[row] = (float)temp[0];
					}
					else{
						float temp;
						scanf("%f", &temp);
						arr_table[i].val[row] = temp;
					}
				}
				return;
			}
		}
	}
	readCommaEvaluate(p->opr.op[0],index);
	readCommaEvaluate(p->opr.op[1],index);
}

void printfEvaluate(nodeType *p, int index){
	if(p->opr.op[1]->opr.oper == 318){
		if(p->opr.op[0]->type == typeCon){
			printf("%s\n",p->opr.op[0]->con.value);
		}
		else{
			if(p->opr.op[0]->opr.oper == 302){
				writeCommaEvaluate(p->opr.op[0], index);
			}
			else{
				struct type_check *temp = exprEvaluate(p->opr.op[0],index);
				if(strcmp(temp->type, "int")==0){
					printf("%d\n", atoi(temp->val));
				}
				else if(strcmp(temp->type, "real")==0){
					printf("%f\n", atof(temp->val));
				}
				else if(strcmp(temp->type, "char")==0){
					printf("%c\n", (char)atoi(temp->val));
				}
				else{
					printf("%s\n", temp->val);
				}
			}
		}
	}
	else{
		printf("%s\n",p->opr.op[0]->con.value);
		if(p->opr.op[1]->opr.oper == 302){
			writeCommaEvaluate(p->opr.op[1], index);
		}
		else{
			struct type_check *temp = exprEvaluate(p->opr.op[1],index);
			if(strcmp(temp->type, "int")==0){
				printf("%d\n", atoi(temp->val));
			}
			else if(strcmp(temp->type, "real")==0){
				printf("%f\n", atof(temp->val));
			}
			else if(strcmp(temp->type, "char")==0){
				printf("%c\n", (char)atoi(temp->val));
			}
			else{
				printf("%s\n", temp->val);
			}
		}
	}
}

void writeCommaEvaluate(nodeType *p, int index){
	//BASE 
	if(p->opr.oper != 302){
		struct type_check *temp = exprEvaluate(p, index);
		if(strcmp(temp->type, "int")==0){
			printf("%d\n", atoi(temp->val));
		}
		else if(strcmp(temp->type, "real")==0){
			printf("%f\n", atof(temp->val));
		}
		else if(strcmp(temp->type, "char")==0){
			printf("%c\n", (char)atoi(temp->val));
		}
		else{
			printf("%s\n", temp->val);
		}
		return;
	}
	writeCommaEvaluate(p->opr.op[0],index);
	writeCommaEvaluate(p->opr.op[1],index);
}

bool gtrEvaluate(nodeType* p,int index){
	struct type_check *lefval = exprEvaluate(p->opr.op[0],index);
	struct type_check *rightval = exprEvaluate(p->opr.op[1],index);
	float a = atof(lefval->val);
	float b = atof(rightval->val);
	if(a>b)
		return true;
	else
		return false;
}
bool neqEvaluate(nodeType* p,int index){
	struct type_check *lefval = exprEvaluate(p->opr.op[0],index);
	struct type_check *rightval = exprEvaluate(p->opr.op[1],index);
	float a = atof(lefval->val);
	float b = atof(rightval->val);
	if(a!=b)
		return true;
	else
		return false;
}
bool eqeqEvaluate(nodeType* p,int index){
	struct type_check *lefval = exprEvaluate(p->opr.op[0],index);
	struct type_check *rightval = exprEvaluate(p->opr.op[1],index);
	float a = atof(lefval->val);
	float b = atof(rightval->val);
	if(a==b)
		return true;
	else
		return false;
}

bool gtreqEvaluate(nodeType* p,int index){
	struct type_check *lefval = exprEvaluate(p->opr.op[0],index);
	struct type_check *rightval = exprEvaluate(p->opr.op[1],index);
	float a = atof(lefval->val);
	float b = atof(rightval->val);
	if(a>=b)
		return true;
	else
		return false;
}
bool ltEvaluate(nodeType *p,int index){
	struct type_check *lefval = exprEvaluate(p->opr.op[0],index);
	struct type_check *rightval = exprEvaluate(p->opr.op[1],index);
	float a = atof(lefval->val);
	float b = atof(rightval->val);
	if(a<b)
		return true;
	else
		return false;
}
bool lteqEvaluate(nodeType *p,int index){
	struct type_check *lefval = exprEvaluate(p->opr.op[0],index);
	struct type_check *rightval = exprEvaluate(p->opr.op[1],index);
	float a = atof(lefval->val);
	float b = atof(rightval->val);
	if(a<=b)
		return true;
	else
		return false;
}

void eqEvaluate(nodeType* p,int index){
	if(p->opr.op[0]->type == typeOpr){
		struct type_check *temp = exprEvaluate(p->opr.op[1],index);
		char *arr_name = p->opr.op[0]->opr.op[0]->id.name;
		struct type_check *temp1 = exprEvaluate(p->opr.op[0]->opr.op[1],index);
		int row = atoi(temp1->val);
		float rightValue;
		if(strcmp(temp->val, "true")==0){
			rightValue = 1;
		}
		else if(strcmp(temp->val, "false")==0){
			rightValue = 0;
		}
		else if(strcmp(temp->type, "char")==0){
			rightValue = (float)temp->val[1];
		}
		else{
			rightValue = atof(temp->val);
		}
		int i = 0;
		while(i < arr_count){
			if(strcmp(arr_name, arr_table[i].name)==0){
				arr_table[i].val[row] = rightValue;
				return;
			}
			i++;
		}
		return;
	}
	else{
		char *leftName = p->opr.op[0]->id.name;
		struct type_check *temp = exprEvaluate(p->opr.op[1],index);
		float rightValue;
		if(strcmp(temp->val, "true")==0){
			rightValue = 1;
		}
		else if(strcmp(temp->val, "false")==0){
			rightValue = 0;
		}
		else if(strcmp(temp->type, "char")==0){
			rightValue = (float)temp->val[1];
		}
		else{
			rightValue = atof(temp->val);
		}
		for(int i = 0; i < id_count; i++){
			if(strcmp(id_table[i].name, leftName)==0){	
				id_table[i].val = rightValue;
				break;
			}
		}
	}
}

struct type_check *exprEvaluate(nodeType *p,int index){
	struct type_check *s = malloc(sizeof(struct type_check));
	s->val = malloc(100);
	s->type = malloc(100);
	
	if(!brk_cnt && !cont_cnt){
		return s;
	}
	if(p->type == typeCon){
		strcpy(s->val, p->con.value);
		strcpy(s->type, p->con.type);
		return s;
	}
	else if(p->type == typeId){
		for(int i = 0;i<id_count;i++){
			if(strcmp(id_table[i].name, p->id.name)==0){
				if(strcmp(id_table[i].type,"boolean")==0){
					if(id_table[i].val == 1){
						strcpy(s->val, "true");
					}
					else{
						strcpy(s->val, "false");
					}
				}
				else{
					sprintf(s->val, "%g", id_table[i].val);
					strcpy(s->type, id_table[i].type);
				}
				return s;
			}
		}
		printf("error: variable not declared\n");
		exit(0);
	}
	else if(p->type == typeOpr){
		bool ff = false;
		switch (p->opr.oper)
		{	
			case ARR:
				return arrEvaluate(p,index);
			case PLUS: 
				return addEvaluate(p->opr.op[0],p->opr.op[1],index);
			case MINUS: 
				return subEvaluate(p->opr.op[0],p->opr.op[1],index);
			case MUL: 
				return mulEvaluate(p->opr.op[0],p->opr.op[1],index);
			case DIV: 
				return divEvaluate(p->opr.op[0],p->opr.op[1],index);
			case MOD:
				return modEvaluate(p->opr.op[0],p->opr.op[1],index);
			case LESS: 
				ff = ltEvaluate(p,index);
				if(ff)
				{
					strcpy(s->val,"true");
					strcpy(s->type,"boolean");
				}
				else{
					strcpy(s->val,"false");
					strcpy(s->type,"boolean");
				}
				return s;
			case GTR: 
				ff = gtrEvaluate(p,index);
				if(ff)
				{
					strcpy(s->val,"true");
					strcpy(s->type,"boolean");
				}
				else{
					strcpy(s->val,"false");
					strcpy(s->type,"boolean");
				}
				return s;
			case GTR_EQ: 
				ff = gtreqEvaluate(p,index);
				if(ff)
				{
					strcpy(s->val,"true");
					strcpy(s->type,"boolean");
				}
				else{
					strcpy(s->val,"false");
					strcpy(s->type,"boolean");
				}
				return s;
			case LESS_EQ: 
				ff = lteqEvaluate(p,index);
				if(ff)
				{
					strcpy(s->val,"true");
					strcpy(s->type,"boolean");
				}
				else{
					strcpy(s->val,"false");
					strcpy(s->type,"boolean");
				}
				return s;
			case NOT_EQ: 
				ff = neqEvaluate(p,index);
				if(ff)
				{
					strcpy(s->val,"true");
					strcpy(s->type,"boolean");
				}
				else{
					strcpy(s->val,"false");
					strcpy(s->type,"boolean");
				}
				return s;
			 case EQ: 
				ff = eqeqEvaluate(p,index);
				if(ff)
				{
					strcpy(s->val,"true");
					strcpy(s->type,"boolean");
				}
				else{
					strcpy(s->val,"false");
					strcpy(s->type,"boolean");
				}
				return s;
			case AND: return andEvaluate(p->opr.op[0],p->opr.op[1],index);
			case OR: return orEvaluate(p->opr.op[0],p->opr.op[1],index);
			case NOT: return notEvaluate(p->opr.op[0],index);
			default:
				break;
		}
		return s;
	}
}

struct type_check *andEvaluate(nodeType *p1,nodeType *p2,int index){
	struct type_check *s1 = exprEvaluate(p1,index);
	struct type_check *s2 = exprEvaluate(p2,index);
	struct type_check *s = malloc(sizeof(struct type_check));
	s->val = malloc(100);
	s->type = malloc(100);
	if(strcmp(s1->val, "false")==0 || strcmp(s2->val, "false")==0){
		strcpy(s->val, "false");
		strcpy(s->type, "boolean");
	}
	else{
		strcpy(s->val, "true");
		strcpy(s->type, "boolean");
	}
	return s;
}

struct type_check *orEvaluate(nodeType *p1,nodeType *p2,int index){
	struct type_check *s1 = exprEvaluate(p1,index);
	struct type_check *s2 = exprEvaluate(p2,index);
	struct type_check *s = malloc(sizeof(struct type_check));
	s->val = malloc(100);
	s->type = malloc(100);
	if(strcmp(s1->val, "true")==0 || strcmp(s2->val, "true")==0){
		strcpy(s->val, "true");
		strcpy(s->type, "boolean");
	}
	else{
		strcpy(s->val, "false");
		strcpy(s->type, "boolean");
	}
	return s;
}

struct type_check *notEvaluate(nodeType *p, int index){
	struct type_check *s1 = exprEvaluate(p,index);
	struct type_check *s = malloc(sizeof(struct type_check));
	s->val = malloc(100);
	s->type = malloc(100);
	if(strcmp(s1->val, "true")==0){
		strcpy(s->val, "false");
		strcpy(s->type, "boolean");
	}
	else{
		strcpy(s->val, "true");
		strcpy(s->type, "boolean");
	}
	return s;
}

struct type_check *addEvaluate(nodeType *p1,nodeType *p2,int index){
	struct type_check *s1 = exprEvaluate(p1,index);
	struct type_check *s2 = exprEvaluate(p2,index);
	float a = atof(s1->val);
	float b = atof(s2->val);
	float c = a+b;
	struct type_check *s = malloc(sizeof(struct type_check));
	s->val = malloc(100);
	s->type = malloc(100);
	sprintf(s->val,"%f",c);
	strcpy(s->type, "real");
	return s;
}
struct type_check *subEvaluate(nodeType *p1,nodeType *p2,int index){
	struct type_check *s1 = exprEvaluate(p1,index);
	struct type_check *s2 = exprEvaluate(p2,index);
	float a = atof(s1->val);
	float b = atof(s2->val);
	float c = a-b;
	struct type_check *s = malloc(sizeof(struct type_check));
	s->val = malloc(100);
	s->type = malloc(100);
	sprintf(s->val,"%f",c);
	strcpy(s->type, "real");
	return s;
}
struct type_check *mulEvaluate(nodeType *p1,nodeType *p2,int index){
	struct type_check *s1 = exprEvaluate(p1,index);
	struct type_check *s2 = exprEvaluate(p2,index);
	float a = atof(s1->val);
	float b = atof(s2->val);
	float c = a*b;
	struct type_check *s = malloc(sizeof(struct type_check));
	s->val = malloc(100);
	s->type = malloc(100);
	sprintf(s->val,"%f",c);
	strcpy(s->type, "real");
	return s;
}
struct type_check *divEvaluate(nodeType *p1,nodeType *p2,int index){
	struct type_check *s1 = exprEvaluate(p1,index);
	struct type_check *s2 = exprEvaluate(p2,index);
	float a = atof(s1->val);
	float b = atof(s2->val);
	float c = a/b;
	struct type_check *s = malloc(sizeof(struct type_check));
	s->val = malloc(100);
	s->type = malloc(100);
	sprintf(s->val,"%f",c);
	strcpy(s->type, "real");
	return s;
}
struct type_check *modEvaluate(nodeType *p1,nodeType *p2,int index){
	struct type_check *s1 = exprEvaluate(p1,index);
	struct type_check *s2 = exprEvaluate(p2,index);
	float a = atof(s1->val);
	float b = atof(s2->val);
	int c = (int)a%(int)b;
	struct type_check *s = malloc(sizeof(struct type_check));
	s->val = malloc(100);
	s->type = malloc(100);
	sprintf(s->val,"%d",c);
	strcpy(s->type, "int");
	return s;
}
void print_Id_Table(){
    printf("ID SYMBOL TABLE----------------------\n");
    printf("Name\t\tType\t\tValue\n");
    for(int i = 0;i<id_count;i++){
        printf("%s\t\t", id_table[i].name);
        printf("%s\t\t", id_table[i].type);
        if(strcmp(id_table[i].type, "int")==0){
        	printf("%d\n", (int)id_table[i].val);
        }
        else if(strcmp(id_table[i].type, "real")==0){
        	printf("%f\n", id_table[i].val);
        }
        else if(strcmp(id_table[i].type, "boolean")==0){
        	if(id_table[i].val == 1){
        		printf("true\n");
        	}
        	else{
        		printf("false\n");
        	}
        }
        else{
        	printf("%c\n", (char)id_table[i].val);
        }
    }
}
void print_Arr_Table(){
	printf("ARR SYMBOL TABLE----------------------\n");
    	printf("Name\t\tType\t\tValue\n");
	for(int i = 0;i<arr_count;i++){
		if(strcmp(arr_table[i].type, "int")==0){
			for(int j = arr_table[i].c1; j <= arr_table[i].c2; j++){
				printf("%s[%d]\t\t", arr_table[i].name, j);
        			printf("%s\t\t", arr_table[i].type);
				printf("%d\n", (int)arr_table[i].val[j]);
			}
		}
		else if(strcmp(arr_table[i].type, "real")==0){
			for(int j = arr_table[i].c1; j <= arr_table[i].c2; j++){
				printf("%s[%d]\t\t", arr_table[i].name, j);
        			printf("%s\t\t", arr_table[i].type);
				printf("%f\n", arr_table[i].val[j]);
			}
		}
		else if(strcmp(arr_table[i].type, "boolean")==0){
			for(int j = arr_table[i].c1; j <= arr_table[i].c2; j++){
				printf("%s[%d]\t\t", arr_table[i].name, j);
        			printf("%s\t\t", arr_table[i].type);
				if(arr_table[i].val[j] == 1){
					printf("true\n");
				}
				else{
					printf("false\n");
				}
			}
		}
		else{
			for(int j = arr_table[i].c1; j <= arr_table[i].c2; j++){
				printf("%s[%d]\t\t", arr_table[i].name, j);
        			printf("%s\t\t", arr_table[i].type);
				printf("%c\n", (char)arr_table[i].val[j]);
			}
		}
    	}
}
