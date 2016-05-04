# ------------------------------------------------------------------------------------------- #
#
# GENDP.SH - Gera lista de Datas de Publicacao com numero de registros por fita
#
# ------------------------------------------------------------------------------------------- #
# Chico       - 29/03/2001
# Execucao    - processamento
# chamada     - ../tpl.mdl/gendp.sh
# Observacoes - Os arquivos ISO devem estar no diretorio fasea
# ------------------------------------------------------------------------------------------- #

TPR="start"
. log

if [ $# -ne 2 ]
then

   echo "Sintaxe: ../tpl.mdl/gendp.sh <baseline/update> <ANO_CORRENTE_2_digitos>"
   exit
fi

echo
echo "Inicio: gendb.sh $1 $2" 
echo

# ------------------------------------------------------------------------------------------- #
# Gera FST a ser utilizada no processo

echo "1 0 v1" > work.fst

# ------------------------------------------------------------------------------------------- #
# Obtem uma lista dos arquivos a serem operados

ls i*b.mst|cut -f1 -d\. > work.lst

# ------------------------------------------------------------------------------------------ #
# verifica existencia da lista de arquivos ISO e da FST

if [ ! -s work.lst ]
then

   TPR="fatal"
   MSG="Error: work.fst not found"
   . log

fi

# ------------------------------------------------------------------------------------------- #
# Comanda a execucao para cada item da lista gerada
# ------------------------------------------------------------------------------------------- #

COUNT=1
cp work.lst ./file_tmp
wc -l work.lst|sed "s/tmp_file//">tmp1
mx seq=tmp1 "pft=f(val(v1),1,0)/" now>tmp
read LEN < tmp

while
    [ $COUNT -le $LEN ]
do
    NAMEIN=`head -$COUNT work.lst|tail -1|cut -f3 -d/ | cut -f1 -d.`
    echo "Processando $NAMEIN..."

    # -------------------------------------------------------------------- #
    # Obtem os anos das Datas de Publicacao numa base de dados

    TPR="iffatal"
    MSG="erro na geracao de $NAMEIN.rdp Master File"
    mx $NAMEIN "pft=v354.4/" -all now > $NAMEIN.rdp
    . log

    TPR="iffatal"
    MSG="erro na geracao da base work de $NAMEIN"
    mx seq=$NAMEIN.rdp create=work -all now
    . log

    # -------------------------------------------------------------------- #
    # Indexa para obter uma lista com os anos e quantidade de ocorrencias

    TPR="iffatal"
    MSG="erro invertendo a base work de $NAMEIN"
    mx work fst=@ fullinv=work
    #gentree work work 100000 no
    . log

    # -------------------------------------------------------------------- #
    # Obtem uma lista com qtd de ocorrencia para cada ano listado

    mz work +all now | grep + > work.txt

    #if [ ! -s work.txt ]
    #then

    #  TPR="fatal"
    #  MSG="Error: A fita $NAMEIN nao contem qqr DP"
    #  . log

    #fi

    # -------------------------------------------------------------------- #
    # Monta uma base com com as qtd de ocorrencias e outra com os anos

    TPR="iffatal"
    MSG="Error: Nao pode criar worked de $NAMEIN"
    cut -f2 -d: work.txt | cut -f2 -d/ > work.seq
    mx seq=work.seq -all now create=worked
    . log

    TPR="iffatal"
    MSG="Error: Nao pode criar work final de $NAMEIN"
    cut -c4-7 work.txt > work.dp
    mx seq=work.dp -all now create=work
    . log

    # -------------------------------------------------------------------- #
    # Gera uma lista com ano e ocorrencias no ano

    TPR="iffatal"
    MSG="Error: Nao pode gerar item da lista de DP de $NAMEIN"
    mx work "pft=v1,' - ',ref(['worked']mfn,v1)/" -all now > $NAMEIN.dp
    . log

#    if [ ! -s $NAMEIN.dp ]
#    then
#
#       TPR="fatal"
#       MSG="Error: Lista $NAMEIN.dp gerada nao contem dados"
#       . log
#    fi

    COUNT=`expr $COUNT + 1`

done

rm worked.xrf worked.mst
rm work.xrf work.mst work.fst work.cnt work.dp work.iyp work.l* work.n* work.seq work.txt

# Gera relatorio MDLback.TXT (Nro de registros por ano e Total) e LABBAK??

cat *.rdp > conta.lst
echo
echo "Verificando anos do MEDLINE $1..."
cat conta.lst|sort -u > anos.lst
ANO_CURR=`tail -1 anos.lst`

TOTAL_REC=0
COUNT=1
cp anos.lst ./tmp_file
wc -l anos.lst|sed "s/tmp_file//">tmp1
mx seq=tmp1 "pft=f(val(v1),1,0)/" now>tmp
read LEN < tmp

rm tmp tmp1

if [ -f mdl$1.txt ]
then
   rm mdl$1.txt
fi

while
    [ $COUNT -le $LEN ]
do

    ANO=`head -$COUNT anos.lst|tail -1`    
    NRO=`cat conta.lst|grep $ANO|wc -l`    
    Name_ANO_2=`echo $ANO |cut -c3-` 
    ANO_2=`echo $ANO`
    echo "$ANO |  $NRO" >> mdl$1.txt
    echo --------------- >> mdl$1.txt
     
    #if [ "$1" = "back" -a ! "$ANO_2" = "$ANO_CURR" ]
    if [ "$1" = "baseline" ]
    then
       grep $ANO *.dp|cut -f1 -d\.|sort -u > "labbak"$Name_ANO_2"i"
       grep $ANO *.dp|cut -f1 -d\.|sed "s/imd/bmd/"|sort -u > "labbak"$Name_ANO_2"b"
    fi
     
    if [ "$1" = "update"  ]
    then
       ls imd?????.dp|cut -f1 -d\.|sort -u > labsdi"$2"i
       ls imd?????.dp|cut -f1 -d\.|sed "s/imd/bmd/"|sort -u > labsdi"$2"b
    fi

    TOTAL_REC=`expr $TOTAL_REC + $NRO`
    COUNT=`expr $COUNT + 1`

done

#rm conta.lst
#rm anos.lst

echo "TOT  |   $TOTAL_REC" >> mdl$1.txt


#rm *.rdp
#rm *.dp
rm tmp_file


# Checa se o nro registros do Browse eh igual ao Invertido
COUNT=1
ls bmd*.xrf|cut -c2-|cut -f1 -d. > balsdiall
wc -l balsdiall>tmp1
mx seq=tmp1 "pft=f(val(v1),1,0)/" now>tmp

read LEN < tmp
rm tmp tmp1

while
     [ $COUNT -le $LEN ]
do
     head -$COUNT balsdiall|tail -1|cut -f1 -d"|" > tmp
     read NAMEIN < tmp
     rm tmp
     . scrmax b$NAMEIN
     B=`echo $MAXMFN`
     . scrmax i$NAMEIN
     I=`echo $MAXMFN`
     if [ $B -ne $I ]
     then
        TPR="fatal"
        MSG="$NAMEIN - Browse diferente Inverted"
        . log
     fi
     echo "check $NAMEIN...  OK"
     COUNT=`expr $COUNT + 1`
done
unset COUNT
rm balsdiall 

TPR="end"
. log

