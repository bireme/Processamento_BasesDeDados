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
   echo "gerando mdlbb$i..."
   TPR="iffatal"
   MSG="Erro: ./tpl.mdl/genmdlxmli.sh - $i"
   ./tpl.mdl/genmdlxmli.sh $i labbak$ANO_2DIGITOS"i" DP
   . log

   echo "gerando mdl$i..."
   TPR="iffatal"
   MSG="Erro: ./tpl.mdl/genmdlxmlb.sh - $i"
   ./tpl.mdl/genmdlxmlb.sh $i labbak$ANO_2DIGITOS"b" DP
   . log
   
   #cd m$ANO_2DIGITOS.mdl
   #mv mdl$ANO_2DIGITOS.mst mdl.mst
   #mv mdl$ANO_2DIGITOS.xrf mdl.xrf
   #cd ..

done

echo "Acabou!!!"

