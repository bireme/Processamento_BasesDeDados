# --------------------------------------------------- #
# Eliminacao de registros marcados para delecao
# --------------------------------------------------- #
# Execucao: diretorio do ano, p. ex.: m02.mdl
#  Chamada: mdlmensal5.sh <dbn>
#    Saida: <dbn> sem registros marcados
#

if [ "$#" -ne 1 ]
then 
   TPR="fatal"
   MSG="use: mdlmensal5.sh <dbn(mdl02)>"
   . log 
fi

if [ -f mdlkill.xrf ]
then

  # Gera a estrutura do MST de BROWSE
  echo "mstxl=64G" > mdlxl.par
  CIPAR=mdlxl.par
  export CIPAR

  TPR="iffatal"
  MSG="erro na geracao da estrutura do Master de BROWSE"
  mx tmp count=0 now create=$1"t"
  . log

  # Apaga registros de $1
  TPR="iffatal"
  MSG="Error: $1 ou mdlkill nao encontrado (Master de Browse)"
  mx $1 "join=mdlkill,1999:1=v999^3/" "proc=if v32001^m>'' then 'd*' else 'd32001d1999' fi" append=$1"t" -all now tell=50000
  . log
  rm mdlkill.*

  # Repoe denominacao original da base de dados
  mv $1"t".xrf $1.xrf
  mv $1"t".mst $1.mst

  rm mdlxl.par

fi

TPR="end"
. log
