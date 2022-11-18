# Summary
Creates pdf voting vouchers from a QR in .svg and a background template in .pdf. The voting code is extract from the .svg file name.

# Usage
Command line:
```
/QRstamp.sh background-cat.pdf $(find ./svg -name "0x0438*" | sort -k2 -n -t_)
```

* It takes ~10 min to process 1000

# Dependencies
Command line:
```
sudo apt install pexec librsvg2-bin texlive-extra-utils
sudo snap install pdftk
```

# Tips

## rename svg files
Command line:
```
 DIR="Process_20220301_censusTest_04_01_QRs"; for i in $(ls ${DIR}); do mv ${DIR}/$i ${DIR}/$(echo $i | cut -d- -f2).svg; done
```

## Blank background
Command line
```
echo '\shipout\hbox{}\end' | pdftex -jobname=background
rm background.log
```

## Adding text
Edit script:
```
echo "Codi QR de votació"| iconv -f utf-8 -t iso-8859-1 | enscript -X 88591
```

# TODO
## Use '/tmp'
