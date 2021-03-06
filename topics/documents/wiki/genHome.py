#!/usr/local/bin/python
# -*- coding: utf-8 -*-

h = [
	'Concepts, languages, techniques',
	'Mappers',
	'Tools, libraries, functions',
	'Transformation operators',
	'Grammar mutations'
	]

c = [
	['BGF', 'XBGF', 'CBGF', 'EXBGF', 'MegaL', 'LDF', 'XLDF', 'EDD',
	'ANF|Abstract Normal Form', 'LCI', 'BTF', 'LCF', 'Rascal', 'Prolog', 'XML', 'XSD', 'Factorial Language', 'Java Language Specification', 'Grammarware', 'Grammar in a broad sense', 'Metaprogramming', 'Grammar programming', 'Grammar convergence', 'Guided grammar convergence', 'Negotiated transformation']
	,
	['ANTLR2BGF', 'AsFix2BTF', 'BGF2BNF', 'BGF2DMS', 'BGF2dot', 'BGF2HTML', 'BGF2Rascal', 'BGF2SDF', 'BGF2TeX', 'BGF2TXL', 'BTF2BGF', 'BTF2source', 'CBGF2', 'CBGF2CBNF', 'CBGF2XBGF', 'DCG2BGF', 'Ecore2BGF', 'EDD2Rascal', 'EXBGF2XBGF', 'HTML2BGF', 'Java2BGF', 'LDF2BGF', 'LDF2HTML', 'LDF2PDF', 'LDF2SET', 'LDF2TEX', 'LLL2BGF', 'PDF2BGF', 'Python2BGF', 'Rascal2BGF', 'RascalADT2BGF', 'RascalSyntax2BGF', 'SDF2BGF', 'Spec2BGF', 'TXL2BGF', 'XBGF2CBGF', 'XBGF2HTML', 'XBGF2TeX', 'XBGF2XBNF', 'XML2BTF', 'XSD2BGF', 'XSD2LDF', 'ADT2PP', 'XBGF2Rascal']
	,
	['AppendXBGF', 'BGFlc', 'BGFover', 'BGFpp', 'BGFreformat', 'BuildTestSetXML', 'CBGF', 'CheckBGF', 'CheckXBGF', 'EXBGFover', 'ExtractOver', 'FindH', 'GBTF', 'GDT|Grammar Diff Tool', 'LCI', 'LDinclude', 'MergeBGF', 'NormBGF', 'PlotBGF', 'REPP', 'ShowBGF', 'ShowG', 'ShowPNF', 'ShowRootProds', 'ShowT', 'ShowX', 'ShowXBGF', 'ShowXSD', 'TDT', 'TnB', 'TokenOverview', 'Validate', 'XBGF', 'XBGFinfo', 'XBGFlc', 'XBGFover', 'XBGFsliced', 'XBTF', 'XLLL', 'CheckBTF', 'ImplodeBTF', 'ReadBGF', 'ReadBTF', 'ReadXBGF', 'WriteBGF', 'WriteBTF', 'WriteLDF', 'WriteXBGF', 'WriteΞBGF']
	,
	['abridge', 'abstractize', 'addH', 'addV', 'anonymize', 'appear', 'chain', 'concretize', 'deanonymize', 'define', 'designate', 'detour', 'deyaccify', 'disappear', 'distribute', 'downgrade', 'dump', 'eliminate', 'equate', 'extract', 'factor', 'fold', 'horizontal', 'importG', 'inject', 'inline', 'introduce', 'lassoc', 'massage', 'narrow', 'permute', 'project', 'rassoc', 'redefine', 'removeH', 'removeV', 'renameT', 'renameL', 'renameN', 'renameS', 'replace', 'undefine', 'unfold', 'unite', 'unlabel', 'upgrade', 'vertical', 'widen', 'yaccify', 'bypass', 'concatT', 'splitT', 'splitN', 'reroot', 'unchain', 'addC', 'clone', 'iterate']
	,
	['ANF|Abstract Normal Form', 'AbridgeAll', 'ChainMixed', 'ConcatAllT', 'DeanonymizeAllN', 'DefineMin', 'DesignateAll', 'DeyaccifyAll', 'DistributeAll', 'EliminateTop', 'EquateAll', 'FoldG', 'FoldMax', 'HorizontalAll', 'InlineLazy', 'InlineMax', 'InlinePlus', 'InsertLayout', 'IterateAllL', 'IterateAllP', 'LAssocAll', 'LYaccifyAll', 'RAssocAll', 'RYaccifyAll', 'RelaxNG2BGF', 'RenameAllL', 'RenameAllN', 'RenameAllS', 'RenameAllT', 'Reroot2top', 'Retire iterations', 'Retire lazy', 'Retire seplists', 'RetireLs', 'RetireSs', 'RetireTop', 'RetireTs', 'Scope', 'Skeletonise', 'SplitAllT', 'SubGrammar', 'TypeI', 'UnchainAll', 'UnfoldMax', 'VerticalAll', 'VerticalDistributeAll']
	]

l = len(h)
w = [4+max(len(h[i]),max(map(len,c[i]))) for i in range(0,l)]
c = map(sorted,c)
d = max(map(len,c))

f = open('texts/Home.md', 'w')
f.write('''<center>
![SLPS](http://grammarware.github.com/logos/slps.200.png)
# [Software Language Processing Suite](http://slps.github.com)
# Documentation Wiki
# ([[Statistics]])
</center>

''')
f.write('|**'+'**|**'.join(h)+'**|\n')
f.write('|'+'|'.join(['-'*v for v in w])+'|\n')
for i in range(0,l):
	while(len(c[i])<d): c[i].append('')
f.write('\n'.join(['|'+'|'.join([c[i][j] and ('[['+c[i][j]+']]').center(w[i]) or ''.center(w[i]) for i in range(0,l)])+'|' for j in range(0,d)]).replace('CBGF','ΞBGF').replace('CBNF','ΞBNF'))
f.close()
