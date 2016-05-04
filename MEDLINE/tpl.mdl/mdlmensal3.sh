# ------------------------------------------------------- #
# Eliminacao de registros repetidos em masteres dos backs
# ------------------------------------------------------- #
# Execucao: no diretorio do ano, p. ex.: m02.mdl
#  Chamada: mdlmensal3.sh <dbn> <pmid[anoset]>
#    Saida: dbn sem registros repetidos com o back processado
#
#  ATENCAO: As bases PMID sao esperada no diretorio "tabs/pmid"
#

TPR="start"
. log

if [ "$#" -ne 2 ]
then 
   TPR="fatal"
   MSG="use: mdlmensal3.sh <dbn_sdi> <dbn_bak> (pmid6683)>"
   . log 
fi

if [ -f $1"t".xrf ]
then
   rm $1"t".mst
   rm $1"t".xrf 
fi

# Gera a estrutura do MST de BROWSE
echo "mstxl=64G" > mdlxl.par
CIPAR=mdlxl.par
export CIPAR

TPR="iffatal"
MSG="erro na geracao da estrutura do Master de BROWSE"
mx tmp count=0 now create=$1"t"
. log

if [ ! -f ../tabs/pmid/$2.iyp ]
then
   TPR="fatal"
   MSG="Erro: ../tabs/pmid/$2.iyp nao encontrado"
   . log
fi

# Monta uma base dos registros nao repetidos
TPR="iffatal"
MSG="Erro: join $1 com $2"
mx $1 "join=../tabs/pmid/$2=v999^3/" "proc='d32001',if p(v32001^m) then 'd*' fi" append=$1"t" -all now tell=50000
. log

mv $1"t".mst $1.mst
mv $1"t".xrf $1.xrf

rm mdlxl.par

TPR="end"
. log
