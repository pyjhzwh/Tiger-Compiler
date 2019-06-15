E_enventry E_VarEntry(Ty_ty ty)
{
	E_enventry p = checked_malloc(sizeof(*p));
	p->kind = E_varEntry;
	p->u.var.ty = ty;
	return p;
}

E_enventry E_FunEntry (Ty_tyList formals, Ty_ty result)
{
	E_enventry p = checked_malloc(sizeof(*p));
	p->kind = E_funEntry;
	p->u.fun.formals = formals;
	p->u.fun.result = result;
	return p;
}

S_table E_base_tenv(void)
{
	S_table t = S_empty();
  S_enter(t, S_Symbol("int"), Ty_Int());
  S_enter(t, S_Symbol("string"), Ty_String());
  return t;
}

S_table E_base_venv(void)
{
  S_table t = S_empty();
  return t;
}
