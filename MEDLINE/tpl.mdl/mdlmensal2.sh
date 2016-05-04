# --------------------------------------------------- #
# Eliminacao de registros repetidos do proprio master
# --------------------------------------------------- #
# Execucao: diretorio do ano, p. ex.: m02.mdl
#  Chamada: mdlmensal2.sh <dbn>
#    Saida: <dbn> sem registros repetidos
#

if [ "$#" -ne 1 ]
then 
   TPR="fatal"
   MSG="use: mdlmensal2.sh <dbn(mdl02)>"
   . log 
fi


# Gera a estrutura do MST de BROWSE
# Observacao do CHICO (i): Esta fase eh redundante, mdl02 ja nao tem v667
#echo "mstxl=4" > mdlxl.par
#CIPAR=mdlxl.par
#export CIPAR

#TPR="iffatal"
#MSG="erro na geracao da estrutura do Master de BROWSE"
#$LINDG4/mx tmp count=0 now create=$1"t"
#. log

#TPR="iffatal"
#MSG="Erro: Deleta registros com v999 ausente"
#$LINDG4/mx $1 gizmo=../tabs/tab142b "proc=if p(v667) or v999^q.4 < '1966' then 'd*' fi" -all now append=$1"t" tell=50000
#. log


#mv $1"t".xrf $1.xrf
#mv $1"t".mst $1.mst
# Observacao do CHICO (f):

# Insercao do CHICO (i):
# Gera base com PMID para evitar efeitos danosos dos caracteres dos dados
TPR="iffatal"
MSG="Erro extraindo base com PMID apenas"
mx $1 "proc='d*a999~^3'v999^3'~'" create=mdlpmid -all now tell=100000
. log

# Insercao do CHICO (f):

# Alteracao do CHICO (i):
# Inverte base do ano pelo PMID
echo "969 0 v999^3" > mdlpmid.fst
TPR="iffatal"
MSG="Erro: gentree mdlpmid"
mx mdlpmid "fst=@mdlpmid.fst" fullinv=mdlpmid tell=200000
. log

echo "Join de mdlpmid com mdlpmid..."
TPR="iffatal"
MSG="Erro: join mdlpmid com mdlpmid"
# mx mdlpmid "join=mdlpmid=v999^3" "pft=(v32001^m+|+|)/" -all now|grep "\+" >m1
mx mdlpmid "join=mdlpmid=v999^3" "pft=lw(9999),(v32001^m+|+|)/" -all now>m0
. log
grep "\+" m0>m1

rm mdlpmid.* m0
# Alteracao do CHICO (f):

sort -u m1 -o m2
rm m1
mx seq=m2 create=m2 -all now
mxcp m2 create=m3 repeat=+
rm m2 m2.*

# Cria o SHELL de eliminar registros repetidos, deixando os MFNs mais rescentes
TPR="iffatal"
MSG="Erro: geracao TEMP.SH"
mx m3 lw=0 "pft=(|mx $1 from=|v1| \"proc='d*'\" count=1 now -all copy=$1|,if iocc+1 >= nocc(v1) then break fi/)/" -all now tell=300000 > temp.sh
. log

chmod 755 temp.sh
rm m3.*

# Gera a estrutura do MST de BROWSE
echo "mstxl=64G" > mdlxl.par
CIPAR=mdlxl.par
export CIPAR

TPR="iffatal"
MSG="Erro na geracao da estrutura do Master de BROWSE"
mx tmp count=0 now create=$1"t"
. log

# Elimina os MFNs repetidos
echo "Eliminando docs repetidos (demora algum tempo)..."
echo
./temp.sh

# Passa a base de dados a limpo
TPR="iffatal"
MSG="Erro ao recriar a base sem repeticoes"
echo "recriar Master de Browse sem repeticoes..."
echo
mx $1 append=$1"t" -all now tell=100000
. log

mv $1"t".mst $1.mst
mv $1"t".xrf $1.xrf

#rm $1"t".mst
#rm $1"t".xrf
rm $1.iso
#rm $1.iyp $1.ly? $1.n0? $1.cnt $1.lk? temp.sh

TPR="end"
. log
