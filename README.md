# TP1-PLC-Transformador-Sol2NetLang

### Para instalar o flex:

$ sudo apt-get update

$ sudo apt-get install flex


### Para correr o programa:
- Transformar o Sol2NetLang.l num ficheiro C lex.yy.c
```
/TP1-PLC-Transformador-Sol2NetLang$ flex Sol2NetLang.l
```
- Compilar o lex.yy.c e criar um executável
```
/TP1-PLC-Transformador-Sol2NetLang$ gcc lex.yy.c
```
- O executável recebe a página HTML e cria o ficheiro output.json onde guarda o resultado
```
/TP1-PLC-Transformador-Sol2NetLang$ ./a.out < pagina.html > output.json
```



