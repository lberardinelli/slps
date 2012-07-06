@contributor{Vadim Zaytsev - vadim@grammarware.net - SWAT, CWI}
module converge::PureGuided

import syntax::BGF;
import syntax::XBGF;
import syntax::CBGF;
import analyse::Prodsigs;
import analyse::Metrics;
import normal::ANF;
import export::BNF;
import io::ReadBGF;
import io::WriteBGF;
import transform::XBGF;
import transform::CBGF;
import lib::Rascalware;
import IO;
import String;
import Relation;

list[str] sources =
	//["antlr","dcg","ecore","emf","jaxb","om","python","rascal-a","rascal-c","sdf","txl","xsd"];
	//["emf","jaxb","om","rascal-c","sdf","xsd"];
	["txl"];
	// atom/expr: antlr, dcg
	// arg/string: ecore, rascal-a
	// good: emf, jaxb, om, rascal-c, sdf, xsd
	// multiroot: python
	// unknown: txl

bool conflicted(NameMatch a, NameMatch b)
{
	//println("a = <a>");
	//println("b = <b>");
	//println("a o b = <invert(a) o b>");
	return !isEmpty(invert(a) o b);
}

BGFProduction getSingleProd(str n, BGFProdList ps)
{
	//BGFProdList ps1 = [*prodsOfN(n,ps) | n <- ns]; // Y SO complicated?
	BGFProdList ps1 = prodsOfN(n,ps);
	if (len(ps1)!=1)
		throw "Grammar not in ANF with <ps1>";
	else
		return ps1[0];
}

BGFProduction unwind(BGFProduction p1, BGFProdList ps1)
	= (production(_,_,nonterminal(n)) := p1 && n in definedNs(ps1))? getSingleProd(n,ps1) : p1;

bool strongEq(BGFProduction p1, BGFProdList ps1, BGFProduction p2, BGFProdList ps2)
	= analyse::Prodsigs::eqps(unwind(p1,ps1),unwind(p2,ps2));

//bool strongEq(BGFProduction p1, BGFProdList ps1, BGFProduction p2, BGFProdList ps2)
//{
//	println("<unwind(p1,ps1)> vs <unwind(p2,ps2)>");
//	s1 = analyse::Prodsigs::makesig(unwind(p1,ps1));
//	s2 = analyse::Prodsigs::makesig(unwind(p2,ps2));
//	println("<s1> vs <s2>");
//	println("EQ: <analyse::Prodsigs::eqps(s1,s2)>; EQUIV: <analyse::Prodsigs::weqps(s1,s2)>");
//	return analyse::Prodsigs::eqps(unwind(p1,ps1),unwind(p2,ps2));
//}

bool weakEq(BGFProduction p1, BGFProdList ps1, BGFProduction p2, BGFProdList ps2)
	= analyse::Prodsigs::weqps(unwind(p1,ps1),unwind(p2,ps2));

tuple[NameMatch,BGFProdList,BGFProdList]
	matchProds(NameMatch known, BGFProdList mps, BGFProdList sps)
{
	BGFProdList ps1 = [*prodsOfN(n,mps) | <n,_> <- known];
	BGFProdList ps2 = [*prodsOfN(n,sps) | <n,_> <- known];
	println("Trying to match production rules:");
	for (p <- ps1) println(" <pp(p)>\t <pp(analyse::Prodsigs::makesig(p))>");
	println("   vs");
	for (p <- ps2) println(" <pp(p)>\t <pp(analyse::Prodsigs::makesig(p))>");
	// check for strong prodsig-equivalence first
	println("Looking for strong equivalence.");
	//println("<pp(analyse::Prodsigs::makesig(p1))> vs <pp(analyse::Prodsigs::makesig(p2))>");
	//println("Equality: <analyse::Prodsigs::eqps(p1,p2)>; equivalence: <analyse::Prodsigs::weqps(p1,p2)>");
	for (p1 <- ps1, p2 <- ps2, strongEq(p1,mps,p2,sps))
	{
		nm = analyse::Prodsigs::makenamematch(p1,p2);
		//println("Found prodsig-equivalent production rules:\n <pp(p1)>   &\n <pp(p2)>");
		println("Found prodsig-equivalent production rules: <pp(nm)>");
		p1a = unwind(p1,mps);
		p2a = unwind(p2,sps);
		if (p1 != p1a && p1 != p2a)
		{
			nm2 = analyse::Prodsigs::makenamematch(p1a,p2a);
			println("More prodsig-equivalent production rules: <pp(nm2)>");
			nm += nm2;
		}
		truenm = {};
		for (<a,b> <- nm-known)
			if ((a==b) && a in known<0>)
				println("Reconfirmed <a>");
			else
			{
				println("Will assume that <a> == <b>");
				truenm += <a,b>;
			}
		if (conflicted(truenm,known))
			println("Naming conflict, reconsider.");
		else
			return <truenm, mps - p1, sps - p2>; 
	}
	// check for weak prodsig-equivalence now
	println("Looking for weak equivalence.");
	for (p1 <- ps1, p2 <- ps2, weakEq(p1,mps,p2,sps))
	{
		nm = analyse::Prodsigs::makenamematch(p1,p2);
		//println("Found weakly prodsig-equivalent production rules:\n <pp(p1)>   &\n <pp(p2)>");
		println("Found weakly prodsig-equivalent production rules: <pp(nm)>");
		p1a = unwind(p1,mps);
		p2a = unwind(p2,sps);
		if (p1 != p1a && p1 != p2a)
		{
			nm2 = analyse::Prodsigs::makenamematch(p1a,p2a);
			println("More prodsig-equivalent production rules: <pp(nm2)>");
			nm += nm2;
		}
		truenm = {};
		for (<a,b> <- nm-known)
			if ((a==b) && a in known<0>)
				println("Reconfirmed <a>");
			else
			{
				println("Will assume that <a> == <b>");
				truenm += <a,b>;
			}
		if (conflicted(truenm,known))
			println("Naming conflict, reconsider.");
		else
		{
			//if (!isEmpty(nm-known))
			//	println("Will assume that <pp(nm)> after <pp(known)>");
			//return <nm, mps - p1, sps - p2>;
			
			return <truenm, mps - p1, sps - p2>; 
		} 
	}
	//println(assumeRenamings(servant,known));
	println("No match found.");
}

BGFProdList assumeRenamings(BGFProdList where, NameMatch naming)
{
	BGFProdList ps = where;
	for (<n1,n2> <- naming)
		if (n1 != n2 && n2 in allNs(ps) && n1 != "")
			ps = transform(forward([renameN_renameN(n2,n1)]),grammar([],ps)).prods;
	return ps;
}

//BGFGrammar
NameMatch converge(BGFGrammar master, BGFGrammar servant)
{
	println("Master grammar:\n<pp(master)>");
	CBGFSequence acbgf = []; // normalisation
	CBGFSequence ncbgf = []; // nominal matching
	CBGFSequence scbgf = []; // structural matching
	//println("Input: <src>");
	println("Normalising the grammar...");
	acbgf = normal::ANF::normalise(servant);
	servant = transform(forward(acbgf),servant);
	//iprintln(ncbgf);
	println("Servant grammar:\n<pp(servant)>");
	println("Starting with the root: <master.roots>, <servant.roots>.");
	// TODO: multiple roots
	NameMatch known = {<master.roots[0],servant.roots[0]>};
	ps1 = master.prods;
	ps2 = assumeRenamings(servant.prods, known);
	int cx = 10;
	//println("Let\'s go!\n<isEmpty(ps1)>");
	while(!isEmpty(ps1))
	{
		print("...<cx>...");
		cx -= 1;
		<nnm,ps1a,ps2a> = matchProds(known, ps1, ps2);
		ps1 = ps1a;
		ps2 = assumeRenamings(ps2a,nnm);
		known = known + nnm;
		if (cx==0)
			break;
	}
	println("Done with the grammar.");
	println("Nominal matching: <pp(known)>");
	for (<a,b> <- known)
		if (a==b)
			;
		elseif (a=="")
			;
		else
			ncbgf += renameN_renameN(b,a);
	// Assume nominal matching!
	servant = transform(forward(ncbgf),servant);
	println("<pp(servant)>");
	//return servant;
	return known;
}

public void main()
{
	//Signature s1 = {<"a",fpnt()>,<"b",fpnt()>,<"c",fpmany([fpnt(),fpplus()])>,<"z",fpmany([fpnt(),fpplus()])>};
	//Signature s2 = {<"x",fpnt()>,<"y",fpmany([fpnt(),fpplus()])>};
	//println("\t<pp(s1)>\nvs\n\t<pp(s2)>");
	//println("<analyse::Prodsigs::makenamematches(s1,s2)>");
	//return;
	master = loadSimpleGrammar(|home:///projects/slps/topics/convergence/guided/bgf/master.bgf|);
	for (src <- sources)
	{
		//BGFGrammar res = 
		NameMatch res = converge(master,loadSimpleGrammar(|home:///projects/slps/topics/convergence/guided/bgf/<src>.bgf|));
		//writeBGF(res,|home:///projects/slps/topics/convergence/guided/bgf/<src>.almost.bgf|);
		writeFile(|home:///projects/slps/topics/convergence/guided/bgf/<src>.almost.bnf|,replaceAll(pp(res),", ",",\n"));
	}
	println("Done.");
}

BGFGrammar loadSimpleGrammar(loc l)
{
	BGFGrammar g = readBGF(l), q;
	//return g;
	 //we simplify our life by converting built-in types ("values") to regular nonterminals
	if (/val(string()) := g)
		q = transform([replace(val(string()),nonterminal("STRING"),globally())],g);
	else
		q = g;
	if (/val(integer()) := q)
		q = transform([replace(val(integer()),nonterminal("INTEGER"),globally())],q);
	//return <g,q>;
	return q;
}