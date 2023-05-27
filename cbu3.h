/* A Bison parser, made by GNU Bison 2.7.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2012 Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_CBU3_H_INCLUDED
# define YY_YY_CBU3_H_INCLUDED
/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     ADD = 258,
     SUB = 259,
     ASSGN = 260,
     ID = 261,
     NUM = 262,
     STMTEND = 263,
     START = 264,
     END = 265,
     ID2 = 266,
     MUL = 267,
     DIV = 268,
     LB = 269,
     RB = 270,
     OPEN = 271,
     CLOSE = 272,
     IF = 273,
     ELSE = 274,
     LT = 275,
     GT = 276,
     LE = 277,
     GE = 278,
     EQ = 279,
     NE = 280,
     WHILE = 281,
     IF_ELSE = 282,
     REAL = 283,
     ID4 = 284,
     AA = 285,
     SA = 286,
     MA = 287,
     DA = 288,
     ID3 = 289,
     LOOPCON = 290,
     LOOPEND = 291,
     FUNC = 292,
     FSTMT = 293,
     FUNCEND = 294,
     CALLBACK = 295,
     FNAME = 296,
     FOR = 297,
     FORSTLI = 298,
     FORCON = 299,
     FORSTART = 300,
     QM = 301,
     COLON = 302,
     TLVAL = 303,
     TSTMT = 304,
     TERN = 305,
     TEX = 306,
     TCON = 307,
     SCANF = 308,
     COMMA = 309,
     PD = 310,
     SCAN = 311,
     UPC = 312,
     AND = 313,
     PRINTF = 314,
     PRINT = 315,
     WLOOPEND = 316,
     FLOOPEND = 317,
     IF_LT = 318,
     IF_GT = 319,
     IF_LE = 320,
     IF_GE = 321,
     IF_EQ = 322,
     IF_NE = 323,
     W_LT = 324,
     W_GT = 325,
     W_LE = 326,
     W_GE = 327,
     W_EQ = 328,
     W_NE = 329,
     T_LT = 330,
     T_GT = 331,
     T_LE = 332,
     T_GE = 333,
     T_EQ = 334,
     T_NE = 335,
     F_LT = 336,
     F_GT = 337,
     F_LE = 338,
     F_GE = 339,
     F_EQ = 340,
     F_NE = 341,
     SWAPS = 342,
     SWAPE = 343,
     SWAPM = 344,
     SWAPH = 345,
     ID5 = 346,
     SWAP = 347,
     DEFAULT = 348,
     CASES = 349,
     SWITCHH = 350,
     CASEL = 351,
     CASEM = 352,
     CASEH = 353,
     CASE = 354,
     SWITCH = 355,
     BREAK = 356,
     IS = 357,
     THEN = 358,
     WA = 359,
     THIS = 360,
     SAVE = 361,
     RUN = 362,
     ING = 363,
     LAST = 364,
     LOOP = 365,
     ID6 = 366,
     ID7 = 367,
     INC = 368,
     DEC = 369,
     NOW = 370,
     CALL = 371,
     IN = 372,
     CONTENT = 373,
     INIT = 374,
     FN = 375,
     VAL = 376
   };
#endif


#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */

#endif /* !YY_YY_CBU3_H_INCLUDED  */
