#!/bin/bash

NOME_REPORT=$1
if [ -f $NOME_REPORT ];then
rm $NOME_REPORT
else
touch $NOME_REPORT
fi

for i in *fastq; do
echo "================" >> $NOME_REPORT
echo $i >> $NOME_REPORT 
echo "----------------" >> $NOME_REPORT
#numero reads
echo "number of reads" >> $NOME_REPORT
cat $i | grep @ | wc -l >> $NOME_REPORT 
#numero basi buone
echo "number of high quality (F) bases" >> $NOME_REPORT 
cat $i | sed 's/[^F]//g' | tr -d '\n' | wc -c >> $NOME_REPORT
#numero adattatori unici
echo "number of barcodes" >> $NOME_REPORT
cat $i | grep @ | sed "s/.*1:N:0://" | sort | uniq | wc -l >> $NOME_REPORT
done

