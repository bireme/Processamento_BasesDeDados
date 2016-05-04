rm rel_mdl_idSciELO_notfound_ISSN_Revista_TMP.txt
rm rel_mdl_idSciELO_notfound.txt
# Local da execucao
echo "executando $0"
LOCAL=`pwd`
if [ $LOCAL != "/bases/mdlG4" ]
then
  TPR="fatal"
  MSG="$0 - local da execucao deve ser em /bases/mdlG4"
  . log
fi

for i in $MDL_BASELINE4DIGITOS $MDL_ANOCORRENTE4DIGITOS
do
   echo "$i..."
   ANO_2DIGITOS=`echo $i|cut -c3-4`
   cd m$ANO_2DIGITOS.mdl

   TPR="iffatal"
   MSG="Erro - $ANO_2DIGITOS"
   mx mdl "pft=(if v968^a='pii' and v968.1='S' and v968*5.1='-' and a(v866) and not v968*10.1='(' then mfn,x1,v999^3[1],x1,v968,x1,v999^5[1],x1,v999^q[1].4/ fi)" -all now lw=0 >> ../rel_mdl_idSciELO_notfound.txt
   . log
   
   TPR="iffatal"
   MSG="Erro - $ANO_2DIGITOS"
   mx mdl "pft=(if v968^a='pii' and v968.1='S' and v968*5.1='-' and a(v866) and not v968*10.1='(' then v968*1.9,'|',v999^5[1]/ fi)" -all now lw=0 >> ../rel_mdl_idSciELO_notfound_ISSN_Revista_TMP.txt
   . log

   cd ..
done

cat rel_mdl_idSciELO_notfound_ISSN_Revista_TMP.txt|sort -u > rel_mdl_idSciELO_notfound_ISSN_Revista.txt
rm rel_mdl_idSciELO_notfound_ISSN_Revista_TMP.txt

echo "Acabou!!!"

