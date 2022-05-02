all: 	
		clear
		lex lexico.l
		yacc -v sintatico.y 
		g++ -o glf y.tab.c -ll 
		./glf < teste.kappa
		
