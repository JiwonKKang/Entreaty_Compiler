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
hletter	[\xb0-\xfe][\xa0-\xfe]
letter	({eletter}|{hletter})
digit	[0-9]
id	{letter}({letter}|{digit})*
%%
{ws}	{/* do nothing */}
{nl}	{lineno++; }
\+		{return(ADD); }
\-		{return(SUB); }
:=		{return(ASSGN); }
"*"             {return(MUL);}
"/"             {return(DIV);}
while           {return(WHILE);}
;		{return(STMTEND); }
"{"             {return(LB);}
"}"             {return(RB);}
"("             {return(OPEN);}
")"             {return(CLOSE);}
if              {return(IF);}
else            {return(ELSE);}
function       {return(FUNC);}
":"	{return(COLON);}
"?"	{return(QM);}
"<"         {return(LT);}
">"         {return(GT);}
"<="      {return(LE);}
">="      {return(GE);}
"=="      {return(EQ);}
"!="      {return(NE);}
"+="	  {return(AA);}
"-="	  {return(SA);}
"*="	  {return(MA);}
"/="	  {return(DA);}
for	{return(FOR);}
scanf	{return(SCANF);}
","	{return(COMMA);}
"%d"	{return(PD);}
\"	{return(UPC);}
"&"	{return(AND);}
printf	{return(PRINTF);}
swap	{return(SWAP);}
case	{return(CASE);}
break	{return(BREAK);}
default	{return(DEFAULT);}
switch	{return(SWITCH);}
"void main() {"	{return(START);}
"return 0; }"	{return(END); }
ÇÔ¼ö{letter}+	{return(FNAME);}
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