%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
-
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
int	cond_check(Node* n);



%}

%token	ADD SUB ASSGN ID NUM STMTEND START END ID2 MUL DIV LB RB OPEN CLOSE IF ELSE LT GT LE GE EQ NE WHILE IF_ELSE REAL ID4 
%token  AA SA MA DA ID3 LOOPCON LOOPEND FUNC FSTMT FUNCEND CALLBACK FNAME FOR FORSTLI FORCON FORSTART QM COLON TLVAL TSTMT TERN TEX TCON
%token  SCANF COMMA PD SCAN UPC AND PRINTF PRINT WLOOPEND FLOOPEND
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

stmt		: 	ID ASSGN expr STMTEND	{ $1->token = ID2; $$=MakeOPTree(ASSGN, $1, $3);}
		|	WHILE loop_con LB stmt_list RB	{$$=MakeOPTree(WHILE, $2, $4);}
		|	t_stmt t_expr STMTEND	{ $$=MakeOPTree(TERN, $1, $2); }	
		|	ID AA expr STMTEND { $1->token= ID3; $$=MakeOPTree(AA, $1, $3); } 
		|	ID SA expr STMTEND { $1->token= ID3; $$=MakeOPTree(SA, $1, $3); }
		|	ID MA expr STMTEND { $1->token= ID3; $$=MakeOPTree(MA, $1, $3); }
		|	ID DA expr STMTEND { $1->token= ID3; $$=MakeOPTree(DA, $1, $3); }
		|	FUNC FNAME LB f_stmt_list RB { $$=MakeOPTree(FUNC, $4, NULL); }
		|	FOR for_con for_stmt_list	{ $$=MakeOPTree(FOR, $2, $3); }
		|	SCANF OPEN UPC PD UPC COMMA AND ID CLOSE STMTEND {$8->token=ID2; $$=MakeOPTree(SCAN, $8, NULL);}
		|	PRINTF OPEN UPC PD UPC COMMA ID CLOSE STMTEND { $$=MakeOPTree(PRINT, $8, NULL); }
		|	if_stmt else_stmt { $$=MakeOPTree(IF_ELSE, $1, $2); }
		| 	if_stmt
		|	call_back
		;

t_stmt		:	t_con t_expr COLON {$$=MakeOPTree(TSTMT, $1, $2); }
		;

t_expr		:	t_lval expr { $$=MakeOPTree(TEX, $1, $2); }
		;

t_lval		:	{$$=MakeNode(TLVAL, TLVAL);}
		;

t_con		:	ID ASSGN OPEN condition CLOSE QM {$1->token=ID4; $$=MakeOPTree(TCON, $1, $4);}

for_stmt_list	:	stmt CLOSE LB stmt_list RB	{$$=MakeOPTree(FORSTLI, $4, $1);}
		;

for_con		:	OPEN for_start condition STMTEND	{$$=MakeOPTree(FORCON, $2, $3);}
		;
for_start		:	stmt floop_end	{$$=MakeOPTree(FORSTART, $1, $2);}
		;

f_stmt_list 	:	stmt_list f_end	   {$$=MakeOPTree(FSTMT, $2, $1);}
		;
floop_end		:	{ $$=MakeNode(FLOOPEND, FLOOPEND); };

f_end		:	{ $$=MakeNode(FUNCEND, FUNCEND); }
		;


call_back		:	FNAME OPEN CLOSE STMTEND {$$=MakeNode(CALLBACK, CALLBACK);}
		;

loop_con		:	OPEN condition CLOSE wloop_end { $$=MakeOPTree(LOOPCON, $4, $2); };

wloop_end	:	{ $$=MakeNode(WLOOPEND, WLOOPEND); };


if_stmt		:	IF OPEN condition CLOSE LB stmt_list RB { $$=MakeOPTree(IF, $3, $6); }
		;


else_stmt		:	ELSE LB stmt_list RB { $$=MakeOPTree(ELSE, $3, NULL); }
		;



condition      	 :    expr EQ expr { $$=MakeOPTree(EQ, $1, $3);}
		|    expr LT expr { $$=MakeOPTree(LT, $1, $3);}
		|    expr GT expr { $$=MakeOPTree(GT, $1, $3);}
		|    expr LE expr { $$=MakeOPTree(LE, $1, $3);}
		|    expr GE expr { $$=MakeOPTree(GE, $1, $3);}
		|    expr NE expr { $$=MakeOPTree(NE, $1, $3);}
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
		if(n->brother != NULL) {
			if(n->brother->token == ELSE) {
				fprintf(fp, "GOTO L%d\n", cnt+1);
			}
		}
	}
	prtcode(n->token, n->tokenval);
	DFSTree(n->brother);
	
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
      		fprintf(fp, "LABEL L%d\n", cnt++);
      		break;
	case IF_ELSE:
		fprintf(fp, "LABEL L%d\n", cnt);
		break;
	case EQ:
		cnt++;
      		fprintf(fp, "-\n");
      		fprintf(fp, "GOTRUE L%d\n", cnt);
      		break;
	case IF_EQ:
		cnt++;
		fprintf(fp, "-\n");
      		fprintf(fp, "GOTRUE IF_L%d\n", cnt);
      		break;
   	case NE:
		cnt++;
      		fprintf(fp, "-\n");
      		fprintf(fp, "GOFALSE L%d\n", cnt);
      		break;
	case LT:
		cnt++;
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOPLUS L%d\n", cnt);
		fprintf(fp, "GOFALSE L%d\n", cnt);
		break;
	case GT:
		cnt++;
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOMINUS L%d\n", cnt);
		fprintf(fp, "GOFALSE L%d\n", cnt);
		break;
	case LE:
		cnt++;
		fprintf(fp, "-\n");
		fprintf(fp, "GOPLUS L%d\n", cnt);
		break;
	case GE:
		cnt++;
		fprintf(fp, "-\n");
		fprintf(fp, "GOMINUS L%d\n", cnt);
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
		fprintf(fp, "GOTO WLOOP%d\n", w_cnt);
		fprintf(fp, "LABEL L%d\n", cnt);
		break;
	case FOR:
		fprintf(fp, "GOTO FLOOP%d\n", for_cnt);
		fprintf(fp, "LABEL L%d\n", cnt);
		cnt--;
		break;
	case TEX:
		fprintf(fp, ":=\n");
		break;
	case TLVAL:
		fprintf(fp, "LVALUE %s\n", str);
		break;
	case TSTMT:
		fprintf(fp, "GOTO TL%d\n", ++tl_cnt); //TO DO tl_cnt 전역으로 만들어놨으니 TL카운트 이용하게 변경
		fprintf(fp, "LABEL L%d\n", cnt);
		break;
	case TERN:
		fprintf(fp,	"LABEL TL%d\n", tl_cnt);
		break;
	case SCAN:
		fprintf(fp, "INNUM\n");
		fprintf(fp, ":=\n");
		break;
	case PRINT:
		fprintf(fp, "OUTNUM\n");
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
