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
MSG="Erro: traz $TRANSFER@pr10vm:/home/apps/bvs.br/wp-enfermagem/bases/lildbi/dbcertif/lilacs/LILACS.xrf"
echo "Trazendo base BDENF de pr10vm ..."
scp -P 8022 $TRANSFER@pr10vm:/home/apps/bvs.br/wp-enfermagem/bases/lildbi/dbcertif/lilacs/LILACS.xrf .
. log
scp  -P 8022 $TRANSFER@pr10vm:/home/apps/bvs.br/wp-enfermagem/bases/lildbi/dbcertif/lilacs/LILACS.mst .
. log

echo
echo "Dados transferidos de pr10vm.bireme.br!!!"
echo

