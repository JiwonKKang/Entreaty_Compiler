%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define DEBUG	0

#define	 MAXSYM	100
#define	 MAXSYMLEN	20
#define	 MAXTSYMLEN	15
#define	 MAXTSYMBOL	MAXSYM/2

#define STMTLIST 500

typedef struct nodeType {
	int token;
	int tokenval;
	struct nodeType *son;
	struct nodeType *brother;
	} Node;

#define YYSTYPE Node*

int tsymbolcnt=0;
int errorcnt=0;

FILE *yyin;
FILE *fp;

extern char symtbl[MAXSYM][MAXSYMLEN];
extern int maxsym;
extern int lineno;
void yyerror(char *c);
int yylex();
int cnt=0;
int f_cnt=0;
int cb_cnt=0;
int fe_cnt=0;
char str[50];
int w_cnt;
int for_cnt;
int tl_cnt;
int if_cnt;
int ife_cnt;
int inner_if_cnt;
int inner_w_cnt;
int inner_f_cnt;
int w_c_cnt;
int f_c_cnt;
int inner_e_cnt;
int case_cnt;
int s_cnt;

void DFSTree(Node*);
Node * MakeOPTree(int, Node*, Node*);
Node * MakeNode(int, int);
Node * MakeListTree(Node*, Node*);
void codegen(Node*);
void prtcode(int, int);

void	dwgen();
int	gentemp();
void	assgnstmt(int, int);
void	numassgn(int, int);
void	addstmt(int, int, int);
void	substmt(int, int, int);
int	insertsym(char *);
int	if_cond_check(int);
int	w_cond_check(int);
int	t_cond_check(int);
int	f_cond_check(int);
int 	count_if_nodes(Node*);
int	count_while_nodes(Node*);
int	count_f_nodes(Node*);
int 	count_e_nodes(Node*);

%}

%token	ADD SUB ASSGN ID NUM STMTEND START END ID2 MUL DIV LB RB OPEN CLOSE IF ELSE LT GT LE GE EQ NE WHILE IF_ELSE REAL ID4 
%token  AA SA MA DA ID3 LOOPCON LOOPEND FUNC FSTMT FUNCEND CALLBACK FNAME FOR FORSTLI FORCON FORSTART QM COLON TLVAL TSTMT TERN TEX TCON
%token  SCANF COMMA PD SCAN UPC AND PRINTF PRINT WLOOPEND FLOOPEND IF_LT IF_GT IF_LE IF_GE IF_EQ IF_NE W_LT W_GT W_LE W_GE W_EQ W_NE
%token	T_LT T_GT T_LE T_GE T_EQ T_NE F_LT F_GT F_LE F_GE F_EQ F_NE SWAPS SWAPE SWAPM SWAPH ID5 SWAP DEFAULT CASES SWITCHH
%token	CASEL CASEM CASEH CASE SWITCH BREAK IS THEN WA THIS SAVE RUN ING LAST LOOP ID6 ID7 INC DEC NOW CALL IN CONTENT INIT FN VAL
%right ASSGN
%left ADD SUB
%left MUL DIV

%%
program	: START stmt_list END	{ if (errorcnt==0) {codegen($2); dwgen();} }
		;

stmt_list	: 	stmt_list stmt 	{$$=MakeListTree($1, $2);}
		|	stmt			{$$=MakeListTree(NULL, $1);}
		| 	error STMTEND	{ errorcnt++; yyerrok;}
		;

stmt		: 	ID ASSGN expr THIS SAVE STMTEND	{ $1->token = ID2; $$=MakeOPTree(ASSGN, $1, $3);}
		|	loop_con LB stmt_list RB LOOP STMTEND	{$$=MakeOPTree(WHILE, $1, $3);}
		|	t_stmt t_expr 	{ $$=MakeOPTree(TERN, $1, $2); }	
		|	ID AA expr { $1->token= ID3; $$=MakeOPTree(AA, $1, $3); } 
		|	ID SA expr { $1->token= ID3; $$=MakeOPTree(SA, $1, $3); }
		|	ID MA expr { $1->token= ID3; $$=MakeOPTree(MA, $1, $3); }
		|	ID DA expr { $1->token= ID3; $$=MakeOPTree(DA, $1, $3); }
		|	FUNC FNAME AND CONTENT LB f_stmt_list RB IN FN THIS INIT STMTEND{ $$=MakeOPTree(FUNC, $6, NULL); }
		|	FOR for_con for_stmt_list	{ $$=MakeOPTree(FOR, $2, $3); }
		|	ID VAL SCANF {$1->token=ID2; $$=MakeOPTree(SCAN, $1, NULL);}
		|	ID VAL PRINTF STMTEND { $$=MakeOPTree(PRINT, $1, NULL); }
		|	swap_h SWAP 	{$$=MakeOPTree(SWAPE, $1, NULL); }	
		|	if_stmt else_stmt { $$=MakeOPTree(IF_ELSE, $1, $2); }
		| 	if_stmt
		|	inc_dec_stmt STMTEND
		|	call_back
		|	switch_stmt default_stmt	{ $$=MakeOPTree(SWITCH, $1, $2); }
		;

inc_dec_stmt 	:	ID INC { $1->token=ID6; $$=MakeOPTree(INC, $1, NULL); }
		|	ID DEC { $1->token=ID7; $$=MakeOPTree(DEC, $1, NULL); }
		;

switch_stmt	:	SWITCH ID IS case_list {$2->token=ID4; $$=MakeOPTree(SWITCHH, $2, $4);}
		;

case_list		:	case_list case_h				{$$=MakeListTree($1, $2); }
		|	case_h 				 	{$$=MakeListTree(NULL, $1); }
		;

default_stmt	:	DEFAULT COLON stmt_list BREAK	{$$=MakeOPTree(DEFAULT, $3, NULL); }
		;

case_h		:	case_m COLON stmt_list BREAK	{$$=MakeOPTree(CASEH, $1, $3);}
		;

case_m		:	NUM CASE case_l 	{$$=MakeOPTree(CASEM, $3, $2);} //todo
		;

case_l		:	{$$=MakeNode(CASEL,CASEL);}
		;

swap_h		:	swap_m ID 	{$2->token=ID5; $$=MakeOPTree(SWAPH, $1, $2);}

swap_m		:	ID WA swap_s	{$1->token=ID5; $$=MakeOPTree(SWAPM, $3, $1);}
		;

swap_s		:	{$$=MakeNode(SWAPS,SWAPS);}
		;

t_stmt		:	t_con t_expr ELSE {$$=MakeOPTree(TSTMT, $1, $2); }
		;

t_expr		:	t_lval expr THIS SAVE STMTEND { $$=MakeOPTree(TEX, $1, $2); }
		;

t_lval		:	{$$=MakeNode(TLVAL, TLVAL);}
		;

t_con		:	ID ASSGN condition {$3->token=t_cond_check($3->token); $1->token=ID4; $$=MakeOPTree(TCON, $1, $3);}

for_stmt_list	:	LAST stmt ING LB stmt_list RB LOOP STMTEND	{$$=MakeOPTree(FORSTLI, $5, $2);}
		;

for_con		:	for_start condition	{$2->token=f_cond_check($2->token); $$=MakeOPTree(FORCON, $1, $2);}
		;
for_start		:	stmt floop_end	{$$=MakeOPTree(FORSTART, $1, $2);}
		;

f_stmt_list 	:	stmt_list f_end	   {$$=MakeOPTree(FSTMT, $2, $1);}
		;
floop_end		:	{ $$=MakeNode(FLOOPEND, FLOOPEND); };

f_end		:	{ $$=MakeNode(FUNCEND, FUNCEND); }
		;


call_back		:	FNAME THIS CALL STMTEND {$$=MakeNode(CALLBACK, CALLBACK);}
		;

loop_con		:	condition wloop_end {$1->token=w_cond_check($1->token); $$=MakeOPTree(LOOPCON, $2, $1); };

wloop_end	:	{ $$=MakeNode(WLOOPEND, WLOOPEND); };


if_stmt		:	IF condition LB stmt_list RB RUN STMTEND {$2->token=if_cond_check($2->token); $$=MakeOPTree(IF, $2, $4); }
		;


else_stmt		:	ELSE LB stmt_list RB RUN STMTEND { $$=MakeOPTree(ELSE, $3, NULL); }
		;



condition      	 :    expr IS expr WA EQ { $$=MakeOPTree(EQ, $1, $3);}
		|     expr IS expr THEN LT { $$=MakeOPTree(LT, $1, $3);}
		|     expr IS expr THEN GT { $$=MakeOPTree(GT, $1, $3);}
		|     expr IS expr THEN LE { $$=MakeOPTree(LE, $1, $3);}
		|     expr IS expr THEN GE { $$=MakeOPTree(GE, $1, $3);}
		|     expr IS expr WA NE { $$=MakeOPTree(NE, $1, $3);}
		;

	

expr		: 	expr ADD term	{ $$=MakeOPTree(ADD, $1, $3); }
		|	expr SUB term	{ $$=MakeOPTree(SUB, $1, $3); }
		|	term
		;
    

term   		:       term MUL factor { $$=MakeOPTree(MUL, $1, $3); }
       		|       term DIV factor { $$=MakeOPTree(DIV, $1, $3); }
       		|       factor
       		;



factor		:	ID		{ /* ID node is created in lex */ }
		|	NUM		{ /* NUM node is created in lex */ }
		;


%%
int main(int argc, char *argv[]) 
{
	printf("\nsample CBU compiler v2.0\n");
	printf("(C) Copyright by Jae Sung Lee (jasonlee@cbnu.ac.kr), 2022.\n");
	
	if (argc == 2)
		yyin = fopen(argv[1], "r");
	else {
		printf("Usage: cbu2 inputfile\noutput file is 'a.asm'\n");
		return(0);
		}
		
	fp=fopen("a.asm", "w");
	
	yyparse();
	
	fclose(yyin);
	fclose(fp);

	if (errorcnt==0) 
		{ printf("Successfully compiled. Assembly code is in 'a.asm'.\n");}
}

void yyerror(char *s)
{
	printf("%s (line %d)\n", s, lineno);
}


Node * MakeOPTree(int op, Node* operand1, Node* operand2)
{
Node * newnode;

	newnode = (Node *)malloc(sizeof (Node));
	newnode->token = op;
	newnode->tokenval = op;
	newnode->son = operand1;
	newnode->brother = NULL;
	operand1->brother = operand2;
	return newnode;
}

Node * MakeNode(int token, int operand)
{
Node * newnode;

	newnode = (Node *) malloc(sizeof (Node));
	newnode->token = token;
	newnode->tokenval = operand; 
	newnode->son = newnode->brother = NULL;
	return newnode;
}

Node * MakeListTree(Node* operand1, Node* operand2)
{
Node * newnode;
Node * node;

	if (operand1 == NULL){
		newnode = (Node *)malloc(sizeof (Node));
		newnode->token = newnode-> tokenval = STMTLIST;
		newnode->son = operand2;
		newnode->brother = NULL;
		return newnode;
		}
	else {
		node = operand1->son;
		while (node->brother != NULL) node = node->brother;
		node->brother = operand2;
		return operand1;
		}
}

void codegen(Node * root)
{
	DFSTree(root);
}

void DFSTree(Node * n)
{
	Node * brother;
	if (n==NULL) return;
	
	DFSTree(n->son);
	if (n->token == IF) {
		inner_if_cnt = count_if_nodes(n->son);
		if(n->brother != NULL) {
			if(n->brother->token == ELSE) {
				fprintf(fp, "GOTO ELSELABEL%d\n", (++ife_cnt));
			}
		}
	}
	if(n->token == WHILE) {
		inner_w_cnt = count_while_nodes(n->son);
	}
	if(n->token == FOR) {
		inner_f_cnt = count_f_nodes(n->son);
	}
	if(n->token == ELSE) {
		inner_e_cnt = count_e_nodes(n->son);
	}
	prtcode(n->token, n->tokenval);
	DFSTree(n->brother);
	
}

int if_cond_check(int token) 
{
	if (token == EQ) {
		return IF_EQ;
	}
	if (token == LT) {
		return IF_LT;
	} 
	if (token == LE) {
		return IF_LE;
	} 
	if (token == GT) {
		return IF_GT;
	} 
	if (token == GE) {
		return IF_GE;
	} 
	if (token == NE) {
		return IF_NE;
	}  
}

int w_cond_check(int token) 
{
	if (token == EQ) {
		return W_EQ;
	}
	if (token == LT) {
		return W_LT;
	} 
	if (token == LE) {
		return W_LE;
	} 
	if (token == GT) {
		return W_GT;
	} 
	if (token == GE) {
		return W_GE;
	} 
	if (token == NE) {
		return W_NE;
	}  
}

int f_cond_check(int token) 
{
	if (token == EQ) {
		return F_EQ;
	}
	if (token == LT) {
		return F_LT;
	} 
	if (token == LE) {
		return F_LE;
	} 
	if (token == GT) {
		return F_GT;
	} 
	if (token == GE) {
		return F_GE;
	} 
	if (token == NE) {
		return F_NE;
	}  
}

int t_cond_check(int token) 
{
	if (token == EQ) {
		return T_EQ;
	}
	if (token == LT) {
		return T_LT;
	} 
	if (token == LE) {
		return T_LE;
	} 
	if (token == GT) {
		return T_GT;
	} 
	if (token == GE) {
		return T_GE;
	} 
	if (token == NE) {
		return T_NE;
	}  
}

int count_if_nodes(Node *n) {
    if (n == NULL) {
        return 0;
    }
    
    int count = 0;
    
    if (n->token == IF) {
        count++;
    }
    
    count += count_if_nodes(n->son);
    count += count_if_nodes(n->brother);
    
    return count;
}

int count_while_nodes(Node *n) {
    if (n == NULL) {
        return 0;
    }
    
    int count = 0;
    
    if (n->token == WHILE) {
        count++;
    }

    count += count_while_nodes(n->son);
    count += count_while_nodes(n->brother);
    
    return count;
}

int count_f_nodes(Node *n) {
    if (n == NULL) {
        return 0;
    }
    
    int count = 0;
    
    if (n->token == FOR) {
        count++;
    }

    count += count_f_nodes(n->son);
    count += count_f_nodes(n->brother);
    
    return count;
}

int count_e_nodes(Node *n) {
    if (n == NULL) {
        return 0;
    }
    
    int count = 0;
    
    if (n->token == ELSE) {
        count++;
    }

    count += count_e_nodes(n->son);
    count += count_e_nodes(n->brother);
    
    return count;
}


void prtcode(int token, int val)
{
	
	switch (token) {
	case ID:
		fprintf(fp,"RVALUE %s\n", symtbl[val]);
		break;
	case ID2:
		fprintf(fp, "LVALUE %s\n", symtbl[val]);
		break;
	case ID3:
		fprintf(fp, "LVALUE %s\n", symtbl[val]);
		fprintf(fp, "RVALUE %s\n", symtbl[val]);
		break;
	case ID4:
		strcpy(str, symtbl[val]);
		break;
	case ID5:
		fprintf(fp, "RVALUE %s\n", symtbl[val]);
		fprintf(fp, ":=\n");
		fprintf(fp, "LVALUE %s\n", symtbl[val]);
		break;
	case ID6:
		fprintf(fp, "LVALUE %s\n", symtbl[val]);
		fprintf(fp, "RVALUE %s\n", symtbl[val]);
		fprintf(fp, "PUSH 1\n");
		fprintf(fp, "+\n");
		fprintf(fp, ":=\n");
		break;
	case ID7:
		fprintf(fp, "LVALUE %s\n", symtbl[val]);
		fprintf(fp, "RVALUE %s\n", symtbl[val]);
		fprintf(fp, "PUSH 1");
		fprintf(fp, "-\n");
		fprintf(fp, ":=\n");
		break;
	case NUM:
		fprintf(fp, "PUSH %d\n", val);
		break;
	case ADD:
		fprintf(fp, "+\n");
		break;
	case SUB:
		fprintf(fp, "-\n");
		break;
	case MUL:
		fprintf(fp, "*\n");
		break;
	case DIV:
		fprintf(fp, "/\n");
		break;
	case ASSGN:
		fprintf(fp, ":=\n");
		break;
	case IF:
      		fprintf(fp, "LABEL IFLABEL%d\n", if_cnt - inner_if_cnt);
      		break;
	case IF_ELSE:
		fprintf(fp, "LABEL ELSELABEL%d\n", ife_cnt-inner_e_cnt);
		break;
	case IF_EQ:
		fprintf(fp, "-\n");
      		fprintf(fp, "GOTRUE IFLABEL%d\n", ++if_cnt);
      		break;
	case IF_NE:
		fprintf(fp, "-\n");
      		fprintf(fp, "GOFALSE IFLABEL%d\n", ++if_cnt);
      		break;
	case IF_LT:
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOPLUS IFLABEL%d\n", ++if_cnt);
		fprintf(fp, "GOFALSE IFLABEL%d\n", if_cnt);
		break;
	case IF_GT:
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOMINUS IFLABEL%d\n", ++if_cnt);
		fprintf(fp, "GOFALSE IFLABEL%d\n", if_cnt);
		break;
	case IF_LE:
		fprintf(fp, "-\n");
		fprintf(fp, "GOPLUS IFLABEL%d\n", ++if_cnt);
		break;
	case IF_GE:
		fprintf(fp, "-\n");
		fprintf(fp, "GOMINUS WLABEL%d\n", ++if_cnt);
		break;
	case W_EQ:
		fprintf(fp, "-\n");
      		fprintf(fp, "GOTRUE WLABEL%d\n", ++w_c_cnt);
      		break;
	case W_NE:
		fprintf(fp, "-\n");
      		fprintf(fp, "GOFALSE WLABEL%d\n", ++w_c_cnt);
      		break;
	case W_LT:
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOPLUS WLABEL%d\n", ++w_c_cnt);
		fprintf(fp, "GOFALSE WLABEL%d\n", w_c_cnt);
		break;
	case W_GT:
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOMINUS WLABEL%d\n", ++w_c_cnt);
		fprintf(fp, "GOFALSE WLABEL%d\n", w_c_cnt);
		break;
	case W_LE:
		fprintf(fp, "-\n");
		fprintf(fp, "GOPLUS WLABEL%d\n", ++w_c_cnt);
		break;
	case W_GE:
		fprintf(fp, "-\n");
		fprintf(fp, "GOMINUS WLABEL%d\n", ++w_c_cnt);
		break;
	case F_EQ:
		fprintf(fp, "-\n");
      		fprintf(fp, "GOTRUE FLABEL%d\n", ++f_c_cnt);
      		break;
	case F_NE:
		fprintf(fp, "-\n");
      		fprintf(fp, "GOFALSE FLABEL%d\n", ++f_c_cnt);
      		break;
	case F_LT:
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOPLUS FLABEL%d\n", ++f_c_cnt);
		fprintf(fp, "GOFALSE FLABEL%d\n", f_c_cnt);
		break;
	case F_GT:
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOMINUS FLABEL%d\n", ++f_c_cnt);
		fprintf(fp, "GOFALSE FLABEL%d\n", f_c_cnt);
		break;
	case F_LE:
		fprintf(fp, "-\n");
		fprintf(fp, "GOPLUS FLABEL%d\n", ++f_c_cnt);
		break;
 	case F_GE:
		fprintf(fp, "-\n");
		fprintf(fp, "GOMINUS FLABEL%d\n", ++f_c_cnt);
		break;
	case T_EQ:
		fprintf(fp, "-\n");
      		fprintf(fp, "GOTRUE TL%d\n", ++tl_cnt);
      		break;
	case T_NE:
		fprintf(fp, "-\n");
      		fprintf(fp, "GOFALSE TL%d\n", ++tl_cnt);
      		break;
	case T_LT:
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOPLUS TL%d\n", ++tl_cnt);
		fprintf(fp, "GOFALSE TL%d\n", tl_cnt);
		break;
	case T_GT:
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOMINUS TL%d\n", ++tl_cnt);
		fprintf(fp, "GOFALSE TL%d\n", tl_cnt);
		break;
	case T_LE:
		fprintf(fp, "-\n");
		fprintf(fp, "GOPLUS TL%d\n", ++tl_cnt);
		break;
	case T_GE:
		fprintf(fp, "-\n");
		fprintf(fp, "GOMINUS TL%d\n", ++tl_cnt);
		break;
	case AA:
		fprintf(fp, "+\n");
		fprintf(fp, ":=\n");
		break;
	case SA:
		fprintf(fp, "-\n");
		fprintf(fp, ":=\n");
		break;
	case MA:
		fprintf(fp, "*\n");
		fprintf(fp, ":=\n");
		break;
	case DA:
		fprintf(fp, "/\n");
		fprintf(fp, ":=\n");
		break;
	case WLOOPEND:
		fprintf(fp, "LABEL WLOOP%d\n", ++w_cnt);
		break;
	case FLOOPEND:
		fprintf(fp, "LABEL FLOOP%d\n", ++for_cnt);
		break;
	case FUNCEND:
		fprintf(fp, "GOTO FLABEL%d\n", ++f_cnt);
		fprintf(fp, "LABEL CALLBACK%d\n", cb_cnt);
		cb_cnt--;
		break;
	case FUNC:
		fprintf(fp, "GOTO FUNCOUT%d\n", ++fe_cnt);
		fprintf(fp, "LABEL FLABEL%d\n", f_cnt--);
		f_cnt--;
		break;
	case CALLBACK:
		fprintf(fp, "GOTO CALLBACK%d\n", cb_cnt+1);
		fprintf(fp, "LABEL FUNCOUT%d\n", fe_cnt);
		fe_cnt--;
		break;
	case WHILE:
		fprintf(fp, "GOTO WLOOP%d\n", w_cnt-inner_w_cnt);
		fprintf(fp, "LABEL WLABEL%d\n", w_c_cnt-inner_w_cnt);
		break;
	case FOR:
		fprintf(fp, "GOTO FLOOP%d\n", for_cnt - inner_f_cnt);
		fprintf(fp, "LABEL FLABEL%d\n", f_c_cnt - inner_f_cnt);
		break;
	case TEX:
		fprintf(fp, ":=\n");
		break;
	case TLVAL:
		fprintf(fp, "LVALUE %s\n", str);
		break;
	case TSTMT:
		fprintf(fp, "GOTO TOUT%d\n", tl_cnt); 
		fprintf(fp, "LABEL TL%d\n", tl_cnt);
		break;
	case TERN:
		fprintf(fp,	"LABEL TOUT%d\n", tl_cnt);
		break;
	case SCAN:
		fprintf(fp, "INNUM\n");
		fprintf(fp, ":=\n");
		break;
	case PRINT:
		fprintf(fp, "OUTNUM\n");
		break;
	case SWAPS:
		insertsym("TEMP");
		fprintf(fp, "LVALUE TEMP\n");
		break;
	case SWAPE:
		fprintf(fp, "RVALUE TEMP\n");
		fprintf(fp, ":=\n");
		break;
	case CASEL:
		fprintf(fp, "RVALUE %s\n", str);
		break;
	case CASEM:
		fprintf(fp, "-\n");
		fprintf(fp, "GOTRUE CLABEL%d\n", ++case_cnt);
		break;
	case CASEH:
		fprintf(fp, "GOTO SLABEL%d\n", s_cnt);
		fprintf(fp, "LABEL CLABEL%d\n", case_cnt);
		break;
	case SWITCH:
		fprintf(fp, "LABEL SLABEL%d\n", s_cnt++);
		break;
	case STMTLIST:
	default:
		break;
	};
}



/*
int gentemp()
{
char buffer[MAXTSYMLEN];
char tempsym[MAXSYMLEN]="TTCBU";

	tsymbolcnt++;
	if (tsymbolcnt > MAXTSYMBOL) printf("temp symbol overflow\n");
	itoa(tsymbolcnt, buffer, 10);
	strcat(tempsym, buffer);
	return( insertsym(tempsym) ); // Warning: duplicated symbol is not checked for lazy implementation
}
*/
void dwgen()
{
int i;
	fprintf(fp, "HALT\n");
	fprintf(fp, "$ -- END OF EXECUTION CODE AND START OF VAR DEFINITIONS --\n");

// Warning: this code should be different if variable declaration is supported in the language 
	for(i=0; i<maxsym; i++) 
		fprintf(fp, "DW %s\n", symtbl[i]);
	fprintf(fp, "END\n");
}
