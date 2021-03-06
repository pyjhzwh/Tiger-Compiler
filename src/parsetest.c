#include <stdio.h>
#include <stdlib.h>
#include "util.h"
#include "errormsg.h"
#include "parse.h"
#include "symbol.h"
#include "absyn.h"
#include "types.h"
#include "semant.h"

extern int yyparse(void);

/*
void parse(string fname)
{EM_reset(fname);
 if (yyparse() == 0) // parsing worked
   fprintf(stderr,"Parsing successful!\n");
 else fprintf(stderr,"Parsing failed\n");
}
*/

int main(int argc, char **argv) {
 if (argc!=2) {fprintf(stderr,"usage: a.out filename\n"); exit(1);}
 A_exp absyn_root = parse(argv[1]);
 if (absyn_root){
  	SEM_transProg(absyn_root);
  }
  fprintf(stderr,"\n");
 return 0;
}
