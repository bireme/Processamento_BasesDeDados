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

TPR="iffatal"
MSG="Erro: coleta_BDENF.sh"
../tpl.bde/coleta_BDENF.sh
. log

TPR="iffatal"
MSG="Erro: normaliza_BDENF.sh"
../tpl.bde/normaliza_BDENF.sh
. log

TPR="iffatal"
MSG="Erro: iah_BDENF.sh"
../tpl.bde/iah_BDENF.sh
. log

TPR="iffatal"
MSG="Erro: iahx_xml_BDENF.sh"
../tpl.bde/iahx_xml_BDENF.sh
. log

TPR="iffatal"
MSG="Erro: iahh_BDENF.sh.sh" 
../tpl.bde/iahh_BDENF.sh
. log

echo "Acabou!!!"
