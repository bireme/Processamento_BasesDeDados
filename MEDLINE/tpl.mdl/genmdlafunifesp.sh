# Checando passagem de parametro
if [ "$#" -ne 1 ]
then
   TPR="fatal"
   MSG="Exemplo: $0 <DP>"
   . log
fi

if [ ! -s ../tabs/mdlafunifesp.txt ]
then
  TPR="fatal"
  MSG="Error: ../tabs/mdlafunifesp.txt nao encontrado"
  . log
fi

echo "Geracao indice MDLAFUNIFESP..."

echo "mdl.cnt=mdlot.cnt" >  UNI.cip
echo "mdl.iyp=mdlot.iyp" >> UNI.cip
echo "mdl.ly1=mdlot.ly1" >> UNI.cip
echo "mdl.ly2=mdlot.ly2" >> UNI.cip
echo "mdl.n01=mdlot.n01" >> UNI.cip
echo "mdl.n02=mdlot.n02" >> UNI.cip

TPR="iffatal"
MSG="Erro: geracao master file mdlafunifesp.mst"
mx seq=../tabs/mdlafunifesp.txt -all now create=mdlafunifesp
. log

TPR="iffatal"
MSG="Erro: geracao invertido mdlafunifesp"
mx cipar=UNI.cip mdlafunifesp "fst=99 1000 e1:=l(['mdl']'UI 'v1),if e1>0 then '|',f(e1,1,0),'|',v2/ fi" fullinv=mdlafunifesp master=mdl
. log

rm UNI.cip

