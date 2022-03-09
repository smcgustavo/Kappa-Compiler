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
%right '=' '!'
%left '|'
%left '&'
%left TK_EQ TK_DIFF
%left '<' '>' TK_HE TK_LE
%left  '-'
%left '*' '/'
%left '(' ')'


%%
S 				: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
				{
					cout << "/*Salve Kappa!*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao_dec <<$5.traducao << "\treturn 0;\n}" << endl;
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
					//variable var1;
					//cout<<var1.nome<<endl;
					//cout<<var1.tipo<<endl;
					//cout<<var1.valor<<endl;
					//cout<<var1.tmp<<endl;
					if(verificaVariavel($2.label) != true){
						variable ref;
						ref.tipo = "";
						ref.nome = $2.label;
						ref.valor = ""; //Forço a variável a receber uma string vazia pois irei fazer comparações utilizando a string "vazia"
						ref.tmp = genLabel();
						tabelaSimbolos.push_back(ref);//Salva na tabela de simbolos o tipo e o nome da variável
						$$.traducao_dec = "\tvar " + ref.tmp + ";\n";
						$$.label = "";
					}else{
						yyerror("Você já declarou essa variável animal\n");
					}			
				}
				|TK_DEC_VAR TK_ID '=' E //Declaração de uma variável do tipo int com atribuição. Podendo esta ser de uma outra variável ou de um valor qualquer.
				{

					if(verificaVariavel($4.label)){
						variable var1 = acharVariable($4.label);
						variable ref;
						if(var1.valor != ""){
							ref.tipo = var1.tipo;
							ref.nome = $2.label;
							ref.valor = var1.valor;
							ref.tmp = genLabel();
							//cout<<ref.tmp<<endl;
							//cout<<$4.tmp<<endl;
							//cout<<ref.tmp<<endl;
							tabelaSimbolos.push_back(ref);
							$$.traducao_dec = "\t" + ref.tipo + " " + ref.tmp + ";\n";
							$$.traducao = "\t" + ref.tmp + " = " + var1.tmp + ";\n";
							$$.label = "";

						}else{
							yyerror("Voce ainda não inicialiou a variavel que está sendo atribuida");
						}
					}
					else{
						variable ref;
						ref.tipo = $4.tipo;
						ref.nome = $2.label;
						ref.valor = $4.label;
						ref.tmp = genLabel();
						cout<<ref.tmp<<endl;
						cout<<$4.tmp<<endl;
						tabelaSimbolos.push_back(ref);
					    $$.traducao_dec = "\t" + ref.tipo + " " + ref.tmp + ";\n";
						$$.traducao = "\t" + ref.tmp + " = " + $4.tmp + ";\n";
						$$.label = "";
					}
						
					
				}
				;

LOGICOS 		:
				;

E 				: E '+' E //Soma de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
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
					/*if($$.tipo == "float" && var1.valor != "" && var2.valor != "" && (var1.tipo == "int" || var1.tipo == "float") &&
					(var2.tipo == "int" || var2.tipo == "float") ){
						//int tmp = std::stoi(var1.valor) + std::stoi(var2.valor);//já declaradas														
						//$$.label = std::to_string(tmp);
						$$.traducao = "testando1";
					}
					else if($$.tipo == "float" && ($1.tipo == "int" || $1.tipo == "float") && ($3.tipo == "int" || $1.tipo == "float")){
						$$.traducao = "testando2";	
					}
					else if($$.tipo == "float" && var2.valor != "" && ($1.tipo == "int" || $1.tipo == "float") && (var2.tipo == "int" || var2.tipo == "float") ||
					$$.tipo == "float" && var1.valor != "" && ($3.tipo == "int" || $3.tipo == "float") && (var1.tipo == "int" || var1.tipo == "float")){
						$$.traducao = "testando3";
					}
					else if($$.tipo == "int" && $1.tipo == "int" && $3.tipo == "int" ||
					 $$.tipo == "int" && var2.valor != "" && $1.tipo == "int" && var2.tipo == "int" || 
					 $$.tipo == "int" && var1.valor != "" && var1.tipo == "int" && $3.tipo == "int" ){
						 $$.traducao = "testando4";	
					}*/
					//-------------------------------------- COMPARAÇÕES INT ----------------------------------------------//
					if($$.tipo == "int" && var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){//Verifica se os dois termos a serem somados são variáveis
						int tmp = std::stoi(var1.valor) + std::stoi(var2.valor);//já declaradas														
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && var1.valor != "" && var1.tipo == "int" && $3.tipo == "int"){//Verifica se o primeiro termo é uma variável declarada e o segundo termo 
						int tmp = std::stoi(var1.valor) + std::stoi($3.label);//um valor qualquer
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && var2.valor != "" && var2.tipo == "int" && $1.tipo == "int"){//Verifica se o segundo termo é uma variável declarada e o primeiro termo	 
						int tmp = std::stoi(var2.valor) + std::stoi($1.label);//um valor qualquer
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && $1.tipo == "int" && $3.tipo == "int"){//Verifica se ambos os termos são valores quaisquer
						int tmp = std::stoi($1.label) + std::stoi($3.label);
						$$.label = std::to_string(tmp);
					}
					//------------------------------------------- COMPARAÇÕES FLOAT ---------------------------------------------------//
					else if($$.tipo == "float" && var1.valor != "" && var2.valor != "" && (var1.tipo == "int" || var1.tipo == "float") && 
						   (var2.tipo == "int" || var2.tipo == "float") ){//Verifica se ambos os termos a serem somados são variáveis declaráveis.Caso algum termo seja inteiro ou ambos 
						float tmp = std::stof(var1.valor) + std::stof(var2.valor);//Já faço a conversão pra float
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "float" && var1.valor != "" && (var1.tipo == "int" || var1.tipo == "float") && ($3.tipo == "int" || $3.tipo == "float" ) ){
						float tmp = std::stof(var1.valor) + std::stof($3.label);//Verifica se o primeiro termo é uma variável já declarada e o segundo termo um valor qualquer
						$$.label = std::to_string(tmp);//Caso tenha algum inteiro já é feita a conversão para float
					}
					else if($$.tipo == "float" && var2.valor != "" && (var2.tipo == "int" || var2.tipo == "float") && ($1.tipo == "int" || $1.tipo == "float" ) ){
						float tmp = std::stof(var2.valor) + std::stof($1.label);//Verifica se o segundo termo é uma variável já declarada e o primeiro termo um valor qualquer
						$$.label = std::to_string(tmp);//Caso tenha algum inteiro já é feita a conversão para float
					}
					else if($$.tipo == "float" && ($1.tipo == "int" || $1.tipo == "float" ) && ($3.tipo == "int" || $3.tipo == "float" )){
						float tmp = std::stof($1.label) + std::stof($3.label);
						$$.label = std::to_string(tmp);
					}
					else{
						yyerror("Soma não permitada ou tipo não compatível\n");
					}
				}
				| E '-' E //Subtração de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){
						if($1.label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if($3.label == tabelaSimbolos[i].nome){
							var2 = tabelaSimbolos[i];		
						}
					}
					//-------------------------------------- COMPARAÇÕES INT ----------------------------------------------//
					if($$.tipo == "int" && var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){
						int tmp = std::stoi(var1.valor) - std::stoi(var2.valor);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && var1.valor != "" && var1.tipo == "int" && $3.tipo == "int"){	 
						int tmp = std::stoi(var1.valor) - std::stoi($3.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && var2.valor != "" && var2.tipo == "int" && $1.tipo == "int"){	 
						int tmp = std::stoi(var2.valor) - std::stoi($1.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && $1.tipo == "int" && $3.tipo == "int"){
						int tmp = std::stoi($1.label) - std::stoi($3.label);
						$$.label = std::to_string(tmp);
					}
					//------------------------------------------- COMPARAÇÕES FLOAT ---------------------------------------------------//
					else if($$.tipo == "float" && var1.valor != "" && var2.valor != "" && (var1.tipo == "int" || var1.tipo == "float") && 
						   (var2.tipo == "int" || var2.tipo == "float") ){	 
						float tmp = std::stof(var1.valor) - std::stof(var2.valor);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "float" && var1.valor != "" && (var1.tipo == "int" || var1.tipo == "float") && ($3.tipo == "int" || $3.tipo == "float" ) ){
						float tmp = std::stof(var1.valor) - std::stof($3.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "float" && var2.valor != "" && (var2.tipo == "int" || var2.tipo == "float") && ($1.tipo == "int" || $1.tipo == "float" ) ){
						float tmp = std::stof(var2.valor) - std::stof($1.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "float" && ($1.tipo == "int" || $1.tipo == "float" ) && ($3.tipo == "int" || $3.tipo == "float" )){
						float tmp = std::stof($1.label) - std::stof($3.label);
						$$.label = std::to_string(tmp);
					}
					else{
						yyerror("Subtração não permitada ou tipo não compatível\n");
					}
				}
				| E '*' E //Multiplicação de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){
						if($1.label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if($3.label == tabelaSimbolos[i].nome){
							var2 = tabelaSimbolos[i];		
						}
					}
					//-------------------------------------- COMPARAÇÕES INT ----------------------------------------------//
					if($$.tipo == "int" && var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){
						int tmp = std::stoi(var1.valor) * std::stoi(var2.valor);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && var1.valor != "" && var1.tipo == "int" && $3.tipo == "int"){	 
						int tmp = std::stoi(var1.valor) * std::stoi($3.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && var2.valor != "" && var2.tipo == "int" && $1.tipo == "int"){	 
						int tmp = std::stoi(var2.valor) * std::stoi($1.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && $1.tipo == "int" && $3.tipo == "int"){
						int tmp = std::stoi($1.label) * std::stoi($3.label);
						$$.label = std::to_string(tmp);
					}
					//------------------------------------------- COMPARAÇÕES FLOAT ---------------------------------------------------//
					else if($$.tipo == "float" && var1.valor != "" && var2.valor != "" && (var1.tipo == "int" || var1.tipo == "float") && 
						   (var2.tipo == "int" || var2.tipo == "float") ){	 
						float tmp = std::stof(var1.valor) * std::stof(var2.valor);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "float" && var1.valor != "" && (var1.tipo == "int" || var1.tipo == "float") && ($3.tipo == "int" || $3.tipo == "float" ) ){
						float tmp = std::stof(var1.valor) * std::stof($3.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "float" && var2.valor != "" && (var2.tipo == "int" || var2.tipo == "float") && ($1.tipo == "int" || $1.tipo == "float" ) ){
						float tmp = std::stof(var2.valor) * std::stof($1.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "float" && ($1.tipo == "int" || $1.tipo == "float" ) && ($3.tipo == "int" || $3.tipo == "float" )){
						float tmp = std::stof($1.label) * std::stof($3.label);
						$$.label = std::to_string(tmp);
					}
					else{
						yyerror("Multiplicação não permitada ou tipo não compatível\n");
					}
				}
				| E '/' E //Divisão de dois termos, podendo esses serem variáveis já declaradas ou valores quaisquer
				{
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){
						if($1.label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if($3.label == tabelaSimbolos[i].nome){
							var2 = tabelaSimbolos[i];		
						}
					}
					//-----------------------VERIFICAÇÃO DIVISAO POR ZERO-----------------------//
					if($3.label == "0" || var2.valor == "0"){
						yyerror("Impossível dividir por zero\n");
					}
					//-------------------------------------- COMPARAÇÕES INT ----------------------------------------------//
					else if($$.tipo == "int" && var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){
						int tmp = std::stoi(var1.valor) / std::stoi(var2.valor);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && var1.valor != "" && var1.tipo == "int" && $3.tipo == "int"){	 
						int tmp = std::stoi(var1.valor) / std::stoi($3.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && var2.valor != "" && var2.tipo == "int" && $1.tipo == "int"){	 
						int tmp = std::stoi(var2.valor) / std::stoi($1.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "int" && $1.tipo == "int" && $3.tipo == "int"){
						int tmp = std::stoi($1.label) / std::stoi($3.label);
						$$.label = std::to_string(tmp);
					}
					//------------------------------------------- COMPARAÇÕES FLOAT ---------------------------------------------------//
					else if($$.tipo == "float" && var1.valor != "" && var2.valor != "" && (var1.tipo == "int" || var1.tipo == "float") && 
						   (var2.tipo == "int" || var2.tipo == "float") ){	 
						float tmp = std::stof(var1.valor) / std::stof(var2.valor);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "float" && var1.valor != "" && (var1.tipo == "int" || var1.tipo == "float") && ($3.tipo == "int" || $3.tipo == "float" ) ){
						float tmp = std::stof(var1.valor) / std::stof($3.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "float" && var2.valor != "" && (var2.tipo == "int" || var2.tipo == "float") && ($1.tipo == "int" || $1.tipo == "float" ) ){
						float tmp = std::stof(var2.valor) / std::stof($1.label);
						$$.label = std::to_string(tmp);
					}
					else if($$.tipo == "float" && ($1.tipo == "int" || $1.tipo == "float" ) && ($3.tipo == "int" || $3.tipo == "float" )){
						float tmp = std::stof($1.label) / std::stof($3.label);
						$$.label = std::to_string(tmp);
					}
					else{
						yyerror("Divisão não permitada ou tipo não compatível\n");
					}
				}
				| TK_ID '=' E // Atribuição de uma variável ou um valor qualquer a uma variável já declarada
				{

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
					
					if(encontrei == true && found == true && var1.tipo == "float" && (var2.tipo == "int" || var2.tipo == "float") ){//If que verifica se a variavel que está recebendo
						tabelaSimbolos[i].valor = var2.valor;//a atribuição é do tipo float, permitindo ser adicionado uma variável do tipo int ou float
						$$.traducao = "teste1";//$$.traducao ="\t" + tabelaSimbolos[i].nome + " = " + tabelaSimbolos[i].valor + ";\n";//Salva o novo valor na variavel e na tabela de simbolos	
					}
					else if(encontrei == true && var1.tipo == "float" && ($3.tipo == "int" || $3.tipo == "float")){//Verifica se a variável que está recebendo a atribuição é do tipo
						tabelaSimbolos[i].valor = $3.label;//float e o se o valor qualquer adicionado é do tipo int ou float para fazer a atribuição
						$$.traducao = "teste2";//$$.traducao ="\t" + tabelaSimbolos[i].nome + " = " + tabelaSimbolos[i].valor + ";\n";
					}
					else if(encontrei == true && found == true && var1.tipo == var2.tipo){//Verifica se o termo a ser atribuido é do mesmo tipo da variável a recebe-lo
						tabelaSimbolos[i].valor = var2.valor;
						
						$$.traducao = "teste3";//$$.traducao ="\t" + tabelaSimbolos[i].nome + " = " + tabelaSimbolos[i].valor + ";\n";//Salva o novo valor na variavel e na tabela de simbolos
					}
					else if(var1.tipo == $3.tipo && encontrei == true){//Verifica se o termo a ser atribuido é um valor qualquer
						tabelaSimbolos[i].valor = $3.label;
						//$$.traducao ="\t" + tabelaSimbolos[i].nome + " = " + tabelaSimbolos[i].valor + ";\n";
						$$.traducao = "teste4";
					}else{
						yyerror("Você não declarou a variável ou o valor atribuido é diferente do tipo declarado\n");
					}
				}
				| TK_NUM
				{
					$$.tipo = "int";
					$$.tmp = genLabel();
					cout<< "printando " << $$.tipo << " " << $$.tmp <<$$.label <<endl;
					$$.traducao_dec = "\t" + $$.tipo + " " + $$.tmp + ";\n";
					$$.traducao = "\t" + $$.tmp + " = " + $$.label + ";\n";
				}
				| TK_FLOAT
				{
					$$.tipo = "float";
					$$.traducao = "to aqui";
				}
				| TK_CHAR
				{
					$$.tipo = "char";
				}
				| TK_BOOL
				{
					$$.tipo = "bool";
				}
				| TK_ID
				{	
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
						yyerror("Você não especificou o tipo da variável ou não declarou a mesma");	
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
		yyerror("tipo de variaveis incompativeis\n");

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