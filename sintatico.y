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

//funções yacc
int yylex(void);
void yyerror(string);

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
%token E
%token DECLARACAO
%token TK_MAIN
%token TK_ENTRADA TK_SAIDA
%token TK_ID TK_DEC_VAR TK_GLOBAL
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL TK_TIPO_CHAR TK_TIPO_STRING
%token TK_CONV_FLOAT TK_CONV_INT TK_LE TK_HE TK_EQ TK_DIFF
%token TK_UN_SUM TK_UN_SUB TK_NUN_SUM TK_NUN_SUB TK_NUN_MUL TK_NUN_DIV
%token TK_CHAR TK_FLOAT TK_BOOL TK_NUM
%token TK_STRING TK_FIM TK_ERROR




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
S 			: BLOCOGLOBAL BLOCOCONTEXTO TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				printGlobalVariables();
				cout << "/*Salve Kappa*/\n" << "#include <iostream>\n#include <stdlib.h>\n#include <string.h>\n#include <stdio.h>\n#define TRUE 1\n#define FALSE 0\n\nint main(void)\n{" <<endl;
				printVector();
				cout << $7.traducao << endl;
				freeVectors();
				cout << "\treturn 0;\n}" << endl;
			}
			;

BLOCO		  : '{' COMANDOS '}'
				{
					$$.traducao = $2.traducao;
				}
				;

BLOCOGLOBAL   :
							{
								contextoVariaveis.push_back(globalTabSym);
							}

BLOCOCONTEXTO :
							{
								addMapToStack();
							}

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

						| ENTRADA ';'
						{
							$$ = $1;
						}

						| SAIDA ';'
						{
							$$ = $1;
						}
ENTRADA 	: TK_ID '=' TK_ENTRADA
			{
				$$.label = genLabel();
				$$.tipo = $1.tipo;
				variable Var = searchForVariable($1.label);
				cout << $$.label << " = " << $3.label << endl;
				$$.traducao = "\tstd::cin << " + $$.traducao + $1.traducao + ";\n";
			};

SAIDA 		: TK_SAIDA '=' TK_ID
			{
				$$.label = genLabel();
				variable Var = searchForVariable($3.label);
				$$.traducao = "\tstd::cout  << " + Var.nome + ";\n";
			}

ATRIBUICAO 	            : TK_DEC_VAR TK_ID TK_TIPO_CHAR '=' E
						{
							erroTipo("char", $5.tipo);
							string nomeAuxID = genLabel();
							$$.traducao = $5.traducao + "\t" + nomeAuxID + " = " + $5.label + ";\n";
							addVarToTabSym(nomeAuxID, $2.label, $$.traducao, "char");
							addVarToTempVector("\tchar " + nomeAuxID + ";\n");
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

									addVarToTabSym(nomeAuxID, $2.label, $$.traducao, "int");
									addVarToTempVector("\tint " + nomeAuxID +  ";\n");
								}
							}

							else{

								string nomeAuxID = genLabel();
								$$.traducao = $5.traducao + "\t" + nomeAuxID + " = " + $5.label  + ";\n";

								addVarToTabSym(nomeAuxID, $2.label, $$.traducao, "int");
								variable Var = searchForVariable($2.label);
								addVarToTempVector("\tint " + nomeAuxID +  ";\n");
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
									addVarToTabSym(nomeAuxID, $2.label, $$.traducao, "float");
									addVarToTempVector("\tfloat " + nomeAuxID +  ";\n");
								}
							}
							else{
								string nomeAuxID = genLabel();
								$$.traducao = $5.traducao + "\t" + nomeAuxID + " = " + $5.label  + ";\n";
								addVarToTabSym(nomeAuxID, $2.label, $$.traducao, "float");
								addVarToTempVector("\tint " + nomeAuxID +  ";\n");
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
								addVarToTabSym(nomeAuxID, $2.label, $$.traducao, "int");
								addVarToTempVector("\tint " + nomeAuxID +  ";\n");
							}
						}

