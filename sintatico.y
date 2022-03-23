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
void criaOperacao(atributos *dolardolar, atributos dolar1, atributos dolar3, string operacao);
void criaOperacaoRelacional(atributos *dolardolar, atributos dolar1, atributos dolar3, string operacao);

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
%token TK_MAIN
%token TK_ENTRADA TK_SAIDA 
%token TK_ID TK_DEC_VAR TK_GLOBAL 
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL TK_TIPO_CHAR TK_TIPO_STRING TK_LESS TK_GREATER
%token TK_CONV_FLOAT TK_CONV_INT TK_LE TK_HE TK_EQ TK_DIFF TK_NOT TK_AND TK_OR
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
				| DECLARACAO ';'
				{
					$$ = $1;
				}
				;
				

DECLARACAO 	    :TK_DEC_VAR TK_ID//Declaração de uma variável do tipo int sem atribuição
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
				|TK_NOT '(' E ')'{
					
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
				|'(' E ')' TK_OR '(' E ')'{
					
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
						$$.tmp = aux + " || " + aux1;
					}
					else{
						yyerror("Comparação não permitida\n");
					}	
				} 
				|'(' E ')' TK_AND '(' E ')'{
					
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
					if(encontrei == true && found == true && var1.tipo == "" && var2.tipo != "" && $3.tmp == "")  {//Se o $3.tmp for igual a vazio a atribuição é somente de variável
						tabelaSimbolos[i].valor = var2.valor;													//e não da soma de duas coisas, pois se fosse da soma de duas coisas
						tabelaSimbolos[i].tipo = var2.tipo;														//o $3.tmp iria ter valor			
						$$.traducao_dec ="\t" + tabelaSimbolos[i].tipo + " " + tabelaSimbolos[i].tmp + ";\n";
						$$.traducao = $3.traducao + "\t" + tabelaSimbolos[i].tmp + " = " + var2.tmp + ";\n";
						cout<<"Tst1"<<endl;
					}
					else if(encontrei == true && var1.tipo == ""){
						tabelaSimbolos[i].valor = $3.label;
						tabelaSimbolos[i].tipo = $3.tipo;
						$$.traducao_dec = "\t" + tabelaSimbolos[i].tipo + " " + tabelaSimbolos[i].tmp + ";\n" + $3.traducao_dec;
						$$.traducao = $3.traducao + "\t" + tabelaSimbolos[i].tmp + " = " + $3.tmp +  ";\n";
						cout<<"Tst2"<<endl;
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
						cout<<"Tst4"<<endl;
					}
					else if(encontrei == true && found == true && var1.tipo != "" && var1.tipo == var2.tipo && $3.tmp == ""){//Verifica se o termo a ser atribuido é do mesmo tipo da variável a recebe-lo
						tabelaSimbolos[i].valor = var2.valor;
						$$.traducao_dec = $3.traducao_dec;
						$$.traducao ="\t" + tabelaSimbolos[i].tmp + " = " + $3.tmp + ";\n";//Salva o novo valor na variavel e na tabela de simbolos
						cout<<"Tst5"<<endl;
					}
					else if(encontrei == true && found == false && var1.tipo == $3.tipo){//Verifica se o termo a ser atribuido é um valor qualquer
						tabelaSimbolos[i].valor = $3.label;
						$$.traducao_dec = $3.traducao_dec;
						$$.traducao = $3.traducao + "\t" + tabelaSimbolos[i].tmp + " = " + $3.tmp + ";\n";
						cout<<"Tst6"<<endl;
					}
					else if(found == true && var2.valor == ""){
						yyerror("Você não inicializou a variável " + $3.label + ".\n");
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
						if(tabelaSimbolos[y].nome == $6.label){
							var2 = tabelaSimbolos[y];
							found = true;
							break;
						}					
					}
					//------------------------------------------------ Atribuições sem valores iniciais ------------------------------------------------//
					if(encontrei == true && found == true && var1.tipo == "" && var2.tipo == "float" && $6.tmp == ""){//Se o $3.tmp for igual a vazio a atribuição é somente de variável
						int aux = std::stoi(var2.valor);
						tabelaSimbolos[i].valor = std::to_string(aux);//e não da soma de duas coisas, pois se fosse da soma de duas coisas
						tabelaSimbolos[i].tipo = "int";//o $3.tmp iria ter valor			
						$$.traducao_dec ="\t" + tabelaSimbolos[i].tipo + " " + tabelaSimbolos[i].tmp + ";\n";
						$$.traducao = $6.traducao + "\t" + tabelaSimbolos[i].tmp + " = (int)" + var2.tmp + ";\n";
						cout<<"Tst1"<<endl;
					}
					else if(encontrei == true && var1.tipo == "" && $6.tmp == "float"){
						int aux = std::stoi($6.label);
						tabelaSimbolos[i].valor = std::to_string(aux);
						tabelaSimbolos[i].tipo = "int";
						$$.traducao_dec = "\t" + tabelaSimbolos[i].tipo + " " + tabelaSimbolos[i].tmp + ";\n" + $6.traducao_dec;
						$$.traducao = $6.traducao + "\t" + tabelaSimbolos[i].tmp + " = (int)" + $6.tmp +  ";\n";
						cout<<"Tst2"<<endl;
					}
					//------------------------------------------------ Atribuições com valores iniciais ------------------------------------------------//
					else if(encontrei == true && found == true && var1.tipo == "int" && var2.tipo == "float" ){//If que verifica se a variavel que está recebendo
						int aux = std::stoi(var2.valor);
						tabelaSimbolos[i].valor = std::to_string(aux);//a atribuição é do tipo float, permitindo ser adicionado uma variável do tipo int ou float
						tabelaSimbolos[i].tipo = "int";//Não preciso do traducao_dec pois a variavel que está recebendo a atribuição e a variável que está sendo atribuida, já foram inicializadas
						$$.traducao_dec = $6.traducao_dec;
						$$.traducao = "\t" + tabelaSimbolos[i].tmp + " = (int)" + var2.tmp + ";\n";//Não preciso propagar o $3.traducao pois eles ja foram feitos antes
						cout<<"Tst3"<<endl;
					}
					else if(encontrei == true && var1.tipo == "int" && $6.tipo == "float"){//Verifica se a variável que está recebendo a atribuição é do tipo
						int aux = std::stoi($6.label);
						tabelaSimbolos[i].valor = std::to_string(aux);//float e se o valor qualquer adicionado é do tipo int ou float para fazer a atribuição
					 	tabelaSimbolos[i].tipo = "int";
						$$.traducao_dec = $6.traducao_dec;
						$$.traducao = $6.traducao + "\t" + tabelaSimbolos[i].tmp + " = (int)" + $6.tmp + ";\n" ;

						cout<<"Tst4"<<endl;
					}
					else if(found == true && var2.valor == ""){
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
						if(tabelaSimbolos[y].nome == $6.label){
							var2 = tabelaSimbolos[y];
							found = true;
							break;
						}					
					}
					//------------------------------------------------ Atribuições sem valores iniciais ------------------------------------------------//
					if(encontrei == true && found == true && var1.tipo == "" && var2.tipo == "int" && $6.tmp == ""){//Se o $3.tmp for igual a vazio a atribuição é somente de variável
						float aux = std::stof(var2.valor);
						tabelaSimbolos[i].valor = std::to_string(aux);//e não da soma de duas coisas, pois se fosse da soma de duas coisas
						tabelaSimbolos[i].tipo = "float";//o $3.tmp iria ter valor			
						$$.traducao_dec ="\t" + tabelaSimbolos[i].tipo + " " + tabelaSimbolos[i].tmp + ";\n";
						$$.traducao = $6.traducao + "\t" + tabelaSimbolos[i].tmp + " = (float)" + var2.tmp + ";\n";
						cout<<"Tst1"<<endl;
					}
					else if(encontrei == true && var1.tipo == "" && $6.tmp == "int"){
						float aux = std::stof($6.label);
						tabelaSimbolos[i].valor = std::to_string(aux);
						tabelaSimbolos[i].tipo = "float";
						$$.traducao_dec = "\t" + tabelaSimbolos[i].tipo + " " + tabelaSimbolos[i].tmp + ";\n" + $6.traducao_dec;
						$$.traducao = $6.traducao + "\t" + tabelaSimbolos[i].tmp + " = (float)" + $6.tmp +  ";\n";
						cout<<"Tst2"<<endl;
					}
					//------------------------------------------------ Atribuições com valores iniciais ------------------------------------------------//
					else if(encontrei == true && found == true && var1.tipo == "float" && var2.tipo == "int" ){//If que verifica se a variavel que está recebendo
						float aux = std::stof(var2.valor);
						tabelaSimbolos[i].valor = std::to_string(aux);//a atribuição é do tipo float, permitindo ser adicionado uma variável do tipo int ou float
						tabelaSimbolos[i].tipo = "float";//Não preciso do traducao_dec pois a variavel que está recebendo a atribuição e a variável que está sendo atribuida, já foram inicializadas
						$$.traducao_dec = $6.traducao_dec;
						$$.traducao = "\t" + tabelaSimbolos[i].tmp + " = (float)" + var2.tmp + ";\n";//Não preciso propagar o $3.traducao pois eles ja foram feitos antes
						cout<<"Tst3"<<endl;
					}
					else if(encontrei == true && var1.tipo == "float" && $6.tipo == "int"){//Verifica se a variável que está recebendo a atribuição é do tipo
						float aux = std::stof($6.label);
						tabelaSimbolos[i].valor = std::to_string(aux);//float e se o valor qualquer adicionado é do tipo int ou float para fazer a atribuição
					 	tabelaSimbolos[i].tipo = "float";
						$$.traducao_dec = $6.traducao_dec;
						$$.traducao = $6.traducao + "\t" + tabelaSimbolos[i].tmp + " = (float)" + $6.tmp + ";\n" ;
						cout<<"Tst4"<<endl;
					}
					else if(found == true && var2.valor == ""){
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

string gentempcode(){
	var_temp_qnt++;
	return "t" + std::to_string(var_temp_qnt);
}

int main(int argc, char* argv[]){
	var_temp_qnt = 0;

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

int erroTipo(string tipo0, string tipo1){
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

void criaOperacao(atributos *dolardolar, atributos dolar1, atributos dolar3, string operacao){//variable v1, variable v2,
	
	variable v1;
	variable v2;
	//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
	for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o primeiro termo é alguma variável já declarada
		
		if(dolar1.label == tabelaSimbolos[i].nome){
			v1 = tabelaSimbolos[i];		
		}
		if(dolar3.label == tabelaSimbolos[i].nome){//For que verifica se o segundo termo é alguma variável já declarada
			v2 = tabelaSimbolos[i];		
		}
	}
		
	if(operacao == "soma"){
	//-------------------------------------------------------- Soma de inteiro --------------------------------------------------------//
		if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "int"){//int var + int var
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = v1.tmp + " + " + v2.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "int"){//int var + int num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = v1.tmp + " + " + dolar3.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "int"){//int num + int var
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = dolar1.tmp + " + " + v2.tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num + int num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = dolar1.tmp + " + " + dolar3.tmp;
		}
	//--------------------------------------------------------- Soma de float ---------------------------------------------------------//
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "float"){//int var + float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v1.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " + " + v2.tmp;
			cout<<"aqui estou"<<endl;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "int"){//float var + float int
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v2.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " + " + aux;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "float"){//float var + float var
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " + " + v2.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "float"){//float var + float num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " + " + dolar3.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "int"){//float var + int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " + " + aux;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "float"){//int var + float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao ="\t" +  aux + " = (float)" + v1.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " + " + dolar3.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "float"){//float num + int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" + aux + " = (float)" + v2.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " + " + aux;
		}	
		else if(v2.valor != "" && v2.tipo == "float" && dolar1.tipo == "float"){//float num + float var
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " + " + v2.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "float" && dolar1.tipo == "int"){//int num + float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao =dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " + " + v2.tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num + float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " + " + dolar3.tmp;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num + int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " + " + aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num + float num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " + " + dolar3.tmp;
		}
		else{
			yyerror("Soma não permitida\n");
		}
		//-------------------------------------------------------- Fim Soma --------------------------------------------------------//
	}
	else if(operacao == "subtracao"){
	//-------------------------------------------------------- Subtração de inteiro --------------------------------------------------------//
		if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "int"){//var int - var int
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = v1.tmp + " - " + v2.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "int"){//var int - num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = v1.tmp + " - " + dolar3.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "int"){//num - var int
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = dolar1.tmp + " - " + v2.tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//num - num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = dolar1.tmp + " - " + dolar3.tmp;
		}
	//--------------------------------------------------------- Subtracão de float ---------------------------------------------------------//
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "float"){//int var - float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v1.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " - " + v2.tmp;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "int"){//float var - float int
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v2.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " - " + aux;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "float"){//float var - float var
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " - " + v2.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "float"){//float var - float num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " - " + dolar3.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "int"){//float var - int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " - " + aux;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "float"){//int var - float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao ="\t" +  aux + " = (float)" + v1.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " - " + dolar3.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "float"){//float num - int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" + aux + " = (float)" + v2.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " - " + aux;
		}	
		else if(v2.valor != "" && v2.tipo == "float" && dolar1.tipo == "float"){//float num - float var
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " - " + v2.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "float" && dolar1.tipo == "int"){//int num - float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao =dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " - " + v2.tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num - float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " - " + dolar3.tmp;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num - int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " - " + aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num - float num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " - " + dolar3.tmp;
		}
		else{
			yyerror("Subtração não permitida\n");
		}
		//-------------------------------------------------------- Fim Subtracao --------------------------------------------------------//
	}
	else if(operacao == "multiplicacao"){
	//-------------------------------------------------------- Multiplicação de inteiro --------------------------------------------------------//
		if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "int"){//var int * var int
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = v1.tmp + " * " + v2.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "int"){//var int * num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = v1.tmp + " * " + dolar3.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "int"){//num * var int
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = dolar1.tmp + " * " + v2.tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//num * num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = dolar1.tmp + " * " + dolar3.tmp;
		}
	//--------------------------------------------------------- Multiplicação de float ---------------------------------------------------------//
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "float"){//int var * float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v1.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " * " + v2.tmp;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "int"){//float var * float int
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v2.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " * " + aux;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "float"){//float var * float var
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " * " + v2.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "float"){//float var * float num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " * " + dolar3.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "int"){//float var * int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " * " + aux;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "float"){//int var * float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao ="\t" +  aux + " = (float)" + v1.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " * " + dolar3.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "float"){//float num * int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" + aux + " = (float)" + v2.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " * " + aux;
		}	
		else if(v2.valor != "" && v2.tipo == "float" && dolar1.tipo == "float"){//float num * float var
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " * " + v2.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "float" && dolar1.tipo == "int"){//int num * float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao =dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " * " + v2.tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num * float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " * " + dolar3.tmp;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num * int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " * " + aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num * float num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " * " + dolar3.tmp;
		}
		else{
			yyerror("Multiplicação não permitida\n");
		}
		//-------------------------------------------------------- Fim Multiplicação --------------------------------------------------------//
	}
	else if(operacao == "divisao"){
	//-------------------------------------------------------- Divisão de inteiro --------------------------------------------------------//
		if(dolar3.label == "0" || v2.valor == "0"){
			yyerror("Impossível dividir por zero\n");
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "int"){//var int / var int
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = v1.tmp + " / " + v2.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "int"){//var int / num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = v1.tmp + " / " + dolar3.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "int"){//num / var int
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = dolar1.tmp + " / " + v2.tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//num / num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "int";
			dolardolar->tmp = dolar1.tmp + " / " + dolar3.tmp;
		}
	//--------------------------------------------------------- Divisão de float ---------------------------------------------------------//
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "float"){//int var / float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v1.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " / " + v2.tmp;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "int"){//float var / float int
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = "\t" +  aux + " = (float)" + v2.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " / " + aux;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "float"){//float var / float var
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " / " + v2.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "float"){//float var / float num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " / " + dolar3.tmp;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "int"){//float var / int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = v1.tmp + " / " + aux;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "float"){//int var / float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao ="\t" +  aux + " = (float)" + v1.tmp + ";\n" + dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " / " + dolar3.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "float"){//float num / int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" + aux + " = (float)" + v2.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " / " + aux;
		}	
		else if(v2.valor != "" && v2.tipo == "float" && dolar1.tipo == "float"){//float num / float var
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " / " + v2.tmp;
		}
		else if(v2.valor != "" && v2.tipo == "float" && dolar1.tipo == "int"){//int num / float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao =dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " / " + v2.tmp;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num / float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = aux + " / " + dolar3.tmp;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num / int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n";
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " / " + aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num / float num
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec;
			dolardolar->traducao = dolar1.traducao + dolar3.traducao;
			dolardolar->tipo = "float";
			dolardolar->tmp = dolar1.tmp + " / " + dolar3.tmp;
		}
		else{
			yyerror("Divisão não permitida\n");
		}
		//-------------------------------------------------------- Fim Divisão --------------------------------------------------------//
	}
	else if(operacao == "tk_less"){
	//-------------------------------------------------------- < de inteiro --------------------------------------------------------//	
		if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "int"){//int var < int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " < " + v2.tmp + ";\n";
			//dolardolar.tipo = "int"; 
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "int"){//int var < int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " < " + dolar3.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "int"){//int num < int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " < " + v2.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num < int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tbool " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " < " + dolar3.tmp + ";\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- < de float --------------------------------------------------------//
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "float"){//int var < float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " < " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "int"){//float var < int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " +  v1.tmp + " < " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "float"){//float var < float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1.tmp + " < " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "float"){//float var < float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " < " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "int"){//float var < int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1.tmp + " < " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "float"){//int var < float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " < " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "int" ){//float num < int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " < " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "float"){//float num < float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " < " + v2.tmp + ";\n";
			//dolardolar->tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && dolar1.tipo == "int" && v2.tipo == "float" ){//int num < float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " < " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num < float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " < " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num < int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " < " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num < float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " < " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else{
			yyerror("Comparação não permitida\n");
		}
	}
	else if(operacao == "tk_greater"){
	//-------------------------------------------------------- > de inteiro --------------------------------------------------------//	
		if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "int"){//int var > int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " > " + v2.tmp + ";\n";
			//dolardolar.tipo = "int"; 
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "int"){//int var > int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " > " + dolar3.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "int"){//int num > int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " > " + v2.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num > int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tbool " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " > " + dolar3.tmp + ";\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- > de float --------------------------------------------------------//
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "float"){//int var > float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " > " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "int"){//float var > int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " +  v1.tmp + " > " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "float"){//float var > float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1.tmp + " > " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "float"){//float var > float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " > " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "int"){//float var > int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1.tmp + " > " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "float"){//int var > float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " > " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "int" ){//float num > int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " > " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "float"){//float num > float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " > " + v2.tmp + ";\n";
			//dolardolar->tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && dolar1.tipo == "int" && v2.tipo == "float" ){//int num > float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " > " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num > float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " > " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num > int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " > " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num > float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " > " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else{
			yyerror("Comparação não permitida\n");
		}
	}
	else if(operacao == "tk_le"){
	//-------------------------------------------------------- <= de inteiro --------------------------------------------------------//	
		if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "int"){//int var <= int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " <= " + v2.tmp + ";\n";
			//dolardolar.tipo = "int"; 
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "int"){//int var <= int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " <= " + dolar3.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "int"){//int num <= int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " <= " + v2.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num <= int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tbool " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " <= " + dolar3.tmp + ";\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- <= de float --------------------------------------------------------//
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "float"){//int var <= float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " <= " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "int"){//float var <= int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " +  v1.tmp + " <= " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "float"){//float var <= float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1.tmp + " <= " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "float"){//float var <= float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " <= " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "int"){//float var <= int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1.tmp + " <= " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "float"){//int var <= float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " <= " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "int" ){//float num <= int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " <= " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "float"){//float num <= float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " <= " + v2.tmp + ";\n";
			//dolardolar->tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && dolar1.tipo == "int" && v2.tipo == "float" ){//int num <= float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " <= " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num <= float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " <= " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num <= int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " <= " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num <= float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " <= " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else{
			yyerror("Comparação não permitida\n");
		}	
	}
	else if(operacao == "tk_he"){
	//-------------------------------------------------------- >= de inteiro --------------------------------------------------------//	
		if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "int"){//int var >= int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " >= " + v2.tmp + ";\n";
			//dolardolar.tipo = "int"; 
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "int"){//int var >= int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " >= " + dolar3.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "int"){//int num >= int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " >= " + v2.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num >= int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tbool " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " >= " + dolar3.tmp + ";\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- >= de float --------------------------------------------------------//
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "float"){//int var >= float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " >= " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "int"){//float var >= int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " +  v1.tmp + " >= " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "float"){//float var >= float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1.tmp + " >= " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "float"){//float var >= float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " >= " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "int"){//float var >= int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1.tmp + " >= " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "float"){//int var >= float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " >= " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "int" ){//float num >= int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " >= " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "float"){//float num >= float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " >= " + v2.tmp + ";\n";
			//dolardolar->tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && dolar1.tipo == "int" && v2.tipo == "float" ){//int num >= float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " >= " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num >= float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " >= " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num >= int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " >= " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num >= float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " >= " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else{
			yyerror("Comparação não permitida\n");
		}	
	}
	else if(operacao == "tk_eq"){
	//-------------------------------------------------------- == de inteiro --------------------------------------------------------//	
		if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "int"){//int var == int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " == " + v2.tmp + ";\n";
			//dolardolar.tipo = "int"; 
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "int"){//int var == int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " == " + dolar3.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "int"){//int num == int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " == " + v2.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num == int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tbool " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " == " + dolar3.tmp + ";\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- == de float --------------------------------------------------------//
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "float"){//int var == float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " == " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "int"){//float var == int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " +  v1.tmp + " == " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "float"){//float var == float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1.tmp + " == " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "float"){//float var == float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " == " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "int"){//float var == int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1.tmp + " == " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "float"){//int var == float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " == " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "int" ){//float num == int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " == " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "float"){//float num == float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " == " + v2.tmp + ";\n";
			//dolardolar->tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && dolar1.tipo == "int" && v2.tipo == "float" ){//int num == float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " == " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num == float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " == " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num == int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " == " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num == float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " == " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.tipo != "" && v2.tipo != "" && v1.tipo == v2.tipo){
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " == " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == dolar3.tipo){
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " == " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else{
			yyerror("Comparação não permitida\n");
		}		
	}
	else if(operacao == "tk_diff"){
	//-------------------------------------------------------- != de inteiro --------------------------------------------------------//	
		if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "int"){//int var != int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " != " + v2.tmp + ";\n";
			//dolardolar.tipo = "int"; 
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "int"){//int var != int num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " != " + dolar3.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && v2.tipo == "int" && dolar1.tipo == "int"){//int num != int var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " != " + v2.tmp + "\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "int"){//int num != int num
			string aux = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tbool " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = "+ dolar1.tmp + " != " + dolar3.tmp + ";\n";
			//dolardolar.tipo = "int";
			dolardolar->tmp = aux;
		}
	//-------------------------------------------------------- != de float --------------------------------------------------------//
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "int" && v2.tipo == "float"){//int var != float var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " +  aux + " != " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "int"){//float var != int var
			string aux = genLabel();
			string aux1 = genLabel();	
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " +  v1.tmp + " != " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v2.valor != "" && v1.tipo == "float" && v2.tipo == "float"){//float var != float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " +  v1.tmp + " != " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "float"){//float var != float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " != " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(v1.valor != "" && v1.tipo == "float" && dolar3.tipo == "int"){//float var != int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + v1.tmp + " != " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.valor != "" && v1.tipo == "int" && dolar3.tipo == "float"){//int var != float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " != " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "int" ){//float num != int var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + v2.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " != " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v2.valor != "" && dolar1.tipo == "float" && v2.tipo == "float"){//float num != float var
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " != " + v2.tmp + ";\n";
			//dolardolar->tipo = "int";
			dolardolar->tmp = aux;
		}
		else if(v2.valor != "" && dolar1.tipo == "int" && v2.tipo == "float" ){//int num != float var
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " != " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "float"){//float num != float num
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " != " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == "float" && dolar3.tipo == "int"){//float num != int num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar3.tmp + ";\n" + "\t" +  aux1 + " = " + dolar1.tmp + " != " + aux + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(dolar1.tipo == "int" && dolar3.tipo == "float"){//int num != float num
			string aux = genLabel();
			string aux1 = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tfloat " + aux + ";\n" + "\tint " + aux1 + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = (float)" + dolar1.tmp + ";\n" + "\t" +  aux1 + " = " + aux + " != " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux1;
		}
		else if(v1.tipo != "" && v2.tipo != "" && v1.tipo == v2.tipo){
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + v1.tmp + " != " + v2.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else if(dolar1.tipo == dolar3.tipo){
			string aux = genLabel();
			dolardolar->traducao_dec = dolar1.traducao_dec + dolar3.traducao_dec + "\tint " + aux + ";\n";
			dolardolar->traducao = dolar1.traducao + dolar3.traducao + "\t" +  aux + " = " + dolar1.tmp + " != " + dolar3.tmp + ";\n";
			//dolardolar->tipo = "float";
			dolardolar->tmp = aux;
		}
		else{
			yyerror("Comparação não permitida\n");
		}		
	}	
	else{
	}
}
