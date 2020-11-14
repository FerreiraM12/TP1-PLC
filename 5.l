%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Comentario {
    const char* id;
	const char* user;
	const char* date;
	const char* commentText;
	//const int likes;
	//const int hasReplies;
	//const int numOfReplies;
    struct Comentario* comPTRArr[25];
} *ComPTR, Com;

ComPTR comPTR1; // Comentario principal
ComPTR comPTR2; // Comentario temporário

int i,count = 0;
int count2 = 0;
int mTreeLoc[25];

void mTreeInserter();
void mTreeInserterAUX();
ComPTR cloneComment();
ComPTR createComment();
void setID();
void setUser();
void setDate();
void setCommentText();
void printComs();
void fillmTreeLoc();
void printmtreeloc();
void indentation();

void mTreeInserter(ComPTR* comPTRloc, int locs[], ComPTR comPTR2) {
    if(*comPTRloc == NULL) *comPTRloc = cloneComment(comPTR2);
    else mTreeInserterAUX(comPTRloc, locs, 1, comPTR2);
}

void mTreeInserterAUX(ComPTR* comPTRloc, int locs[], int ind, ComPTR comPTR2) {
    ComPTR comPTR1;
    if (locs[ind] == -1) return;
    if ((*comPTRloc)->comPTRArr[locs[ind]] == NULL) {
        (*comPTRloc)->comPTRArr[locs[ind]] = cloneComment(comPTR2);
    } else mTreeInserterAUX(&(*comPTRloc)->comPTRArr[locs[ind]], locs, ind+1, comPTR2);
}

ComPTR cloneComment(ComPTR comPTR2) {
    ComPTR comPTR1 = malloc(sizeof(Com));
    comPTR1->id = strdup(comPTR2->id);
    comPTR1->user = strdup(comPTR2->user);
    comPTR1->date = strdup(comPTR2->date);
    comPTR1->commentText = strdup(comPTR2->commentText);
    for(int i=0;i<25;i++) comPTR2->comPTRArr[i] = NULL;
    return comPTR1;
}

ComPTR createComment() {
    ComPTR comPTR2 = malloc(sizeof(Com));
    return comPTR2;
}

void setID(ComPTR comPTR2, char* id) {comPTR2->id = strdup(id);}

void setUser(ComPTR comPTR2, char* user) {comPTR2->user = strdup(user);}

void setDate(ComPTR comPTR2, char* date) {comPTR2->date = strdup(date);}

void setCommentText(ComPTR comPTR2, char* commentText) {comPTR2->commentText = strdup(commentText);}

void printComs(ComPTR comPTR1, int depth) {
    int hasReplies = 0;
    indentation(depth+1); printf("\"id\": \"%s\"\n", comPTR1->id);
    indentation(depth+1); printf("\"user\": \"%s\"\n", comPTR1->user);
    indentation(depth+1); printf("\"date\": \"%s\"\n", comPTR1->date);
    indentation(depth+1); printf("\"timestamp\": \"%s\"\n", "NA");
    indentation(depth+1); printf("\"commentText\": \"%s\"\n", comPTR1->commentText);
    for (int i = 0; i < 25; i++) {
        if (comPTR1->comPTRArr[i] != NULL) hasReplies = 1; break;
    }
    if (hasReplies == 0) {
        indentation(depth+1); printf("\"replies\": []\n");
    }
    else {
        indentation(depth+1); printf("\"replies\": [\n");
        for (int i = 0; i < 24; i++) {
            if (comPTR1->comPTRArr[i] != NULL) {
                printComs(comPTR1->comPTRArr[i], depth+2);
            }
            else break;
        }
    }
}

void fillmTreeLoc(int mTreeLoc[]) {for (i=0;i<25;i++) mTreeLoc[i] = -1;}

void printmtreeloc(int mTreeLoc[]) {
	for (i=0;i<25;i++) printf("%i", mTreeLoc[i]);
    printf("\n");
}

void indentation(int n) {for (i = 0; i < n; i++) printf("    ");}

%}

START_LI_POST_TAG			\<li[' ']class=\"post\"[' ']id=\"post-
END_LI_POST_TAG				Show[' ']more[' ']replies\<\/a\>\n\<\/div\>\n\<\/div\>\n\<\/li\>

START_POST_MESSAGE_TAG		\<div[' ']class=\"post-message\"[' ']data-role=\"message\"[' ']dir=\"auto\"\>\<div\>
END_POST_MESSAGE_TAG		\n\<\/div\>\n<\/div\>

START_USERNAME_TAG			\<a[' ']data-action=\"profile\"[' ']data-username=\"
END_USERNAME_TAG			\"[' ']href

START_DATE_TAG				\<a[' ']class=\"time-ago.+\"\>
END_DATE_TAG				ago\<\/a\>

%option stack
%s COMMENT CONTENT USERNAME DATE

%%

{START_LI_POST_TAG} {
	mTreeLoc[count]++;
    comPTR2 = createComment();
	count++;
	yy_push_state(COMMENT);
}

<COMMENT>[0-9]{10}/(\"\>\<div[' ']role=\"alert\"\>\<\/div\>) {
	setID(comPTR2, yytext);
}

<COMMENT>{START_USERNAME_TAG} {
	yy_push_state(USERNAME);
}

<USERNAME>.+/{END_USERNAME_TAG} {
    setUser(comPTR2, yytext);
	yy_pop_state();
}

<COMMENT>{START_DATE_TAG} {
	yy_push_state(DATE);
}

<DATE>.+ago/\<\/a\> {
    setDate(comPTR2, yytext);
    
	yy_pop_state();
}

<COMMENT>{START_POST_MESSAGE_TAG} {
	yy_push_state(CONTENT);
}

<CONTENT>(\<\/[^d]|\<[^\/]|[^\<])*/{END_POST_MESSAGE_TAG} {
    setCommentText(comPTR2, yytext);
    mTreeInserter(&comPTR1, mTreeLoc, comPTR2);
    comPTR2 = NULL;
	yy_pop_state();
}

<COMMENT>{END_LI_POST_TAG} {
	mTreeLoc[count] = -1;
	count--;
    if (count == 0) {
        if (count2 != 0) printf(",\n");
        count2 = 1;
        indentation(1); printf("{\n");
        printComs(comPTR1, 1);
        comPTR1 = NULL;
        indentation(1); printf("}");
    }
	yy_pop_state();
}

.|\n { ; }

%%

int yywrap() {
    printf("\n]\n");
	return(1);
}

int main(){
	comPTR1 = NULL;
	fillmTreeLoc(mTreeLoc);
    printf("\"commentThread\": [\n");
	yylex(); return 0;
}
