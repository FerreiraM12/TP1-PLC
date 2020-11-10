%{
/* Declaracoes C diversas */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int count = 0;
int comCount = 0;
int i;
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

void indentation(int n) {
	for (i = 0; i < count + n; i++) {
		printf("    ");
	}
}

%}

%option stack

START_LI_POST_TAG			\<li[' ']class=\"post\"[' ']id=\"post-
END_LI_POST_TAG				Show[' ']more[' ']replies\<\/a\>\n\<\/div\>\n\<\/div\>\n\<\/li\>

START_POST_MESSAGE_TAG		\<div[' ']class=\"post-message\"[' ']data-role=\"message\"[' ']dir=\"auto\"\>\<div\>
END_POST_MESSAGE_TAG		\n\<\/div\>\n<\/div\>

START_USERNAME_TAG			\<a[' ']data-action=\"profile\"[' ']data-username=\"
END_USERNAME_TAG			\"[' ']href

START_DATE_TAG				\<a[' ']class=\"time-ago.+\"\>
END_DATE_TAG				ago\<\/a\>



%s COMMENT CONTENT USERNAME DATE

%%

{START_LI_POST_TAG} {
	criaComentario();
	count++;
	comCount++;
	//printf("Count: %i\n", count);
	//printf("PUSH COMMENT\n\n");

	if (count == 1 && comCount > 1) {
		printf(",\n");
		indentation(0);
		printf("{\n");
	} else if (count > 1) {
		indentation(count - 2);
		printf("\"replies\": [\n");
		indentation(count - 1);
		printf("{\n");
	}
	
	yy_push_state(COMMENT);
}

<COMMENT>[0-9]{10}/(\"\>\<div[' ']role=\"alert\"\>\<\/div\>) {
	comentario->id = strdup(yytext);
	indentation(count);
	printf("\"id\": \"%s\"\n", yytext);
}

<COMMENT>{START_POST_MESSAGE_TAG} {
	//printf("PUSH CONTENT\n\n");
	yy_push_state(CONTENT);
}
 
<COMMENT>{START_USERNAME_TAG} {
	//printf("PUSH USERNAME\n\n");
	yy_push_state(USERNAME);
}

<COMMENT>{START_DATE_TAG} {
	//printf("PUSH DATE\n\n");
	yy_push_state(DATE);
}

<COMMENT>{END_LI_POST_TAG} {
	indentation(count-1);
	printf("}\n");
	count--;
	//printf("Count: %i\n", count);
	//printf("POP\n\n");
	if (count != 0) {
		indentation(count);
		printf("]\n");
	}
	yy_pop_state();
}

<DATE>.+ago/\<\/a\> {
	indentation(count);
	printf("\"date\": \"%s\"\n", yytext);
		indentation(count);
	printf("\"timestamp\": \"NA\"\n");
	//printf("POP\n\n");
	yy_pop_state();
}

<USERNAME>.+/{END_USERNAME_TAG} {
	indentation(count);
	printf("\"user\": \"%s\"\n", yytext);
	//printf("POP\n\n");
	yy_pop_state();
}

<CONTENT>(\<\/[^d]|\<[^\/]|[^\<])*/{END_POST_MESSAGE_TAG} {
	comentario->conteudo = strdup(yytext);
	indentation(count);
	printf("\"commentText\": \"");
	printf("%s\"\n\n", yytext);
	
	//printf("POP\n\n");
	yy_pop_state();
}

.|\n { ; }

%%

int yywrap() {
	printf("ComCount: %i\n", comCount);
	return(1);
}

int main(){
	printf("\"commentThread\": ");
	yylex(); return 0;
}
