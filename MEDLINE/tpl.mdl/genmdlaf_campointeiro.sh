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
   MSG="use: genmdlaf.sh <DP>"
   . log 
fi

# -------------------------------------------------------------------- #
# indice de Afiliacao-Autor-MEDLINE
# -------------------------------------------------------------------- #
# FST
echo "1 0 (v1372/)" >  mdlbb$1afIB.fst

TPR="iffatal"
MSG="Erro: geracao CNT mdlbb$1afIB"
mx mdlbb$1 "proc='d*',|a1372|v372^1.150||" create=mdlbb$1_1372 -all now tell=100000
. log
mx mdlbb$1_1372 "proc=if v1372:',' then 'Gsplit=1372=,' fi" create=mdlbb$1_1372_Gsplit -all now tell=100000
. log
mxcp mdlbb$1_1372_Gsplit create=mdlbb$1_1372_Gsplit_mxcp clean tell=100000
. log
mx mdlbb$1_1372_Gsplit_mxcp gizmo=../tabs/gButantan,1372 create=mdlafIB -all now tell=100000
. log

TPR="iffatal"
MSG="Erro: geracao CNT $1af"
mx mdlafIB "fst=@mdlbb$1afIB.fst" fullinv/ansi=mdlafIB -all now tell=100000
. log

TPR="end"
. log
