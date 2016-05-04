if [ ! -s ../tabs/afilmdl1.in ]
then
  TPR="fatal"
  MSG="Error: ../tabs/afilmdl1.in nao encontrado"
  . log
fi

if [ ! -s mdl.mst ]
then
  TPR="fatal"
  MSG="Error: mdl.mst nao encontrado"
  . log
fi

if [ "$#" -ne 1 ]
then
   TPR="fatal"
   MSG="use: genmdlpaisafil.sh <DP>"
   . log
fi

# Gera a estrutura do MST de INDEX
rm mdlaf.txt
rm mdlafil??.???
rm mdlafilaf??.???
rm mdlafilif??.???

echo
echo "extraindo afiliacao de mdl.mst..."
TPR="iffatal"
MSG="Erro Proc $0"
mx null count=0 create=mdlafil$1
mx mdl in=../tabs/afilmdl1.in create=mdlafilaf$1 -all now tell=100000
. log
mx mdlafilaf$1 "join=../tabs/tabpais,701:2,702:3,703:1,20,30=mpu,v2[last]" "proc='d32001'" "proc='S'" -all now create=mdlafil$1 tell=100000
. log

# FST
rm medlineafi.iy0
mx mdlafil$1    "fst=1 0 (if p(v20) then v701/,if v30='AL' then '.. LATIN AMERICA AND THE CARIBBEAN' else '...Other countries' fi else '.. Ignored country' fi/),'.  ALL COUNTRIES'/"   fullinv/ansi=medlineafi tell=100000
. log

rm medlineafe.iy0
mx mdlafil$1    "fst=1 0 (if p(v20) then v702/,if v30='AL' then '.. PAISES DE AMERICA LATINA' else '...Otros Paises' fi else '.. Pais ignorado' fi/),'.  TODOS LOS PAISES'/"   fullinv/ansi=medlineafe tell=100000
. log

rm medlineafp.iy0
mx mdlafil$1    "fst=1 0 (if p(v20) then v703/,if v30='AL' then '.. PAISES DA AMERICA LATINA' else '...Outros Paises' fi else '.. Pais ignorado' fi/),'.  TODOS OS PAISES'/"   fullinv/ansi=medlineafp tell=100000
. log

# -------------------------------------------------------------------------------------------------
# leva afiliacao para master de browse (para, depois, levar ao iAHx)
#
echo "721 0 (if p(v20) then v701/,if v30='AL' then '.. LATIN AMERICA AND THE CARIBBEAN' else '...Other countries' fi else '.. Ignored country' fi/),'.  ALL COUNTRIES'/" > mdlafil.fst
echo "722 0 (if p(v20) then v702/,if v30='AL' then '.. PAISES DE AMERICA LATINA' else '...Otros Paises' fi else '.. Pais ignorado' fi/),'.  TODOS LOS PAISES'/" >> mdlafil.fst
echo "723 0 (if p(v20) then v703/,if v30='AL' then '.. PAISES DA AMERICA LATINA' else '...Outros Paises' fi else '.. Pais ignorado' fi/),'.  TODOS OS PAISES'/" >> mdlafil.fst

mx mdlafil$1   "fst=@mdlafil.fst" tell=100001 create=mdlafil$1_tmp -all now tell=100001
. log

mx  mdlafil$1_tmp "proc='d720','d721',|a721|v721^*||" "proc='d720','d722',|a722|v722^*||" "proc='d720','d723',|a723|v723^*||" create=mdlafil$1_pais720 -all now tell=100002
. log
rm mdlafil$1_tmp.*

mx mdl "join=mdlafil$1_pais720,721,722,723=if a(v721) then 'mfn='mfn/ fi" "proc='d32001'" create=mdl_tmp -all now tell=100003
. log
rm mdlafil$1_pais720.*


#mx mdl_tmp gizmo=../tabs/g850mi,721,722,723 create=mdl$1 -all now tell=100004
mx mdl_tmp create=mdl -all now tell=100004
. log
rm mdl_tmp.*


rm mdlafil.fst
rm mdlafilaf$1.mst
rm mdlafilaf$1.xrf
rm mdlafil$1.mst
rm mdlafil$1.xrf

