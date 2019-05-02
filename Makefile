all: rhythms fills

rhythms:
	mkdir rhythms
	ocaml LyGenerator.ml rhythms.db rhythms
	cd rhythms; for f in `ls *.ly`; do lilypond --png $$f; done

fills:
	mkdir fills
	ocaml LyGenerator.ml fills.db fills
	cd fills; for f in `ls *.ly`; do lilypond --png $$f; done

clean:
	rm -rf rhythms
	rm -rf fills
	
