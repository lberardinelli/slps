@contributor{Vadim Zaytsev - vadim@grammarware.net - SWAT, CWI}
@wiki{WriteBGF}
module io::WriteBGF

import IO;
import language::BGF;
import lang::xml::DOM;

public void writeBGF(BGFGrammar bgf, loc f)
{
	list[Node] xml1 = [element(none(),"root",[charData(s)]) | s <- bgf.roots];
	list[Node] xml2 = [prod2xml(p) | p <- bgf.prods];
	writeFile(f,xmlRaw(document(element(namespace("bgf","http://planet-sl.org/bgf"),"grammar",xml1+xml2))));
}

public Node prod2xml(BGFProduction p)
{
	list[Node] kids = [];
	if (p.label!="") kids += element(none(),"label",[charData(p.label)]);
	kids += element(none(),"nonterminal",[charData(p.lhs)]);
	kids += expr2xml(p.rhs);
	return element(namespace("bgf","http://planet-sl.org/bgf"),"production",kids);
}

public Node expr2xml(BGFExpression ex)
{
	Node e;
	switch(ex)
	{
		case epsilon(): e = element(none(),"epsilon",[]);
		case empty(): e = element(none(),"empty",[]);
		case val(string()): e = element(none(),"value",[charData("string")]);
		case val(integer()): e = element(none(),"value",[charData("int")]);
		case anything(): e = element(none(),"any",[]);
		case terminal(str s): e = element(none(),"terminal",[charData(s)]);
		case nonterminal(str s): e = element(none(),"nonterminal",[charData(s)]);
		case selectable(s,expr): e = element(none(),"selectable",[element(none(),"selector",[charData(s)]),expr2xml(expr)]);
		case sequence(L): e = element(none(),"sequence",[expr2xml(expr) | expr <- L]);
		case choice(L): e = element(none(),"choice",[expr2xml(expr) | expr <- L]);
		case allof(L): e = element(none(),"allof",[expr2xml(expr) | expr <- L]);
		case marked(expr): e = element(none(),"marked",[expr2xml(expr)]);
		case optional(expr): e = element(none(),"optional",[expr2xml(expr)]);
		case not(expr): e = element(none(),"not",[expr2xml(expr)]);
		case plus(expr): e = element(none(),"plus",[expr2xml(expr)]);
		case star(expr): e = element(none(),"star",[expr2xml(expr)]);
		case seplistplus(e1,e2): e = element(none(),"seplistplus",[expr2xml(e1),expr2xml(e2)]);
		case sepliststar(e1,e2): e = element(none(),"sepliststar",[expr2xml(e1),expr2xml(e2)]);
		default: throw "ERROR: expression expected in place of <ex>";
	}
	return element(namespace("bgf","http://planet-sl.org/bgf"),"expression",[e]);
}
