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
END_POST_MESSAGE_TAG		\n\<\/div\>\n<\/div\>

START_USERNAME_TAG			\<a[' ']data-action=\"profile\"[' ']data-username=\"
END_USERNAME_TAG			\"[' ']href

START_DATE_TAG				\<a[' ']class=\"time-ago.+\"\>
END_DATE_TAG				ago\<\/a\>



%x COMMENT CONTENT USERNAME DATE

%%

{START_LI_POST_TAG} {
	criaComentario();
	yy_push_state(COMMENT);
}

<COMMENT>[0-9]{10}/(\"\>\<div[' ']role=\"alert\"\>\<\/div\>) {
	comentario->id = strdup(yytext);
	printf("\{\n\t\"id\": \"%s\"\n", yytext);
}

<COMMENT>{START_POST_MESSAGE_TAG} {
	//printf("\t\"commentText\": \"");
	yy_push_state(CONTENT);
}
 
<COMMENT>{START_USERNAME_TAG} {
	yy_push_state(USERNAME);
}

<COMMENT>{START_DATE_TAG} {
	yy_push_state(DATE);
}

<DATE>.+ago/\<\/a\> {
	printf("\t\"date\": \"%s\"\n\t\"timestamp\": \"NA\"\n", yytext);
	yy_pop_state();
}

<USERNAME>.+/{END_USERNAME_TAG} {
	printf("\t\"user\": \"%s\"\n", yytext);
	yy_pop_state();
}

<CONTENT>(\<\/[^d]|\<[^\/]|[^\<])*/{END_POST_MESSAGE_TAG} {
	comentario->conteudo = strdup(yytext);
	printf("\t\"commentText\": \"");
	printf("%s\"\n\n", yytext);
	yy_pop_state();
}

<INITIAL,COMMENT,DATE>.|\n { ; }

%%

int yywrap() {
	printf("Count: %s\n", comentario->id);
	printf("Text: %s\n", comentario->conteudo);
	return(1);
}

int main(){
	yylex(); return 0;
}
