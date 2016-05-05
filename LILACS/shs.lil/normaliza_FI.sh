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
# Normaliza/harmoniza FI
# -------------------------------------------------------------------------------------------
TPR="iffatal"
MSG="Erro: limpa LILACS"
mxcp LILACS create=LILACS_tmp clean tell=10000
. log

# Faz processamento LILACS nesta base
TPR="iffatal"
MSG="Erro: mx LILACS_tmp"
mx LILACS_tmp gizmo=../tabs/gans850 "proc='S'" now -all tell=100 iso=bde_semanal.iso
. log
rm LILACS_tmp.*


