if [ "$#" -ne 1 ]
then
  TPR="fatal"
  MSG="Use: ./criaV8mdl.sh <DP>"
   . log
fi

TPR="iffatal"
MSG="Erro: criaV8mdl.sh"

echo "Criando URL SciELO (campo 866) a partir do PII do MEDLINE - $1..."

#mx mdlbb$1 lw=0 "join=/bases/lnkG4/tit.org/urlmdl2sciG4,8=(if v968^a='pii' and v968.1='S' and v968*5.1='-' then v968*1.9/ fi)" "proc='d32001d8d866',(if p(v8) then |<866 0>^u|v8^u,v968^*[1],|^s|v8^s,|^o|v8^o,|^t|v8^t,|^l|v8^l|</866>| fi)" create=mdlbb$1_968 -all now tell=100000
#mx mdlbb$1 lw=0 "join=/bases/lnkG4/tit.org/urlmdl2sciG4,8=(if v968^a='pii' and v968.1='S' and v968*5.1='-' then v968*1.9/ fi)" "proc=(if v968^a='pii' and v968.1='S' and v968*5.1='-' then 'd968',|<968 0>|v968|</968>| fi)" "proc='d32001d8d866',(if p(v8) and v968^a='pii' and v968.1='S' and v968*5.1='-' then |<866 0>^u|v8^u,v968^*[1],|^s|v8^s,|^o|v8^o,|^t|v8^t,|^l|v8^l|</866>| fi)" create=mdlbb$1_968 -all now tell=100000
mx mdlbb$1 lw=0 "join=/bases/lnkG4/tit.org/urlmdl2sciG4,8=(if v968^a='pii' and v968.1='S' and v968*5.1='-' and not v968*10.1='(' then v968*1.9/ fi)" "proc=(if v968^a='pii' and v968.1='S' and v968*5.1='-' and not v968*10.1='(' then 'd968',|<968 0>|v968|</968>| fi)" "proc='d32001d8d866',(if p(v8) then |<866 0>^u|v8^u,v968^*[1],|^s|v8^s,|^o|v8^o,|^t|v8^t,|^l|v8^l|</866>| fi)" create=mdlbb$1_968 -all now tell=100000
. log
mv mdlbb$1_968.mst mdlbb$1.mst
mv mdlbb$1_968.xrf mdlbb$1.xrf

#mx mdlbb$1 gizmo=../tabs/gSciELOCol,866 gizmo=../tabs/gmdl968,866 create=mdlbb$1_968_tmp -all now tell=100000
#mx mdlbb$1 gizmo=../tabs/gSciELOCol,866 gizmo=../tabs/gmdl968,866 create=mdlbb$1_968_tmp -all now tell=100000
mx mdlbb$1 gizmo=../tabs/gmdl968,866 create=mdlbb$1_968_tmp -all now tell=100000
. log
mv mdlbb$1_968_tmp.mst mdlbb$1_968.mst
mv mdlbb$1_968_tmp.xrf mdlbb$1_968.xrf

mx mdl$1 "join=mdlbb$1_968,1866:866,1968:968='mfn='mfn" gizmo=../tabs/gmdl968,866 "proc='d32001d1866d866d1968d968',|<866 0>|v1866|</866>|,|<968 0>|v1968|</968>|"  -all now create=mdl$1_968 -all now tell=100000
. log

#mx mdl$1_968 gizmo=../tabs/gans850,866 gizmo=../tabs/diacxu,866 gizmo=../tabs/tab142a,866 -all now create=mdl$1 -all now tell=100000
mx mdl$1_968 -all now create=mdl$1 -all now tell=100000
. log

rm mdlbb$1_968.*
rm mdl$1_968.*

# traz campo 8 da LILACS, quando indicado

TPR="iffatal"
MSG="Erro: traz campo 8 da LILACS, quando indicado"
mx mdl$1 "join=/bases/lilG4/lil.lil/lilacs969,8=v999^3/" "proc='d32001',if p(v32001^m) and a(v866) and a(v967) and p(v8) then else 'd8' fi" now -all tell=100000 create=mdl$1_lilv8
. log

mv mdl$1_lilv8.mst mdl$1.mst
mv mdl$1_lilv8.xrf mdl$1.xrf
