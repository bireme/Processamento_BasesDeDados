#----------------------------------------------------------------------#
# Verifica se esta no local certo para iniciar o processamento
#----------------------------------------------------------------------#
LOCAL=`pwd | cut -d"/" -f4`
if [ $LOCAL != "bde.lil" ]
then
   TPR="fatal"
   MSG="Diretorio de processamento deve ser bde.lil"
   . log
fi

# -------------------------------------------------------------------------------------------
# Processamento like LILACS
# -------------------------------------------------------------------------------------------
TPR="iffatal"
MSG="Erro: ../tpl.lil/genlilbvsall.sh"
../tpl.lil/genothlil.sh bde
. log

