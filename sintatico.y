%{
#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>
#include <stack>
#include <list>
#include <stdlib.h>
#include <string.h>

using std::string;
using std::getline;
//colocar na tabela uma variavel pra pra verificar se a mesma foi inicializada ou nao

#define YYSTYPE atributos
using namespace std;

typedef struct Variable{

	string tipo;
	string nome;
	string valor;
	string tmp;
} variable;

typedef struct Temps{

	string valor;
	string tmp;
} temps;

typedef struct Atributos
{
	string tipo;
	string label;
	string traducao_dec;
	string traducao;
	string tmp;
} atributos;

typedef struct{

	string implicita; //tradução após conversão
	string nomeVar; //nome da variável
	string varConvertida; //nome da variável que foi convertida
} structAux; //struct auxiliar utilizada para conversões

//variaveis
int valorVar = 1;
int mapAtual = 0;
//int var_temp_qnt;
int entryMain = 0;
bool teste;
variable auxiliar;
vector<vector<variable>>globalTabSym;


//funções yacc
int yylex(void);
void yyerror(string);
void criaOperacao(atributos *dolardolar, atributos dolar1, atributos dolar3, string operacao);
bool verifyVariableLocal(string nome);
bool verifyVariableGlobal(string nome);
variable *returnVariable(string nome);

//função geradora de tmps
string genLabel();

%}

//tokens
%token TK_MAIN 
%token TK_INPUT TK_SAIDA TK_WHILE TK_DO TK_FOR TK_IF TK_ELSE TK_END_LOOP TK_SWITCH TK_CASE
%token TK_ID TK_DEC_VAR TK_GLOBAL_VAR TK_BREAK TK_DEFAULT
%token TK_TIPO_INT TK_TIPO_FLOAT TK_COMENTARIO TK_UN_SUM TK_UN_SUB
%token TK_LESS TK_GREATER TK_LE TK_HE TK_EQ TK_DIFF TK_NOT TK_AND TK_OR
%token TK_CHAR TK_FLOAT TK_BOOL TK_NUM TK_STRING   
%token TK_FIM TK_ERROR

%start S


//ordem de precedência
%right '!' '=' 
%left '|'
%left '&'
%left TK_EQ TK_DIFF
%left '<' '>' TK_HE TK_LE
%left '+' '-'
%left '*' '/'
%left '(' ')'


%%
S 				:BLOCOGLOBAL BLOCOCONTEXTO TK_TIPO_INT{cout<<"Entro na main"<<endl;entryMain++;} TK_MAIN '(' ')' BLOCO
				{
					cout << "/*Salve Kappa!*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << 
					"//------------------ Escopo Variáveis ------------------\\\\ \n" << $1.traducao_dec <<$8.traducao_dec << 
					"//------------------ Escopo Atribuições ------------------\\\\ \n" << $1.traducao << $8.traducao << "\treturn 0;\n}" << endl;
				}
				;

BLOCOGLOBAL		: COMANDOS
				{
					$$.traducao = $1.traducao;
					$$.traducao_dec = $1.traducao_dec;
				}
				;

BLOCOCONTEXTO   : 
				{
					if(globalTabSym.empty() != 1){
						variable ref;
						ref.tipo = "";
						ref.nome = "";
						ref.valor = "";
						ref.tmp = "";
						vector<variable> aux;
						aux.push_back(ref);
						globalTabSym.push_back(aux);
						mapAtual++;
					}
					cout<<"blococontexto"<<endl;
					//cout<<"MAPA ATUAL = "<< mapAtual<<endl;
					//cout<<"GLOBAL TAB SMY = "<<globalTabSym.size() <<endl;
				}

BLOCO			: '{' COMANDOS '}'
				{
					$$.traducao = $2.traducao;
					$$.traducao_dec = $2.traducao_dec;
				}
				;

COMANDOS		: COMANDO COMANDOS
				{
					$$.traducao = $1.traducao + $2.traducao;
					$$.traducao_dec = $1.traducao_dec + $2.traducao_dec;
				}
				|
				{
					$$.traducao = "";
					$$.traducao_dec = "";
				}
				;

COMANDO 		: E ';'
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
				//| COMENTARIO
				//{

				//}
				| BLOCOCONTEXTO IF
				{
					$$ = $2;
					if(mapAtual > 0){
						globalTabSym.pop_back();
						mapAtual--;
					}
					cout<<"BLOCOCONTEXTO IF"<<endl;
					//cout<<"MAPA ATUAL = "<< mapAtual<<endl;
					//cout<<"GLOBAL TAB SMY = "<<globalTabSym.size() <<endl;
				}
				| BLOCOCONTEXTO ELSE
				{
					$$ = $2;
					cout<<"BLOCOCONTEXTO ELSE"<<endl;
				}
				| BLOCOCONTEXTO FOR
				{	
					$$ = $2;
					if(mapAtual > 0){
						globalTabSym.pop_back();
						mapAtual--;
					}	
					cout<<"BLOCOCONTEXTO FOR"<<endl;
				}
				| BLOCOCONTEXTO WHILE
				{
					$$ = $2;
					if(mapAtual > 0){
						globalTabSym.pop_back();
						mapAtual--;
					}	
					cout<<"BLOCOCONTEXTO WHILE"<<endl;
				}
				| BLOCOCONTEXTO DOWHILE ';'
				{
					$$ = $2;
					if(mapAtual > 0){
						globalTabSym.pop_back();
						mapAtual--;
					}
					cout<<"BLOCOCONTEXTO DOWHILE"<<endl;
				}
				| BLOCOCONTEXTO SWITCH
				{
					$$ = $2;
				}
				| BREAK ';'
				{
					cout<<"BLOCOCONTEXTO BREAK"<<endl;
				}
				| CONTINUE ';'
				{
					cout<<"BLOCOCONTEXTO CONTINUE"<<endl;
				}
				;

/*COMENTARIO		: TK_COMENTARIO
				{

				}
				;*/

DECLARACAO 	    : TK_DEC_VAR TK_ID//Declaração de uma variável do tipo int sem atribuição
				{
					cout<<"tk_dec_var tk_id"<<endl;
					if(mapAtual == 0 && entryMain == 0){//Verifica se essa declaração está sendo feita antes da main
						yyerror("Só é permitido declarar variável global antes do escopo da main com o modificador \"global\".\n");
					}
					if(verifyVariableLocal($2.label) != true){//Com isso, eu sei que teve declaração antes da main. Dessa forma preciso verificar com o verifyVariableGlobal
						cout<<"teste1"<<endl;//Se a variável não foi declarada antes ja
						variable ref;
						ref.tipo = "";
						ref.nome = $2.label;
						ref.valor = ""; //Forço a variável a receber uma string vazia pois irei fazer comparações utilizando a string "vazia"
						ref.tmp = genLabel();
							
						if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
							vector<variable> aux;
							aux.push_back(ref);
							globalTabSym.push_back(aux);
						}
						else{
							globalTabSym[mapAtual].push_back(ref);
						}
						//$$.traducao = $2.traducao;
					}else{
						yyerror("Voce já declarou a variável " + $2.label + ".\n");
					}
				}
				| TK_DEC_VAR TK_ID '=' E //Declaração de uma variável do tipo int com atribuição. Podendo esta ser de uma outra variável ou de um valor qualquer.
				{
					cout<<"tk_dec_var tk_id = e"<<endl;
					if(mapAtual == 0 && entryMain == 0){//Verifica se essa declaração está sendo feita antes da main
						yyerror("Só é permitido declarar variável global antes do escopo da main com o modificador \"global\".\n");
					}	
					if(verifyVariableLocal($2.label) == false){//Com isso, eu sei que teve declaração antes da main. Dessa forma preciso verificar com o verifyVariableGlobal
						if(verifyVariableLocal($4.label) && $4.tmp == ""){//Se eu não colocar $4.tmp == "" ele não irá interpretar quando alguma operação vier, 
							variable *var1 = returnVariable($4.label);//pois quando tem alguma operação o $4.tmp não fica = ""
							variable ref;
							if(var1->valor != ""){
								cout<<"teste1"<<endl;
								ref.tipo = var1->tipo;
								ref.nome = $2.label;
								ref.valor = var1->valor;
								ref.tmp = genLabel();
								if(var1->tipo == "string"){
									$$.traducao_dec = $4.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
									$$.traducao = $4.traducao + "\t" + ref.tmp + " =  (string*) malloc(" + to_string(var1->valor.size())  + "* sizeof(string));\n" + "\t" + 
									ref.tmp + " = " + var1->tmp + ";\n";
								}
								else{
									$$.traducao_dec = $4.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
									$$.traducao = $4.traducao + "\t" + ref.tmp + " = " + var1->tmp + ";\n";
								}
								if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
									vector<variable> aux;
									aux.push_back(ref);
									globalTabSym.push_back(aux);
								}
								else{
									globalTabSym[mapAtual].push_back(ref);
								}
							}
							else{
								yyerror("Voce ainda não inicialiou a variavel " + var1->nome + ".\n");
							}
						} 
						else{
							cout<<"teste2"<<endl;
							variable ref;
							ref.tipo = $4.tipo;
							ref.nome = $2.label;
							ref.valor = $4.label;
							ref.tmp = genLabel();
							if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){//o tamanho da estrutura tem que ser maior que o tamanho do map
								vector<variable> aux;//pois se for igual, globalTabSym[mapAtual] não vai ter nenhum elemento, com isso tenho que adicionar um elemento(vetor nesse caso)
								aux.push_back(ref);//pra depois poder adicionar somente as variables
								globalTabSym.push_back(aux);
							}
							else{
								globalTabSym[mapAtual].push_back(ref);
							}
							if($4.tipo == "string"){
								$$.traducao_dec = $4.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
								$$.traducao = $4.traducao + "\t" + ref.tmp + " = " + $4.tmp + ";\n";
								$$.traducao = $4.traducao + "\t" + ref.tmp + " =  (string*) malloc(" + to_string($4.label.size())  + "* sizeof(string));\n" + "\t" + 
								ref.tmp + " = " + $4.tmp + ";\n";	
							}
							else{
								$$.traducao_dec = $4.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
								$$.traducao = $4.traducao + "\t" + ref.tmp + " = " + $4.tmp + ";\n";
							}
						}
					}
					else{
						yyerror("Você já declarou a variável " + $2.label + ".\n");
					}
				}
				| TK_GLOBAL_VAR TK_DEC_VAR TK_ID
				{
					cout<<"tk_global tk_dec_var tk_id"<<endl;
					if(mapAtual == 0 && entryMain == 0 || mapAtual == 0 && entryMain == 1){//Comparação que faz com que uma variável global seja criada somente dentro da main
						if(verifyVariableGlobal($3.label) != true){//ou antes dela. E também só pode ser criada fora de qualquer escopo(for, if, while)
							cout<<"teste1"<<endl;
							variable ref;
							ref.tipo = "";
							ref.nome = $3.label;
							ref.valor = ""; 
							ref.tmp = genLabel();
								
							if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
								vector<variable> aux;
								aux.push_back(ref);
								globalTabSym.push_back(aux);
							}
							else{
								globalTabSym[mapAtual].push_back(ref);
							}
						}else{
							yyerror("Voce já declarou a variável " + $3.label + ".\n");
						}
					}
					else{
						yyerror("Declaração de variável global somente fora de função ou antes do bloco main, ambas com o modificador \"global\".\n");
					}
				}
				| TK_GLOBAL_VAR TK_DEC_VAR TK_ID '=' E
				{
					cout<<"tk_global tk_dec_var tk_id = e"<<endl;
					if(mapAtual == 0 && entryMain == 0 || mapAtual == 0 && entryMain == 1){
						if(verifyVariableLocal($5.label) && $5.tmp == ""){//Se eu não colocar $4.tmp == "" ele não irá interpretar quando alguma operação vier, 
							variable *var1 = returnVariable($5.label);//pois quando tem alguma operação o $4.tmp não fica = ""
							variable ref;
							if(var1->valor != ""){
								cout<<"teste1"<<endl;
								ref.tipo = var1->tipo;
								ref.nome = $3.label;
								ref.valor = var1->valor;
								ref.tmp = genLabel();
								if(var1->tipo == "string"){
									$$.traducao_dec = $5.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
									$$.traducao = $5.traducao + "\t" + ref.tmp + " =  (string*) malloc(" + to_string(var1->valor.size())  + "* sizeof(string));\n" + "\t" + 
									ref.tmp + " = " + var1->tmp + ";\n";
								}
								else{
									$$.traducao_dec = $5.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
									$$.traducao = $5.traducao + "\t" + ref.tmp + " = " + var1->tmp + ";\n";
								}
								if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
									vector<variable> aux;
									aux.push_back(ref);
									globalTabSym.push_back(aux);
								}
								else{
									globalTabSym[mapAtual].push_back(ref);
								}
							}
							else{
								yyerror("Voce ainda não inicialiou a variavel " + var1->nome + ".\n");
							}
						} 
						else{
							cout<<"teste2"<<endl;
							variable ref;
							ref.tipo = $5.tipo;
							ref.nome = $3.label;
							ref.valor = $5.label;
							ref.tmp = genLabel();
							if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){//o tamanho da estrutura tem que ser maior que o tamanho do map
								vector<variable> aux;//pois se for igual, globalTabSym[mapAtual] não vai ter nenhum elemento, com isso tenho que adicionar um elemento(vetor nesse caso)
								aux.push_back(ref);//pra depois poder adicionar somente as variables
								globalTabSym.push_back(aux);
							}
							else{
								globalTabSym[mapAtual].push_back(ref);
							}
							if($4.tipo == "string"){
								$$.traducao_dec = $5.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
								$$.traducao = $5.traducao + "\t" + ref.tmp + " = " + $5.tmp + ";\n";
								$$.traducao = $5.traducao + "\t" + ref.tmp + " =  (string*) malloc(" + to_string($5.label.size())  + "* sizeof(string));\n" + "\t" + 
								ref.tmp + " = " + $5.tmp + ";\n";	
							}
							else{
								$$.traducao_dec = $5.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
								$$.traducao = $5.traducao + "\t" + ref.tmp + " = " + $5.tmp + ";\n";
							}
						}
					}
					else{
						yyerror("Declaração de variável global somente fora de função ou antes do bloco main, ambas com o modificador \"global\".\n");
					}
				}
				;

ENTRADA			: TK_INPUT '(' E ')'
				{	
					cout<<"tk_input ( E )"<<endl;
					if(verifyVariableGlobal($3.label)){
						cout<<"teste1"<<endl;
						variable *var1 = returnVariable($3.label);
						
						if(var1->tipo == ""){
							string aux = genLabel();
							$$.traducao_dec = $3.traducao_dec;
							$$.traducao = $3.traducao + "\tinput( " + var1->nome + " );\n" + "\t" + var1->tmp + " = " + aux + ";\n";
						}
						else{
							string aux = genLabel();
							$$.traducao_dec = $3.traducao_dec + "\t" + var1->tipo + " " + aux + ";\n";
							$$.traducao = $3.traducao + "\tinput( " + var1->nome + " );\n" + "\t" + var1->tmp + " = " + aux + ";\n";
						}
					}
					else{
						yyerror("Você não declarou a variável " + $3.label + "\n");
					}
				}
				;	

SAIDA			: TK_SAIDA '(' E ')'
				{
					cout<<"tk_saida ( E )"<<endl;
					if(verifyVariableGlobal($3.label)){
						cout<<"teste1"<<endl;
						variable *var1 = returnVariable($3.label);
						$$.traducao_dec = $3.traducao_dec;
						$$.traducao = $4.traducao + "\tprint( " + var1->tmp + " );\n";
					}
					else{
						yyerror("Você não declarou a variável " + $3.label + "\n");
					}
				}
				;

IF			    : TK_IF '(' E ')' BLOCO 
				{
					cout<<"TK_IF"<<endl;
					variable *var1 = returnVariable($3.label);
					string aux = genLabel();
					if($3.tipo == "bool"){
						$$.traducao_dec = $3.traducao_dec + $5.traducao_dec + "\tint " + aux + ";\n";
						$$.traducao = $3.traducao + "\t" + aux + " = " + $3.tmp + "\n\tif ( !" + aux + ") goto FIM;\n\t{\n" + $5.traducao + "\t}\n\tFIM:\n";
					}
					else if(var1->nome == $3.label && var1->tipo != "char"){
						$$.traducao_dec = $3.traducao_dec + $5.traducao_dec + "\tint " + aux + ";\n";
						$$.traducao = $3.traducao + "\t" + aux + " = " + var1->tmp + "\n\tif ( !" + aux + ") goto FIM;\n\t{\n" + $5.traducao + "\t}\n\tFIM:\n";
					}
					else{
						yyerror("Somente expressões booleanas são validas dentro da condicional");
					}
				}
				;

ELSEE		  	: IF TK_ELSE 
				{
				}
				;

ELSE 			: ELSEE BLOCO
				{
					
				}
				| ELSEE TK_IF '(' E ')' BLOCO
				{
				
				}
				;

SWITCH			: TK_SWITCH '(' E ')' '{' CASE '}'
				{
					cout<<"entro aqui"<<endl;
				}
				;

CASE			: TK_CASE TK_NUM ':' E ';' TK_BREAK ';' CASE
				{
					cout<<"BRAIDA"<<endl;
				}
				| TK_CASE TK_NUM ':' DECLARACAO ';' TK_BREAK ';' CASE	
				{
				}
				| TK_CASE TK_NUM ':' ENTRADA ';' TK_BREAK ';' CASE	
				{
				}
				| TK_CASE TK_NUM ':' SAIDA ';' TK_BREAK ';' CASE	
				{
				}
				| TK_DEFAULT ':' E ';'
				{
				}
				| TK_DEFAULT ':' DECLARACAO ';'
				{
				}
				| TK_DEFAULT ':' ENTRADA ';'
				{
				}
				| TK_DEFAULT ':' SAIDA ';'
				{
				}
				;				

FOR				: TK_FOR '(' DECLARACAO ';' E ';' E ')' BLOCO
				{
					cout<<"TK_FOR()"<<endl;
					string aux = genLabel();
					int posChange = $5.traducao.find_first_of(";");
					posChange++;
					$5.traducao.insert(posChange, "\n\tINICIO_FOR:");
					$$.traducao_dec = $3.traducao_dec + $5.traducao_dec + $7.traducao_dec + $9.traducao_dec;
					$$.traducao = "\tfor( " + $3.label + " ; " + $5.tmp + " ; " + $7.label + "++ ){\n" + $3.traducao + $5.traducao + "\t" + aux + " = !( " + $5.tmp + " );\n\tif( " +
					aux + " ) goto FIM_FOR;\n" + $9.traducao + $7.traducao + "\tgoto INICIO_FOR;\n\tFIM_FOR:\n";
				}
				; 									

WHILE 			: TK_WHILE '(' E ')' BLOCO
				{
					cout<<"TK_WHILE()"<<endl;
					variable *var1 = returnVariable($3.label);
					string aux = genLabel();

					if(var1->nome == $3.label && var1->tipo != "char"){
						$$.traducao_dec = $3.traducao_dec + $5.traducao_dec + "\tint " + aux + ";\n";
						$$.traducao = "\twhile( " + var1->nome + " ){\n" + "\tINICIO_WHILE:\n" + "\t\t" + aux + " = !( " + var1->tmp + " );\n\t\tif( " + aux + " ) goto FIM_WHILE;" +       
						$5.traducao + "\n\t\tgoto INICIO_WHILE;\n\tFIM_WHILE:\n";
					}
					else if($3.tipo == "bool"){
						int posChange = $3.traducao.find_first_of(";");
						posChange = $3.traducao.find(";",posChange + 1);
						posChange++;
						$3.traducao.insert(posChange, "\n\tINICIO_WHILE:");
						$$.traducao_dec = $3.traducao_dec + $5.traducao_dec + + "\tint " + aux + ";\n";
						$$.traducao = "\twhile( " + $3.tmp + " ){\n" + $3.traducao  + "\t\t" + aux + " = !( " + $3.tmp + " );\n\t\tif( " + aux + " ) goto FIM_WHILE;\n" +       
						$5.traducao + "\t\tgoto INICIO_WHILE;\n\tFIM_WHILE:\n";
					}
					else{
						yyerror("Expressão de condição não permitida\n");
					}
				}
				;

DOWHILE 		: TK_DO BLOCO TK_WHILE '(' E ')'
				{
					cout<<"TK_DO WHILE()"<<endl;
					variable *var1 = returnVariable($5.label);
					string aux = genLabel();

					if(var1->nome == $5.label && var1->tipo != "char"){
						$$.traducao_dec = $2.traducao_dec + $5.traducao_dec + "\tint " + aux + ";\n";
						$$.traducao = "\tdo{\n\tINICIO_DO_WHILE:\n" + $2.traducao + "\t\t"+ aux + " = !( " + var1->tmp + " );\n\t\tif( " + aux + " ) goto FIM_DO_WHILE;\n\t\tgoto INICIO_WHILE;" +
						"\n\tFIM_DO_WHILE:\n\t}while( " + var1->nome + " );\n";
					}
					else if($5.tipo == "bool"){
						$$.traducao_dec = $2.traducao_dec + $5.traducao_dec;
						$$.traducao = "\tdo{\n\tINICIO_DO_WHILE:\n" + $2.traducao + "\t\t"+ aux + " = !( " + $5.tmp + " );\n\t\tif( " + aux + " ) goto FIM_DO_WHILE;\n\t\tgoto INICIO_WHILE;" +
						"\n\tFIM_DO_WHILE:\n" + $5.traducao +"\t}while( " + $5.tmp + " );\n";
					}
					else{
						yyerror("Expressão de condição não permitida\n");
					}
				}
				;	

BREAK			: TK_BREAK ';'
				{

				}							
				;

CONTINUE		:
				;

E 				: E '+' E //Soma de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					cout<<"E+E"<<endl;
					criaOperacao(&$$, $1, $3, "soma");
				}
				| E '-' E //Subtração de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					cout<<"E-E"<<endl;
					criaOperacao(&$$, $1, $3, "subtracao");
				}
				| E '*' E //Multiplicação de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					cout<<"E*E"<<endl;
					criaOperacao(&$$, $1, $3, "multiplicacao");
				}
				| E '/' E //Divisão de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					cout<<"E/E"<<endl;
					criaOperacao(&$$, $1, $3, "divisao");
				}
				| E TK_LESS E
				{
					cout<<"E TK_LESS E"<<endl;
					criaOperacao(&$$, $1, $3, "tk_less");
				}
				| E TK_GREATER E
				{
					cout<<"E TK_LE E"<<endl;
					criaOperacao(&$$, $1, $3, "tk_greater");
				}
				| E TK_LE E
				{
					cout<<"E TK_LE E"<<endl;
					criaOperacao(&$$, $1, $3, "tk_le");
				}
				| E TK_HE E
				{
					cout<<"E TK_HE E"<<endl;
					criaOperacao(&$$, $1, $3, "tk_he");
				}
				| E TK_EQ E
				{
					cout<<"E TK_EQ E"<<endl;
					criaOperacao(&$$, $1, $3, "tk_eq");
				}
				| E TK_DIFF E
				{
					cout<<"E TK_DIFF E"<<endl;
					criaOperacao(&$$, $1, $3, "tk_diff");
				}
				| TK_ID TK_UN_SUM
				{
					cout<<"TK_ID TK_UN_SUM"<<endl;
					if(verifyVariableGlobal($1.label) == false){
						yyerror("Você não declarou a variável " + $1.label + "\n");	
					}
					variable *v1 = returnVariable($1.label);
					string aux = genLabel();
					
					if(v1->tipo == ""){
						v1->tipo = "int";
						v1->tipo = "0";
						$$.traducao_dec = $1.traducao_dec + "\tint " + aux + ";\n";
						$$.traducao = $1.traducao + "\t" + aux + " = 1;\n" + "\t" +  v1->tmp + " = " + v1->tmp + " + " + aux + ";\n";
					}
					else if(v1->tipo == "float" || v1->tipo == "int"){
						$$.traducao_dec = $1.traducao_dec + "\t" + v1->tipo + " " + aux + ";\n";
						$$.traducao = $1.traducao + "\t" + aux + " = 1;\n" + "\t" +  v1->tmp + " = " + v1->tmp + " + " + aux + ";\n";
					}
					else{
						yyerror("Soma não permitida\n");		
					}
				}
				| TK_ID TK_UN_SUB
				{
					cout<<"TK_ID TK_UN_SUB"<<endl;
					if(verifyVariableGlobal($1.label) == false){
						yyerror("Você não declarou a variável " + $1.label + "\n");	
					}
					variable *v1 = returnVariable($1.label);
					string aux = genLabel();
					
					if(v1->tipo == ""){
						v1->tipo = "int";
						v1->tipo = "0";
						$$.traducao_dec = $1.traducao_dec + "\tint " + aux + ";\n";
						$$.traducao = $1.traducao + "\t" + aux + " = 1;\n" + "\t" +  v1->tmp + " = " + v1->tmp + " - " + aux + ";\n";
					}
					else if(v1->tipo == "float" || v1->tipo == "int"){
						$$.traducao_dec = $1.traducao_dec + "\t" + v1->tipo + " " + aux + ";\n";
						$$.traducao = $1.traducao + "\t" + aux + " = 1;\n" + "\t" +  v1->tmp + " = " + v1->tmp + " - " + aux + ";\n";
					}
					else{
						yyerror("Soma não permitida\n");		
					}
				}
				| TK_NOT '(' E ')'
				{
					if($3.tmp != ""){
						//---------------------------------- Uma forma --------------------------------//
						//string aux = genLabel();
						//$$.traducao_dec = $2.traducao_dec + $6.traducao_dec;
						//$$.traducao = $2.traducao + $6.traducao;
						//$$.tmp = $2.tmp + "&&" + $6.tmp;
						//---------------------------------- Outra forma --------------------------------//
						string aux = genLabel();
						$$.traducao_dec = $3.traducao_dec + "\tint " + aux + ";\n";
						$$.traducao = $3.traducao + "\t" +  aux + " = " + $3.tmp + ";\n";
						$$.tipo = "int";
						$$.tmp = "!(" + aux + ")";
					}
					else{
						yyerror("Comparação não permitida\n");
					}
				} 
				|'(' E ')' TK_OR '(' E ')'
				{
					if($2.tmp != "" && $6.tmp != ""){
						string aux = genLabel();
						string aux1 = genLabel();
						$$.traducao_dec = $2.traducao_dec + $6.traducao_dec + "\tint " + aux + ";\n" + "\tint " + aux1 + ";\n";
						$$.traducao = $2.traducao + $6.traducao + "\t" +  aux + " = " + $2.tmp + ";\n" + "\t" +  aux1 + " = " + $6.tmp + ";\n";
						$$.tipo = "int";
						$$.tmp = aux + " || " + aux1;
					}
					else{
						yyerror("Comparação não permitida\n");
					}	
				} 
				|'(' E ')' TK_AND '(' E ')'
				{
					if($2.tmp != "" && $6.tmp != ""){
						//---------------------------------- Uma forma --------------------------------//
						//string aux = genLabel();
						//$$.traducao_dec = $2.traducao_dec + $6.traducao_dec;
						//$$.traducao = $2.traducao + $6.traducao;
						//$$.tmp = $2.tmp + "&&" + $6.tmp;
						//---------------------------------- Outra forma --------------------------------//
						string aux = genLabel();
						string aux1 = genLabel();
						$$.traducao_dec = $2.traducao_dec + $6.traducao_dec + "\tint " + aux + ";\n" + "\tint " + aux1 + ";\n";
						$$.traducao = $2.traducao + $6.traducao + "\t" +  aux + " = " + $2.tmp + ";\n" + "\t" +  aux1 + " = " + $6.tmp + ";\n";
						$$.tipo = "int";
						$$.tmp = aux + " && " + aux1;
					}
					else{
						yyerror("Comparação não permitida\n");
					}
				}
				| TK_ID '=' E // Atribuição de uma variável ou um valor qualquer a uma variável já declarada
				{
					cout<<"tk_id = E"<<endl;
					bool encontrei = false;
					bool found = false;
					encontrei = verifyVariableGlobal($1.label);
					found = verifyVariableGlobal($3.label);
					variable *var1 = returnVariable($1.label);
					variable *var2 = returnVariable($3.label);

				//------------------------------------------------ Atribuições sem valores iniciais ------------------------------------------------//
					if(encontrei == true && found == true && var1->tipo == "" && var2->tipo != "" && $3.tmp == "")  {//Se o $3.tmp for igual a vazio a atribuição é somente de variável
						if(var2->tipo == "string"){//e não da soma de duas coisas, pois se fosse da soma de duas coisas o $3.tmp iria ter valor
							var1->valor = var2->valor;
							var1->tipo = var2->tipo;
							$$.traducao_dec ="\t" + var1->tipo + " " + var1->tmp + ";\n";
							$$.traducao = $3.traducao + "\t" + var1->tmp + " =  (string*) malloc(" + to_string(var2->valor.size())  + "* sizeof(string));\n" + "\t" + 
							var1->tmp + " = " + var2->tmp + ";\n";
						}
						else{
							var1->valor = var2->valor;
							var1->tipo = var2->tipo;
							$$.traducao_dec ="\t" + var1->tipo + " " + var1->tmp + ";\n";
							$$.traducao = $3.traducao + "\t" + var1->tmp + " = " + var2->tmp + ";\n"; 
						}
						cout<<"Tst1"<<endl;
					}
					else if(encontrei == true && var1->tipo == ""){
						if($3.tipo == "string"){
							var1->valor = $3.label;
							var1->tipo = $3.tipo;
							$$.traducao_dec = "\t" + var1->tipo + " " + var1->tmp + ";\n" + $3.traducao_dec;
							$$.traducao = $3.traducao + "\t" + var1->tmp + " =  (string*) malloc(" + to_string($3.label.size())  + "* sizeof(string));\n" + "\t" + 
							var1->tmp + " = " + $3.tmp + ";\n";
						}
						else{
							var1->valor = $3.label;
							var1->tipo = $3.tipo;
							$$.traducao_dec = "\t" + var1->tipo + " " + var1->tmp + ";\n" + $3.traducao_dec;
							$$.traducao = $3.traducao + "\t" + var1->tmp + " = " + $3.tmp +  ";\n";
						}
						cout<<"Tst2"<<endl;
					}
				//------------------------------------------------ Atribuições com valores iniciais ------------------------------------------------//
					else if(encontrei == true && found == true && var1->tipo == "float" && (var2->tipo == "int" || var2->tipo == "float") ){//If que verifica se a variavel que está recebendo
						var1->valor = var2->valor;//a atribuição é do tipo float, permitindo ser adicionado uma variável do tipo int ou float
						//Não preciso do traducao_dec pois a variavel que está recebendo a atribuição e a variável que está sendo atribuida, já foram inicializadas
						$$.traducao_dec = $3.traducao_dec;
						$$.traducao = "\t" + var1->tmp + " = " + var2->tmp + ";\n";//Não preciso propagar o $3.traducao pois eles ja foram feitos antes
						cout<<"Tst3"<<endl;
					}
					else if(encontrei == true && var1->tipo == "float" && ($3.tipo == "int" || $3.tipo == "float")){//Verifica se a variável que está recebendo a atribuição é do tipo
						var1->valor = $3.label;//float e se o valor qualquer adicionado é do tipo int ou float para fazer a atribuição
					 	$$.traducao_dec = $3.traducao_dec;
						$$.traducao = $3.traducao + "\t" + var1->tmp + " = " + $3.tmp + ";\n" ;
						cout<<"Tst4"<<endl;
					}
					else if(encontrei == true && found == true && var1->tipo != "" && var1->tipo == var2->tipo && $3.tmp == ""){//Verifica se o termo a ser atribuido é do mesmo tipo da variável a recebe-lo
						
						if(var2->tipo == "string"){//e não da soma de duas coisas, pois se fosse da soma de duas coisas o $3.tmp iria ter valor
							var1->valor = var2->valor;
							$$.traducao_dec = $3.traducao_dec;
							$$.traducao = "\t" + var1->tmp + " =  (string*) malloc(" + to_string(var2->valor.size())  + "* sizeof(string));\n" + "\t" + 
							var1->tmp + " = " + var2->tmp + ";\n";
						}
						else{
							var1->valor = var2->valor;
							$$.traducao_dec = $3.traducao_dec;
							$$.traducao ="\t" + var1->tmp + " = " + var2->tmp + ";\n";//Salva o novo valor na variavel e na tabela de simbolos
						}
						cout<<"Tst5"<<endl;
					}
					else if(encontrei == true && var1->tipo == $3.tipo){//Verifica se o termo a ser atribuido é um valor qualquer
						
						if($3.tipo == "string"){
							var1->valor = $3.label;
							$$.traducao_dec = $3.traducao_dec;
							$$.traducao = $3.traducao + "\t" + var1->tmp + " =  (string*) malloc(" + to_string($3.label.size())  + "* sizeof(string));\n" + "\t" + 
							var1->tmp + " = " + $3.tmp + ";\n";
						}
						else{
							var1->valor = $3.label;
							$$.traducao_dec = $3.traducao_dec;
							$$.traducao = $3.traducao + "\t" + var1->tmp + " = " + $3.tmp + ";\n";
						}
						cout<<"Tst6"<<endl;
					}
					else if(found == true && var2->valor == ""){
						yyerror("Você não inicializou a variável " + $3.label + ".\n");
					}
					else if(encontrei == false){
						yyerror("Você não declarou a variavel " + $1.label + ".\n");	
					}
					else{
						yyerror("Atribuição não permitida, tipo da variável a ser atribuida é diferente do tipo de atribuição.\n");
					}
				}
				| TK_ID '=' '(' TK_TIPO_INT ')' E
				{
					cout<<"tk_id = (TK_TIPO_INT) E"<<endl;
					bool encontrei = false;
					bool found = false;
					encontrei = verifyVariableGlobal($1.label);
					found = verifyVariableGlobal($6.label);
					variable *var1 = returnVariable($1.label);
					variable *var2 = returnVariable($6.label);

					//------------------------------------------------ Atribuições sem valores iniciais ------------------------------------------------//
					if(encontrei == true && found == true && var1->tipo == "" && var2->tipo == "float" && $6.tmp == ""){//Se o $3.tmp for igual a vazio a atribuição é somente de variável
						int aux = std::stoi(var2->valor);
						var1->valor = std::to_string(aux);//e não da soma de duas coisas, pois se fosse da soma de duas coisas
						var1->tipo = "int";//o $3.tmp iria ter valor			
						$$.traducao_dec ="\t" + var1->tipo + " " + var1->tmp + ";\n";
						$$.traducao = $6.traducao + "\t" + var1->tmp + " = (int)" + var2->tmp + ";\n";
						cout<<"Tst1"<<endl;
					}
					else if(encontrei == true && var1->tipo == "" && $6.tipo == "float"){
						int aux = std::stoi($6.label);
						var1->valor = std::to_string(aux);
						var1->tipo = "int";
						$$.traducao_dec = "\t" + var1->tipo + " " + var1->tmp + ";\n" + $6.traducao_dec;
						$$.traducao = $6.traducao + "\t" + var1->tmp + " = (int)" + $6.tmp +  ";\n";
						cout<<"Tst2"<<endl;
					}
					//------------------------------------------------ Atribuições com valores iniciais ------------------------------------------------//
					else if(encontrei == true && found == true && var1->tipo == "int" && var2->tipo == "float" ){//If que verifica se a variavel que está recebendo
						int aux = std::stoi(var2->valor);
						var1->valor = std::to_string(aux);//a atribuição é do tipo float, permitindo ser adicionado uma variável do tipo int ou float
						var1->tipo = "int";//Não preciso do traducao_dec pois a variavel que está recebendo a atribuição e a variável que está sendo atribuida, já foram inicializadas
						$$.traducao_dec = $6.traducao_dec;
						$$.traducao = "\t" + var1->tmp + " = (int)" + var2->tmp + ";\n";//Não preciso propagar o $3.traducao pois eles ja foram feitos antes
						cout<<"Tst3"<<endl;
					}
					else if(encontrei == true && var1->tipo == "int" && $6.tipo == "float"){//Verifica se a variável que está recebendo a atribuição é do tipo
						int aux = std::stoi($6.label);
						var1->valor = std::to_string(aux);//float e se o valor qualquer adicionado é do tipo int ou float para fazer a atribuição
					 	var1->tipo = "int";
						$$.traducao_dec = $6.traducao_dec;
						$$.traducao = $6.traducao + "\t" + var1->tmp + " = (int)" + $6.tmp + ";\n" ;

						cout<<"Tst4"<<endl;
					}
					else if(found == true && var2->valor == ""){
						yyerror("Você não inicializou a variável " + $6.label + ".\n");
					}
					else{
						yyerror("Atribuição não permitida, tipo da variável a ser atribuida é diferente do tipo de atribuição.\n");
					}
				}
				| TK_ID '=' '(' TK_TIPO_FLOAT ')' E
				{
					cout<<"tk_id = (TK_TIPO_FLOAT) E"<<endl;
					bool encontrei = false;
					bool found = false;
					encontrei = verifyVariableGlobal($1.label);
					found = verifyVariableGlobal($6.label);
					variable *var1 = returnVariable($1.label);
					variable *var2 = returnVariable($6.label);
					//cout
					//------------------------------------------------ Atribuições sem valores iniciais ------------------------------------------------//
					if(encontrei == true && found == true && var1->tipo == "" && var2->tipo == "int" && $6.tmp == ""){//Se o $3.tmp for igual a vazio a atribuição é somente de variável
						float aux = std::stof(var2->valor);
						var1->valor = std::to_string(aux);//e não da soma de duas coisas, pois se fosse da soma de duas coisas
						var1->tipo = "float";//o $3.tmp iria ter valor			
						$$.traducao_dec ="\t" + var1->tipo + " " + var1->tmp + ";\n";
						$$.traducao = $6.traducao + "\t" + var1->tmp + " = (float)" + var2->tmp + ";\n";
						cout<<"Tst1"<<endl;
					}
					else if(encontrei == true && var1->tipo == "" && $6.tipo == "int"){
						float aux = std::stof($6.label);
						var1->valor = std::to_string(aux);
						var1->tipo = "float";
						$$.traducao_dec = "\t" + var1->tipo + " " + var1->tmp + ";\n" + $6.traducao_dec;
						$$.traducao = $6.traducao + "\t" + var1->tmp + " = (float)" + $6.tmp +  ";\n";
						cout<<"Tst2"<<endl;
					}
					//------------------------------------------------ Atribuições com valores iniciais ------------------------------------------------//
					else if(encontrei == true && found == true && var1->tipo == "float" && var2->tipo == "int" ){//If que verifica se a variavel que está recebendo
						float aux = std::stof(var2->valor);
						var1->valor = std::to_string(aux);//a atribuição é do tipo float, permitindo ser adicionado uma variável do tipo int ou float
						var1->tipo = "float";//Não preciso do traducao_dec pois a variavel que está recebendo a atribuição e a variável que está sendo atribuida, já foram inicializadas
						$$.traducao_dec = $6.traducao_dec;
						$$.traducao = "\t" + var1->tmp + " = (float)" + var2->tmp + ";\n";//Não preciso propagar o $3.traducao pois eles ja foram feitos antes
						cout<<"Tst3"<<endl;
					}
					else if(encontrei == true && var1->tipo == "float" && $6.tipo == "int"){//Verifica se a variável que está recebendo a atribuição é do tipo
						float aux = std::stof($6.label);
						var1->valor = std::to_string(aux);//float e se o valor qualquer adicionado é do tipo int ou float para fazer a atribuição
					 	var1->tipo = "float";
						$$.traducao_dec = $6.traducao_dec;
						$$.traducao = $6.traducao + "\t" + var1->tmp + " = (float)" + $6.tmp + ";\n" ;
						cout<<"Tst4"<<endl;
					}
					else if(found == true && var2->valor == ""){
						yyerror("Você não inicializou a variável " + $6.label + ".\n");
					}
					else{
						yyerror("Atribuição não permitida, tipo da variável a ser atribuida é diferente do tipo de atribuição.\n");
					}
					
				}
				| TK_NUM
				{
					cout<<"tk_num"<<endl;
					$$.tipo = "int";
					$$.tmp = genLabel();
					$$.traducao_dec = "\t" + $$.tipo + " " + $$.tmp + ";\n";
					$$.traducao = "\t" + $$.tmp + " = " + $$.label + ";\n";
				}
				| TK_FLOAT
				{
					cout<<"tk_float"<<endl;
					$$.tipo = "float";
					$$.tmp = genLabel();
					$$.traducao_dec = "\t" + $$.tipo + " " + $$.tmp + ";\n";
					$$.traducao = "\t" + $$.tmp + " = " + $$.label + ";\n";
				}
				| TK_CHAR
				{
					cout<<"tk_char"<<endl;
					$$.tipo = "char";
					$$.tmp = genLabel();
					$$.traducao_dec = "\t" + $$.tipo + " " + $$.tmp + ";\n";
					$$.traducao = "\t" + $$.tmp + " = " + $$.label + ";\n";
				}
				| TK_STRING
				{
					cout<<"tk_string"<<endl;
					$$.tipo = "string";
					$$.tmp = genLabel();
					
					$$.traducao_dec = "\t" + $$.tipo + " " + $$.tmp + ";\n";
					$$.traducao = "\t" + $$.tmp + " =  (string*) malloc(" + to_string($$.label.size())  + "* sizeof(string));\n" + "\t" + $$.tmp + " = " + $$.label + ";\n";
				}
				| TK_BOOL
				{
					cout<<"tk_bool"<<endl;
					$$.tipo = "bool";
					$$.tmp = genLabel();
					$$.traducao_dec = "\tint " + $$.tmp + ";\n";
					$$.traducao = "\t" + $$.tmp + " = " + $$.label + ";\n";
				}
				| TK_ID
				{	
					cout<<"tk_id"<<endl;
					bool encontrei = false;
					encontrei = verifyVariableGlobal($1.label);
					variable *var1;
					
					if(encontrei == true){
						var1 = returnVariable($1.label);
						$$.tipo = var1->tipo;
					}

					if(!encontrei){
						yyerror("Você não declarou a variável " + $1.label + "\n");	
					}
				}
				;


%%

#include "lex.yy.c"
#include <stdlib.h>

int yyparse();

int main(int argc, char* argv[]){
	//var_temp_qnt = 0;
		
	yyparse();

	return 0;
}

void yyerror(string MSG){
	cout << MSG << endl;
	exit (0);
}	

string genLabel(){

	return "temp" + to_string(valorVar++);
}

bool verifyVariableGlobal(string nome){
	
	for(int i = globalTabSym.size(); i > 0; i--){
			for(int y = 0; y < globalTabSym[i-1].size(); y++){
				if(globalTabSym[i-1][y].nome == nome){
					return true;
				}
			}
	}
	return false;
}

bool verifyVariableLocal(string nome){
	
	if(globalTabSym.empty() == 0 && globalTabSym.size() > mapAtual){
		for(int i = 0; i < globalTabSym[mapAtual].size(); i++){
			if(globalTabSym[mapAtual][i].nome == nome){
					return true;
			}
		}
	}
	return false;
}

variable *returnVariable(string nome){

	auxiliar.tipo = "";
	auxiliar.nome = "";
	auxiliar.valor = "";
	auxiliar.tmp = "";

	for(int i = globalTabSym.size(); i > 0; i--){
		for(int y = 0; y < globalTabSym[i-1].size(); y++){
			if(globalTabSym[i-1][y].nome == nome){
				return &globalTabSym[i-1][y];
			}
		}
	}
	return &auxiliar;
}

void criaOperacao(atributos *dolardolar, atributos dolar1, atributos dolar3, string operacao){//variable v1, variable v2,
	
	variable *v1 = returnVariable(dolar1.label);
	variable *v2 = returnVariable(dolar3.label);

	if(operacao == "soma"){
	//-------------------------------------------------------- Soma de inteiro --------------------------------------------------------//
		if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "int"){//int var + int var
			int aux = std::stoi(v1->valor) + std::stoi(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = v1->tmp + " + " + v2->tmp;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "int"){//int var + int num
			int aux = std::stoi(v1->valor) + std::stoi(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = v1->tmp + " + " + dolar3.tmp;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num + int var
			int aux = std::stoi(dolar1.label) + std::stoi(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = dolar1.tmp + " + " + v2->tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num + int num
			int aux = std::stoi(dolar1.label) + std::stoi(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = dolar1.tmp + " + " + dolar3.tmp;
		}
	//--------------------------------------------------------- Soma de float ---------------------------------------------------------//
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "float"){//int var + float var
			float aux1 = std::stof(v1->valor) + std::stof(v2->valor);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v1->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " + " + v2->tmp;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "int"){//float var + int var
			float aux1 = std::stof(v1->valor) + std::stof(v2->valor);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v2->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " + " + aux;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "float"){//float var + float var
			float aux1 = std::stof(v1->valor) + std::stof(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " + " + v2->tmp;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "float"){//float var + float num
			float aux1 = std::stof(v1->valor) + std::stof(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " + " + dolar3.tmp;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "int"){//float var + int num
			float aux1 = std::stof(v1->valor) + std::stof(dolar3.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " + " + aux;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "float"){//int var + float num
			float aux1 = std::stof(v1->valor) + std::stof(dolar3.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao ="\t" +  aux + " = (float)" + v1->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " + " + dolar3.tmp;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "float"){//float num + int var
			float aux1 = std::stof(v2->valor) + std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" + aux + " = (float)" + v2->tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " + " + aux;
		}	
		else if(v2->valor != "" && v2->tipo == "float" && dolar1.tipo == "float"){//float num + float var
			float aux1 = std::stof(v2->valor) + std::stof(dolar1.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " + " + v2->tmp;
		}
		else if(v2->valor != "" && v2->tipo == "float" && dolar1.tipo == "int"){//int num + float var
			float aux1 = std::stof(v2->valor) + std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao =dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " + " + v2->tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num + float num
			float aux1 = std::stof(dolar3.label) + std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " + " + dolar3.tmp;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num + int num
			float aux1 = std::stof(dolar3.label) + std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " + " + aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num + float num
			float aux1 = std::stof(dolar3.label) + std::stof(dolar1.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " + " + dolar3.tmp;
		}
		else{
			yyerror("Soma não permitida\n");
		}
		//-------------------------------------------------------- Fim Soma --------------------------------------------------------//
	}
	else if(operacao == "subtracao"){
	//-------------------------------------------------------- Subtração de inteiro --------------------------------------------------------//
		if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "int"){//var int - var int
			int aux = std::stoi(v1->valor) - std::stoi(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = v1->tmp + " - " + v2->tmp;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "int"){//var int - int num
			int aux = std::stoi(v1->valor) - std::stoi(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = v1->tmp + " - " + dolar3.tmp;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num - var int
			int aux = std::stoi(dolar1.label) - std::stoi(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = dolar1.tmp + " - " + v2->tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num - int num
			int aux = std::stoi(dolar1.label) - std::stoi(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = dolar1.tmp + " - " + dolar3.tmp;
		}
	//--------------------------------------------------------- Subtracão de float ---------------------------------------------------------//
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "float"){//int var - float var
			float aux1 = std::stof(v1->valor) - std::stof(v2->valor);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v1->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " - " + v2->tmp;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "int"){//float var - int var
			float aux1 = std::stof(v1->valor) - std::stof(v2->valor);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v2->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " - " + aux;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "float"){//float var - float var
			float aux1 = std::stof(v1->valor) - std::stof(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " - " + v2->tmp;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "float"){//float var - float num
			float aux1 = std::stof(v1->valor) - std::stof(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " - " + dolar3.tmp;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "int"){//float var - int num
			float aux1 = std::stof(v1->valor) - std::stof(dolar3.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " - " + aux;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "float"){//int var - float num
			float aux1 = std::stof(v1->valor) - std::stof(dolar3.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao ="\t" +  aux + " = (float)" + v1->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " - " + dolar3.tmp;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "float"){//float num - int var
			float aux1 = std::stof(v2->valor) - std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" + aux + " = (float)" + v2->tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " - " + aux;
		}	
		else if(v2->valor != "" && v2->tipo == "float" && dolar1.tipo == "float"){//float num - float var
			float aux1 = std::stof(v2->valor) - std::stof(dolar1.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " - " + v2->tmp;
		}
		else if(v2->valor != "" && v2->tipo == "float" && dolar1.tipo == "int"){//int num - float var
			float aux1 = std::stof(v2->valor) - std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao =dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " - " + v2->tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num - float num
			float aux1 = std::stof(dolar3.label) - std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " - " + dolar3.tmp;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num - int num
			float aux1 = std::stof(dolar3.label) - std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " - " + aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num - float num
			float aux1 = std::stof(dolar3.label) - std::stof(dolar1.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " - " + dolar3.tmp;
		}
		else{
			yyerror("Subtração não permitida\n");
		}
		//-------------------------------------------------------- Fim Subtracao --------------------------------------------------------//
	}
	else if(operacao == "multiplicacao"){
	//-------------------------------------------------------- Multiplicação de inteiro --------------------------------------------------------//
		if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "int"){//var int * var int
			int aux = std::stoi(v1->valor) * std::stoi(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = v1->tmp + " * " + v2->tmp;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "int"){//var int * int num
			int aux = std::stoi(v1->valor) * std::stoi(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = v1->tmp + " * " + dolar3.tmp;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num * var int
			int aux = std::stoi(dolar1.label) * std::stoi(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = dolar1.tmp + " * " + v2->tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num * int num
			int aux = std::stoi(dolar1.label) * std::stoi(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = dolar1.tmp + " * " + dolar3.tmp;
		}
	//--------------------------------------------------------- Multiplicação de float ---------------------------------------------------------//
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "float"){//int var * float var
			float aux1 = std::stof(v1->valor) * std::stof(v2->valor);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v1->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " * " + v2->tmp;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "int"){//float var * int var
			float aux1 = std::stof(v1->valor) * std::stof(v2->valor);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v2->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " * " + aux;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "float"){//float var * float var
			float aux1 = std::stof(v1->valor) * std::stof(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " * " + v2->tmp;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "float"){//float var * float num
			float aux1 = std::stof(v1->valor) * std::stof(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " * " + dolar3.tmp;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "int"){//float var * int num
			float aux1 = std::stof(v1->valor) * std::stof(dolar3.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " * " + aux;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "float"){//int var * float num
			float aux1 = std::stof(v1->valor) * std::stof(dolar3.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao ="\t" +  aux + " = (float)" + v1->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " * " + dolar3.tmp;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "float"){//float num * int var
			float aux1 = std::stof(v2->valor) * std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" + aux + " = (float)" + v2->tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " * " + aux;
		}	
		else if(v2->valor != "" && v2->tipo == "float" && dolar1.tipo == "float"){//float num * float var
			float aux1 = std::stof(v2->valor) * std::stof(dolar1.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " * " + v2->tmp;
		}
		else if(v2->valor != "" && v2->tipo == "float" && dolar1.tipo == "int"){//int num * float var
			float aux1 = std::stof(v2->valor) * std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao =dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " * " + v2->tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num * float num
			float aux1 = std::stof(dolar3.label) * std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " * " + dolar3.tmp;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num * int num
			float aux1 = std::stof(dolar3.label) * std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " * " + aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num * float num
			float aux1 = std::stof(dolar3.label) * std::stof(dolar1.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " * " + dolar3.tmp;
		}
		else{
			yyerror("Multiplicação não permitida\n");
		}
		//-------------------------------------------------------- Fim Multiplicação --------------------------------------------------------//
	}
	else if(operacao == "divisao"){
	//-------------------------------------------------------- Divisão de inteiro --------------------------------------------------------//
		if(dolar3.label == "0" || v2->valor == "0"){
			yyerror("Impossível dividir por zero\n");
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "int"){//var int / var int
			int aux = std::stoi(v1->valor) / std::stoi(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = v1->tmp + " / " + v2->tmp;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "int"){//var int / int num
			int aux = std::stoi(v1->valor) / std::stoi(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = v1->tmp + " / " + dolar3.tmp;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num / var int
			int aux = std::stoi(dolar1.label) / std::stoi(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = dolar1.tmp + " / " + v2->tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num / int num
			int aux = std::stoi(dolar1.label) / std::stoi(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = dolar1.tmp + " / " + dolar3.tmp;
		}
	//--------------------------------------------------------- Divisão de float ---------------------------------------------------------//
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "float"){//int var / float var
			float aux1 = std::stof(v1->valor) + std::stof(v2->valor);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v1->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " / " + v2->tmp;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "int"){//float var / int var
			float aux1 = std::stof(v1->valor) + std::stof(v2->valor);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v2->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " / " + aux;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "float"){//float var / float var
			float aux1 = std::stof(v1->valor) + std::stof(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " / " + v2->tmp;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "float"){//float var / float num
			float aux1 = std::stof(v1->valor) + std::stof(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " / " + dolar3.tmp;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "int"){//float var / int num
			float aux1 = std::stof(v1->valor) + std::stof(dolar3.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = v1->tmp + " / " + aux;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "float"){//int var / float num
			float aux1 = std::stof(v1->valor) + std::stof(dolar3.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao ="\t" +  aux + " = (float)" + v1->tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " / " + dolar3.tmp;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "float"){//float num / int var
			float aux1 = std::stof(v2->valor) + std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" + aux + " = (float)" + v2->tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " / " + aux;
		}	
		else if(v2->valor != "" && v2->tipo == "float" && dolar1.tipo == "float"){//float num / float var
			float aux1 = std::stof(v2->valor) + std::stof(dolar1.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " / " + v2->tmp;
		}
		else if(v2->valor != "" && v2->tipo == "float" && dolar1.tipo == "int"){//int num / float var
			float aux1 = std::stof(v2->valor) + std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao =dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " / " + v2->tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num / float num
			float aux1 = std::stof(dolar3.label) + std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = aux + " / " + dolar3.tmp;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num / int num
			float aux1 = std::stof(dolar3.label) + std::stof(dolar1.label);
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " / " + aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num / float num
			float aux1 = std::stof(dolar3.label) + std::stof(dolar1.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->label = std::to_string(aux1);
			dolardolar->tmp = dolar1.tmp + " / " + dolar3.tmp;
		}
		else{
			yyerror("Divisão não permitida\n");
		}
		//-------------------------------------------------------- Fim Divisão --------------------------------------------------------//
	}
	else if(operacao == "tk_less"){
	//-------------------------------------------------------- < de inteiro --------------------------------------------------------//	
		if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "int"){//int var < int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " < " + v2->tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "int"){//int var < int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " < " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num < int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " < " + v2->tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num < int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " < " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- < de float --------------------------------------------------------//
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "float"){//int var < float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " < " + v2->tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "int"){//float var < int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " +  v1->tmp + " < " + aux + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "float"){//float var < float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1->tmp + " < " + v2->tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "float"){//float var < float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " < " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "int"){//float var < int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1->tmp + " < " + aux + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "float"){//int var < float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " + aux + " < " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "int" ){//float num < int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " < " + aux + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "float"){//float num < float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " < " + v2->tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && dolar1.tipo == "int" && v2->tipo == "float" ){//int num < float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " < " + v2->tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num < float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " < " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num < int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " < " + aux + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num < float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " < " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux1;
		}
		else{
			yyerror("Comparação não permitida\n");
		}
	}
	else if(operacao == "tk_greater"){
	//-------------------------------------------------------- > de inteiro --------------------------------------------------------//	
		if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "int"){//int var > int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " > " + v2->tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "int"){//int var > int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " > " + dolar3.tmp + "\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num > int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " > " + v2->tmp + "\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num > int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " > " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- > de float --------------------------------------------------------//
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "float"){//int var > float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " > " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "int"){//float var > int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " +  v1->tmp + " > " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "float"){//float var > float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1->tmp + " > " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "float"){//float var > float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " > " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "int"){//float var > int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1->tmp + " > " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "float"){//int var > float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " + aux + " > " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "int" ){//float num > int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " > " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "float"){//float num > float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " > " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && dolar1.tipo == "int" && v2->tipo == "float" ){//int num > float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " > " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num > float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " > " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num > int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " > " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num > float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " > " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else{
			yyerror("Comparação não permitida\n");
		}
	}
	else if(operacao == "tk_le"){
	//-------------------------------------------------------- <= de inteiro --------------------------------------------------------//	
		if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "int"){//int var <= int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " <= " + v2->tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "int"){//int var <= int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " <= " + dolar3.tmp + "\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num <= int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " <= " + v2->tmp + "\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num <= int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " <= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- <= de float --------------------------------------------------------//
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "float"){//int var <= float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " <= " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "int"){//float var <= int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " +  v1->tmp + " <= " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "float"){//float var <= float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1->tmp + " <= " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "float"){//float var <= float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " <= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "int"){//float var <= int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1->tmp + " <= " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "float"){//int var <= float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " + aux + " <= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "int" ){//float num <= int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " <= " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "float"){//float num <= float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " <= " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && dolar1.tipo == "int" && v2->tipo == "float" ){//int num <= float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " <= " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num <= float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " <= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num <= int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " <= " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num <= float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " <= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else{
			yyerror("Comparação não permitida\n");
		}	
	}
	else if(operacao == "tk_he"){
	//-------------------------------------------------------- >= de inteiro --------------------------------------------------------//	
		if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "int"){//int var >= int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " >= " + v2->tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "int"){//int var >= int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " >= " + dolar3.tmp + "\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num >= int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " >= " + v2->tmp + "\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num >= int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " >= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- >= de float --------------------------------------------------------//
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "float"){//int var >= float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " >= " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "int"){//float var >= int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " +  v1->tmp + " >= " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "float"){//float var >= float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1->tmp + " >= " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "float"){//float var >= float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " >= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "int"){//float var >= int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1->tmp + " >= " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "float"){//int var >= float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " + aux + " >= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "int" ){//float num >= int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " >= " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "float"){//float num >= float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " >= " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && dolar1.tipo == "int" && v2->tipo == "float" ){//int num >= float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " >= " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num >= float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " >= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num >= int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " >= " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num >= float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " >= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else{
			yyerror("Comparação não permitida\n");
		}	
	}
	else if(operacao == "tk_eq"){
	//-------------------------------------------------------- == de inteiro --------------------------------------------------------//	
		if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "int"){//int var == int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " == " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "int"){//int var == int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " == " + dolar3.tmp + "\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num == int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " == " + v2->tmp + "\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num == int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " == " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- == de float --------------------------------------------------------//
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "float"){//int var == float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " == " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "int"){//float var == int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " +  v1->tmp + " == " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "float"){//float var == float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1->tmp + " == " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "float"){//float var == float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " == " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "int"){//float var == int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1->tmp + " == " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "float"){//int var == float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " + aux + " == " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "int" ){//float num == int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " == " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "float"){//float num == float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " == " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && dolar1.tipo == "int" && v2->tipo == "float" ){//int num == float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " == " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num == float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " == " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num == int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " == " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num == float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " == " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->tipo != "" && v2->tipo != "" && v1->tipo == v2->tipo){
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " == " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == dolar3.tipo){
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " == " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else{
			yyerror("Comparação não permitida\n");
		}		
	}
	else if(operacao == "tk_diff"){
	//-------------------------------------------------------- != de inteiro --------------------------------------------------------//	
		if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "int"){//int var != int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " != " + v2->tmp + ";\n";
			dolardolar->tipo = "bool"; 
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "int"){//int var != int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " != " + dolar3.tmp + "\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num != int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " != " + v2->tmp + "\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num != int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " != " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- != de float --------------------------------------------------------//
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "int" && v2->tipo == "float"){//int var != float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " != " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "int"){//float var != int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " +  v1->tmp + " != " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v2->valor != "" && v1->tipo == "float" && v2->tipo == "float"){//float var != float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1->tmp + " != " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "float"){//float var != float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " != " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v1->valor != "" && v1->tipo == "float" && dolar3.tipo == "int"){//float var != int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1->tmp + " != " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "float"){//int var != float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1->tmp + ";\n" + "\t" +  aux1 + " = " + aux + " != " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "int" ){//float num != int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2->tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " != " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v2->valor != "" && dolar1.tipo == "float" && v2->tipo == "float"){//float num != float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " != " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && dolar1.tipo == "int" && v2->tipo == "float" ){//int num != float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " != " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num != float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " != " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num != int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " != " + aux + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num != float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " != " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux1;
		}
		else if(v1->tipo != "" && v2->tipo != "" && v1->tipo == v2->tipo){
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " != " + v2->tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == dolar3.tipo){
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " != " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else{
			yyerror("Comparação não permitida\n");
		}		
	}	
	else{
	}
}
