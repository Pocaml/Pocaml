driver : parser.cmo scanner.cmo driver.cmo
	ocamlc -w A -o driver $^

%.cmo : %.ml
	ocamlc -w A -c $<

%.cmi : %.mli
	ocamlc -w A -c $<

scanner.ml : scanner.mll
	ocamllex $^

parser.ml parser.mli : parser.mly
	ocamlyacc $^

driver.out : driver driver.tb
	./driver < driver.tb > driver.out

# Depedencies from ocamldep
driver.cmo : scanner.cmo parser.cmi ast.cmi
driver.cmx : scanner.cmx parser.cmx ast.cmi
parser.cmo : ast.cmi parser.cmi
parser.cmx : ast.cmi parser.cmi
scanner.cmo : parser.cmi
scanner.cmx : parser.cmx


clean :
	rm -rf zipWith3.out wordcount.ml wordcount wordcount.out \
	*.cmi *.cmo parser.ml parser.mli scanner.ml calc.out calc
