#----------------------------------------------------------------------#
# GENKWICTA.SH - Procedimento para geracao do KWICTA de REVISTA - MEDLINE
#
# Sintaxe: genkwicta.sh <dbn> <loopcheck>
#   onde <dbn> -> base de dados
#        <loopcheck> -> loop registros onde sera efetuado o check
#
#----------------------------------------------------------------------#

TPR="start"
. log

if [ "$#" -ne 3 ]
then 
   TPR="fatal"
   MSG="use: genlilta <dbn> <loopcheck> <DP/DE>"
   . log 
fi

# -------------------------------------------------------------------- #
# GERA KWICTA 
# -------------------------------------------------------------------- # 

# Não tem mais JC (320)
#TPR="iffatal"
#MSG="Error: Geracao da lista de Revistas MEDLINE"
#mx mdlbb"$3" "join=../tabs/mdlserl=s(mpu,v320/)" "pft=if a(v32001^m) then v301,'|',v305,'|',v307,'|',v320 fi/" -all now tell=10000 | sort -u > serl"$3".lst
#. log

# -------------------------------------------------------------------- #
# parte de baixo otimizada
# -------------------------------------------------------------------- # 
#TPR="iffatal"
#MSG="Erro na geracao da base com os titulos: tajoin"
#mx ../tabs/$1 "pft=v305,'|',v304/" now -all tell=$2 > serlkta.seq
#. log
#
#TPR="iffatal"
#MSG="Erro no sort serlkta.seq"
#sort -o serlkta_sort.seq -u serlkta.seq
#. log
#
#rm serlkta.mst serlkta.xrf
#TPR="iffatal"
#MSG="Erro na geracao da base com os titulos: tajoin"
#mx seq=serlkta_sort.seq "proc='d*',|a305~|v1|~|,|a304~|v2|~|" append=serlkta now -all tell=$2
#. log


rm serlkta.*
TPR="iffatal"
MSG="Erro na geracao da base com os titulos: tajoin"
#mx ../tabs/$1 "proc='d*',if p(v320) then |a320~|v320|~|,|a305~|v305|~|,|a304~|v304|~| fi" append=serlkta now -all tell=$2
mx ../tabs/$1 "proc='d*',|a305~|v305|~|,|a304~|v304|~|" append=serlkta now -all tell=$2
. log

cat>kwicta.pft<<!
,e1:=1
,e2:=nocc(v1001)

,while e1 <= e2 (
   '^f'
  ( if p(v1001^*) and iocc = e1 then if e1=1 then '^l' else ' ^l' fi,v1001^* else | |+v1001^* fi),('^m'v3),('|'v2)/
  e1:=e1+1
,)
!

TPR="iffatal"
MSG="Erro na geracao do kwicta.seq"
mx serlkta lw=9999 "pft=if p(v304) then (mpu,v304,'|',v305,'|',mfn(1)/) fi" now tell=1000 > kwicta.seq
 . log
rm serlkta.*


# Passa o v2 para UPPER porque tirava os diacriticos
TPR="iffatal"
MSG="Erro na geracao do Master kwicta"
mx seq=kwicta.seq "actab=../tabs/acKWIC437.tab" "fst=1001 4 v1" "proc='d2','a2~'mpu,v2'~'" create=kwicta1 -all now tell=1000
 . log
rm kwicta.seq

TPR="iffatal"
MSG="Erro na geracao do kwictatemp.seq"
mx kwicta1 lw=9999 pft=@kwicta.pft now tell=10000 > kwictatemp.seq
 . log
rm kwicta1.*

TPR="iffatal"
MSG="Erro na geracao do Master kwicta"
mx seq=kwictatemp.seq -all now tell=10000 create=kwicta
. log
rm kwictatemp.seq


# ------------------------------------------------------------------- #
# Classificacao dos termos
# ------------------------------------------------------------------- #

TPR="iffatal"
MSG="error: msrt can not sort terms"
msrt kwicta 60 "mpu,v1^l,'',v1^f" tell=1000
. log

# ------------------------------------------------------------------- #
# Inversao da base kwicta
# ------------------------------------------------------------------- #

echo "1 0 v1^l">kwicta.fst

TPR="iffatal"
MSG="error: Load invert tree kwicta"
gentree kwicta kwicta 1000
  . log
rm kwicta.fst
rm kwicta.lk?

# ------------------------------------------------------------------- #
# Crunch da base kwicta
# ------------------------------------------------------------------- #

TPR="iffatal"
MSG="error: crunch kwicta"
crunch kwicta mst
. log


rm kwicta.pft


TPR="end"
. log
