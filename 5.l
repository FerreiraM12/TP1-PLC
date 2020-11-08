%{
/* Declaracoes C diversas */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int count = 0;

typedef struct Comentario {
	const char* id;
	const char* user;
	const char* date;
	const char* conteudo;
	const int likes;
	const int hasReplies;
	const int numOfReplies;
	struct Comentario* coms[50];
} *comPTR, com;

comPTR comentario;

void criaComentario() {
	comentario = malloc(sizeof(com));
}

%}

%option stack

START_LI_POST_TAG			\<li[' ']class=\"post\"[' ']id=\"post-

START_POST_MESSAGE_TAG		\<div[' ']class=\"post-message\"[' ']data-role=\"message\"[' ']dir=\"auto\"\>\<div\>
END_POST_MESSAGE_TAG		\<\/div\>\n<\/div\>

START_USERNAME_TAG			\<a[' ']data-action=\"profile\"[' ']data-username=\"
END_USERNAME_TAG			\"[' ']href

%x COMMENT CONTENT USERNAME

%%

{START_LI_POST_TAG} {
	criaComentario();
	yy_push_state(COMMENT);
}

<COMMENT>[0-9]{10}/(\"\>\<div[' ']role=\"alert\"\>\<\/div\>) {
	comentario->id = strdup(yytext);
	printf("\"id\": \"%s\"\n", yytext);
}

<COMMENT>{START_POST_MESSAGE_TAG} {
	printf("\"commentText\":");
	yy_push_state(CONTENT);
}

<COMMENT>{START_USERNAME_TAG} {
	yy_push_state(USERNAME);
}

<USERNAME>.+/{END_USERNAME_TAG} {
	printf("\"user\": \"%s\"\n", yytext);
	yy_pop_state();
}

<CONTENT>(.)+(\n)?/{END_POST_MESSAGE_TAG} {
	comentario->conteudo = strdup(yytext);
	printf("\"%s\"\n", yytext);
	yy_pop_state();
}


<INITIAL,COMMENT>.|\n { ; }

%%

int yywrap() {
	printf("Count: %s\n", comentario->id);
	printf("Text: %s\n", comentario->conteudo);
	return(1);
}

int main(){
	yylex(); return 0;
}
