#!/bin/bash

## ./QRstamp background.pdf 0x0432*.svg
##
## In weighted voting, for sorted QRs, with key_weight_code.svg:
##   ./QRstamp background.pdf $(find ./svg -name "0x04*" | sort -k2 -n -t_)

## Command line arguments
if [[ $# -lt 2 ]] ; then
    echo 'Error: At least 2 arguments expected (e.g. background.pdf 0x0432*.svg)'
    exit 1
fi

## Background page
BACKGROUND=$1
shift 1

## Paper size
PAPER=

## Offset "right up"
## TODO use variables
##	doesn't work with "0.0cm 1.9cm", "-0cm 1.9cm"
##	https://unix.stackexchange.com/questions/131766/why-does-my-shell-script-choke-on-whitespace-or-other-special-characters
#	rsvg-convert -f pdf ${file} | pdfjam --quiet --paper 'a5paper' --scale 0.6 --offset \'"${OFFESTQR}"\' --outfile ${TEMPDIR}/QR-${filename}.pdf
OFFESTQR="0cm 1.9cm"
OFFSET1="3.9cm -18.25cm"
OFFSET2="6.25cm -17cm"

## TODO pdfjam crashes with /tmp
#TEMPDIR="/tmp/QRstamp"
TEMPDIR=tmp

mkdir -p ${TEMPDIR}

stamper () {
	file=$1
	filename=$(basename ${file} .svg)
echo ${file}
		
	## QR
	rsvg-convert -f pdf ${file} | pdfjam --quiet --paper 'a4paper' --scale 0.6 --offset '0cm 3cm' --outfile ${TEMPDIR}/QR-${filename}.pdf

	## col1 - voting power
	echo ${filename} | cut -d "_" -f 2 | enscript --quiet -M a4 -B -f Courier-Bold28 -o - | ps2pdf - | pdfjam --quiet --paper 'a4paper' --scale 1 --offset '7.4cm -24.1cm' --outfile ${TEMPDIR}/${filename}-pdfjam.pdf
	pdftk ${TEMPDIR}/QR-${filename}.pdf stamp ${TEMPDIR}/${filename}-pdfjam.pdf output ${TEMPDIR}/col_${filename}.pdf
	rm ${TEMPDIR}/QR-${filename}.pdf

	## col2 - code
	echo ${filename} | cut -d "_" -f 3 | enscript --quiet -M a4 -B -f Courier-Bold32 -o - | ps2pdf - | pdfjam --quiet --paper 'a4paper' --scale 1 --offset '5.5cm -22.7cm' --outfile ${TEMPDIR}/${filename}-pdfjam.pdf
	pdftk ${TEMPDIR}/col_${filename}.pdf stamp ${TEMPDIR}/${filename}-pdfjam.pdf output ${TEMPDIR}/coladd_${filename}.pdf
	rm ${TEMPDIR}/col_${filename}.pdf
	mv ${TEMPDIR}/coladd_${filename}.pdf ${TEMPDIR}/col_${filename}.pdf

	rm ${TEMPDIR}/${filename}-pdfjam.pdf
}

export -f stamper
export TEMPDIR

paging=""

for file in $@
do
	filename=$(basename ${file} .svg)	
	paging="${paging}${TEMPDIR}/col_${filename}.pdf "
done

pexec -p "$(echo $@)" -e file -o - -u -1 -s /bin/bash -c -- \
	'stamper "${file}"'

pdfjam ${paging} --quiet --paper 'a4paper' --outfile /dev/stdout | pdftk - background ${BACKGROUND} output - | pdfjam --quiet --paper 'a4paper' --pdftitle "Vocdoni" --pdfauthor "Aragon Labs AG" --pdfsubject "Voting credentials" --pdfkeywords "hello@aragonlabs.com" --outfile QRs.pdf

rm ${paging}

rmdir -p ${TEMPDIR}

## TODO --keepinfo doesn't work
pdfjam --quiet --paper 'a4paper' --pdftitle "Vocdoni" --pdfauthor "Aragon Labs AG" --pdfsubject "Voting credentials" --pdfkeywords "hello@aragonlabs.com" --nup 2x1 --suffix 2up --landscape QRs.pdf
pdfjam --quiet --paper 'a4paper' --pdftitle "Vocdoni" --pdfauthor "Aragon Labs AG" --pdfsubject "Voting credentials" --pdfkeywords "hello@aragonlabs.com" --nup 2x2 --suffix 4up QRs.pdf
