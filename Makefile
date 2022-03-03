all: 	
		clear
		lex lexico.l
		yacc -d sintatico.y
		g++ -o glf y.tab.c -ll
		./glf < teste.kappa
		./glf < teste.kappa > salveKappa.cpp
		g++ -o teste salveKappa.cpp

