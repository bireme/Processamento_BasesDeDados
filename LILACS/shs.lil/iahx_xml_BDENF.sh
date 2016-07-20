#!/bin/bash

#----------------------------------------------------------------------#
# Verifica se esta no local certo para iniciar o processamento
#----------------------------------------------------------------------#
LOCAL=`pwd | cut -d"/" -f4`
if [ $LOCAL != "bde.lil" ]
then
   TPR="fatal"
   MSG="Diretorio de processamento deve ser bde.lil"
   . log
fi

# APS
cd ../bvs.aps
TPR="iffatal"
MSG="Erro: execucao ./todasAPS.sh"
../tpl.lil/genlilbvsxml.sh bde BDENF aps "06-national"
. log
cd -

# DSS 
cd ../bvs.dss
TPR="iffatal"
MSG="Erro: execucao ./todasAPS.sh"
../tpl.lil/genlilbvsxml.sh bde BDENF dss
. log
cd -

