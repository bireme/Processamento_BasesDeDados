#------------------------------------------------------------------------#
# GENMDLAU - Procedimento para geracao do invertido de AUtor. 
#
# Marcelo - 01/03/94 
# Excecucao - Processamento
# Sintaxe: genmdlScieloID <dbn_mdlbb> <loopcheck>
#    onde:
#          <dbn_mdlbb> base de dados MEDLINE sem ABSTRACT (mdlbb).
#          <loopcheckp> intervalo para checks.
#
#-----------------------------------------------------------------------#

TPR="start"
. log

echo
echo "Inicio: genmdlScieloID"
echo

if [ "$#" -ne 2 ]
then 
   TPR="fatal"
   MSG="use: genmdlScieloID <dbn_mdlbb> <loopcheck>"
   . log 
fi

# -------------------------------------------------------------------- #
# WRKAU.FST 
# -------------------------------------------------------------------- #
cat>mdlScieloID.fst<<!
968 0 (if v968.1='S' and v968*5.1='-' then v968^*/ fi)
!

TPR="iffatal"
MSG="Erro: gentree AU"
gentree $1 mdlScieloID $2
. log

rm  mdlScieloID.fst
rm  mdlScieloID.lk1 mdlScieloID.lk2

echo
echo "Inicio: genmdlScieloID"
echo

TPR="end"
. log
