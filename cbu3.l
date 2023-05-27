%{
#include <string.h>
#include "cbu3.h"
#define MAXSYM	100
#define	MAXSYMLEN	20

#define STMTLIST 500

typedef struct nodeType {
	int token;
	int tokenval;
	struct nodeType *son;
	struct nodeType *brother;
	} Node;

char symtbl[MAXSYM][MAXSYMLEN];
int lineno=1;
int insertsym(char *s);
int maxsym=0;
char s[MAXSYMLEN];
int temp;
Node * MakeNode(int, int);

%}
sp		[ \t]
ws		{sp}+
nl		\n
eletter	[A-Za-z]
letter	({eletter})
digit	[0-9]
id	{letter}({letter}|{digit})*
%%
{ws}	{/* do nothing */}
{nl}	{lineno++; }
\+|더하기		{return(ADD); }
\-|빼기		{return(SUB); }
에		{return(ASSGN);}
을|를		{return(THIS);}
"*"|곱하기             {return(MUL);}
"/"|나누기             {return(DIV);}
해주세요		{return(STMTEND); }
여기부터           {return(LB);}
여기까지             {return(RB);}
하면서		{return(ING);}
만약             {return(IF);}
가	{return(IS);}
보다	{return(THEN);}
와|과	{return(WA);}
저장	{return(SAVE);}
실행	{return(RUN);}
마지막에	{return(LAST);}
아니라면            {return(ELSE);}
이름이       {return(FUNC);}
이고	{return(AND);}
인 	{return(IN);}
선언	{return(INIT);}
내용은	{return(CONTENT);}
함수	{return(FN);}
반복 	{return(LOOP);}
작다면         {return(LT);}
크다면         {return(GT);}
"의 값을"	{return(VAL);}
"작거나 같다면"      {return(LE);}
"크거나 같다면"      {return(GE);}
같다면      {return(EQ);}
"같지 않다면"      {return(NE);}
"+="	  {return(AA);}
"-="	  {return(SA);}
"*="	  {return(MA);}
"/="	  {return(DA);}
일단	{return(FOR);}
"입력 받아주세요"	{return(SCANF);}
"++"	{return(INC);}
"--"	{return(DEC);}
호출	{return(CALL);}
출력	{return(PRINTF);}
이제	{return(NOW);}
"의 값을 서로 바꿔주세요"	{return(SWAP);}
"일 경우"	{return(CASE);}
"그리고 나가주세요"	{return(BREAK);}
"다 아닌경우"	{return(DEFAULT);}
"아래 경우 중"	{return(SWITCH);}
"프로그램을 시작해주세요"	{return(START);}
"프로그램을 끝내주세요"	{return(END); }
func_{letter}+	{return(FNAME);}
{id}	{temp=insertsym(yytext); yylval=MakeNode(ID, temp); return(ID);}
-?{digit}+		{sscanf(yytext, "%d", &temp); yylval=MakeNode(NUM, temp); return(NUM);}
-?{digit}+\.{digit}+ {sscanf(yytext, "%f", &temp); yylval=MakeNode(REAL, temp); return(REAL);}
.		{printf("invalid token %s\n", yytext); }
%%

int insertsym(char *s)
{
int i;

	for(i=0;i<maxsym; i++) {
		if(strcmp(s, symtbl[i])==0) return(i);
		}
	if (i<MAXSYM-1) {
		strcpy(symtbl[maxsym],s);
		maxsym++;
		return(maxsym-1);
		}
	else
		{printf("symbol table overflow\n");}
	return(0);
}

yywrap() {}