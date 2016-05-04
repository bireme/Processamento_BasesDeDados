#!/bin/bash
# -------------------------------------------------------------------------------- #
# genmdljd.sh - Procedimento para geracao do invertido de JOURNAL DESCRIPTOR
# -------------------------------------------------------------------------------- #
#      Entrada: <DP>
#        Saida: arquivos invertidos em tres idiomas
#     Corrente: /bases/mdlG4/tpl.mdl
#      Chamada: ../tpl.mdl/genmdljd.sh <DP>
#      Exemplo: ../tpl.mdl/genmdljd.sh 09
#  Comentarios: as palavras consideradas como erro sao as observadas nos processos
#  Observacoes: Observacoes relevantes para o processamento
# Dependencias: Sequencia encadeada de processamento
#
#               /tpl.mdl/genmdlmensal.sh
#                                      |                  
#                                      + genmdlinv
#                                                |
#                                                + genmdljd.sh
#
# ------------------------------------------------------------------------------- #
#   DATA    Responsaveis                    Comentarios
# 20090914  Fabio Brito/Marcelo Bottura     Edicao original
#
#---------------------------------------------------------------------------------#

TPR="start"
. log

# Checando passagem de parametro
if [ "$#" -ne 1 ]
then
   TPR="fatal"
   MSG="Exemplo: $0 <DP>"
   . log
fi

ONDE=`pwd`
echo "Operando em: $ONDE"

# Fazendo copia de serline
echo "Trazendo v440 da SERLINE..."
cp ../tabs/serl.mst serline.mst
cp ../tabs/serl.xrf serline.xrf

# Invertendo serline
echo "invertendo serline..."
echo "301 0 (v301/)" > serline.fst
echo "305 0 (v305/)" >> serline.fst
mx serline fst=@serline.fst fullinv=serline -all now actab=$TABS/ac850.tab uctab=$TABS/uc850.tab

echo "mstxl=64G" > v440.cip

# ------------------------------------------------------------------------------- #
echo "Trazendo v440 para MDL${1}..."
# ------------------------------------------------------------------------------- #
TPR="iffatal"
MSG="Erro: Trazendo v440 para MDL$1"
mx cipar=v440.cip mdlbb$1 gizmo=../tabs/gansna "join=serline,1440:440=(v301/)" "join=serline,2440:440=(s(mpu,v305,mpl)/)" jmax=1 "proc='d*',if p(v32001^m) then mpu,|<440 0>|v1440|</440>|,mpl, else if a(v32001^m) and p(v32002^m) then mpu,|<440 0>|v2440|</440>|,mpl fi,fi" -all now tell=100000 "create=mdlbb${1}_440" -all now tell=50000
. log


echo "Geracao indices JOURNAL DESCRIPTOR..."
# ------------------------------------------------------------------------------- #
# Criacao de base com os idiomas
# ------------------------------------------------------------------------------- #
echo "Criacao da base temporaria de idiomas - origem astill"
echo "criacao da base de idiomas para MDL$1..."
TPR="iffatal"
MSG="erro: $0 - criacao da base de idiomas MDL$1"
mx mdlbb${1}_440 "join=../tabs/astill,1001:1,1002:2,1003:3=(v440/)" "proc='d*',mpu,|<1001 0>|v1001|</1001>|,|<1002 0>|v1002|</1002>|,|<1003 0>|v1003|</1003>|,|<440 0>|v440|</440>|" "create=mdlbb${1}_astill" -all now tell=100000
. log

# ------------------------------------------------------------------------------- #
# Criacao dos invertidos nos idiomas espanhol, ingles e portugues
# ------------------------------------------------------------------------------- #
for j in i e p
do
	case "$j" in
	'i')
	echo "Gerando invertido mdljdi..."
	TPR="iffatal"
	MSG="Erro na geracao do invertido mdljdi"
	mx mdlbb${1}_astill "fst=440 0 mhu,(v1001/)" "fullinv=mdljdi" -all now tell=100000
	. log
	;;
	'e')
        echo "Gerando invertido mdljde..."
        TPR="iffatal"
        MSG="Erro na geracao do invertido mdljde"
        mx mdlbb${1}_astill "fst=440 0 mhu,(v1002/)" "fullinv=mdljde" -all now tell=100000
	. log
	;;
	'p')
        echo "Gerando invertido mdljdp..."
        TPR="iffatal"
        MSG="Erro na geracao do invertido mdljdp"
        mx mdlbb${1}_astill "fst=440 0 mhu,(v1003/)" "fullinv=mdljdp" -all now tell=100000
	. log
	;;
	esac
done

# ------------------------------------------------------------------------------- #
# Gerando relatorio termos astill - encontrados e nao encontrados
# ------------------------------------------------------------------------------- #
echo "Gerando relatorio dos termos ASTILL"
echo "-----------------------------------------------------------------------------------"          > rel_astill_mdl${1}.txt
echo "         RELATORIO DOS TERMOS ASTILL APOS PROCESSAMENTO DA BASE mdlbb$1"                     >> rel_astill_mdl${1}.txt
echo "-----------------------------------------------------------------------------------"         >> rel_astill_mdl${1}.txt
echo                                                                                               >> rel_astill_mdl${1}.txt

# Quantidade de campos v440 existentes
QTD_440=`mx mdlbb${1}_440 "pft=if p(v440) then (v440||/)fi" -all now | sort -u | wc -l`
echo "              Quantidade de termos existentes no campo 440: $QTD_440"                        >> rel_astill_mdl${1}.txt

# Quantidade de termos existentes na base astill
QTD_DBNASTILL=`mx ../tabs/astill "pft=if p(v3) then v3/fi" -all now | sort -u | wc -l`
echo "            Quantidade de termos existentes na base astill: $QTD_DBNASTILL"                  >> rel_astill_mdl${1}.txt

# Quantidade de Termos encontrados na astill
QTD_ASTILL=`mx mdlbb${1}_astill "pft=if p(v1003) and p(v440) then (v440||/)fi" -all now | sort -u | wc -l`
echo "                Quantidade de Termos encontrados na astill: $QTD_ASTILL"                     >> rel_astill_mdl${1}.txt

# Quantidade de Termos nao encontrados na astill
QTD_NASTILL=`mx mdlbb${1}_astill "pft=if a(v1001) and p(v440) then (v440||/)fi" -all now | sort -u | wc -l`
echo "            Quantidade de Termos nao encontrados na astill: $QTD_NASTILL"                    >> rel_astill_mdl${1}.txt

# Termos encontrados na astill
echo                                                                                               >> rel_astill_mdl${1}.txt
echo "-----------------------------------------------------------------------------------"         >> rel_astill_mdl${1}.txt
echo " Termos encontrados na ASTILL"                                                               >> rel_astill_mdl${1}.txt
echo "-----------------------------------------------------------------------------------"         >> rel_astill_mdl${1}.txt
mx mdlbb${1}_astill "pft=if p(v1003) and p(v440) then (v440||/)fi" -all now | sort -u              >> rel_astill_mdl${1}.txt

# Termos nao encontrados na astill
echo                                                                                               >> rel_astill_mdl${1}.txt
echo "-----------------------------------------------------------------------------------"         >> rel_astill_mdl${1}.txt
echo " Termos nao encontrados na ASTILL"                                                           >> rel_astill_mdl${1}.txt
echo "-----------------------------------------------------------------------------------"         >> rel_astill_mdl${1}.txt
mx mdlbb${1}_astill "pft=if a(v1001) and p(v440) then (v440||/)fi" -all now | sort -u              >> rel_astill_mdl${1}.txt

retag mdlbb${1}_astill ../tabs/mdl_astill.tab
# ------------------------------------------------------------------------------- #
# Limpeza da area de trabalho
# ------------------------------------------------------------------------------- #
rm serline.*
rm v440.cip
#rm mdlbb${1}_440.*
#rm mdlbb${1}_astill.*


echo "Termino: $0"

TPR="end"
. log

