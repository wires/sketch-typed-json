Ty = "(" _ t:Ty _ ")" { return t }
   / _ t:PrimTy _ { return t }
   / _ t:CoProductTy _ { return t }
   / _ t:ProductTy _ { return t }
   / _ t:ArrayTy _ { return t }
   / _ t:RecordTy _ { return t }

PrimTy
	= "bool" { return "bool" }
  / "int" { return "int" }
	/ "float" { return "float" }
	/ "string" { return "string" }
    
ArrayTy = "[" t:Ty "]" {
	return { t:"array", type: t }
}

CoProductTy = "|" tys:(t:Ty _ { return t})+ "|" {
	if(tys.length == 1) {return tys[0]}
	return {t:"coprod", types: tys}
}
ProductTy = "{" (! recField) tys:(t:Ty _ { return t})+ "}" {
	if(tys.length == 1) {return tys[0]}
	return {t:"product", types: tys}
}

RecordTy = "{" rs:recField* "}" {
	return {t:"record", fields: rs}
}
recField = _ name:identifier _ opt:"?"? _ ":" type:Ty {
  return { name, opt: opt ? true : false, type }
}

identifier = [a-zA-Z]([a-zA-Z0-9])* { return text() }

_ "whitespace"
  = [ \t\n\r]*