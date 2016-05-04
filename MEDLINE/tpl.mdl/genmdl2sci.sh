TPR="start"
. log

if [ "$#" -ne 1 ]
then
   TPR="fatal"
   MSG="use: genmdl2sci.sh <DPDP>"
   . log
fi

# Gera CIP com todos os blocos possíveis
cat>mdlsci.par<<!
mdl$1.mst=/bases/mdlG4/m$1.mdl/mdl$1.mst
mdl$1.xrf=/bases/mdlG4/m$1.mdl/mdl$1.xrf
mdl$1.*=/bases/mdlG4/m$1.mdl/mdlot.*
!

cat>mdlfe.fst<<!
1 1000 if p(v32001^m) then '/'v32001^m'/',,'FE INTERNET' fi
!

find /bases/lnkG4 -name iah*.mst|cut -f5 -d\/|sort -u > tmp

rm all_iah.*
for i in `mx seq=tmp "pft=v1' '" now`
do
  DBN_IAH=`find /bases/lnkG4 -name iah*.mst|sort -u|grep $i|tail -1`
  echo "Append $DBN_IAH..."
  TPR="iffatal"
  MSG="Erro: append $i em iah2all_sci"
  mx $DBN_IAH now -all tell=10000 append=all_iah
  . log
done

rm tmp

# gera indice MDLFE
TPR="iffatal"
MSG="use: geracao invertido MDLFE"
mx cipar=mdlsci.par all_iah "join=mdl$1,0=|UI |v350^*" "fst=@mdlfe.fst" fullinv=mdlfe master=mdl$1 -all now 
. log

rm mdlfe.fst
rm all_iah.*
rm mdlsci.par

TPR="end"
. log

