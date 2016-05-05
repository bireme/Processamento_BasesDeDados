#----------------------------------------------------------------------#
# Verifica se esta no local certo para iniciar o processamento
#----------------------------------------------------------------------#
LOCAL=`pwd | cut -d"/" -f4`
if [ $LOCAL != "fio.lil" ]
then
   TPR="fatal"
   MSG="Diretorio de processamento deve ser fio.lil"
   . log
fi


TPR="iffatal"
MSG="Erro: mx LILACS"
mx LILACS "gizmo=../tabs/gCampo4,4" gizmo=../tabs/g87,87,88 gizmo=../tabs/gV8homolog,8 "proc='d870d880'" gizmo=../tabs/gV8ColSUS,8 "proc='d8',if p(v8^u) then |a8Internet^i|v8^u|| else |a8|v8|| fi" "proc='S'" now -all tell=5000 create=LILACS_tmp
. log

echo "limpa campo 3 antes de iniciar..."
TPR="iffatal"
MSG="Erro: mx LILACS"
mxcp LILACS_tmp create=LILACS_tmp1 period=\^,3
. log

mv LILACS_tmp1.xrf LILACS.xrf
mv LILACS_tmp1.mst LILACS.mst

# -------------------------------------------------------------------------------------------
# Processamento like LILACS
# -------------------------------------------------------------------------------------------
TPR="iffatal"
MSG="Erro: limpa LILACS"
mxcp LILACS create=LILACS_tmp clean tell=10000
. log

# Faz processamento LILACS nesta base
TPR="iffatal"
MSG="Erro: mx LILACS_tmp"
mx LILACS_tmp gizmo=../tabs/gans850 "proc='S'" now -all tell=100 create=lil
. log
rm LILACS_tmp.*

TPR="iffatal"
MSG="Erro: ../tpl.lil/genlilbvsall.sh"
../tpl.lil/genlilbvsall.sh
. log

TPR="iffatal"
MSG="Erro: join traz v2 de lil para lilacs - FIOCRUZ"
mx lilacs "join=LILACS,1002:2='mfn='mfn" "proc='d32001d2d1002','a2~'v1002'~'" copy=lilacs -all now tell=1000
. log

echo "Acabou!!!"
