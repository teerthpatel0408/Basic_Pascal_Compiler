#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stdbool.h>
#include<limits.h>

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

char *keywords[] = {"program", "integer", "real", "boolean", "char", "var", "to", "downto", "if", "else", "while", "for", "do", "array", "and", "or", "not", "begin", "end", "read", "write", NULL};

void isKeyword(char *name){
	for(int i = 0; keywords[i] != NULL; i++){
		if(strcmp(keywords[i], name) == 0){
			printf("ERROR: %s is a keyword and cannot be used as a variable name.", name);
			exit(0);
		}
	}
}

int id_count = 0;
int arr_count = 0;

id_sym id_table[1000];
arr_sym arr_table[1000];

void convert_to_lowercase(char *str) {
  while (*str) {
    *str = tolower(*str);
    str++;
  }
}

char *findIdType(char *name){
    convert_to_lowercase(name);
    for(int i = 0; i<id_count; i++){
        if(strcmp(id_table[i].name, name) == 0){
            return id_table[i].type;
        }
    }
    printf("ERROR: Variable %s not declared\n", name);
    exit(0);
}

char *findArrType(char *name){
    convert_to_lowercase(name);
    for(int i = 0; i<arr_count; i++){
        if(strcmp(arr_table[i].name, name) == 0){
            return arr_table[i].type;
        }
    }
    printf("ERROR: Array %s not declared\n", name);
    exit(0);
}

bool isPresentId(char *name){
    convert_to_lowercase(name);
    for(int i = 0; i<id_count; i++){
        if(strcmp(id_table[i].name, name) == 0){
            return true;
        }
    }
    return false;
}

bool isPresentArr(char *name){
    convert_to_lowercase(name);
    for(int i = 0; i<arr_count; i++){
        if(strcmp(arr_table[i].name, name) == 0){
            return true;
        }
    }
    return false;
}

float findArrVal(char *name, int index){
    convert_to_lowercase(name);
    for(int i = 0; i<arr_count; i++){
        if(strcmp(arr_table[i].name, name) == 0){
            return arr_table[i].val[index];
        }
    }
    printf("ERROR: Array %s not declared\n", name);
    exit(0);
}

void insertArr(char *name, char *type, int c1, int c2){
    convert_to_lowercase(name);
    isKeyword(name);
    if(isPresentId(name)){
        printf("ERROR: Identifier %s already declared\n", name);
        exit(0);
    }
    for(int i = 0; i<arr_count; i++){
        if(strcmp(arr_table[i].name, name) == 0){
            printf("ERROR: Array %s already declared\n", name);
            exit(0);
        }
    }
    arr_table[arr_count] = *(arr_sym*)malloc(sizeof(arr_sym));
    arr_table[arr_count].name = strdup(name);
    arr_table[arr_count].type = strdup(type);
    arr_table[arr_count].c1 = c1;
    arr_table[arr_count].c2 = c2;
    for(int i=c1;i<=c2;i++){
    	arr_table[arr_count].val[i]=0;
    }
    arr_count++;
}

void insertID(char *name, char *type){
    convert_to_lowercase(name);
    isKeyword(name);
    if(isPresentArr(name)){
        printf("ERROR: Array %s already declared\n", name);
        exit(0);
        
    }
    for(int i = 0; i<id_count; i++){
        if(strcmp(id_table[i].name, name) == 0){
            printf("ERROR: Variable %s already declared\n", name);
            exit(0);
        }
    }
    id_table[id_count] = *(id_sym*)malloc(sizeof(id_sym));
    id_table[id_count].name = strdup(name);
    id_table[id_count].type = strdup(type);
    id_table[id_count].val = INT_MIN;
    id_count++;
}

void typeCheck(char *name, char *type){
    convert_to_lowercase(name);
    bool found = true;
    for(int i = 0; i<id_count; i++){
        if(strcmp(id_table[i].name, name) == 0){
            found = false;
            if(strcmp(id_table[i].type, type) != 0){
                printf("ERROR: Type mismatch for %s\n", name);
                exit(0);
            }
            break;
        }
    }
    if(found){
        printf("ERROR: Variable %s not declared\n", name);
        exit(0);
    }
}


void typeCheckArr(char *name, char *type){
    convert_to_lowercase(name);
    bool found = true;
    for(int i = 0; i<arr_count; i++){
        if(strcmp(arr_table[i].name, name) == 0){
            found = false;
            if(strcmp(arr_table[i].type, type) != 0){
                printf("ERROR: Type mismatch for %s\n", name);
                exit(0);
            }
            break;
        }
    }
    if(found){
        printf("ERROR: Array %s not declared\n", name);
        exit(0);
    }
}


bool findArrSize(char *name, int index){
    convert_to_lowercase(name);
    for(int i = 0; i<arr_count; i++){
        if(strcmp(arr_table[i].name, name) == 0){
            if(index > arr_table[i].c2 || index < arr_table[i].c1){
            	return false;
            }
            return true;
        }
    }
    printf("ERROR: Array %s not declared\n", name);
    exit(0);
}

void updateID(char *name, float val){
    convert_to_lowercase(name);
    for(int i = 0; i<id_count; i++){
        if(strcmp(id_table[i].name, name) == 0){
            id_table[i].val = val;
        }
    }
}

void updateArr(char *name, int index, float val){
    convert_to_lowercase(name);
    for(int i = 0; i<arr_count; i++){
        if(strcmp(arr_table[i].name, name) == 0){
            arr_table[i].val[index] = val;
        }
    }
}

void print_Id_Table(){
    printf("\nNEW SYMBOL TABLE----------------------\n");
    for(int i = 0;i<id_count;i++){
        if(strcmp(id_table[i].type, "int") == 0)
            printf("%s\t%s\t%d\n", id_table[i].name, id_table[i].type, (int)id_table[i].val);
        else if(strcmp(id_table[i].type, "real") == 0)
            printf("%s\t%s\t%f\n", id_table[i].name, id_table[i].type, id_table[i].val);
        else if(strcmp(id_table[i].type, "char") == 0)
            printf("%s\t%s\t%c\n", id_table[i].name, id_table[i].type, (int)id_table[i].val+'a');
    }
}

void print_Arr_Table(){
    printf("\nNEW ARRAY TABLE----------------------\n");
    for(int i = 0; i < arr_count; i++){
        printf("%s\t%s\t%d\t%d\n", arr_table[i].name, arr_table[i].type, arr_table[i].c1, arr_table[i].c2);
    }
}

int comparator(float a, float b, char *op){
    if(strcmp(op,">")==0){
        return a>b;
    }
    else if(strcmp(op,"<")==0){
        return a<b;
    }
    else if(strcmp(op,">=")==0){
        return a>=b;
    }
    else if(strcmp(op,"<=")==0){
        return a<=b;
    }
    else if(strcmp(op,"<>")==0){
        return a!=b;
    }
    else if(strcmp(op,"and")==0){
        return a&&b;
    }
    else if(strcmp(op,"or")==0){
        return a||b;
    }
    else if(strcmp(op,"=")==0){
        return a==b;
    }
    else{
        printf("ERROR: Invalid operator\n");
        exit(0);
    }
}
