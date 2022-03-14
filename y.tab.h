/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

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

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    DECLARACAO = 258,
    TK_MAIN = 259,
    TK_ENTRADA = 260,
    TK_SAIDA = 261,
    TK_ID = 262,
    TK_DEC_VAR = 263,
    TK_GLOBAL = 264,
    TK_TIPO_INT = 265,
    TK_TIPO_FLOAT = 266,
    TK_TIPO_BOOL = 267,
    TK_TIPO_CHAR = 268,
    TK_TIPO_STRING = 269,
    TK_CONV_FLOAT = 270,
    TK_CONV_INT = 271,
    TK_LE = 272,
    TK_HE = 273,
    TK_EQ = 274,
    TK_DIFF = 275,
    TK_UN_SUM = 276,
    TK_UN_SUB = 277,
    TK_NUN_SUM = 278,
    TK_NUN_SUB = 279,
    TK_NUN_MUL = 280,
    TK_NUN_DIV = 281,
    TK_CHAR = 282,
    TK_FLOAT = 283,
    TK_BOOL = 284,
    TK_NUM = 285,
    TK_ENTER = 286,
    TK_STRING = 287,
    TK_FIM = 288,
    TK_ERROR = 289
  };
#endif
/* Tokens.  */
#define DECLARACAO 258
#define TK_MAIN 259
#define TK_ENTRADA 260
#define TK_SAIDA 261
#define TK_ID 262
#define TK_DEC_VAR 263
#define TK_GLOBAL 264
#define TK_TIPO_INT 265
#define TK_TIPO_FLOAT 266
#define TK_TIPO_BOOL 267
#define TK_TIPO_CHAR 268
#define TK_TIPO_STRING 269
#define TK_CONV_FLOAT 270
#define TK_CONV_INT 271
#define TK_LE 272
#define TK_HE 273
#define TK_EQ 274
#define TK_DIFF 275
#define TK_UN_SUM 276
#define TK_UN_SUB 277
#define TK_NUN_SUM 278
#define TK_NUN_SUB 279
#define TK_NUN_MUL 280
#define TK_NUN_DIV 281
#define TK_CHAR 282
#define TK_FLOAT 283
#define TK_BOOL 284
#define TK_NUM 285
#define TK_ENTER 286
#define TK_STRING 287
#define TK_FIM 288
#define TK_ERROR 289

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
