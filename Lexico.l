%{
#include <string>
#include <iostream>
#include <sstream>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]
ENTER [ \n]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*
BOOL "True"|"False"
STRING \"({LETRA}|{NUM})*\"

%%

"//".*      {}


"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"break"     {return TK_BREAK;}

"continue"  {return TK_CONTINUE;}

"int"		{return TK_TIPO_INT;}

"float"     {return TK_TIPO_FLOAT;}

"var"       {return TK_DEC_VAR;}

"global"    {return TK_GLOBAL_VAR;}

"if"        {return TK_IF;}

"else"      {return TK_ELSE;}

"end"       {return TK_END_LOOP;}

"while"     {return TK_WHILE;}

"do"        {return TK_DO;}

"for"		{return TK_FOR;}

"input"     {return TK_INPUT;}

"print"		{return TK_SAIDA;}

"<="        {return TK_LE;}

">="        {return TK_HE;}

"=="        {return TK_EQ;}

"!="        {return TK_DIFF;}

"switch"    {return TK_SWITCH;}

"case"      {return TK_CASE;}

"default"   {return TK_DEFAULT;}

"<"         {return TK_LESS;}

">"         {return TK_GREATER;}

"!"         {return TK_NOT;}

"||"        {return TK_OR;}   

"&&"        {return TK_AND;}

"//"        {return TK_COMENTARIO;}

"++"        {return TK_UN_SUM;}

"--"        {return TK_UN_SUB;}

[(){}[\];,:]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }

{NUM}		{ yylval.label = yytext; return TK_NUM;  }
{BOOL}		{ yylval.label = yytext; return TK_BOOL; }
{CHAR}      { yylval.label = yytext; return TK_CHAR; }
{REAL}      { yylval.label = yytext; return TK_FLOAT;}
{ID}		{ yylval.label = yytext; return TK_ID; }
{STRING}	{ yylval.label = yytext; return TK_STRING;}


.			{ *yytext; }

%%
