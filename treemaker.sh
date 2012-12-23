#/bin/bash

cd ~/testing/chpathn
if [ $? -eq 0 ]; then
	mkdir "./ leadspace"
	touch "./ leadspace/ leadspaceFil"
	mkdir "./	leadtab"
	touch "./	leadtab/	leadtabFil"
	mkdir "./-leaddash"
	touch "./-leaddash/-leaddashFil"
	mkdir "./|#leadsymbs"
	touch "./|#leadsymbs/¬½leadsymbs"
	mkdir "./trailspace "
	touch "./trailspace /trailspaceFil "
	mkdir "./trailtab	"
	touch "./trailtab	/trailtabFil	"
	mkdir "./middle space"
	touch "./middle space/middle space Fil"
	touch "âàáäêèéëîìíïôòóöûùúü"
	mkdir "./middle space/middle space2/"
	touch "./middle space/middle space2/middle space2 Fil"
fi
