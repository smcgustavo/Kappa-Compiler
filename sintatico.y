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
#include <tuple>

using std::string;
using std::getline;
//colocar na tabela uma variavel pra verificar se a mesma foi inicializada ou nao

#define YYSTYPE atributos
using namespace std;

typedef struct Vector{
	//vector<string> variaveis;
	string tmVetor;
	string isVector;
	string tmp;
} Vector;

typedef struct Variable{
	Vector vetor;
	string tipo;
	string nome;
	string valor;
	string tmp;
} variable;

typedef struct Temps{
	string valor;
	string tmp;
} temps;

typedef struct Execucao {
	string Inicio;
	string Fim;
} Execucao;

typedef struct Atributos{
	string tipo;
	string label;
	string traducao_dec;
	string traducao;
	string tmp;
	string operacao;
} atributos;

typedef struct Function{
	//atributos bloco;
	string argumentos;
	string nome;
	string retorno;
} Function;

typedef struct{
	string implicita; //tradução após conversão
	string nomeVar; //nome da variável
	string varConvertida; //nome da variável que foi convertida
} structAux; //struct auxiliar utilizada para conversões

//variaveis
int valorVar = 1;//Gerador de tmp
int valorBlock = 0;//Gerador de blocos
int mapAtual = 0;//Contador de mapas
int entryMain = 0;//variável para indicar quando entrar na main
int entryFunc = 0;//variável para indicar quando entrar em função
variable auxiliar;//Auxiliar que retorna uma struct vazia de variable
vector<vector<variable>>globalTabSym;//Tabela de variáveis global
vector<string> auxArray;//Vetor que retorna o nome/valor dos itens adicionados no vetor
vector<string> auxArrayTmp;//Vetor que irá retornar todas as tmps de quando um vetor for criado
stack<Execucao> loops;//Pilha de contador de contextos
stack<string> switchCases;//Pilha de expressões 
vector<Function> funcoes;//Vetor que armazena uma struct que possui tipo de retorno,nome e os argumentos passados de uma função
Function funcaoAux;//Auxiliar que retorna uma struct de funcao vazia caso não ache uma determinada função no vetor de funções
string tipoRetorno;//string que irá retornar o tipo do comando return de uma função, para depois ser verificado se o tipo bate com o tipo da função


//funções yacc
int yylex(void);
void yyerror(string);
void criaOperacao(atributos *dolardolar, atributos dolar1, atributos dolar3, string operacao);
bool verifyVariableLocal(string nome);
bool verifyVariableGlobal(string nome);
bool verifyFunction(string nome);
variable *returnVariable(string nome);
Function *returnFunction(string nome);
Execucao criaBloco(string inicio, string fim);

//função geradora de tmps
string genLabel();
Execucao genBlock(string);

%}

//tokens
%token TK_MAIN
%token TK_INPUT TK_SAIDA TK_WHILE TK_DO TK_FOR TK_IF TK_ELSE TK_END_LOOP
%token TK_ID TK_DEC_VAR TK_GLOBAL_VAR TK_TIPO_VOID TK_TIPO_CHAR
%token TK_TIPO_INT TK_TIPO_FLOAT TK_COMENTARIO TK_UN_SUM TK_UN_SUB 
%token TK_LESS TK_GREATER TK_LE TK_HE TK_EQ TK_DIFF TK_NOT TK_AND TK_OR
%token TK_CHAR TK_FLOAT TK_BOOL TK_NUM TK_STRING TK_INT   
%token TK_FIM TK_ERROR TK_BREAK TK_CONTINUE TK_RETURN TK_ADD_VETOR
%token TK_SWITCH TK_CASE TK_DEFAULT
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


%%//for(int i = 0; i < globalTabSym.size();){}
S 				: FUNCOES BLOCOGLOBAL BLOCOCONTEXTO TK_INT{cout<<"Entro na main"<<endl;entryMain++;} TK_MAIN '(' ')' BLOCO 
				{
					cout << "/*Salve Kappa!*/\n" << "\n#include <iostream>\n#include<string.h>\n#include<stdio.h>\nusing std::string;\n\n" + $1.traducao + "\nint main(void)\n{\n" << 
					"//------------------ Escopo Variáveis ------------------\\\\ \n" << $1.traducao_dec << $2.traducao_dec << $9.traducao_dec << 
					"//------------------ Escopo Atribuições ------------------\\\\ \n" << $2.traducao << $9.traducao << "\treturn 0;\n}" << endl;
				}
				;

BLOCOGLOBAL		: COMANDOS
				{
					$$.traducao = $1.traducao;
					$$.traducao_dec = $1.traducao_dec;
				}
				;

FUNCOES			: FUNCTIONS
				{
					cout<<"FUNCOES"<<endl;
					entryFunc = 0;
					$$ = $1;
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
						//cout<<"Entro aqui"<<endl;
						//cout<<"GLOBAL TAB SMY = "<<globalTabSym.size() <<endl;
					}
					cout<<"MAPA ATUAL = "<< mapAtual<<endl;
					//if(mapAtual == 1 && globalTabSym.size() == 2 && globalTabSym[1][0].nome == ""){
						//globalTabSym.pop_back();
						//mapAtual--;
					//}
					/*if(globalTabSym.empty() == 1 && entryMain == 1){
						variable ref;
						ref.tipo = "";
						ref.nome = "";
						ref.valor = "";
						ref.tmp = "";
						vector<variable> aux;
						aux.push_back(ref);
						globalTabSym.push_back(aux);
						mapAtual++;
					}*/
					cout<<"blococontexto"<<endl;
					//cout<<entryMain<<endl;
					cout<<"MAPA ATUAL = "<< mapAtual<<endl;
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
				| CHAMADAFUNCAO 
				{
					$$ = $1;
				}
				| BLOCOCONTEXTO IF
				{
					$$ = $2;
					if(mapAtual > 0){
						globalTabSym.pop_back();
						mapAtual--;
					}
					cout<<"BLOCOCONTEXTO IF"<<endl;
					//cout<<"mapa atual" <<mapAtual<<endl;
					//cout<<"MAPA ATUAL = "<< mapAtual<<endl;
					//cout<<"GLOBAL TAB SMY = "<<globalTabSym.size() <<endl;
					loops.pop();
				}
				| BLOCOCONTEXTO ELSE
				{
					$$ = $2;
					if(mapAtual > 0){
						globalTabSym.pop_back();
						mapAtual--;
					}
					cout<<"BLOCOCONTEXTO ELSE"<<endl;
					//cout<<"mapa atual" <<mapAtual<<endl;
					//loops.pop();
				}
				| BLOCOCONTEXTO FOR
				{	
					$$ = $2;
					if(mapAtual > 0){
						globalTabSym.pop_back();
						mapAtual--;
					}
					loops.pop();
					cout<<"BLOCOCONTEXTO FOR"<<endl;
				}
				| BLOCOCONTEXTO WHILE
				{	
					$$ = $2;
					if(mapAtual > 0){
						globalTabSym.pop_back();
						mapAtual--;
					}
					loops.pop();	
					cout<<"BLOCOCONTEXTO WHILE"<<endl;
				}
				| BLOCOCONTEXTO DOWHILE ';'
				{
					$$ = $2;
					if(mapAtual > 0){
						globalTabSym.pop_back();
						mapAtual--;
					}
					loops.pop();
					cout<<"BLOCOCONTEXTO DOWHILE"<<endl;
				}
				| BLOCOCONTEXTO SWITCH
                {
                    $$ = $2;
					cout<<"BLOCOCONTEXTO SWITCH"<<endl;
                }
				| BREAK ';'
				{
					$$ = $1;
					cout<<"BREAK"<<endl;
				}
				| CONTINUE ';'
				{
					$$ = $1;
					cout<<"CONTINUE"<<endl;
				}
				;


DECLARACAO 	    : TK_DEC_VAR TK_ID//Declaração de uma variável sem atribuição
				{
					cout<<"tk_dec_var tk_id"<<endl;
					cout<<"MAPA ATUAL "<<mapAtual<<endl;
					if(mapAtual == 0 && entryMain == 0 && entryFunc == 0){//Verifica se essa declaração está sendo feita antes da main
						yyerror("Só é permitido declarar variável global antes do escopo da main com o modificador \"global\".\n");
					}
					if(mapAtual == 1 && entryMain == 1){//Esse if informa que já teve declaração de variável global antes da main
						if(verifyVariableGlobal($2.label) != true){//Dessa forma preciso verificar com o verifyVariableGlobal se a variável não foi declarada antes 
							cout<<"teste1"<<endl;
							variable ref;
							ref.tipo = "";
							ref.nome = $2.label;
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
						$$.traducao = "\tvar " + ref.nome + ";\n";
						}else{
							yyerror("Voce já declarou a variável " + $2.label + ".\n");
						}
					}
					else{
						if(verifyVariableLocal($2.label) != true){
							cout<<"teste2"<<endl;
							variable ref;
							ref.tipo = "";
							ref.nome = $2.label;
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
						$$.traducao = "\tvar " + ref.nome + ";\n";
						}else{
							yyerror("Voce já declarou a variável " + $2.label + ".\n");
						}
					}	
				}
				| TK_DEC_VAR TK_ID '=' E //Declaração de uma variável com atribuição. Podendo esta ser de uma outra variável ou de um valor qualquer.
				{
					cout<<"tk_dec_var tk_id = e"<<endl;
					if(mapAtual == 0 && entryMain == 0 && entryFunc == 0){//Verifica se essa declaração está sendo feita antes da main
						yyerror("Só é permitido declarar variável global antes do escopo da main com o modificador \"global\".\n");
					}	

					if(mapAtual == 1 && entryMain == 1){//Esse if informa que já teve declaração de variável global antes da main
						if(verifyVariableGlobal($2.label) == false){//Dessa forma preciso verificar com o verifyVariableGlobal
							if(verifyVariableGlobal($4.label) && $4.tmp == ""){//Se eu não colocar $4.tmp == "" ele não irá interpretar quando alguma operação vier, 
								variable *var1 = returnVariable($4.label);//pois quando tem alguma operação o $4.tmp não fica = ""
								variable ref;
								if(var1->valor != ""){
									cout<<"teste1"<<endl;
									ref.tipo = var1->tipo;
									ref.nome = $2.label;
									ref.valor = var1->valor;
									ref.tmp = genLabel();
									if(var1->tipo == "char *"){
										$$.traducao_dec = $4.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
										$$.traducao = $4.traducao + "\t" + ref.tmp + " = (char*) malloc(" + to_string(var1->valor.size()-2)  + "* sizeof(char));\n" + "\tstrcpy( " + 
										ref.tmp + "," + var1->tmp + " );\n";
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
								if($4.tipo == "char *"){
									$$.traducao_dec = $4.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
									//$$.traducao = $4.traducao + "\t" + ref.tmp + " = " + $4.tmp + ";\n";
									$$.traducao = $4.traducao + "\t" + ref.tmp + " = (char*) malloc(" + to_string($4.label.size()-2)  + "* sizeof(char));\n" + "\tstrcpy( " + 
									ref.tmp + "," + $4.tmp + " );\n";	
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
					else{
						if(verifyVariableLocal($2.label) == false){
							if(verifyVariableLocal($4.label) && $4.tmp == ""){//Se eu não colocar $4.tmp == "" ele não irá interpretar quando alguma operação vier, 
								variable *var1 = returnVariable($4.label);//pois quando tem alguma operação o $4.tmp não fica = ""
								variable ref;
								if(var1->valor != ""){
									cout<<"teste3"<<endl;
									ref.tipo = var1->tipo;
									ref.nome = $2.label;
									ref.valor = var1->valor;
									ref.tmp = genLabel();
									if(var1->tipo == "char *"){
										$$.traducao_dec = $4.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
										$$.traducao = $4.traducao + "\t" + ref.tmp + " =  (char*) malloc(" + to_string(var1->valor.size()-2)  + "* sizeof(char));\n" + "\tstrcpy( " + 
										ref.tmp + "," + var1->tmp + " );\n";
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
								cout<<"teste4"<<endl;
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
								//cout<<"salvando no indice "<< mapAtual<<endl;
								if($4.tipo == "char *"){
									$$.traducao_dec = $4.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
									//$$.traducao = $4.traducao + "\t" + ref.tmp + " = " + $4.tmp + ";\n";
									$$.traducao = $4.traducao + "\t" + ref.tmp + " =  (char*) malloc(" + to_string($4.label.size()-2)  + "* sizeof(char));\n" + "\tstrcpy( " + 
									ref.tmp + "," + $4.tmp + " );\n";	
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
				}
				| TK_DEC_VAR TK_ID '[' ']'//Declaração de um vetor sem inicialização
				{	
					cout<<"tk_dec_var tk_id = [ ]"<<endl;
					if(mapAtual == 0 && entryMain == 0 && entryFunc == 0){//Verifica se essa declaração está sendo feita antes da main
						yyerror("Só é permitido declarar vetor global antes do escopo da main com o modificador \"global\".\n");
					}

					if(mapAtual == 1 && entryMain == 1){
						if(verifyVariableGlobal($2.label) != true){//Com isso, eu sei que teve declaração antes da main. Dessa forma preciso verificar com o verifyVariableGlobal
							cout<<"teste1"<<endl;//Se a variável não foi declarada antes ja
							variable ref;
							ref.tipo = "";
							ref.nome = $2.label;
							ref.valor = ""; //Forço a variável a receber uma string vazia pois irei fazer comparações utilizando a string "vazia"
							ref.tmp = genLabel();
							ref.vetor.isVector = "true";
							ref.vetor.tmVetor = "";
							ref.vetor.tmp = genLabel();
								
							if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
								vector<variable> aux;
								aux.push_back(ref);
								globalTabSym.push_back(aux);
							}
							else{
								globalTabSym[mapAtual].push_back(ref);
							}
							$$.traducao = "\tvar *" + ref.nome + ";\n";
						}else{
							yyerror("Voce já declarou a variável " + $2.label + ".\n");
						}
					}
					else{
						if(verifyVariableLocal($2.label) != true){
							cout<<"teste1"<<endl;
							variable ref;
							ref.tipo = "";
							ref.nome = $2.label;
							ref.valor = ""; 
							ref.tmp = genLabel();
							ref.vetor.isVector = "true";
							ref.vetor.tmVetor = "";
							ref.vetor.tmp = genLabel();
								
							if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
								vector<variable> aux;
								aux.push_back(ref);
								globalTabSym.push_back(aux);
							}
							else{
								globalTabSym[mapAtual].push_back(ref);
							}
							$$.traducao = "\tvar *" + ref.nome + ";\n";
						}else{
							yyerror("Voce já declarou a variável " + $2.label + ".\n");
						}
					}
				}
				/*| TK_DEC_VAR TK_ID '[' TK_NUM ']'
				{
					cout<<"tk_dec_var tk_id [ tk_num ]"<<endl;
					if(mapAtual == 0 && entryMain == 0 && entryFunc == 0){//Verifica se essa declaração está sendo feita antes da main
						yyerror("Só é permitido declarar vetor global antes do escopo da main com o modificador \"global\".\n");
					}
					if(mapAtual == 1 && entryMain == 1){
						if(verifyVariableGlobal($2.label) != true){//Com isso, eu sei que teve declaração antes da main. Dessa forma preciso verificar com o verifyVariableGlobal
							cout<<"teste1"<<endl;//Se a variável não foi declarada antes ja
							variable ref;
							ref.tipo = "";
							ref.nome = $2.label;
							ref.valor = ""; 
							ref.tmp = genLabel();
							ref.vetor.isVector = "true";
							ref.vetor.tmVetor = $5.label;
								
							if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
								vector<variable> aux;
								aux.push_back(ref);
								globalTabSym.push_back(aux);
							}
							else{
								globalTabSym[mapAtual].push_back(ref);
							}
							$$.traducao = "\tvar " + ref.nome + "[" + ref.vetor.tmVetor + "];\n";
						}else{
							yyerror("Voce já declarou a variável " + $2.label + ".\n");
						}
					}
					else{
						if(verifyVariableLocal($2.label) != true){//Com isso, eu sei que teve declaração antes da main. Dessa forma preciso verificar com o verifyVariableGlobal
							cout<<"teste1"<<endl;//Se a variável não foi declarada antes ja
							variable ref;
							ref.tipo = "";
							ref.nome = $2.label;
							ref.valor = ""; 
							ref.tmp = genLabel();
							ref.vetor.isVector = "true";
							ref.vetor.tmVetor = $5.label;
								
							if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
								vector<variable> aux;
								aux.push_back(ref);
								globalTabSym.push_back(aux);
							}
							else{
								globalTabSym[mapAtual].push_back(ref);
							}
							$$.traducao = "\tvar " + ref.nome + "[" + ref.vetor.tmVetor + "];\n";
						}else{
							yyerror("Voce já declarou a variável " + $2.label + ".\n");
						}
					}
				}*/
				| TK_DEC_VAR TK_ID '[' ']' '=' '{' VALORES '}'//Declaração de vetor com valores
				{
					cout<<"tk_dec_var tk_id [ ] = {valores}"<<endl;
					if(mapAtual == 0 && entryMain == 0 && entryFunc == 0){//Verifica se essa declaração está sendo feita antes da main
						yyerror("Só é permitido declarar vetor global antes do escopo da main com o modificador \"global\".\n");
					}	

					if(mapAtual == 1 && entryMain == 1){
						if(verifyVariableGlobal($2.label) != true){
							cout<<"teste1"<<endl;
							variable ref;
							ref.tipo = $7.tipo;
							ref.nome = $2.label;
							ref.valor = ""; 
							ref.tmp = genLabel();
							ref.vetor.isVector = "true";
							ref.vetor.tmVetor = std::to_string(auxArray.size());
							ref.vetor.tmp = genLabel();
								
							if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
								vector<variable> aux;
								aux.push_back(ref);
								globalTabSym.push_back(aux);
							}
							else{
								globalTabSym[mapAtual].push_back(ref);
							}
							string aux1;
							string aux2;
							aux1 = "\t" + ref.tmp + " = (" + $7.tipo + "*) malloc(" + std::to_string(auxArray.size()) + "* sizeof(" + $7.tipo + "));//vetor\n\t" + ref.vetor.tmp + " = 0;\n";
							
							for(int i = 0; i < auxArray.size(); i++){
								aux2 = aux2 + "\t" + $2.label + "[" + ref.vetor.tmp + "] = " + auxArrayTmp[i] + ";\n\t" + ref.vetor.tmp + " = " + ref.vetor.tmp + " + 1;\n";
							}
							
							$$.traducao_dec = "\t" + $7.tipo + " = *" + ref.tmp + $7.traducao_dec;
							//$$.traducao ="\t" + $2.label + "[ ] = {" + $7.label + "};\n" + $7.traducao + aux1 + aux2;	
							$$.traducao = $7.traducao + aux1 + aux2;
							auxArray.clear();//Limpa o array pra ser usado outra vez
							auxArrayTmp.clear();//Limpa o array pra ser usado outra vez
						}else{
							yyerror("Voce já declarou a variável " + $2.label + ".\n");
						}
					}
					else{
						if(verifyVariableLocal($2.label) != true){
							cout<<"teste2"<<endl;
							variable ref;
							ref.tipo = $7.tipo;
							ref.nome = $2.label;
							ref.valor = ""; 
							ref.tmp = genLabel();
							ref.vetor.isVector = "true";
							ref.vetor.tmVetor = std::to_string(auxArray.size());
							ref.vetor.tmp = genLabel();
								
							if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
								vector<variable> aux;
								aux.push_back(ref);
								globalTabSym.push_back(aux);
							}
							else{
								globalTabSym[mapAtual].push_back(ref);
							}
							string aux1;
							string aux2;
							aux1 = "\t" + ref.tmp + " = (" + $7.tipo + "*) malloc(" + std::to_string(auxArray.size()) + "* sizeof(" + $7.tipo + "));//vetor\n\t" + ref.vetor.tmp + " = 0;\n";
							
							for(int i = 0; i < auxArray.size(); i++){
								aux2 = aux2 + "\t" + $2.label + " [" + ref.vetor.tmp + "] = " + auxArrayTmp[i] + ";\n\t" + ref.vetor.tmp + " = " + ref.vetor.tmp + " + 1;\n";
							}
							
							$$.traducao_dec = "\t" + $7.tipo + " = *" + ref.tmp + $7.traducao_dec;
							//$$.traducao ="\t" + $2.label + "[ ] = {" + $7.label + "};\n" + $7.traducao + aux1 + aux2;	
							$$.traducao = $7.traducao + aux1 + aux2;
							auxArray.clear();
							auxArrayTmp.clear();
						}else{
							yyerror("Voce já declarou a variável " + $2.label + ".\n");
						}
					}
					/*string aux1;
					string aux2;
					string tmp = genLabel();
					aux1 = "\t(" + $7.tipo + "*) malloc(" + std::to_string(auxArray.size()) + "* sizeof(" + $7.tipo + "));//vetor\n\t" + tmp + " = 0;\n";
					
					for(int i =0;i<auxArray.size();i++){
						aux2 = aux2 + "\t" + $2.label + " [" + tmp + "] = " + auxArrayTmp[i] + ";\n\t" + tmp + " = " + tmp + " + 1;\n";
					}
					
					$$.traducao_dec = $7.traducao_dec;
					//$$.traducao ="\t" + $2.label + "[ ] = {" + $7.label + "};\n" + $7.traducao + aux1 + aux2;	
					$$.traducao = $7.traducao + aux1 + aux2;*/				
				}
				| TK_GLOBAL_VAR TK_DEC_VAR TK_ID '[' ']'//Declaração de vetor global sem inicialização
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
							ref.vetor.isVector = "true";
							ref.vetor.tmVetor = "";
							ref.vetor.tmp = genLabel();
								
							if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
								vector<variable> aux;
								aux.push_back(ref);
								globalTabSym.push_back(aux);
							}
							else{
								globalTabSym[mapAtual].push_back(ref);
							}
							$$.traducao = "\tglobal var *" + ref.nome + ";\n";
						}else{
							yyerror("Voce já declarou a variável " + $3.label + ".\n");
						}
					}
					else{
						yyerror("Declaração de variável global somente fora de função ou antes do bloco main, ambas com o modificador \"global\".\n");
					}
				}
				| TK_GLOBAL_VAR TK_DEC_VAR TK_ID //Declaração de variável global
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
							$$.traducao = "\tglobal var " + ref.nome + ";\n";
						}else{
							yyerror("Voce já declarou a variável " + $3.label + ".\n");
						}
					}
					else{
						yyerror("Declaração de variável global somente fora de função ou antes do bloco main, ambas com o modificador \"global\".\n");
					}
				}
				| TK_GLOBAL_VAR TK_DEC_VAR TK_ID '=' E//Declaração de variável global com inicialização
				{
					cout<<"tk_global tk_dec_var tk_id = e"<<endl;
					if(mapAtual == 0 && entryMain == 0 || mapAtual == 0 && entryMain == 1){
						if(verifyVariableGlobal($5.label) && $5.tmp == ""){//Se eu não colocar $4.tmp == "" ele não irá interpretar quando alguma operação vier, 
							variable *var1 = returnVariable($5.label);//pois quando tem alguma operação o $4.tmp não fica = ""
							variable ref;
							if(var1->valor != ""){
								cout<<"teste1"<<endl;
								ref.tipo = var1->tipo;
								ref.nome = $3.label;
								ref.valor = var1->valor;
								ref.tmp = genLabel();
								if(var1->tipo == "char *"){
									$$.traducao_dec = $5.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
									$$.traducao = $5.traducao + "\t" + ref.tmp + " = (char*) malloc(" + to_string(var1->valor.size()-2)  + "* sizeof(char));\n" + "\tstrcpy( " + 
									ref.tmp + "," + var1->tmp + " );\n";
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
							if($4.tipo == "char *"){
								$$.traducao_dec = $5.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
								//$$.traducao = $5.traducao + "\t" + ref.tmp + " = " + $5.tmp + ";\n";
								$$.traducao = $5.traducao + "\t" + ref.tmp + " = (char*) malloc(" + to_string($5.label.size()-2)  + "* sizeof(char));\n" + "\tstrcpy( " + 
								ref.tmp + "," + $5.tmp + " );\n";	
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
				| TK_GLOBAL_VAR TK_DEC_VAR TK_ID '[' ']' '=' '{' VALORES '}'//Declaração de vetor global com inicialização
				{
					cout<<"tk_global tk_dec_var tk_id = e"<<endl;
					if(mapAtual == 0 && entryMain == 0 || mapAtual == 0 && entryMain == 1){
						if(verifyVariableGlobal($3.label) != true ){
							cout<<"teste1"<<endl;
							variable ref;
							ref.tipo = $8.tipo;
							ref.nome = $3.label;
							ref.valor = ""; 
							ref.tmp = genLabel();
							ref.vetor.isVector = "true";
							ref.vetor.tmVetor = std::to_string(auxArray.size());
							ref.vetor.tmp = genLabel();

							if(globalTabSym.empty() == 1 || globalTabSym.empty() == 0 && globalTabSym.size() == mapAtual ){
								vector<variable> aux;
								aux.push_back(ref);
								globalTabSym.push_back(aux);
							}
							else{
								globalTabSym[mapAtual].push_back(ref);
							}
							string aux1;
							string aux2;
							aux1 = "\t" + ref.tmp + " = (" + $8.tipo + "*) malloc(" + std::to_string(auxArray.size()) + "* sizeof(" + $8.tipo + "));//vetor\n\t" + ref.vetor.tmp + " = 0;\n";
							
							for(int i = 0; i < auxArray.size(); i++){
								aux2 = aux2 + "\t" + $3.label + "[" + ref.vetor.tmp + "] = " + auxArrayTmp[i] + ";\n\t" + ref.vetor.tmp + " = " + ref.vetor.tmp + " + 1;\n";
							}
							
							$$.traducao_dec = "\t" + $8.tipo + " = *" + ref.tmp + $8.traducao_dec;
							//$$.traducao ="\t" + $2.label + "[ ] = {" + $7.label + "};\n" + $7.traducao + aux1 + aux2;	
							$$.traducao = $8.traducao + aux1 + aux2;
							auxArray.clear();//Limpa o array pra ser usado outra vez
							auxArrayTmp.clear();//Limpa o array pra ser usado outra vez
						}
						else{
							yyerror("Voce já declarou a variável " + $3.label + ".\n");
						}
					}
					else{
						yyerror("Declaração de variável global somente fora de função ou antes do bloco main, ambas com o modificador \"global\".\n");
					}
				}
				;
				

VALORES 		: DEC ',' VALORES 
				{
					if($1.tipo != $3.tipo){
						yyerror("Atribuição do tipo " + $1.tipo + " ao vetor de tipo " + $3.tipo + ".\n");
					}
					else{
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = $1.tipo;
						$$.label = $1.label + " , " +  $3.label;
						variable *var1 = returnVariable($1.label);
						if(var1->valor != ""){
							auxArray.insert(auxArray.begin(),var1->nome);
							auxArrayTmp.insert(auxArrayTmp.begin(),var1->tmp);
						}
						else{
							auxArray.insert(auxArray.begin(),$1.label);
							auxArrayTmp.insert(auxArrayTmp.begin(),$1.tmp);
						}
					}
				}
				| DEC
				{	
					$$ = $1;
					$$.label = $1.label;
					variable *var1 = returnVariable($1.label);
					if(var1->valor != ""){
						auxArray.insert(auxArray.begin(),var1->nome);
						auxArrayTmp.insert(auxArrayTmp.begin(),var1->tmp);
					}
					else{
						auxArray.insert(auxArray.begin(),$1.label);
						auxArrayTmp.insert(auxArrayTmp.begin(),$1.tmp);
					}
				}
				;

//---------------------------------------------------------- CHAMADA FUNCAO ----------------------------------------------------------//
CHAMADAFUNCAO	: NOMECHAMADA '(' ARGS ')' ';'
				{
					cout<<"CHAMADA FUNCAO "<<endl;
					
					if(verifyFunction($1.label)){
						Function *aux = returnFunction($1.label);
						if(aux->argumentos == $3.tipo){
							$$.traducao_dec = $3.traducao_dec;
							$$.traducao = $3.traducao + "\t" + $1.label + "( " + $3.tmp + " );\n";
						}
						else{
							yyerror("Argumentos passados diferentes dos tipos de argumentos declarados na função");
						}
					}
					else{
						yyerror("Função " + $1.label + " não declarada.");
					}
				}
				;

NOMECHAMADA		: TK_ID
				{
					$$ = $1;
				}
				;

ARGS			: 
				{
					$$.tipo = "";
				}
				| MOREARGS
				{
					$$ = $1;
				}	
				;

MOREARGS	    : E ',' MOREARGS
				{
					$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
					$$.traducao = $1.traducao + $3.traducao;
					$$.tipo = $1.tipo + " " + $3.tipo; 
					$$.tmp = $1.tmp + " , " + $3.tmp;
				}
				| FIMARGS
				{
					$$ = $1;
				}
				;

FIMARGS			: E 
				{
					$$ = $1;
				}
				;	

//------------------------------------------------------- FIM CHAMADA FUNCAO -------------------------------------------------------//

//------------------------------------------------------------------- FUNCAO -------------------------------------------------------------------//
FUNCTIONS		: FUNCAO FUNCTIONS
				{
					$$.traducao_dec = $1.traducao_dec + $2.traducao_dec;
					$$.traducao = $1.traducao + $2.traducao;
				}
				|	
				{

				}
				;

FUNCAO 			: TIPORETORNO{entryFunc = 1;} NOME '(' ARGUMENTOS ')' BLOCO
				{
					cout<<"FUNCAO"<<endl;

					if($1.label == "void" && tipoRetorno != ""){
						yyerror("Função " + $3.label+ " é tipo void e não apresenta retorno.");
					}
					if($1.label != "void" && tipoRetorno == ""){
						yyerror("Função " + $3.label + " diferente de void sem retorno.");
					}
					if($1.label != "void" && $1.label != tipoRetorno){
						yyerror("Tipo do retorno da função " + $3.label + " diferente do tipo declarado na função.");
					}
					Function func;
					func.retorno = $1.label;
					func.nome = $3.label;
					func.argumentos = $5.label;
					//func.bloco.traducao_dec = $7.traducao_dec;
					//func.bloco.traducao = $7.traducao;
				 	funcoes.push_back(func);

					$$.traducao_dec = $5.traducao_dec + $7.traducao_dec;
					$$.traducao = $1.label + " " + $3.label + " ( " + $5.traducao + " ){\n" + $7.traducao + "}\n";
					if(mapAtual > 0){
						globalTabSym.pop_back();
						mapAtual--;
					}
					else{
						globalTabSym[mapAtual].clear();
					}
					entryFunc = 0;
					tipoRetorno = "";
				}		

TIPORETORNO		: TK_TIPO_FLOAT
				{
					$$.label = "float";
				}
				| TK_TIPO_VOID
				{
					$$.label = "void";
				}
				| TK_TIPO_CHAR
				{
					$$.label = "char";
				}
				| TK_TIPO_INT
				{
					$$.label = "int";
				}
				;

NOME			: TK_ID
				{
					$$ = $1;
				}
				;

ARGUMENTOS		: 
				{

				}
				| MOREARGUMENTS
				{
					$$ = $1;
				}	
				;

MOREARGUMENTS	: TIPOARGUMENTO TK_ID ',' MOREARGUMENTS
				{
					cout<<"tipo argumento tk_id ; morearguments "<<mapAtual<<endl;
					variable ref;
					ref.tipo = $1.label;
					ref.nome = $2.label;
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
					
					$$.label = $1.label + " " + $4.label;
					$$.traducao_dec = "\t" + $1.label + " " + ref.tmp + ";\n" + $4.traducao_dec;
					$$.traducao = $1.label + " " + ref.tmp + " , " + $4.traducao;
				}
				| FIMARGUMENTS
				{
					$$ = $1;
				}
				;

FIMARGUMENTS	: TIPOARGUMENTO TK_ID
				{
					cout<<"tipoargumento tk_id "<<mapAtual<<endl;
					variable ref;
					ref.tipo = $1.label;
					ref.nome = $2.label;
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
					
					$$.label = $1.label;
					$$.traducao_dec = "\t" + $1.label + " " + ref.tmp + ";\n";
					$$.traducao = $1.label + " " + ref.tmp;
				}	
				;

TIPOARGUMENTO	:
				| TK_TIPO_FLOAT
				{
					$$.label = "float";
				}
				| TK_TIPO_CHAR
				{
					$$.label = "char";	
				}
				| TK_TIPO_INT
				{
					$$.label = "int";
				}
				;
//------------------------------------------------------------------- FIM FUNCAO -------------------------------------------------------------------//

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
							$$.traducao = "\tcin >> " + var1->tmp + ";\n";
						}
						else{
							string aux = genLabel();
							$$.traducao_dec = $3.traducao_dec + "\t" + var1->tipo + " " + aux + ";\n";
							$$.traducao = $3.traducao + "\tinput( " + var1->nome + " );\n" + "\t" + var1->tmp + " = " + aux + ";\n";
							$$.traducao = "\tcin >> " + var1->tmp + ";\n";
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
						$$.traducao = $4.traducao + "\tcout << " + var1->tmp + ";\n";
					}
					else{
						yyerror("Você não declarou a variável " + $3.label + "\n");
					}
				}
				;

IF			    : TK_IF {Execucao atual = genBlock("If");
					loops.push(atual);}'(' E ')' BLOCO 
				{
					cout<<"TK_IF"<<endl;
					variable *var1 = returnVariable($4.label);
					string aux = genLabel();
					if($4.tipo == "bool"){
						$$.traducao_dec = $4.traducao_dec + $6.traducao_dec + "\tint " + aux + ";\n";
						$$.traducao = $4.traducao + "\t" + aux + " = " + $4.tmp + ";\n\tif ( !" + aux + ") goto " + loops.top().Fim + ";\n\t{\n" + $6.traducao + "\t}\n\t" + 
						loops.top().Fim + ":\n";
					}
					else if(var1->nome == $4.label && var1->tipo != "char"){
						$$.traducao_dec = $4.traducao_dec + $6.traducao_dec + "\tint " + aux + ";\n";
						$$.traducao = $4.traducao + "\t" + aux + " = " + var1->tmp + ";\n\tif ( !" + aux + ") goto " + loops.top().Fim + ";\n\t{\n" + $6.traducao + "\t}\n\t" +
						loops.top().Fim + ":\n";
					}
					else{
						yyerror("Somente expressões booleanas são validas dentro da condicional");
					}
				}
				;

ELSE 			: IF ELSEE
				{
					$$.traducao = $1.traducao + $2.traducao;
				}
				;

ELSEE			: TK_ELSE{if(mapAtual > 0){
								globalTabSym.pop_back();
							 }} TK_IF '(' E ')' BLOCO ELSEE
				{
					valorBlock--;
					Execucao atual = genBlock("Else");
					variable *var1 = returnVariable($5.label);
					string aux = genLabel();
					if($5.tipo == "bool"){
						$$.traducao_dec = $5.traducao_dec + $7.traducao_dec + "\tint " + aux + ";\n" + $8.traducao_dec;
						$$.traducao = $5.traducao + "\t" + aux + " = " + $5.tmp + ";\n\tif ( !" + aux + ") goto " + atual.Fim + ";\n\t{\n" + $7.traducao + "\t}\n\t" + 
						atual.Fim + ":\n" + $8.traducao;
					}
					else if(var1->nome == $5.label && var1->tipo != "char"){
						$$.traducao_dec = $5.traducao_dec + $7.traducao_dec + "\tint " + aux + ";\n" + $8.traducao_dec;
						$$.traducao = $5.traducao + "\t" + aux + " = " + var1->tmp + ";\n\tif ( !" + aux + ") goto " + atual.Fim + ";\n\t{\n" + $7.traducao + "\t}\n\t" + 
						atual.Fim + ":\n" + $8.traducao;
					}
					else{
						yyerror("Somente expressões booleanas são validas dentro da condicional");
					}
				}
				| TK_ELSE{if(mapAtual > 0){
								globalTabSym.pop_back();
							 }} BLOCO
				{
					valorBlock--;
					Execucao atual = genBlock("Else");
					cout<<"Else"<<endl;
					$$.traducao_dec = $3.traducao_dec;
					$$.traducao = "\t" + atual.Inicio + ":\n\t{\n"+ $3.traducao + "\t}\n\t" + atual.Fim + ":\n";
				}
				;

FOR				: TK_FOR {Execucao atual = genBlock("For");
					loops.push(atual);}'(' DECLARACAO ';' E ';' E ')' BLOCO
				{	
					string inicio = loops.top().Inicio;
					string fim = loops.top().Fim;
					//Empilha os nomes de inicio e fim dos blocos
					cout<<"TK_FOR()"<<endl;
					string aux = genLabel();

					if($6.tipo != "bool"){
						yyerror("Condição de verificação precisa ser booleana.");
					}

					int posChange = $6.traducao.find_first_of(";");
					posChange++;
					$6.traducao.insert(posChange, "\n"+ inicio+":" ); // Inicio -> Inicio bloco
					$$.traducao_dec = $4.traducao_dec + $6.traducao_dec + $8.traducao_dec + $10.traducao_dec;
					//$$.traducao = "\tfor( " + $4.label + " ; " + $6.tmp + " ; " + $8.label + "++ ){";
					$$.traducao = "\n" + $4.traducao + $6.traducao + "\t" + aux + " = !( " + $6.tmp + " );\n\tif( " +
					aux + " ) goto "+ fim +";\n\t{\n" + $10.traducao + "\t}\n" + $8.traducao + "\tgoto "+ inicio +";\n"+fim+":\n";
				}
				; 									

WHILE 			: TK_WHILE {Execucao atual = genBlock("While");
					loops.push(atual);} '(' E ')' BLOCO
				{
					cout<<"TK_WHILE()"<<endl;
					variable *var1 = returnVariable($4.label);
					string aux = genLabel();
					string inicio = loops.top().Inicio;
					string fim = loops.top().Fim;
					if(var1->nome == $4.label && var1->tipo != "char"){
						$$.traducao_dec = $4.traducao_dec + $6.traducao_dec + "\tint " + aux + ";\n";
						$$.traducao = "\n" + inicio + ":\n" + "\t" + aux + " = !( " + var1->tmp + " );\n\tif( " + aux + " ) goto "+fim+";\n\t{\n" +       
						$6.traducao + "\t}\n\tgoto "+ inicio +";\n"+fim+":\n";
					}
					else if($4.tipo == "bool"){
						int posChange = $4.traducao.find_first_of(";");
						posChange = $4.traducao.find(";",posChange + 1);
						posChange++;
						//cout<<"temp 4"<<$4.tmp<<endl;
						$4.traducao.insert(posChange, "\n"+inicio+":");
						$$.traducao_dec = $4.traducao_dec + $6.traducao_dec + + "\tint " + aux + ";\n";
						$$.traducao = "\n" + $4.traducao  + "\t" + aux + " = !( " + $4.tmp + " );\n\tif( " + aux + " ) goto "+fim+";\n\t{\n" +       
						$6.traducao + "\t}\n\tgoto "+inicio+";\n"+fim+":\n";
					}
					else{
						yyerror("Expressão de condição não permitida\n");
					}
				}
				;

DOWHILE 		: TK_DO {Execucao atual = genBlock("DoWhile");
					loops.push(atual);} BLOCO TK_WHILE '(' E ')'
				{
					string inicio = loops.top().Inicio;
					string fim = loops.top().Fim;
					cout<<"TK_DO WHILE()"<<endl;
					variable *var1 = returnVariable($6.label);
					string aux = genLabel();

					if(var1->nome == $6.label && var1->tipo != "char"){
						$$.traducao_dec = $3.traducao_dec + $6.traducao_dec + "\tint " + aux + ";\n";
						$$.traducao = "\n"+inicio+":\n\t{\n" + $3.traducao + "\t}\n\t"+ aux + " = !( " + var1->tmp + " );\n\tif( " + aux + " ) goto "+fim+"\n" + $6.traducao +
						"\tgoto "+inicio+";" + "\n"+fim+":\n";
					}
					else if($6.tipo == "bool"){
						$$.traducao_dec = $3.traducao_dec + $6.traducao_dec;
						$$.traducao = "\n"+inicio+":\n\t{\n" + $3.traducao + "\t}\n\t"+ aux + " = !( " + $6.tmp + " );\n\tif( " + aux + " ) goto " + fim +"\n"+ $6.traducao +
						"\tgoto "+inicio+";" +"\n"+fim+":\n";
					}
					else{
						yyerror("Expressão de condição não permitida\n");
					}
				}
				;	

SWITCH          : TK_SWITCH {Execucao atual = genBlock("Switch");
					loops.push(atual);}'(' E ')' '{' BLOCK '}'
                {
                    cout<<"TK_Switch"<<endl;
                }
                ;

BLOCK			: CASELIST
				| CASELIST DEFAULTSTM	
				;

CASELIST		: CASE
				| CASE CASELIST
				;

CASE            : TK_CASE TK_NUM ':' COMANDO TK_BREAK ';'
                {
					
                }
                ;

DEFAULTSTM		: TK_DEFAULT COMANDO ':'  
				{
					
				}
				;				

BREAK			: TK_BREAK
				{
					if(loops.empty() == true){
						yyerror("Comando break fora de um loop.\n");
					}
					$$.traducao = "\n\tgoto " + loops.top().Fim + ";//Break\n";
				}							
				;

CONTINUE		: TK_CONTINUE
				{
					if(loops.empty() == true){
						yyerror("Comando continue fora de um loop.\n");
					}
					$$.traducao = "\n\tgoto " + loops.top().Inicio + ";//Continue\n";
				}
				;


E 				: E '+' E //Soma de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					cout<<"E+E"<<endl;
					//operacao = "soma";
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
						v1->valor = "0";
						$$.traducao_dec = $1.traducao_dec + "\tint " + v1->tmp + ";\n" + "\tint " + aux + ";\n";
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
						v1->valor = "0";
						$$.traducao_dec = $1.traducao_dec + "\tint " + v1->tmp + ";\n" + "\tint " + aux + ";\n";
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
						if(var2->tipo == "char *"){//e não da soma de duas coisas, pois se fosse da soma de duas coisas o $3.tmp iria ter valor
							var1->valor = var2->valor;
							var1->tipo = var2->tipo;
							$$.traducao_dec ="\t" + var1->tipo + " " + var1->tmp + ";\n";
							$$.traducao = $3.traducao + "\t" + var1->tmp + " =  (char *) malloc(" + to_string(var2->valor.size()-2)  + "* sizeof(char));\n" + "\tstrcpy( " + 
							var1->tmp + "," + var2->tmp + " );\n";
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
						if($3.tipo == "char *"){
							var1->valor = $3.label;
							var1->tipo = $3.tipo;
							$$.traducao_dec = "\t" + var1->tipo + " " + var1->tmp + ";\n" + $3.traducao_dec;
							$$.traducao = $3.traducao + "\t" + var1->tmp + " =  (char *) malloc(" + to_string($3.label.size()-2)  + "* sizeof(char));\n" + "\tstrcpy( " + 
							var1->tmp + "," + $3.tmp + " );\n";
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
					else if(encontrei == true && found == true && var1->tipo == "float" && var2->tipo == "int" ){//If que verifica se a variavel que está recebendo
						string aux = genLabel();
						var1->valor = var2->valor;//a atribuição é do tipo float, permitindo ser adicionado uma variável do tipo int ou float
						//Não preciso do traducao_dec pois a variavel que está recebendo a atribuição e a variável que está sendo atribuida, já foram inicializadas
						
						if(var2->tmp.size() < 8){
							$$.traducao_dec = $3.traducao_dec + "\tfloat " + aux + ";\n";
							$$.traducao = "\t" + aux + " = (float)" + var2->tmp + ";\n" + "\t" + var1->tmp + " = " + aux + ";\n";//Não preciso propagar o $3.traducao pois eles ja foram feitos antes
						}
						else{
							string aux1 = genLabel();
							$$.traducao_dec = $3.traducao_dec + "\tint " + aux + ";\n" + "\tfloat " + aux1 + ";\n";
							$$.traducao = "\t" + aux + " = " + var2->tmp + ";\n" + "\t" + aux1 + " = (float)" + aux + ";\n" + "\t" + var1->tmp + " = " + aux1 + ";\n";
						}
						cout<<"Tst3"<<endl;
					}
					//else if(encontrei == true && var1->tipo == "float" && ($3.tipo == "int" || $3.tipo == "float"))
					else if(encontrei == true && var1->tipo == "float" && $3.tipo == "int"){//Verifica se a variável que está recebendo a atribuição é do tipo
						string aux = genLabel();
						var1->valor = $3.label;//float e se o valor qualquer adicionado é do tipo int ou float para fazer a atribuição

						if($3.tmp.size() < 8){
							$$.traducao_dec = $3.traducao_dec + "\tfloat " + aux + ";\n";
							$$.traducao = $3.traducao + "\t" + aux + " = (float)" + $3.tmp + ";\n" + "\t" + var1->tmp + " = " + aux + ";\n";
						}
						else{
							string aux1 = genLabel();
							$$.traducao_dec = $3.traducao_dec + "\tint " + aux + ";\n" + "\tfloat " + aux1 + ";\n";
							$$.traducao = $3.traducao + "\t" + aux + " = " + $3.tmp + ";\n" + "\t" + aux1 + " = (float)" + aux + ";\n" + "\t" + var1->tmp + " = " + aux1 + ";\n" ;
						}
						cout<<"Tst4"<<endl;
					}
					else if(encontrei == true && found == true && var1->tipo != "" && var1->tipo == var2->tipo && $3.tmp == ""){//Verifica se o termo a ser atribuido é do mesmo tipo da variável a recebe-lo
						
						if(var2->tipo == "char *"){//e não da soma de duas coisas, pois se fosse da soma de duas coisas o $3.tmp iria ter valor
							var1->valor = var2->valor;
							$$.traducao_dec = $3.traducao_dec;
							$$.traducao = "\t" + var1->tmp + " =  (char *) malloc(" + to_string(var2->valor.size()-2)  + "* sizeof(char));\n" + "\tstrcpy( " + 
							var1->tmp + "," + var2->tmp + " );\n";
						}
						else{
							var1->valor = var2->valor;
							$$.traducao_dec = $3.traducao_dec;
							$$.traducao ="\t" + var1->tmp + " = " + var2->tmp + ";\n";//Salva o novo valor na variavel e na tabela de simbolos
						}
						cout<<"Tst5"<<endl;
					}
					else if(encontrei == true && var1->tipo == $3.tipo){//Verifica se o termo a ser atribuido é um valor qualquer
						
						if($3.tipo == "char *"){
							var1->valor = $3.label;
							$$.traducao_dec = $3.traducao_dec;
							$$.traducao = $3.traducao + "\t" + var1->tmp + " =  (char *) malloc(" + to_string($3.label.size()-2)  + "* sizeof(char));\n" + "\tstrcpy( " + 
							var1->tmp + "," + $3.tmp + " );\n";
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
				| TK_ID TK_ADD_VETOR '(' E ')'//'[' TK_NUM ']' '=' E
				{
					bool encontrei = false;
					bool found = false;
					encontrei = verifyVariableGlobal($1.label);
					found = verifyVariableGlobal($4.label);
					variable *var1 = returnVariable($1.label);
					variable *var2 = returnVariable($4.label);
				
				//------------------------------------------------ Atribuições sem valores iniciais ------------------------------------------------//
					if(encontrei == true && found == true && var1->tipo == "" && var2->tipo != "" && var2->tipo != "bool" && $4.tmp == ""){
						var1->tipo = var2->tipo;
						$$.traducao_dec = $4.traducao_dec + "\t" + var1->tipo + " *" + var1->tmp + ";\n";
						$$.traducao = "\t" + var1->tmp + " = (" + var1->tipo + "*) malloc( 1 * sizeof(" + var1->tipo + "));//vetor\n\t" + var1->vetor.tmp + " = 0;\n" + 
						"\t" + var1->nome + "[" + var1->vetor.tmp + "] = " + var2->tmp + ";\n\t" + var1->vetor.tmp + " = " + var1->vetor.tmp + " + 1;\n";
					}
					else if(encontrei == true && found == false && var1->tipo == "" && $4.tipo != "bool"){
						var1->tipo = $4.tipo;
						$$.traducao_dec = $4.traducao_dec + "\t" + var1->tipo + " *" + var1->tmp + ";\n";
						$$.traducao = $4.traducao + "\t" + var1->tmp + " = (" + var1->tipo + "*) malloc( 1 * sizeof(" + var1->tipo + "));//vetor\n\t" + var1->vetor.tmp + " = 0;\n" + 
						"\t" + var1->nome + "[" + var1->vetor.tmp + "] = " + $4.tmp + ";\n\t" + var1->vetor.tmp + " = " + var1->vetor.tmp + " + 1;\n";
					}
				//------------------------------------------------ Atribuições com valores iniciais ------------------------------------------------//	
					else if(encontrei == true && found == true && var1->tipo != "" && var1->tipo != "bool" && var1->tipo == var2->tipo && $4.tmp == ""){
						$$.traducao_dec = $4.traducao_dec;
						$$.traducao = $4.traducao + "\t" + var1->tmp + " = (" + var1->tipo + "*) realloc(" + var1->tmp + " , " + var1->vetor.tmVetor + 
						" + 1 * sizeof(" + var1->tipo + "));//vetor\n" + "\t" + var1->nome + "[" + var1->vetor.tmp + "] = " + var2->tmp + ";\n\t" + var1->vetor.tmp + " = " + 
						var1->vetor.tmp + " + 1;\n";
						int aux = std::stoi(var1->vetor.tmVetor) + 1;
						var1->vetor.tmVetor = to_string(aux);
					}
					else if(encontrei == true && var1->tipo != "" && var1->tipo != "bool" && var1->tipo == $4.tipo ){
						$$.traducao_dec = $4.traducao_dec;
						$$.traducao = $4.traducao + "\t" + var1->tmp + " = (" + var1->tipo + "*) realloc(" + var1->tmp + " , " + var1->vetor.tmVetor + 
						" + 1 * sizeof(" + var1->tipo + "));//vetor\n" + "\t" + var1->nome + "[" + var1->vetor.tmp + "] = " + $4.tmp + ";\n\t" + var1->vetor.tmp + " = " + 
						var1->vetor.tmp + " + 1;\n";
						int aux = std::stoi(var1->vetor.tmVetor) + 1;
						var1->vetor.tmVetor = to_string(aux);
					}	
					else if(found == true && var2->valor == ""){
						yyerror("Você não inicializou a variável " + $4.label + ".\n");
					}
					else if(encontrei == false){
						yyerror("Variável " + $1.label + " não declarada.\n");
					}
					else{
						yyerror("Atribuição não permitida, tipo da variável a ser atribuida é diferente do tipo do vetor.\n");
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
				| TK_RETURN DEC
				{
					if(entryFunc == 1){
						bool encontrei = false;
						encontrei = verifyVariableLocal($2.label);
						variable *var1;
						var1 = returnVariable($2.label);
						cout<<"TIPO DA VARIAVELLLLLLLLLLLLLL "<<$2.tipo<<endl;
						if(encontrei){
							$$.traducao = "\treturn " + var1->tmp + ";\n";
							tipoRetorno = var1->tipo;
						}
						else{
							$$.traducao_dec = $2.traducao_dec;
							$$.traducao = $2.traducao + "\treturn " + $2.tmp + ";\n";
							tipoRetorno = $2.tipo;
						}
					}
					else{
						yyerror("Retorno fora de função.");
					}
				}
				| DEC
				{
					$$ = $1;
				}
				;


DEC				: TK_NUM
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
					$$.tipo = "char *";
					$$.tmp = genLabel();
					
					$$.traducao_dec = "\t" + $$.tipo + " " + $$.tmp + ";\n";
					$$.traducao = "\t" + $$.tmp + " =  (char*) malloc(" + to_string($$.label.size()-2)  + "* sizeof(char));\n" + "\tstrcpy( " + $$.tmp + "," +
					$$.label + " );\n";
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

Execucao criaBloco(string inicio, string fim){
	Execucao nova;
	nova.Inicio = inicio;
	nova.Fim = fim;
	return nova;
}

Execucao genBlock(string tipo){
	Execucao nova;
	string numero = to_string(valorBlock++);
	nova.Inicio = "INICIO_"+ tipo +"_"+ numero;
	nova.Fim = "FIM_"+ tipo +"_"+ numero;
	return nova;
}

bool verifyFunction(string nome){
	
	for(int i = 0; i < funcoes.size(); i++){
		if(funcoes[i].nome == nome){
			return true;
		}
	}
	return false;
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

Function *returnFunction(string nome){

	funcaoAux.argumentos = "";
	funcaoAux.nome = "";
	funcaoAux.retorno = "";

	for(int i = 0; i < funcoes.size(); i++){
		if(funcoes[i].nome == nome){
			return &funcoes[i];
		}
	}
	return &funcaoAux;
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

/*
void apagaMap(){
	globalTabSym[mapAtual].clear();
}

void imprimeMap(){
	for(int i = 0; i < globalTabSym.size(); i++){
		for(int y = 0; y < globalTabSym[i].size();y++){
			cout<<globalTabSym[i][y].nome<<endl;
		}
	}
}*/

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
			//dolardolar->operacao = "soma";
		}
		else if(v1->valor != "" && v1->tipo == "int" && dolar3.tipo == "int"){//int var + int num
			int aux = std::stoi(v1->valor) + std::stoi(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = v1->tmp + " + " + dolar3.tmp;
			//dolardolar->operacao = "soma";
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num + int var
			int aux = std::stoi(dolar1.label) + std::stoi(v2->valor);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = dolar1.tmp + " + " + v2->tmp;
			//dolardolar->operacao = "soma";
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num + int num
			int aux = std::stoi(dolar1.label) + std::stoi(dolar3.label);
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->label = std::to_string(aux);
			dolardolar->tmp = dolar1.tmp + " + " + dolar3.tmp;
			//dolardolar->operacao = "soma";
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
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " > " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num > int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " > " + v2->tmp + ";\n";
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
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " <= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num <= int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " <= " + v2->tmp + ";\n";
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
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " >= " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num >= int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " >= " + v2->tmp + ";\n";
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
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " == " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num == int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " == " + v2->tmp + ";\n";
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
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1->tmp + " != " + dolar3.tmp + ";\n";
			dolardolar->tipo = "bool";
			dolardolar->tmp = aux;
		}
		else if(v2->valor != "" && v2->tipo == "int" && dolar1.tipo == "int"){//int num != int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " != " + v2->tmp + ";\n";
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