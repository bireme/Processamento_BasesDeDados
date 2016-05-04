if [ "$#" -ne 1 ]
then
   TPR="fatal"
   MSG="use: $0 <DP>"
   . log
fi


rm mdlicd.iy0

echo "gerando invertido mdlicd..."
TPR="iffatal"
MSG="Erro: $0 - mx mdl in=../tabs/mdlproc351.in"
$LINDG4/mx mdlbb$1 in=../tabs/mdlproc87e88.in "join=../tabs/MSHcodecuiicd10dj=(if p(v351) then 'MSHMFN='v351^*/ fi)" "join=null=proc(if a(v14) then 'd*' else proc(|a20~|v1^v|;~|),proc('Gsplit=20=;') fi)" "fst=1 0 (|ICD10 |v14^*/),(|MSHEX |v20/)" fullinv=mdlicd tell=150000
. log


