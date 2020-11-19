# TP1-PLC-Transformador-Sol2NetLang
Transformador Sol2NetLang em Flex

Para instalar o flex:
$ sudo apt-get update
$ sudo apt-get install flex

Para correr o programa:
/TP1-PLC-Transformador-Sol2NetLang$ flex Sol2NetLang.l
Transforma o Sol2NetLang.l num ficheiro C lex.yy.c

/TP1-PLC-Transformador-Sol2NetLang$ gcc lex.yy.c
Compila o lex.yy.c e cria um executável

/TP1-PLC-Transformador-Sol2NetLang$ ./a.out < pagina.html > output.json
O executável recebe a página HTML e cria o ficheiro output.json onde guarda o resultado
