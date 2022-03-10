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
//colocar na tabela uma variavel pra pra verificar se a mesma foi inicializada ou nao

#define YYSTYPE atributos

using namespace std;
int var_temp_qnt;

typedef struct Variable{

	string tipo;
	string nome;
	string valor;
	string tmp;
} variable;

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
vector<variable> tabelaSimbolos; // Vetor global para armazenar as variáveis declaradas

//funções yacc
int yylex(void);
void yyerror(string);
string gentempcode();
bool verificaVariavel(string nome);
variable acharVariable(string nome);

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
%token TK_CHAR TK_FLOAT TK_BOOL TK_NUM TK_ENTER
%token TK_STRING TK_FIM TK_ERROR

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
S 				: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
				{
					cout << "/*Salve Kappa!*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << 
					"//------------------ Escopo Variáveis ------------------\\\\ \n" << $5.traducao_dec << "//------------------ Escopo Atribuições ------------------\\\\ \n" << $5.traducao << "\treturn 0;\n}" << endl;
				}
				;

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
				| ATRIBUICAO ';' 
				{
					$$ = $1;
				}
				| DECLARACAO ';'
				{
					$$ = $1;
				}
				| LOGICOS ';'
				{
					$$ = $1;
				}
				;
				

ATRIBUICAO 	    :TK_DEC_VAR TK_ID//Declaração de uma variável do tipo int sem atribuição
				{
					cout<<"tk_dec_var tk_id"<<endl;
					if(verificaVariavel($2.label) != true){
						cout<<"teste1"<<endl;
						variable ref;
						ref.tipo = "";
						ref.nome = $2.label;
						ref.valor = ""; //Forço a variável a receber uma string vazia pois irei fazer comparações utilizando a string "vazia"
						ref.tmp = genLabel();
						tabelaSimbolos.push_back(ref);//Salva na tabela de simbolos o tipo e o nome da variável
						//$$.traducao = $1.traducao;
					}else{
						yyerror("Você já declarou essa variável animal.\n");
					}			
				}
				|TK_DEC_VAR TK_ID '=' E //Declaração de uma variável do tipo int com atribuição. Podendo esta ser de uma outra variável ou de um valor qualquer.
				{
					cout<<"tk_dec_var tk_id = e"<<endl;
					//cout<<$4.tmp<<endl;
					//cout<<$4.label<<endl;
					if(verificaVariavel($4.label) && $4.tmp == ""){//Se eu não colocar $4.tmp == "" ele não irá interpretar quando alguma operação vier, pois quando tem alguma operação
						variable var1 = acharVariable($4.label);//o $4.tmp não fica = ""
						variable ref;
						if(var1.valor != ""){
							cout<<"teste2"<<endl;
							ref.tipo = var1.tipo;
							ref.nome = $2.label;
							ref.valor = var1.valor;
							ref.tmp = genLabel();
							tabelaSimbolos.push_back(ref);
							$$.traducao_dec = $4.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
							$$.traducao = $4.traducao + "\t" + ref.tmp + " = " + var1.tmp + ";\n";

						}else{
							yyerror("Voce ainda não inicialiou a variavel que está sendo atribuida.\n");
						}
					}
					else{
						cout<<"teste3"<<endl;
						variable ref;
						ref.tipo = $4.tipo;
						ref.nome = $2.label;
						ref.valor = $4.label;
						ref.tmp = genLabel();
						tabelaSimbolos.push_back(ref);
					    $$.traducao_dec = $4.traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
						$$.traducao = $4.traducao + "\t" + ref.tmp + " = " + $4.tmp + ";\n";
					}
				}

LOGICOS 		:
				;

E 				: E '+' E //Soma de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					cout<<"E+E"<<endl;
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o primeiro termo é alguma variável já declarada
						if($1.label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if($3.label == tabelaSimbolos[i].nome){//For que verifica se o segundo termo é alguma variável já declarada
							var2 = tabelaSimbolos[i];		
						}
					}
					//-------------------------------------------------------- Soma de inteiro --------------------------------------------------------//
					if(var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){//var int + var int
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = var1.tmp + " + " + var2.tmp;
					}
					else if(var1.valor != "" && var1.tipo == "int" && $3.tipo == "int"){//var int + num
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = var1.tmp + " + " + $3.tmp;
					}
					else if(var2.valor != "" && var2.tipo == "int" && $1.tipo == "int"){//num + var int
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = $1.tmp + " + " + var2.tmp;
					}
					else if($1.tipo == "int" && $3.tipo == "int"){//num + num
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = $1.tmp + " + " + $3.tmp;
					}
					//--------------------------------------------------------- Soma de float ---------------------------------------------------------//
					else if(var1.valor != "" && var2.valor != "" && ((var1.tipo == "int" && var2.tipo == "float") || (var1.tipo == "float" && var2.tipo == "int") || (var1.tipo == "float" && var2.tipo == "float"))){//var a(int||float) + var a(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = var1.tmp + " + " + var2.tmp;
					}
					else if(var1.valor != "" && ((var1.tipo == "int" && $3.tipo == "float" ) || (var1.tipo == "float" && $3.tipo == "int" ) || (var1.tipo == "float" && $3.tipo == "float" ))){//var a(int||float) + num(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = var1.tmp + " + " + $3.tmp;
					}	
					else if(var2.valor != "" && ((var2.tipo == "int" && $1.tipo == "float" ) || (var2.tipo == "float" && $1.tipo == "int" ) || (var2.tipo == "float" && $1.tipo == "float" ))){//num(int||float) + var a(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = $1.tmp + " + " + var2.tmp;
					}
					else if(($1.tipo == "int" && $3.tipo == "float" ) || ($1.tipo == "float" && $3.tipo == "int" ) || ($1.tipo == "float" && $3.tipo == "float" )){//num(int||float) + num(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = $1.tmp + " + " + $3.tmp;
					}
					else{
						yyerror("Soma não permitida\n");
					}
					
				}
				| E '-' E //Subtração de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					cout<<"E-E"<<endl;
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o primeiro termo é alguma variável já declarada
						if($1.label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if($3.label == tabelaSimbolos[i].nome){//For que verifica se o segundo termo é alguma variável já declarada
							var2 = tabelaSimbolos[i];		
						}
					}
					//-------------------------------------------------------- Subtração de inteiro --------------------------------------------------------//
					if(var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){//var int - var int
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = var1.tmp + " - " + var2.tmp;
					}
					else if(var1.valor != "" && var1.tipo == "int" && $3.tipo == "int"){//var int - num
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = var1.tmp + " - " + $3.tmp;
					}
					else if(var2.valor != "" && var2.tipo == "int" && $1.tipo == "int"){//num - var int
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = $1.tmp + " - " + var2.tmp;
					}
					else if($1.tipo == "int" && $3.tipo == "int"){//num - num
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = $1.tmp + " - " + $3.tmp;
					}
					//--------------------------------------------------------- Subtração de float ---------------------------------------------------------//
					else if(var1.valor != "" && var2.valor != "" && ((var1.tipo == "int" && var2.tipo == "float") || (var1.tipo == "float" && var2.tipo == "int") || (var1.tipo == "float" && var2.tipo == "float"))){//var a(int||float) - var a(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = var1.tmp + " - " + var2.tmp;
					}
					else if(var1.valor != "" && ((var1.tipo == "int" && $3.tipo == "float" ) || (var1.tipo == "float" && $3.tipo == "int" ) || (var1.tipo == "float" && $3.tipo == "float" ))){//var a(int||float) - num(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = var1.tmp + " - " + $3.tmp;
					}	
					else if(var2.valor != "" && ((var2.tipo == "int" && $1.tipo == "float" ) || (var2.tipo == "float" && $1.tipo == "int" ) || (var2.tipo == "float" && $1.tipo == "float" ))){//num(int||float) - var a(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = $1.tmp + " - " + var2.tmp;
					}
					else if(($1.tipo == "int" && $3.tipo == "float" ) || ($1.tipo == "float" && $3.tipo == "int" ) || ($1.tipo == "float" && $3.tipo == "float" )){//num(int||float) + num(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = $1.tmp + " - " + $3.tmp;
					}
					else{
						yyerror("Subtração não permitida\n");
					}
				}
				| E '*' E //Multiplicação de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					cout<<"E*E"<<endl;
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o primeiro termo é alguma variável já declarada
						if($1.label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if($3.label == tabelaSimbolos[i].nome){//For que verifica se o segundo termo é alguma variável já declarada
							var2 = tabelaSimbolos[i];		
						}
					}
					//-------------------------------------------------------- Multiplicação de inteiro --------------------------------------------------------//
					if(var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){//var int * var int
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = var1.tmp + " * " + var2.tmp;
					}
					else if(var1.valor != "" && var1.tipo == "int" && $3.tipo == "int"){//var int * num
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = var1.tmp + " * " + $3.tmp;
					}
					else if(var2.valor != "" && var2.tipo == "int" && $1.tipo == "int"){//num * var int
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = $1.tmp + " * " + var2.tmp;
					}
					else if($1.tipo == "int" && $3.tipo == "int"){//num * num
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = $1.tmp + " * " + $3.tmp;
					}
					//--------------------------------------------------------- Multiplicação de float ---------------------------------------------------------//
					else if(var1.valor != "" && var2.valor != "" && ((var1.tipo == "int" && var2.tipo == "float") || (var1.tipo == "float" && var2.tipo == "int") || (var1.tipo == "float" && var2.tipo == "float"))){//var a(int||float) * var a(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = var1.tmp + " * " + var2.tmp;
					}
					else if(var1.valor != "" && ((var1.tipo == "int" && $3.tipo == "float" ) || (var1.tipo == "float" && $3.tipo == "int" ) || (var1.tipo == "float" && $3.tipo == "float" ))){//var a(int||float) * num(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = var1.tmp + " * " + $3.tmp;
					}	
					else if(var2.valor != "" && ((var2.tipo == "int" && $1.tipo == "float" ) || (var2.tipo == "float" && $1.tipo == "int" ) || (var2.tipo == "float" && $1.tipo == "float" ))){//num(int||float) * var a(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = $1.tmp + " * " + var2.tmp;
					}
					else if(($1.tipo == "int" && $3.tipo == "float" ) || ($1.tipo == "float" && $3.tipo == "int" ) || ($1.tipo == "float" && $3.tipo == "float" )){//num(int||float) * num(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = $1.tmp + " * " + $3.tmp;
					}
					else{
						yyerror("Multiplicação não permitida\n");
					}
				}
				| E '/' E //Divisão de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					cout<<"E/E"<<endl;
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o primeiro termo é alguma variável já declarada
						if($1.label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if($3.label == tabelaSimbolos[i].nome){//For que verifica se o segundo termo é alguma variável já declarada
							var2 = tabelaSimbolos[i];		
						}
					}
					//-------------------------------------------------------- Divisão de inteiro --------------------------------------------------------//
					if($3.label == "0" || var2.valor == "0"){
						yyerror("Impossível dividir por zero\n");
					}
					else if(var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){//var int / var int
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = var1.tmp + " / " + var2.tmp;
					}
					else if(var1.valor != "" && var1.tipo == "int" && $3.tipo == "int"){//var int / num
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = var1.tmp + " / " + $3.tmp;
					}
					else if(var2.valor != "" && var2.tipo == "int" && $1.tipo == "int"){//num / var int
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = $1.tmp + " / " + var2.tmp;
					}
					else if($1.tipo == "int" && $3.tipo == "int"){//num / num
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "int";
						$$.tmp = $1.tmp + " / " + $3.tmp;
					}
					//--------------------------------------------------------- Divisão de float ---------------------------------------------------------//
					else if(var1.valor != "" && var2.valor != "" && ((var1.tipo == "int" && var2.tipo == "float") || (var1.tipo == "float" && var2.tipo == "int") || (var1.tipo == "float" && var2.tipo == "float"))){//var a(int||float) / var a(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = var1.tmp + " / " + var2.tmp;
					}
					else if(var1.valor != "" && ((var1.tipo == "int" && $3.tipo == "float" ) || (var1.tipo == "float" && $3.tipo == "int" ) || (var1.tipo == "float" && $3.tipo == "float" ))){//var a(int||float) / num(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = var1.tmp + " / " + $3.tmp;
					}	
					else if(var2.valor != "" && ((var2.tipo == "int" && $1.tipo == "float" ) || (var2.tipo == "float" && $1.tipo == "int" ) || (var2.tipo == "float" && $1.tipo == "float" ))){//num(int||float) / var a(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = $1.tmp + " / " + var2.tmp;
					}
					else if(($1.tipo == "int" && $3.tipo == "float" ) || ($1.tipo == "float" && $3.tipo == "int" ) || ($1.tipo == "float" && $3.tipo == "float" )){//num(int||float) / num(int||float)
						$$.traducao_dec = $1.traducao_dec + $3.traducao_dec;
						$$.traducao = $1.traducao + $3.traducao;
						$$.tipo = "float";
						$$.tmp = $1.tmp + " / " + $3.tmp;
					}
					else{
						yyerror("Divisão não permitida\n");
					}
				}
				| TK_ID '=' E // Atribuição de uma variável ou um valor qualquer a uma variável já declarada
				{
					cout<<"tk_id = E"<<endl;
					bool encontrei = false;
					bool found = false;
					variable var1;
					variable var2;
					int i;
					for(i = 0; i < tabelaSimbolos.size();i++){//For que localiza a variavel na tabela de simbolos
						if(tabelaSimbolos[i].nome == $1.label){
							var1 = tabelaSimbolos[i];
							encontrei = true;
							break;
						}					
					}
					for(int y = 0; y < tabelaSimbolos.size();y++){//For que irá servir para verificar se o termo a ser atribuido é uma variável já declarada
						if(tabelaSimbolos[y].nome == $3.label){
							var2 = tabelaSimbolos[y];
							found = true;
							break;
						}					
					}
					//------------------------------------------------ Atribuições sem valores iniciais ------------------------------------------------//
					if(encontrei == true && found == true && var1.tipo == "" && var2.tipo != "" && $3.tmp == ""){//Se o $3.tmp for igual a vazio a atribuição é somente de variável
						tabelaSimbolos[i].valor = var2.valor;													//e não da soma de duas coisas, pois se fosse da soma de duas coisas
						tabelaSimbolos[i].tipo = var2.tipo;														//o $3.tmp iria ter valor			
						$$.traducao_dec ="\t" + tabelaSimbolos[i].tipo + " " + tabelaSimbolos[i].tmp + ";\n";
						$$.traducao =  $3.traducao + "\t" + tabelaSimbolos[i].tmp + " = " + var2.tmp + ";\n";
						//cout<<"Tst1"<<endl;
					}
					else if(encontrei == true && var1.tipo == ""){
						tabelaSimbolos[i].valor = $3.label;
						tabelaSimbolos[i].tipo = $3.tipo;
						$$.traducao_dec = "\t" + tabelaSimbolos[i].tipo + " " + tabelaSimbolos[i].tmp + ";\n" + $3.traducao_dec;
						$$.traducao = $3.traducao + "\t" + tabelaSimbolos[i].tmp + " = " + $3.tmp +  ";\n";
						//cout<<"Tst2"<<endl;
					}
					//------------------------------------------------ Atribuições com valores iniciais ------------------------------------------------//
					else if(encontrei == true && found == true && var1.tipo == "float" && (var2.tipo == "int" || var2.tipo == "float") ){//If que verifica se a variavel que está recebendo
						tabelaSimbolos[i].valor = var2.valor;//a atribuição é do tipo float, permitindo ser adicionado uma variável do tipo int ou float
						//Não preciso do traducao_dec pois a variavel que está recebendo a atribuição e a variável que está sendo atribuida, já foram inicializadas
						$$.traducao_dec = $3.traducao_dec;
						$$.traducao = "\t" + tabelaSimbolos[i].tmp + " = " + var2.tmp + ";\n";//Não preciso propagar o $3.traducao pois eles ja foram feitos antes
						cout<<"Tst3"<<endl;
					}
					else if(encontrei == true && var1.tipo == "float" && ($3.tipo == "int" || $3.tipo == "float")){//Verifica se a variável que está recebendo a atribuição é do tipo
						tabelaSimbolos[i].valor = $3.label;//float e se o valor qualquer adicionado é do tipo int ou float para fazer a atribuição
					 	$$.traducao_dec = $3.traducao_dec;
						$$.traducao = $3.traducao + "\t" + tabelaSimbolos[i].tmp + " = " + $3.tmp + ";\n" ;
						//cout<<"Tst4"<<endl;
					}
					else if(encontrei == true && found == true && var1.tipo != "" && var1.tipo == var2.tipo){//Verifica se o termo a ser atribuido é do mesmo tipo da variável a recebe-lo
						tabelaSimbolos[i].valor = var2.valor;
						$$.traducao_dec = $3.traducao_dec;
						$$.traducao ="\t" + tabelaSimbolos[i].tmp + " = " + var2.tmp + ";\n";//Salva o novo valor na variavel e na tabela de simbolos
						//cout<<"Tst5"<<endl;
					}
					else if(encontrei == true && found == false && var1.tipo == $3.tipo){//Verifica se o termo a ser atribuido é um valor qualquer
						tabelaSimbolos[i].valor = $3.label;
						$$.traducao_dec = $3.traducao_dec;
						$$.traducao = $3.traducao + "\t" + tabelaSimbolos[i].tmp + " = " + $3.tmp + ";\n";
						//cout<<"Tst6"<<endl;
					}
					else if(found == true && var2.valor == ""){
						yyerror("Você não inicializou a variável " + $3.label + ".\n");
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
				| TK_BOOL
				{
					cout<<"tk_bool"<<endl;
					$$.tipo = "bool";
					$$.tmp = genLabel();
					//$$.traducao_dec = "\t" + $$.tipo + " " + $$.tmp + ";\n";
					$$.traducao = "\t" + $$.tmp + " = " + $$.label + ";\n";
				}
				| TK_ID
				{	
					cout<<"tk_id"<<endl;
					bool encontrei = false;
					variable variavel;
					for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o nome de uma variável já foi declarado antes
						if(tabelaSimbolos[i].nome == $1.label){
							variavel = tabelaSimbolos[i];
							encontrei = true;
							$$.tipo = variavel.tipo;//Salva o tipo da variavel
						}					
					}

					if(!encontrei){
						yyerror("Você não declarou a variável " + $1.label + "\n");	
					}
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
		yyerror("Tipo de variaveis incompativeis.\n");

	}
	
	return 0;
}

bool verificaVariavel(string nome){
	for(int i = 0; i < tabelaSimbolos.size(); i++){
		if(tabelaSimbolos[i].nome == nome){
			return true;
			break;
		}
	}
	return false;
}

variable acharVariable(string nome){

	variable var1;
	var1.nome = "";
	var1.tipo = "";
	var1.valor = "";
	var1.tmp = "";

	for(int i = 0; i < tabelaSimbolos.size(); i++){
		if(tabelaSimbolos[i].nome == nome){
			return tabelaSimbolos[i];
			break;
		}
	}
	return var1;
}