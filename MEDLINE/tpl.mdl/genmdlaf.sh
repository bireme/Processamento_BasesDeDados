#------------------------------------------------------------------------#
# GENMDLAU - Procedimento para geracao do invertido de AUTOR PESS 
#
# Sintaxe: genmdlaf.sh <dbn> <loopcheck>
#   onde <dbn> -> base de dados
#        <loopcheck> -> loop registros onde sera efetuado o check
#
#-----------------------------------------------------------------------#

TPR="start"
. log

if [ "$#" -ne 1 ]
then 
   TPR="fatal"
   MSG="use: genmdlaf.sh <dbn>"
   . log 
fi

# -------------------------------------------------------------------- #
# indice de Afiliacao-Autor-MEDLINE
# -------------------------------------------------------------------- #
# FST
#echo "1 0 v999^v/" >  $1af.fst
#echo "1 4 v999^v/" >> $1af.fst
echo "1 0 (v372^1/)" >  $1af.fst
echo "1 4 (v372^1/)" >> $1af.fst

TPR="iffatal"
MSG="Erro: geracao CNT $1af"
#mx $1 gizmo=../tabs/diacux gizmo=../tabs/tab142b "fst=@$1af.fst" fullinv=$1af -all now tell=1000000
mx $1 "fst=@$1af.fst" fullinv/ansi=$1af -all now tell=1000000
. log

rm $1af.fst
rm $1af.lk1
rm $1af.lk2

TPR="end"
. log
