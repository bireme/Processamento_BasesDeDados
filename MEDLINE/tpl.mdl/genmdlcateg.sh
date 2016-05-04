if [ "$#" -ne 1 ]
then
  TPR="fatal"
  MSG="use: $0 <DP>"
  . log
fi

echo "1 0 mpl,if not v105:'T' then v01/ fi" > decs.fst
echo "1 0 mpl,if not v105:'T' then v02/ fi" >> decs.fst
echo "1 0 mpl,if not v105:'T' then v03/ fi" >> decs.fst
echo "14 0 mpl,|/|v14" >> decs.fst

cp ../tabs/decs.mst .
cp ../tabs/decs.xrf .

TPR="iffatal"
MSG="Erro na geracao da arvore tdecs"
gentree decs decs 15000 no
. log

TPR="iffatal"
MSG="Erro na geracao do indice mdlcateg - $1"
echo "mstxl=64G" > mdlxl.par
echo "trazendo v20 do DeCS..."
mx cipar=mdlxl.par ../m$1.mdl/mdlbb$1 "join=decs,20,106=mpu,(v870^h/),(v880^h/),proc('d*')" "proc='d32001',if v106:'c' then 'd20' fi" create=mdlbb$1"v20" -all now tell=100000
#mx cipar=mdlxl.par ../m$1.mdl/mdlbb$1 "join=decs,20=mpu,(v870^h/),proc('d*')" "proc='d32001'" create=mdlbb$1"v20" -all now tell=100000
. log

echo "gerando FFIG4..."
crunchmf mdlbb$1"v20" mdlbb$1"v20FFI" target=same format=cisisX
. log
rm mdlbb$1"v20".*

echo "tirando repetidos v20..."
$FFIG4/mx cipar=mdlxl.par mdlbb$1"v20FFI" "proc='d20',(if v20 >'' then if citype(v20.2)='A' then '<203 0>'v20.2'</203>' else '<203 0>'v20.1'</203>' fi fi,if v20.3 >'' then '<203 0>'v20.3'</203>' fi,if v20.7 >'' then '<203 0>'v20.7'</203>' fi,if v20.11 >'' then '<203 0>'v20.11'</203>' fi,if v20.15 >'' then '<203 0>'v20.15'</203>' fi,if v20.19 >'' then '<203 0>'v20.19'</203>' fi,if v20.23 >'' then '<203 0>'v20.23'</203>' fi,if v20.27 >'' then '<203 0>'v20.27'</203>' fi,if v20.31 >'' then '<203 0>'v20.31'</203>' fi,if v20.35 >'' then '<203 0>'v20.35'</203>' fi,if v20.39 >'' then '<203 0>'v20.39'</203>' fi,if v20.43 >'' then '<203 0>'v20.43'</203>' fi,)" -all now tell=200000 create=mdlbb$1"v20FFItmp"
. log


echo "Passou..."

#$FFIG4/mx cipar=mdlxl.par mdlbb$1"v20FFItmp" "proc=@../tabs/mdl203.prc" create=mdlbb$1"v20FFIunico" -all now tell=300000
#$FFIG4/mx              cipar=mdlxl.par mdlbb$1"v20FFItmp" "proc='d203'(if p(v203) then if iocc>565 then break fi, if s1:s('~'v203'~') then else s1:=(s1'~'v203'~'),'<203 0>'v203'</203>' fi fi)" create=mdlbb$1"v20FFIunico" -all now tell=100000
#ok
$FFIG4/mx cipar=mdlxl.par fmtl=20000000 cipar=mdlxl.par mdlbb$1"v20FFItmp" "proc='d203'(if p(v203) then                            if s1:s('~'v203'~') then else s1:=(s1'~'v203'~'),'<203 0>'v203'</203>' fi fi)" create=mdlbb$1"v20FFIunico" -all now tell=100000
. log
echo "203 0 (v203/)" > mdlbb$1"v20FFIunico".fst

rm mdlbb$1"v20FFItmp".*
rm mdlbb$1"v20FFI".*

$FFIG4/mx mdlbb$1"v20FFIunico" fst=@ fullinv=mdlcateg tell=100000 -all now 
. log

rm mdlbb$1"v20FFIunico".*
rm decs.lk? decs.fst
