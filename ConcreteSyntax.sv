grammar dc_lavender ;

{- This file defines the concrete syntax of the arithmetic expression
   language "dc".  The concrete productions are used to define the
   parser.  They also define an attribute, pp, which unparses the tree
   to generate a string, and attributes, ast_Root and ast_Expr, which
   are used to generate the abstract syntax tree.  -}

nonterminal Root_c with pp, ast_Root;

synthesized attribute ast_Root :: Root;


concrete production root_c
r::Root_c ::= e::Topmost_c 
{
  r.pp = e.pp;
  r.ast_Root = root(e.ast_Expr); 
  -- 'root' is the abstract production defined in AbstractSyntax.sv
}

synthesized attribute ast_Expr :: Expr ;

nonterminal Rel_c with pp, ast_Expr;
nonterminal Logical_c with pp, ast_Expr;
nonterminal Expr_c with pp, ast_Expr;
nonterminal Term_c with pp, ast_Expr;
nonterminal Factor_c with pp, ast_Expr;
nonterminal Exp_c with pp, ast_Expr;
nonterminal Topmost_c with pp, ast_Expr;
nonterminal Not_c with pp, ast_Expr;
-- Nonterminal declarations can also specify some attributes that decorate it.

{- Note about this concrete syntax: We're choosing to use the
   Expr/Term/Factor decomposition here.  Silver also supports the
   commonly used 'association' and 'precedence' specifications. See
   comments in Terminals.sv for more details.  -}
concrete productions e::Rel_c
| l::Expr_c '<'  r :: Expr_c { e.ast_Expr = rel(l.ast_Expr, r.ast_Expr, "<" ); }
| l::Expr_c '<=' r :: Expr_c { e.ast_Expr = rel(l.ast_Expr, r.ast_Expr, "<="); }
| l::Expr_c '>'  r :: Expr_c { e.ast_Expr = rel(l.ast_Expr, r.ast_Expr, ">" ); }
| l::Expr_c '>=' r :: Expr_c { e.ast_Expr = rel(l.ast_Expr, r.ast_Expr, ">="); }
| l::Expr_c '==' r :: Expr_c { e.ast_Expr = rel(l.ast_Expr, r.ast_Expr, "=="); }
| l::Expr_c '!=' r :: Expr_c { e.ast_Expr = rel(l.ast_Expr, r.ast_Expr, "!="); }
| '!' l::Rel_c               { e.ast_Expr = not(l.ast_Expr);                   }
| '(' l::Logical_c ')'       { e.ast_Expr = l.ast_Expr;                        }

concrete productions e::Logical_c
| l::Logical_c '||' r :: Rel_c { e.ast_Expr = logical(l.ast_Expr, r.ast_Expr, "||"); }
| l::Logical_c '&&' r :: Rel_c { e.ast_Expr = logical(l.ast_Expr, r.ast_Expr, "&&"); }
| l::Rel_c                     { e.ast_Expr = l.ast_Expr; }

concrete productions e::Topmost_c
| l::Logical_c     { e.ast_Expr = l.ast_Expr;   }
| l::Expr_c        { e.ast_Expr = l.ast_Expr;   }

--concrete productions e::Not_c
--| '!' l::Logical_c { e.ast_Expr = not(l.ast_Expr); }
--| l::Logical_c     { e.ast_Expr = l.ast_Expr;   }
--| '(' l::Not_c ')' { e.ast_Expr = l.ast_Expr;   }


concrete production add_c
sum::Expr_c ::= e::Expr_c '+' t::Term_c
{
 sum.pp = e.pp ++ " + " ++ t.pp ;
 sum.ast_Expr = add(e.ast_Expr, t.ast_Expr );
}

concrete production sub_c
dff::Expr_c ::= e::Expr_c '-' t::Term_c
{
 dff.pp = e.pp ++ " - " ++ t.pp ;
 dff.ast_Expr = sub(e.ast_Expr, t.ast_Expr);
}

concrete production exprTerm_c
e::Expr_c ::= t::Term_c
{
 e.pp = t.pp ;
 e.ast_Expr = t.ast_Expr ;
}

concrete production mul_c
prd::Term_c ::= t::Term_c '*' f::Factor_c
{
 prd.pp = t.pp ++ " * " ++ f.pp ;
 prd.ast_Expr = mul(t.ast_Expr, f.ast_Expr);
}

concrete production div_c
d::Term_c ::= t::Term_c '/' f::Factor_c
{
 d.pp = t.pp ++ " / " ++ f.pp ;
 d.ast_Expr = div(t.ast_Expr, f.ast_Expr);
}

concrete production termFactor_c
t::Term_c ::= f::Factor_c
{
 t.pp = f.pp ;
 t.ast_Expr = f.ast_Expr ;
}
concrete production termFactorExp_c
f::Factor_c ::= t::Exp_c
{
 f.pp = t.pp;
 f.ast_Expr = t.ast_Expr;
}

concrete production nested_c
e::Exp_c ::= '(' inner::Expr_c ')'
{
 e.pp = "(" ++ inner.pp ++ ")" ;
 e.ast_Expr = inner.ast_Expr ;
}

concrete production exp_c
e::Factor_c ::= base::Factor_c '^' power::Exp_c
{
 e.pp = base.pp ++ "^" ++ power.pp;
 e.ast_Expr = exp(base.ast_Expr, power.ast_Expr);
}

concrete production integerConstant_c
ic::Exp_c ::= i::IntLit_t
{
 ic.pp = i.lexeme ;
 ic.ast_Expr = integerConstant(i);
}



