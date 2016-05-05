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
# atualiza em IAH-homologacao
# -------------------------------------------------------------------------------------------

# copia sus.lil para serverW
TPR="iffatal"
MSG="Erro copiando sus.lil para serverW"
rm LILACS.mst LILACS.xrf
ssh $TRANSFER@serverw.bireme.br mkdir /home/basesG4/lil/bde.lil
scp *.mst *.xrf $TRANSFER@serverw:/home/basesG4/lil/bde.lil
. log
cd iy0
scp *.* $TRANSFER@serverw:/home/basesG4/lil/bde.lil
. log

DIA_DA_SEMANA=`date '+%a'`
if [ $DIA_DA_SEMANA = "Mon" ]
then
	   /usr/local/bireme/procs/emailITI.sh bde
fi

echo "Acabou!!!"
