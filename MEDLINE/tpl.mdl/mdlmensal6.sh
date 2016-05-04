# ---------------------------------------------------- #
# Emparalhamento de registros das bases BROWSE e INDEX
# ---------------------------------------------------- #
# Execucao: diretorio do ano, p. ex.: m02.mdl
#  Chamada: mdlmensal6.sh <dbn_bws> <dbn_idx>
#    Saida: <dbn_idx> emparelhada com <dbn_bws>
#

TPR="start"
. log

if [ "$#" -ne 2 ]
then 
   TPR="fatal"
   MSG="use: mdlmensal6.sh <dbn(mdl02)> <dbn_mdlbb(mdlbb02)>"
   . log 
fi

echo "999 0 (v999^3/)" > $1.fst

gentree $1 $1 200000 no


# Gera a estrutura do MST de INDEX
echo "mstxl=64G" > mdlxl.par
CIPAR=mdlxl.par
export CIPAR

TPR="iffatal"
MSG="erro na geracao da estrutura do Master de INDEX"
mx tmp count=0 now create=$2"f"
. log

# Elimina registros presente em $1 e inexistentes em $2
TPR="iffatal"
MSG="Error: $2 nao encontrada"
mx $2 "join=$1,1370:370=v969/" "proc=if a(v32001^m) then 'd*' else 'd32001d1370' fi" append=$2"f" -all now tell=50000
. log

#TPR="iffatal"
#MSG="Error: $1 not found"
#mx $2"f" "proc=if v668<>'Completed'  then 'd*' fi" create=$2 -all now tell=50000
#. log

# Repoe denominacao original da base de dados
mv $2"f".mst $2.mst
mv $2"f".xrf $2.xrf

rm mdlxl.par
rm $1.iyp $1.ly? $1.n0? $1.cnt $1.lk? $1.fst
rm $2.iyp $2.ly? $2.n0? $2.cnt $2.lk? $2.fst

TPR="end"
. log
