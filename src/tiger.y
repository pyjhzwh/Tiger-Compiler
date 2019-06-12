%{
#include <stdio.h>
#include <stdlib.h>
#include "util.h"
#include "errormsg.h"
#include "absyn.h"

int yylex(void); /* function prototype */

void yyerror(char *s) {
  EM_error(EM_tokPos, "%s", s);
}

A_exp absyn_root;


%}

%union {
	int pos;
	int ival;
	string sval;
  A_var var;
  A_exp exp;
  A_dec dec;
  A_ty ty;
  A_decList decList;
  A_expList expList;
  A_field field;
  A_fieldList fieldList;
  A_fundec fundec;
  A_fundecList fundecList;
  A_namety namety;
  A_nametyList nametyList;
  A_efield efield;
  A_efieldList efieldList;
  }

%nonassoc LOW
%nonassoc TYPE FUNCTION
%nonassoc ID
%nonassoc LBRACK
%nonassoc DO OF
%nonassoc THEN
%nonassoc ELSE
%left SEMICOLON
%nonassoc ASSIGN
%left OR
%left AND
%nonassoc EQ NEQ LT LE GT GE
%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS

%token <sval> ID STRING
%token <ival> INT

%token
  COMMA COLON SEMICOLON LPAREN RPAREN LBRACK RBRACK
  LBRACE RBRACE DOT
  PLUS MINUS TIMES DIVIDE EQ NEQ LT LE GT GE
  AND OR ASSIGN
  ARRAY IF THEN ELSE WHILE FOR TO DO LET IN END OF
  BREAK NIL
  FUNCTION VAR TYPE

%type <exp> exp program seqExp negation callExp infixExp arrCreate recCreate
 assignment ifThenElse ifThen whileExp forExp letExp
%type <var> lValue subscript fieldExp
%type <ty> ty arrTy recTy
%type <dec> dec varDec
%type <decList> decs
%type <expList> expList expSeq
%type <field> fieldDec
%type <fieldList> fieldDecs
%type <fundec> funDec
/*%type <fundecList>*/
%type <namety> tyDec
/*%type <nametyList>*/
%type <efield> fieldCreate
%type <efieldList> fieldCreates
%start program

%%

program:  exp { absyn_root = $1; }

exp     : lValue  {$$ = A_VarExp(EM_tokPos,$1);}
        | NIL {$$ = A_NilExp(EM_tokPos);}
        | INT {$$ = A_IntExp(EM_tokPos, $1);}
        | STRING {$$ = A_StringExp(EM_tokPos, $1);}
        | seqExp  {$$ = $1;}
        | negation  {$$ = $1;}
        | callExp  {$$ = $1;}
        | infixExp  {$$ = $1;}
        | arrCreate  {$$ = $1;}
        | recCreate  {$$ = $1;}
        | assignment  {$$ = $1;}
        | ifThenElse  {$$ = $1;}
        | ifThen  {$$ = $1;}
        | whileExp  {$$ = $1;}
        | forExp  {$$ = $1;}
        | BREAK {$$ = A_BreakExp(EM_tokPos);}
        | letExp  {$$ = $1;}


seqExp  : LPAREN expSeq RPAREN {$$ = A_SeqExp(EM_tokPos, $2);}
        | LPAREN RPAREN {$$ = A_SeqExp(EM_tokPos, NULL);}


expSeq  : exp { $$ = A_ExpList($1,NULL);}
        | exp SEMICOLON expSeq {$$ = A_ExpList($1, $3);}


negation: MINUS exp %prec UMINUS
          {$$ = A_OpExp(EM_tokPos,A_minusOp,A_IntExp(EM_tokPos,0),$2);}


callExp : ID LPAREN RPAREN {$$ = A_CallExp(EM_tokPos,S_Symbol($1),NULL);}
        | ID LPAREN expList RPAREN {$$ = A_CallExp(EM_tokPos,S_Symbol($1),$3);}


expList : exp { $$ = A_ExpList($1,NULL);}
        | exp COMMA expList {$$ = A_ExpList($1, $3);}

infixExp: exp PLUS exp {$$ = A_OpExp(EM_tokPos,A_plusOp,$1,$3);}
        | exp MINUS exp {$$ = A_OpExp(EM_tokPos,A_minusOp,$1,$3);}
        | exp TIMES exp {$$ = A_OpExp(EM_tokPos,A_timesOp,$1,$3);}
        | exp DIVIDE exp {$$ = A_OpExp(EM_tokPos,A_divideOp,$1,$3);}
        | exp EQ exp {$$ = A_OpExp(EM_tokPos,A_eqOp,$1,$3);}
        | exp NEQ exp {$$ = A_OpExp(EM_tokPos,A_neqOp,$1,$3);}
        | exp LT exp {$$ = A_OpExp(EM_tokPos,A_ltOp,$1,$3);}
        | exp LE exp {$$ = A_OpExp(EM_tokPos,A_leOp,$1,$3);}
        | exp GT exp {$$ = A_OpExp(EM_tokPos,A_gtOp,$1,$3);}
        | exp GE exp {$$ = A_OpExp(EM_tokPos,A_geOp,$1,$3);}
        | exp AND exp {$$ = A_IfExp(EM_tokPos, $1, $3, A_IntExp(EM_tokPos,0));}
        | exp OR exp {$$ = A_IfExp(EM_tokPos, $1, A_IntExp(EM_tokPos,1), $3);}


arrCreate : ID LBRACK exp RBRACK OF exp
          {$$ = A_ArrayExp(EM_tokPos, S_Symbol($1), $3, $6);}

recCreate : ID LBRACE RBRACE
          { $$ = A_RecordExp(EM_tokPos, S_Symbol($1), NULL); }
          | ID LBRACE fieldCreates RBRACE
          { $$ = A_RecordExp(EM_tokPos, S_Symbol($1), $3); }

fieldCreates:fieldCreate
            {$$ = A_EfieldList($1,NULL);}
            | fieldCreate COMMA fieldCreates
            {$$ = A_EfieldList($1,$3);}

fieldCreate : ID EQ exp {$$ = A_Efield(S_Symbol($1),$3);}

assignment  : lValue ASSIGN exp
            {$$ = A_AssignExp(EM_tokPos,$1, $3);}

ifThenElse  : IF exp THEN exp ELSE exp
            {$$ = A_IfExp(EM_tokPos,$2,$4,$6);}

ifThen      : IF exp THEN exp
            {$$ = A_IfExp(EM_tokPos,$2,$4,NULL);}

whileExp    : WHILE exp DO exp
            {$$ = A_WhileExp(EM_tokPos,$2,$4);}

forExp      : FOR ID ASSIGN exp TO exp DO exp
            {$$ = A_ForExp(EM_tokPos,S_Symbol($2),$4,$6,$8);}

letExp      : LET decs IN expSeq END
            {$$ = A_LetExp(EM_tokPos,$2,A_SeqExp(EM_tokPos,$4));}

decs        : dec {$$ = A_DecList($1,NULL);}
            | dec decs {$$ = A_DecList($1,$2);}

dec         : tyDec {$$ = A_TypeDec(EM_tokPos,A_NametyList($1,NULL));}
            | varDec {$$ = $1;}
            | funDec {$$ = A_FunctionDec(EM_tokPos,A_FundecList($1,NULL));}

tyDec       : TYPE ID EQ ty {$$ = A_Namety(S_Symbol($2), $4);} /* may be wrong*/

ty          : ID {$$ = A_NameTy(EM_tokPos,S_Symbol($1));}
            | arrTy {$$ = $1;}
            | recTy {$$ = $1;}

arrTy:      ARRAY OF ID {$$ = A_ArrayTy(EM_tokPos,S_Symbol($3));}

recTy:   LBRACE fieldDecs RBRACE {$$ = A_RecordTy(EM_tokPos,$2);}
      | LBRACE RBRACE {$$ = A_RecordTy(EM_tokPos,NULL);}

fieldDecs : fieldDec {$$ = A_FieldList($1,NULL);}
          | fieldDec COMMA fieldDecs {$$ = A_FieldList($1,$3);}

fieldDec : ID COLON ID {$$ = A_Field(EM_tokPos,S_Symbol($1),S_Symbol($3));}

funDec : FUNCTION ID LPAREN fieldDecs RPAREN EQ exp
       {$$ = A_Fundec(EM_tokPos,S_Symbol($2),$4,NULL,$7);}
       | FUNCTION ID LPAREN RPAREN EQ exp
       {$$ = A_Fundec(EM_tokPos,S_Symbol($2),NULL,NULL,$6);}
       | FUNCTION ID LPAREN fieldDecs RPAREN COLON ID EQ exp
       {$$ = A_Fundec(EM_tokPos,S_Symbol($2),$4,S_Symbol($7),$9);}
       | FUNCTION ID LPAREN RPAREN COLON ID EQ exp
       {$$ = A_Fundec(EM_tokPos,S_Symbol($2),NULL,S_Symbol($6),$8);}

varDec  : VAR ID ASSIGN exp {$$ = A_VarDec(EM_tokPos,S_Symbol($2),NULL,$4);}
        | VAR ID COLON ID ASSIGN exp
        {$$ = A_VarDec(EM_tokPos,S_Symbol($2),S_Symbol($4),$6);}

lValue  : ID  {$$ = A_SimpleVar(EM_tokPos,S_Symbol($1));}
        | subscript {$$ = $1;}
        | fieldExp  {$$ = $1;}

subscript : lValue LBRACK exp RBRACK
          {$$ = A_SubscriptVar(EM_tokPos,$1,$3);}

fieldExp : lValue DOT ID
          {$$ = A_FieldVar(EM_tokPos,$1,S_Symbol($3));}
