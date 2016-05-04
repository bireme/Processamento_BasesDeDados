# Local da execucao
echo "executando $0"
LOCAL=`pwd`
if [ $LOCAL != "/bases/mdlG4" ]
then
  TPR="fatal"
  MSG="$0 - local da execucao deve ser em /bases/mdlG4"
  . log
fi

COUNT=0
for i in $MDL_BASELINE4DIGITOS
do
   echo "$i..."
   ANO_2DIGITOS=`echo $i|cut -c3-4`
   cd m$ANO_2DIGITOS.mdl
   if [ $COUNT -le 3 ]
   then
       echo "gerando genmdlinv.sh $ANO_2DIGITOS..."
       TPR="iffatal"
       MSG="Erro: ../tpl.mdl/genmdlinv.sh - $ANO_2DIGITOS"
       ../tpl.mdl/genmdlinv.sh 100000 $ANO_2DIGITOS &
       . log
   else
       echo "gerando genmdlinv.sh $ANO_2DIGITOS..."
       TPR="iffatal"
       MSG="Erro: ../tpl.mdl/genmdlinv.sh - $ANO_2DIGITOS"
       ../tpl.mdl/genmdlinv.sh 100000 $ANO_2DIGITOS
       . log
       COUNT=0
   fi

   COUNT=`expr $COUNT + 1`
   cd ..
done

echo "Acabou!!!"

