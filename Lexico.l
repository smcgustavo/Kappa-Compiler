%{
#include <string>

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

%%

"//".*      {}


"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}



"int"		{return TK_TIPO_INT;}

"char"      {return TK_TIPO_CHAR;}

"float"     {return TK_TIPO_FLOAT;}

"bool"		{yylval.label = "bool"; yylval.traducao = yytext; return TK_TIPO_BOOL;}

"var"       {return TK_DEC_VAR;}




"entrada"	{return TK_ENTRADA;}

"saida"		{return TK_SAIDA;}




"(f)"		{return TK_CONV_FLOAT;}

"(i)"		{return TK_CONV_INT;}




"<="        {return TK_LE;}

">="        {return TK_HE;}

"=="        {return TK_EQ;}

"!="        {return TK_DIFF;}


[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }

{NUM}		{ yylval.label = yytext; return TK_NUM;  }
{BOOL}		{ yylval.label = yytext; return TK_BOOL; }
{CHAR}      { yylval.label = yytext; return TK_CHAR; }
{REAL}      { yylval.label = yytext; return TK_FLOAT;}
{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ *yytext; }

%%
