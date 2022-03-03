%{
#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>
#include <stack>
#include <list>
using std::string;
using std::getline;

#define YYSTYPE atributos

using namespace std;
int var_temp_qnt;

typedef struct Variable{

	string tipo;
	string nome;
	string valor;
} variable;

typedef struct Atributos
{
	string tipo;
	string label;
	string traducao;
} atributos;

typedef struct{

	string implicita; //tradução após conversão
	string nomeVar; //nome da variável
	string varConvertida; //nome da variável que foi convertida
} structAux; //struct auxiliar utilizada para conversões

//variaveis
int valorVar = 0;

//funções yacc
int yylex(void);
void yyerror(string);
string gentempcode();

//função geradora de label
string genLabel();

//funções de conversão
structAux implicitConversion(string tipo0, string tipo1, string nome0, string nome1);
string explicitConversion(string tipo0, string tipo1);

//funções para checar tipos específicos
string isBoolean(string tipo0, string tipo1);
int erroTipo(string tipo0, string tipo1);





%}

//tokens
%token DECLARACAO
%token TK_MAIN
%token TK_ENTRADA TK_SAIDA
%token TK_ID TK_DEC_VAR TK_GLOBAL
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL TK_TIPO_CHAR TK_TIPO_STRING
%token TK_CONV_FLOAT TK_CONV_INT TK_LE TK_HE TK_EQ TK_DIFF
%token TK_UN_SUM TK_UN_SUB TK_NUN_SUM TK_NUN_SUB TK_NUN_MUL TK_NUN_DIV
%token TK_CHAR TK_FLOAT TK_BOOL TK_NUM
%token TK_STRING TK_FIM TK_ERROR

%start S


//ordem de precedência
%right '=' '!'
%left '|'
%left '&'
%left TK_EQ TK_DIFF
%left '<' '>' TK_HE TK_LE
%left '+' '-'
%left '*' '/'
%left '(' ')'


%%
S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Salve Kappa!*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl;

			}
			;

BLOCO		  : '{' COMANDOS '}'
				{
					$$.traducao = $2.traducao;
				}
				;
COMANDOS	  : COMANDO COMANDOS
					{
						$$.traducao = $1.traducao + $2.traducao;
					}

					|
					{
						$$.traducao = "";
					}
					;

COMANDO 	  : E ';'
						{
							$$ = $1;
						}

						| ATRIBUICAO ';'
						{
							$$ = $1;
						}

						| DECLARACAO ';'
						{
							$$ = $1;
						}



ATRIBUICAO 	            : TK_DEC_VAR TK_ID TK_TIPO_CHAR '=' E
						{
							erroTipo("char", $5.tipo);
							string nomeAuxID = genLabel();
							$$.traducao = $5.traducao + "\t" + nomeAuxID + " = " + $5.label + ";\n";
						}

						| TK_DEC_VAR TK_ID TK_TIPO_INT '=' E
						{
							$$.tipo = "int";
							if($$.tipo != $5.tipo){

								if($5.tipo == "char" || $5.tipo == "string"){
									yyerror("Declaração de char/string em int não permitido!");
								}

								else{

									string nomeAuxID = genLabel();
									$$.traducao = $5.traducao + "\t" + nomeAuxID + " = (int) " + $5.label  + ";\n";
								}
							}

							else{

								string nomeAuxID = genLabel();
								$$.traducao = $5.traducao + "\t" + nomeAuxID + " = " + $5.label  + ";\n";
								

							}
						}

						| TK_DEC_VAR TK_ID TK_TIPO_FLOAT '=' E
						{
							$$.tipo = "float";
							if($$.tipo != $5.tipo){
								if($5.tipo == "char" || $5.tipo == "string"){
									yyerror("Declaração de char/string em float não permitido!");
								}
								else{
									string nomeAuxID = genLabel();
									$$.traducao = $5.traducao + "\t" + nomeAuxID + " = (float) " + $5.label  + ";\n";

								}
							}
							else{
								string nomeAuxID = genLabel();
								$$.traducao = $5.traducao + "\t" + nomeAuxID + " = " + $5.label  + ";\n";

							}
						}

						| TK_DEC_VAR TK_ID TK_TIPO_BOOL '=' E
						{
							$$.tipo = "bool";
							if($$.tipo != $5.tipo){
								yyerror("Tipo booleano somente aceita boleano!");
							}
							else{
								string nomeAuxID = genLabel();
								$$.traducao = $5.traducao + "\t" + nomeAuxID + " = " + $5.label  + ";\n";

							}
						}

E 			: E '+' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " + " + $3.label + ";\n";
			}
			| E '-' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " - " + $3.label + ";\n";
			}
			| E '*' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			| E '/' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			| TK_ID '=' E
			{
				$$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
			}
			| TK_NUM
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			;

%%

#include "lex.yy.c"

int yyparse();

string gentempcode()
{
	var_temp_qnt++;
	return "t" + std::to_string(var_temp_qnt);
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	yyparse();

	return 0;
}

void yyerror(string MSG)
{
	cout << MSG << endl;
	exit (0);
}	

string genLabel(){

	return "temp" + to_string(valorVar++);
}

int erroTipo(string tipo0, string tipo1)
{
	if (tipo1 != tipo0)
	{
		yyerror("tipo de variaveis incompativeis\n");

	}
			return 0;
}