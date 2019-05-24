%{
#include <string.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

int charPos=1;

int yywrap(void)
{
 charPos=1;
 return 1;
}


void ADJ(void)
{
 EM_tokPos=charPos;
 charPos+=yyleng;
}

%}

%%
" "	 {ADJ(); continue;}
\n	 {ADJ(); EM_newline(); continue;}
","	 {ADJ(); return COMMA;}
for  	 {ADJ(); return FOR;}
[0-9]+	 {ADJ(); yylval.ival=atoi(yytext); return INT;}
.	 {ADJ(); EM_error(EM_tokPos,"illegal token");}

