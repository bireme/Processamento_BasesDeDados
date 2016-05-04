# --------------------------------------------------- #
# Eliminacao de registros repetidos do proprio master
# --------------------------------------------------- #
# Execucao: diretorio do ano, p. ex.: m02.mdl
#  Chamada: mdlmensal4.sh <dbn>
#    Saida: <dbn> sem registros repetidos
#

TPR="start"
. log

if [ "$#" -ne 1 ]
then 
   TPR="fatal"
   MSG4="use: mdlmensal4.sh <dbn(mdlbb02)>"
   . log 
fi

# G4era a estrutura do MST de INDEX
echo "mstxl=64G" > mdlxl.par
CIPAR=mdlxl.par
export CIPAR

TPR="iffatal"
MSG4="erro na geracao da estrutura do Master de INDEX"
mx tmp count=0 now create=$1"t"
. log

TPR="iffatal"
MSG4="Erro: Deleta ausentes 969"
$LINDG4/mx cipar=mdlxl.par $1 "proc=if a(v969) then 'd*' fi" -all now append=$1"t" tell=100000
. log
mv $1"t".xrf $1.xrf
mv $1"t".mst $1.mst


echo "969 0 v969/" > $1.fst
TPR="iffatal"
MSG4="Erro: gentree $1"
$LINDG4/mx $1 fst=@ fullinv=$1 -all now tell=400000
#gentree $1 $1 100000 no
. log

rm $1.lk? $1.fst

echo "Join de $1 com $1"
TPR="iffatal"
MSG4="Erro: join $1 com $1"
$LINDG4/mx $1 "join=$1,1969:969=v969/" "pft=lw(9999),(v32001^m+|+|)/" -all now tell=500000>m0
. log
grep "\+" m0>m1
rm m0

sort -u m1 -o m2
rm m1
mx seq=m2 create=m2 -all now
mxcp m2 create=m3 repeat=+
rm m2 m2.*

TPR="iffatal"
MSG4="Erro: geracao TEMP.SH"
mx m3 lw=0 "pft=(|$LINDG4/mx $1 from=|v1| \"proc='d*'\" count=1 now -all copy=$1|,if iocc+1 >= nocc(v1) then break fi/)/" -all now tell=10000 > temp.sh
. log
chmod 755 temp.sh
rm m3.*

# G4era a estrutura do MST de INDEX
echo "mstxl=64G" > mdlxl.par
CIPAR=mdlxl.par
export CIPAR

TPR="iffatal"
MSG4="erro na geracao da estrutura do Master de INDEX"
$LINDG4/mx tmp count=0 now create=$1"t"
. log

# Elimina os MFNs repetidos
./temp.sh

# Passa a base de dados a limpo
TPR="iffatal"
MSG4="Erro ao recriar a base sem repeticoes"
$LINDG4/mx $1 append=$1"t" -all now tell=600000
. log

# Repoe denominacao original da base de dados
mv $1"t".xrf $1.xrf
mv $1"t".mst $1.mst

rm $1.iyp $1.ly? $1.n0? $1.cnt $1.lk? temp.sh mdlxl.par

TPR="end"
. log
