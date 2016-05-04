#find /bases/lnkG4 -name iah*.mst|cut -f5 -d\/|sort -u > tmp
ls /bases/lnkG4/iah.lnk/iah*.mst|cut -f5 -d\/|sort -u > tmp

rm all_iah.*
for i in `mx seq=tmp "pft=v1' '" now`
do
  DBN_IAH=`find /bases/lnkG4 -name iah*.mst|sort -u|grep $i|tail -1`
  echo "Append $DBN_IAH..."
  TPR="iffatal"
  MSG="Erro: append $i em all_iah"
  mx $DBN_IAH now -all tell=10000 append=all_iah
  . log
done

echo "inverte all_iah..."
echo "1 0 v350^*[1]/" > all_iah.fst
TPR="iffatal"
MSG="Erro mx all_iah fst=@ fullinv=all_iah"
mx all_iah fst=@ fullinv=all_iah
. log

TPR="iffatal"
MSG="Erro mx mdlbb$1 join=all_iah,1880:880=v969/"
mx mdlbb$1 "join=all_iah,1880:880=v969/" jmax=1 "proc='d32001',if p(v1880) then 'd968d1880a968~'v1880^*[1]'^apii~' fi" create=mdlbb$1"_iah" -all now tell=100000
. log

mv mdlbb$1"_iah".mst mdlbb$1.mst
mv mdlbb$1"_iah".xrf mdlbb$1.xrf

rm tmp
rm all_iah.*
