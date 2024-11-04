%{
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

extern int yylex(void);
extern int yyparse(void);
extern FILE *yyin;
extern int yylineno;
extern char *yytext;

void yyerror(const char *s);
int goto_line = -1;

typedef enum { STMT_VAR_DECL, STMT_ASSIGN,STMT_WHILE, STMT_ASSIGN_S,STMT_PRINT_BS,STMT_PRINT_N, STMT_PRINT_F, STMT_PRINT_S, STMT_IF,STMT_IF_COMPARE,STMT_STRING, STMT_FUNC_DEF, STMT_FUNC_CALL } stmt_type;

typedef struct statement {
    stmt_type type;
    union {
        struct {
            char *var;
            int ivalue;
            float fvalue;
            char *st;
            int count;
        } assignment;
        struct {
            char *var;
            int Iv, Fv, Cv;
        } var_decl;
        struct {
            int ivalue;
            float fvalue;
            char *s;
        } print;
        struct {
            int condition,big_small,opcondition;
            struct statement_list *if_stmt;
            struct statement_list *else_stmt;
        } if_stmt;
		struct {
            int times;
            struct statement_list *while_stmt;
        } while_stmt;
        char *string;
        struct {
            char *name;
            struct statement_list *body;
        } func_def;
        struct {
            char *name;
        } func_call;
    } data;
} statement;

typedef struct statement_list {
    statement *stmt;
    struct statement_list *next;
} statement_list;

typedef struct function {
    char *name;
    statement_list *body;
    struct function *next;
} function;

typedef struct {
    char *name;
    int ivalue;
    float fvalue;
    char *str_value;
    int Iv, Fv, Cv;
} variable;

variable vars[100]; // 최대 100개의 변수 저장
int var_count = 0;

function *functions = NULL;

void add_statement(statement_list **list, statement *stmt) {
    statement_list *new_node = (statement_list *)malloc(sizeof(statement_list));
    new_node->stmt = stmt;
    new_node->next = NULL;

    if (*list == NULL) {
        *list = new_node;
    } else {
        statement_list *current = *list;
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = new_node;
    }
}

void add_function(char *name, statement_list *body) {
    function *new_func = (function *)malloc(sizeof(function));
    new_func->name = _strdup(name);
    new_func->body = body;
    new_func->next = functions;
    functions = new_func;
}

statement_list *find_function(char *name) {
    function *current = functions;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current->body;
        }
        current = current->next;
    }
    return NULL;
}

void process_statements(statement_list *list) {
    statement_list *current = list;
    while (current != NULL) {
        statement *stmt = current->stmt;
        switch (stmt->type) {
            case STMT_VAR_DECL:
                break;
            case STMT_ASSIGN:
                for (int i = 0; i < var_count; i++) {
                    if (strcmp(vars[i].name, stmt->data.assignment.var) == 0) {
                        if (vars[i].Iv == 1) {
                            vars[i].ivalue = stmt->data.assignment.ivalue;                 
                        } else if (vars[i].Fv == 1) {
                            vars[i].fvalue = stmt->data.assignment.fvalue;  
                        }
                        break;
                    }
                }
                break;
            case STMT_ASSIGN_S:
                for (int i = 0; i < var_count; i++) {
                    if (strcmp(vars[i].name, stmt->data.assignment.var) == 0) {
                        vars[i].str_value = stmt->data.assignment.st;
                        break;
                    }
                }
                break;
            case STMT_PRINT_N:
                printf("%d", stmt->data.print.ivalue);
                break;
            case STMT_PRINT_F:
                printf("%f", stmt->data.print.fvalue);
                break;
            case STMT_PRINT_S:
                printf("%s", stmt->data.print.s);
                break;
			case STMT_PRINT_BS:
                printf("\n");
                break;
            case STMT_IF:
                if (stmt->data.if_stmt.condition) {
                    process_statements(stmt->data.if_stmt.if_stmt);
                } else {
                    process_statements(stmt->data.if_stmt.else_stmt);
                }
                break;
			case STMT_IF_COMPARE:
                if (stmt->data.if_stmt.big_small==1) {
                    if(stmt->data.if_stmt.condition > stmt->data.if_stmt.opcondition){
					process_statements(stmt->data.if_stmt.if_stmt);
					}else{
					process_statements(stmt->data.if_stmt.else_stmt);
					}
                } else if(stmt->data.if_stmt.big_small==2){
                    if(stmt->data.if_stmt.condition >= stmt->data.if_stmt.opcondition){
					process_statements(stmt->data.if_stmt.if_stmt);
					}else{
					process_statements(stmt->data.if_stmt.else_stmt);
					}
                }else if(stmt->data.if_stmt.big_small==3){
					if(stmt->data.if_stmt.condition < stmt->data.if_stmt.opcondition){
					process_statements(stmt->data.if_stmt.if_stmt);
					}else{
					process_statements(stmt->data.if_stmt.else_stmt);
					}
				}
				else if(stmt->data.if_stmt.big_small==4){
				if(stmt->data.if_stmt.condition <= stmt->data.if_stmt.opcondition){
					process_statements(stmt->data.if_stmt.if_stmt);
					}else{
					process_statements(stmt->data.if_stmt.else_stmt);
					}
				}
                break;
			case STMT_WHILE:
                for(int k=0;k<stmt->data.while_stmt.times;k++){
				process_statements(stmt->data.while_stmt.while_stmt);
				}
				break;
            case STMT_STRING:
				printf("%s\n",stmt->data.string);
                break;
            case STMT_FUNC_DEF:
                add_function(stmt->data.func_def.name, stmt->data.func_def.body);
                break;
            case STMT_FUNC_CALL:
                statement_list *func_body = find_function(stmt->data.func_call.name);
                if (func_body != NULL) {
                    process_statements(func_body);
                } else {
                    printf("Error: Function %s not defined\n", stmt->data.func_call.name);
                }
                break;
            default:
                printf("Unknown statement type\n");
                break;
        }
        current = current->next;
    }
}

%}

%union {
    int ival;
    float fval;
    char *sval;
    struct statement *stmt;
    struct statement_list *stmt_list;
}

%token <sval> START END INT FLOAT CHAR PLUS1 MULT DIV ADD SUB PRINT PRINT_END LOOP IF QUESTION INPUT LBRACKET RBRACKET IDENTIFIER PSTRING LEND ELS STRING FUNC DEF CALL FEND ASSIGN RSTRING SVALUE BSN BIGGER BIG SMALL SMALLER WHILE
%token <ival> NUMBER EOL IVALUE
%token <fval> FVALUE

%type <ival> expression term factor number variable
%type <sval> statements statement variable_declaration assignment print_statement if_statement string_statement function_definition function_call BackSlash bigger_or_smaller while_statement
%left ADD SUB
%left MULT DIV
%right ASSIGN
%nonassoc IFX

%%

program:
    START statements END { printf("Parsing completed.\n"); process_statements($2); }
;

statements:
    { $$ = NULL; }
    | statements statement { add_statement(&$$, $2); }
    | statements EOL { $$ = $1; /* 빈 줄 무시 */ }
;

statement:
    variable_declaration
    | assignment
    | print_statement
    | if_statement
    | string_statement
    | function_definition
    | function_call
	| BackSlash
	| bigger_or_smaller
	| while_statement
;

BackSlash:
	BSN EOL{
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_PRINT_BS;
        $$ = stmt;
	}
;
variable_declaration:
    INT IDENTIFIER EOL {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_VAR_DECL;
        stmt->data.var_decl.var = _strdup($2); 
        stmt->data.var_decl.Iv = 1;
        vars[var_count].name = stmt->data.var_decl.var;
        vars[var_count].ivalue = 0;
        vars[var_count].Iv = 1;
        var_count++;
        $$ = stmt;
        free($2);
    }
    | FLOAT IDENTIFIER EOL {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_VAR_DECL;
        stmt->data.var_decl.var = _strdup($2); 
        stmt->data.var_decl.Fv = 1;
        vars[var_count].name = stmt->data.var_decl.var;
        vars[var_count].fvalue = 0.0;
        vars[var_count].Fv = 1;
        var_count++;
        $$ = stmt;
        free($2);
    }
    | CHAR IDENTIFIER EOL {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_VAR_DECL;
        stmt->data.var_decl.var = _strdup($2); 
        stmt->data.var_decl.Cv = 1;
        vars[var_count].name = stmt->data.var_decl.var;
        vars[var_count].str_value = NULL;
        vars[var_count].Cv = 1;
        var_count++;
        $$ = stmt;
        free($2);
    }
;

assignment:
    IDENTIFIER ASSIGN expression EOL {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_ASSIGN;
        stmt->data.assignment.var = _strdup($1);
        for (int i = 0; i < var_count; i++) {
            if (strcmp(vars[i].name, $1) == 0) {
                if (vars[i].Iv) {
                    stmt->data.assignment.ivalue = $3;
                    vars[i].ivalue = $3;
                } else if (vars[i].Fv) {
                    stmt->data.assignment.fvalue = (float)$3;
                    vars[i].fvalue = (float)$3;
                } else {
                    yyerror("Type error: variable type not defined.");
                }
                break;
            }
        }
        $$ = stmt;
        free($1);
    }
    | IDENTIFIER ASSIGN RSTRING EOL {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_ASSIGN_S;
        stmt->data.assignment.var = _strdup($1);
        stmt->data.assignment.st = _strdup($3);
        for (int i = 0; i < var_count; i++) {
            if (strcmp(vars[i].name, $1) == 0) {
                vars[i].str_value = _strdup($3);
                break;
            }
        }
        $$ = stmt;
        free($1);
    }
;

expression:
    expression ADD term { $$ = $1 + $3; }
    | expression SUB term { $$ = $1 - $3; }
    | term 
;

term:
    term MULT factor { $$ = $1 * $3; }
    | term DIV factor { $$ = $1 / $3; }
    | factor
;

string_statement:
    PSTRING EOL {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_STRING;
        stmt->data.string = $1;
        $$ = stmt;
    }
;

factor:
    variable PLUS1 { $$ = $1 + 1; }
    | variable
    | number
;

variable:
    IDENTIFIER {
        int i;
        for (i = 0; i < var_count; i++) {
            if (strcmp(vars[i].name, $1) == 0) {
                if (vars[i].Iv) { $$ = vars[i].ivalue; }
                else if (vars[i].Fv) { $$ = (float)vars[i].fvalue; }
                else if (vars[i].Cv) { $$ = (char *)vars[i].str_value; }
                else { yyerror("type error: variable type not defined"); }
                break;
            }
        }
        if (i == var_count) {
            yyerror("Undefined variable");
            $$ = 0;
        }
        free($1);
    }
;
number:
    NUMBER { $$ = $1; }
;

print_statement:
    PRINT IVALUE expression PRINT_END EOL {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_PRINT_N;
        stmt->data.print.ivalue = $3;     
        $$ = stmt;
    }
    | PRINT FVALUE expression PRINT_END EOL {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_PRINT_F;
        stmt->data.print.fvalue = $3;    
        $$ = stmt;
    }
	
	| PRINT SVALUE IDENTIFIER PRINT_END EOL {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_PRINT_S;
        for (int i = 0; i < var_count; i++) {
            if (strcmp(vars[i].name, $3) == 0) {
                stmt->data.print.s = _strdup(vars[i].str_value);
                break;
            }
        }
        $$ = stmt;
    }
    | PRINT RSTRING PRINT_END EOL {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_PRINT_S;
        stmt->data.print.s = _strdup($2);
        $$ = stmt;
    }
;

bigger_or_smaller:
	BIG {$$ = 1;}
	|BIGGER{$$ = 2;}
	|SMALL{$$ = 3;}
	|SMALLER{$$ = 4;}

if_statement:
    IF expression QUESTION statement ELS statement EOL { 
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_IF;
        stmt->data.if_stmt.condition = $2;
        stmt->data.if_stmt.if_stmt = (statement_list *)malloc(sizeof(statement_list));
        stmt->data.if_stmt.if_stmt->stmt = $4;
        stmt->data.if_stmt.if_stmt->next = NULL;
        stmt->data.if_stmt.else_stmt = (statement_list *)malloc(sizeof(statement_list));
        stmt->data.if_stmt.else_stmt->stmt = $6;
        stmt->data.if_stmt.else_stmt->next = NULL;
        $$ = stmt;
    } 
    | IF expression bigger_or_smaller expression statement ELS statement EOL { 
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_IF_COMPARE;
        stmt->data.if_stmt.condition = $2;
        stmt->data.if_stmt.big_small = $3;
        stmt->data.if_stmt.opcondition = $4;
        stmt->data.if_stmt.if_stmt = (statement_list *)malloc(sizeof(statement_list));
        stmt->data.if_stmt.if_stmt->stmt = $5;
        stmt->data.if_stmt.if_stmt->next = NULL;
        stmt->data.if_stmt.else_stmt = (statement_list *)malloc(sizeof(statement_list));
        stmt->data.if_stmt.else_stmt->stmt = $7;
        stmt->data.if_stmt.else_stmt->next = NULL;
        $$ = stmt;
    }
;

while_statement:
    WHILE expression statement EOL { 
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_WHILE;
        stmt->data.while_stmt.times = $2;
        stmt->data.while_stmt.while_stmt = (statement_list *)malloc(sizeof(statement_list));
        stmt->data.while_stmt.while_stmt->stmt = $3;
        stmt->data.while_stmt.while_stmt->next = NULL;
        $$ = stmt;
    }
;

function_definition:
    FUNC IDENTIFIER DEF statements FEND {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_FUNC_DEF;
        stmt->data.func_def.name = $2;
        stmt->data.func_def.body = $4;
        $$ = stmt;
    }
;

function_call:
    CALL IDENTIFIER EOL {
        statement *stmt = (statement *)malloc(sizeof(statement));
        stmt->type = STMT_FUNC_CALL;
        stmt->data.func_call.name = $2;
        $$ = stmt;
    }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s at line %d, near '%s'\n", s, yylineno, yytext);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Could not open file: %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    }
    //yydebug = 1; // Enable debug output
    yyparse();
    return 0;
}
