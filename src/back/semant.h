#ifndef SEMANT_H
#define SEMANT_H

//#include "translate.h"

/* Definitions */
struct expty {Tr_exp exp; Ty_ty ty;};

struct expty expTy(Tr_exp exp, Ty_ty ty){
  struct expty e; e.exp=exp; e.ty=ty; return e;
}

/* Function Declarations */
static struct expty transExp(Tr_level level, S_table venv, S_table tenv, A_exp a, Temp_label breaklbl);
static struct expty transVar(Tr_level level, S_table venv, S_table tenv, A_var v, Temp_label breaklbl);
static void transDec(Tr_level level, S_table venv, S_table tenv, A_dec d, Temp_label breaklbl);
static Ty_ty transTy(Tr_level level, S_table tenv, A_ty a);

static bool compare_ty(Ty_ty ty1, Ty_ty ty2);


F_fragList SEM_transProg(A_exp exp);

#endif
