#!/bin/bash


if [ "$#" -ne 2 ]
then
   TPR="fatal"
   MSG="use: genupdatemdl.sh <dbn> <dbn_NAMEIN_update>"
   . log
fi

if [ ! -f $1.xrf ]
then
   MSG="$1.xrf nao encontrado"
   TPR="fatal"
   . log
fi
if [ ! -f ../fasea/update_isis/$2.xrf ]
then
   MSG="../fasea/update_isis/$2.xrf nao encontrado"
   TPR="fatal"
   . log
fi

# Gera a estrutura do MST de INDEX
  echo "mstxl=64G" > mdlxl.par
  CIPAR=mdlxl.par
  export CIPAR

# Troca registros 
#echo "atualizando documentos de $1 por $22..."
TPR="iffatal"
MSG="Join $1 com $2"
if [ "$1" = "mdl" ]
then
   IMDL=`echo $2|sed 's/bmd/imd/'`
   cat>bmdl.cip<<!
   $2.mst=../fasea/update_isis/$2.mst
   $2.xrf=../fasea/update_isis/$2.xrf
   $2.cnt=../fasea/update_isis/$IMDL.cnt
   $2.iyp=../fasea/update_isis/$IMDL.iyp
   $2.ly1=../fasea/update_isis/$IMDL.ly1
   $2.ly2=../fasea/update_isis/$IMDL.ly2
   $2.n01=../fasea/update_isis/$IMDL.n01
   $2.n02=../fasea/update_isis/$IMDL.n02
!
   mx cipar=bmdl.cip $1 "jchk=$2=v999^3/" "proc='d32001',if p(v32001^m) then 'd*','a969~'v999^3'~',|<721>|v721|</721>|,|<722>|v722|</722>|,|<723>|v723|</723>|,|<993>|v993|</993>| fi" now -all create=mdlupdate_tmp tell=100000
   . log

   mx cipar=bmdl.cip mdlupdate_tmp "join=$2=v969/" "proc=if p(v32001^m) then '<993>upd_$2</993>' fi" jmax=1 "proc='d32001d969'" now -all create=$1 tell=100000
   . log
   rm mdlupdate_tmp.*
   rm bmdl.cip
else
   mx $1 "jchk=../fasea/update_isis/$2=v969/" "proc='d32001',if p(v32001^m) then 'd*','a1969~'v969'~',|<993>|v993|</993>| fi" now -all create=mdlbbupdate_tmp tell=100000
   . log

   mx mdlbbupdate_tmp "join=../fasea/update_isis/$2=v1969/" "proc=if p(v32001^m) then '<993>upd_$2</993>' fi" jmax=1 "proc='d32001d1969'" now -all create=$1 tell=100000
   . log
   rm mdlbbupdate_tmp.*

fi 

