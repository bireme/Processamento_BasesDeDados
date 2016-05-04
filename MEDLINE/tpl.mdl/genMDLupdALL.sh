# Local da execucao
echo "executando $0"
LOCAL=`pwd`
if [ $LOCAL != "/bases/mdlG4" ]
then
  TPR="fatal"
  MSG="$0 - local da execucao deve ser em /bases/mdlG4"
  . log
fi

for i in $MDL_BASELINE4DIGITOS
do
   echo "$i..."
   ANO_2DIGITOS=`echo $i|cut -c3-4`
   cd m$ANO_2DIGITOS.mdl

   TPR="iffatal"
   MSG="Erro: ./tpl.mdl/genmdlxmli.sh - $i"
   ../tpl.mdl/upmdlany.sh b $MDL_ANOCORRENTE2DIGITOS
   . log

   TPR="iffatal"
   MSG="Erro: ./tpl.mdl/genmdlxmli.sh - $i"
   ../tpl.mdl/upmdlany.sh i $MDL_ANOCORRENTE2DIGITOS
   . log
   cd ..

done

echo "Acabou!!!"

