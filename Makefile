all: rhythms fills

rhythms: PngCroper.exe
	mkdir rhythms
	ocaml LyGenerator.ml rhythms.db rhythms
	cd rhythms; for f in `ls *.ly`; do lilypond --png $$f; done
	for f in `ls rhythms/*.png`; do ./PngCroper.exe $$f; done

fills: PngCroper.exe
	mkdir fills
	ocaml LyGenerator.ml fills.db fills
	cd fills; for f in `ls *.ly`; do lilypond --png $$f; done
	for f in `ls fills/*.png`; do PngCroper.exe $$f; done

PngCroper.exe:
	dune build PngCroper.exe
	cp _build/default/PngCroper.exe PngCroper.exe

clean:
	rm -rf rhythms
	rm -rf fills
	rm -f PngCroper.exe
	
