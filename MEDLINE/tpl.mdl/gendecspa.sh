for i in papa
do
  if [ ! -s $i.seq ]
    then
    TPR="fatal"
    MSG="Error: $i.seq nao encontrado"
    . log
  fi
done

echo 1 0 v1/ > decs.fst

TPR="iffatal"
MSG="Erro PA - inversao do DeCS"
gentree decs decs 10000 no
. log

#mz decs minpost=2 now > nul

TPR="iffatal"
MSG="Erro PA - criacao PAPA_TMP"
mx seq=papa.seq create=papa_tmp -all now
. log

TPR="iffatal"
MSG="Erro PA - MXCP PAPA_TMP"
mxcp papa_tmp create=papa clean
. log

rm pa??_tmp.*

# lista PAs
TPR="iffatal"
MSG="Erro PA - criacao pa.lst"
mx papa "pft=v2/" now > pa.lst
. log
sort -u pa.lst > pa.srt

TPR="iffatal"
MSG="Erro PA - criacao drug.lst"
mx papa "pft=if v1<>v2 then v1/ fi" now > drug.lst
. log
sort -u drug.lst > drug.srt

# verifica se todos PAs estao no decs

#TPR="iffatal"
#MSG="Erro PA - criacao drug.lst"
#mx seq=pa.srt "join=decs,10:1=v1" "pft=if a(v32001^m) then v1/ else if v1<>v10 then v1/ fi fi" now
#. log

mx seq=pa.srt create=pa1 -all now
mx seq=drug.srt create=drug -all now

# coloca categoria pa1 em todos PAs
TPR="iffatal"
MSG="Erro PA - criacao nivel 1 em pa1"
mx pa1 "proc='d20a20~PA1.'mfn(3)'~'" copy=pa1 now -all tell=1000 
. log

# gera nivel dois

echo 2 0 v2/ > papa.fst

TPR="iffatal"
MSG="Erro PA - inversao do PAPA"
gentree papa papa 1000 no
. log

TPR="iffatal"
MSG="Erro PA - geracao pa2.lst"
#/usr/local/bireme/cisis/4.3a/lind/mx mfrl=128000 fmtl=64000 pa1 lw=999 "join=papa,10:1=v1" "pft=(if p(v32001^m) then if v1[1]=v10 then v1[1]'|'v20[1] else v10'|'v20[1]'.'right(s('000'f(iocc,0,0)),3)/ fi, else v1[1]'|'v20[1]/ fi)" now tell=10000> pa2.lst
mx mfrl=128000 fmtl=64000 pa1 lw=999 "join=papa,10:1=v1" "pft=(if p(v32001^m) then if v1[1]=v10 then v1[1]'|'v20[1] else v10'|'v20[1]'.'right(s('000'f(iocc,0,0)),3)/ fi, else v1[1]'|'v20[1]/ fi)" now tell=10000> pa2.lst
. log

mx pa1 "pft=v1'|'v20/" now >> pa2.lst

sort -u pa2.lst > pa2.srt

mx seq=pa2.srt create=pa2 "proc='d*a100~'v1'~a201~'v2'~'" now -all tell=1000

echo 1 0 v100/ > pa2.fst

TPR="iffatal"
MSG="Erro PA - inversao do PA2"
gentree pa2 pa2 10000 no
. log

TPR="iffatal"
MSG="Erro PA - Geracao do Decs final"
#/usr/local/bireme/cisis/4.3a/lind/mx mfrl=128000 fmtl=64000 decs "join=pa2=v1" "proc='d32001d100d201',if p(v32001^m) then |a20~|v201|~| fi" create=decspa -all now tell=1000
mx mfrl=128000 fmtl=64000 decs "join=pa2=v1" "proc='d32001d100d201',if p(v32001^m) then |a20~|v201|~| fi" create=decspa -all now tell=1000
. log

mv decspa.mst decs.mst
mv decspa.xrf decs.xrf

rm pa.* pa1.* pa2.*
rm papa.mst papa.xrf papa.n01 papa.n02 papa.ly1 papa.ly2 papa.cnt papa.iyp papa.fst 
rm decs.n01 decs.n02 decs.ly1 decs.ly2 decs.cnt decs.iyp decs.fst
rm *.lk?
rm drug.*
