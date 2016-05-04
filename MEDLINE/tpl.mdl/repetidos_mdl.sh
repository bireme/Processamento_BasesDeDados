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


# Insercao do CHICO (i):
# Gera base com PMID para evitar efeitos danosos dos caracteres dos dados
TPR="iffatal"
MSG="Erro extraindo base com PMID apenas"
mx $1 "proc=if p(v999) then 'd*a969~'v999^3'~' else 'd*a969~'v969'~' fi" create=mdlpmid -all now tell=100000
. log

# Insercao do CHICO (f):

# Alteracao do CHICO (i):
# Inverte base do ano pelo PMID
echo "969 0 v969" > mdlpmid.fst
TPR="iffatal"
MSG="Erro: gentree mdlpmid"
mx mdlpmid "fst=@mdlpmid.fst" fullinv=mdlpmid tell=200000
. log

echo "Join de mdlpmid com mdlpmid..."
TPR="iffatal"
MSG="Erro: join mdlpmid com mdlpmid"
mx mdlpmid "join=mdlpmid=v969" "pft=lw(9999),(v32001^m+|+|)/" -all now>m0
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

rm temp.sh

TPR="end"
. log
