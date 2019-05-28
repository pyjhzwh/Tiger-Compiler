%{
#include <string.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

const int INITIAL_STRING_LENGTH=64;
int STRBUF_CAPACITY;
int charPos=1;
int commentDepth=0;
string strbuf;

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

static void init_strbuf()
{
  strbuf = checked_malloc(INITIAL_STRING_LENGTH);
  STRBUF_CAPACITY = INITIAL_STRING_LENGTH;
  strbuf[0] = '\0';
}

static void append_strbuf(char c)
{
  int new_length = strlen(strbuf) + 1;
  /* if current capacticy is not enough for new char, then double capacticy */
  if(new_length >= STRBUF_CAPACITY) {
    char *tmp = strbuf;
    STRBUF_CAPACITY *= 2;
    strbuf = checked_malloc(STRBUF_CAPACITY);
    strcpy(strbuf, tmp);
  }
  strbuf[new_length-1] = c;
  strbuf[new_length] = '\0';
}

%}

%x COMMENT
%x STR

%%
 /* ignore */
[ \t\r]	 {ADJ(); continue;}

 /* new line */
\n|\r\n	 {ADJ(); EM_newline(); continue;}

 /* comment */
"/*" {ADJ(); commentDepth++;  BEGIN COMMENT; continue;}
<COMMENT>"/*"            {ADJ(); commentDepth++;}
<COMMENT>"*/"            {ADJ(); if (--commentDepth == 0) BEGIN(INITIAL);}
<COMMENT>(\n|\r\n)	     {ADJ(); EM_newline();}
<COMMENT><<EOF>>         {ADJ(); EM_error(EM_tokPos,"unclose comment"); yyterminate();}
<COMMENT>.               {ADJ();}

 /* keywords */
"array"       {ADJ(); return ARRAY;}
"break"       {ADJ(); return BREAK;}
"do"          {ADJ(); return DO;}
"else"        {ADJ(); return ELSE;}
"end"         {ADJ(); return END;}
"for"         {ADJ(); return FOR;}
"function"    {ADJ(); return FUNCTION;}
"if"          {ADJ(); return IF;}
"in"          {ADJ(); return IN;}
"let"         {ADJ(); return LET;}
"nil"         {ADJ(); return NIL;}
"of"          {ADJ(); return OF;}
"then"        {ADJ(); return THEN;}
"to"          {ADJ(); return TO;}
"type"        {ADJ(); return TYPE;}
"var"         {ADJ(); return VAR;}
"while"       {ADJ(); return WHILE;}

 /* identifier */
[a-zA-Z][a-zA-Z0-9_]*   {ADJ(); yylval.sval=String(yytext); return ID;}

 /* integer */
[0-9]+    {ADJ(); yylval.ival=atoi(yytext); return INT;}

 /* punctuation and operators */
"("       {ADJ(); return LPAREN;}
")"       {ADJ(); return RPAREN;}
"["       {ADJ(); return LBRACK;}
"]"       {ADJ(); return RBRACK;}
"{"       {ADJ(); return LBRACE;}
"}"       {ADJ(); return RBRACE;}
":"       {ADJ(); return COLON;}
":="      {ADJ(); return ASSIGN;}
"."       {ADJ(); return DOT;}
","	      {ADJ(); return COMMA;}
";"       {ADJ(); return SEMICOLON;}
"*"       {ADJ(); return TIMES;}
"/"       {ADJ(); return DIVIDE;}
"+"       {ADJ(); return PLUS;}
"-"       {ADJ(); return MINUS;}
"="       {ADJ(); return EQ;}
"<>"      {ADJ(); return NEQ;}
">"       {ADJ(); return GT;}
"<"       {ADJ(); return LT;}
">="      {ADJ(); return GE;}
"<="      {ADJ(); return LE;}
"&"       {ADJ(); return AND;}
"|"       {ADJ(); return OR;}

 /* string */
\"        {ADJ(); init_strbuf(); BEGIN STR;}
<STR>\"   {ADJ(); yylval.sval=String(strbuf); BEGIN INITIAL; return STRING;}
<STR>\\n  {ADJ(); append_strbuf('\n');}
<STR>\\t  {ADJ(); append_strbuf('\t');}
 /* <STR>^[@GHIKJLMZ]   {ADJ(); append_strbuf(yytext,yyleng);} */
<STR>\\\" {ADJ(); append_strbuf('\"');}
<STR>\\\\ {ADJ(); append_strbuf('\\');}
<STR>\\[\t\n\r(\r\n)]+\\  {ADJ(); for(int i=0; i < yyleng; i++) if(yytext[i]=='\n') EM_newline();
                          continue;}
<STR>\\[0-9]{3}	    {ADJ(); int tmp = atoi(yytext); if(tmp > 0xff) { EM_error(EM_tokPos,"ascii code out of range"); yyterminate(); }
                    append_strbuf(tmp);}
<STR><<EOF>>        {ADJ(); EM_error(EM_tokPos,"unclose string"); yyterminate();}

<STR>[^\n\t\\\"]+ {ADJ();  for(int i=0; i < yyleng; i++) append_strbuf(yytext[i]); }
<STR>.    {ADJ(); EM_error(EM_tokPos,"illegal token");}

.         {ADJ(); EM_error(EM_tokPos,"illegal token");}
