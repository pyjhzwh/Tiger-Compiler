static Ty_ty actual_ty(Ty_ty ty)
{
  Ty_ty actual = ty;
  while(actual && actual->Ty_name == Ty_name)
  {
    actual = actual->u.name.ty;
    /* detect a cycle, break;*/
    if(actual==ty)
      break;
  }
  return actual;
}


static bool compare_ty(Ty_ty ty1, Ty_ty ty2)
{
  ty1 = actual_ty(ty1);
  ty2 = actual_ty(ty2);
  if (ty1->kind == Ty_int || ty1->kind == Ty_string || ty2->kind == Ty_int || ty2->kind == Ty_string)
    return ty1->kind == ty2->kind;

  if (ty1->kind == Ty_nil && ty2->kind == Ty_nil)
    return FALSE;

  if (ty1->kind == Ty_nil)
    return ty2->kind == Ty_record || ty2->kind == Ty_array;

  if (ty2->kind == Ty_nil)
    return ty1->kind == Ty_record || ty1->kind == Ty_array;

  return ty1 == ty2;

}

static struct expty transExp(Tr_level level, S_table venv, S_table tenv, A_exp a, Temp_label breaklbl)
{
  switch (a->kind) {
    case A_OpExp:{
      A_oper oper = a->u.op.oper;
      struct expty left =transExp(venv,tenv,a->u.op.left);
      struct expty right=transExp(venv,tenv,a->u.op.right);
      switch (oper) {
        case A_plusOp:
        case A_minusOp:
        case A_timesOp:
        case A_divideOp:{
          if (left.ty->kind!=Ty_int)
          EM_error(a->u.op.left->pos, "integer required");
          if (right.ty->kind!=Ty_int)
          EM_error(a->u.op.right->pos,"integer required");
          return expTy(NULL, Ty_Int());
        }
        case A_eqOp:
        case A_neqOp:{

        }
      }
    }
  }
}

struct expty transVar(S_table venv, S_table tenv, A_var v ) {
  switch(v->kind) {
    case A_simpleVar: {
    E_enventry x = S_look(venv,v->u.simple) ;
    if (x && x->kind==E_varEntry)
      return expTy(NULL, actuality(x->u.var.ty));
    else {EM_error(v->pos,"undefined variable %s", S_name(v->u.simple));
          return expTy(NULL, Ty_Int());}
    }
  case A_fieldVar:
}
