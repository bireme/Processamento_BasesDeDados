#!/bin/bash
# ------------------------------------------------------------------------- #
# GenBasesCISIS.sh - Extrai elementos de XML da NLM para base CISIS (MEDLINE)
# ------------------------------------------------------------------------- #
#   Parametros: [ update / baseline ]
#        Saida: masteres de inversao e browser
#     Corrente: /bases/mdlG4/fasea/
#      Chamada: ../tpl.mdl/GenBasesCISIS.sh [update|baseline]
#      Exemplo: nohup ../tpl.mdl/GenBasesCISIS.sh [update|baseline] &> ../outs/[update|baseline]_proc.YYYYMMDD.out &
#  Objetivo(s): Criar bases CISIS com elementos de XML da NLM para processamento MEDLINE
#  Comentarios:
#  Observacoes: A estrutura de diretorios esperada eh:
#                       /bases/???.???
#                               |
#                               +--- outs
#                               +--- tabs
#                               +--- tpl.mdl
#                               +--- bases
#                               +--- fasea
#                                        |
#                                        + update_xml
#                                        + update_isis
#                                        + baseline_xml
#                                        + baseline_isis
#                                        + arquivos XML para processar
#
# Dependencias:
#
# ==> tpl.mdl/GenBasesCISIS.sh
#    - bases/decs.mst-xrf-fst
#    - bases/gqlfi.mst-xrf
#    - bases/XMLs.lst
#    ==> tpl.mdl/ConvXML2ISIS.sh
#       ==> tpl.mdl/Xml2Isis.sh
#              - xmls (diretorio) 
#              - tabs/mdl.tab
#       ==> tpl.mdl/Medline.sh
#
#       - tabs/ixmlmdl.prc
#       - $TABS/gutf8ansFFIG4
#       - $TABS/gansnaFFIG4"
#       - $TABS/ghtmlansFFIG4
#       - gqlfi
#       - tabs/decs.prc
#       - tabs/bxmlmdl.prc
#       - tabs/DeleteCitation.tab
#       - id.fst
#
#
# ------------------------------------------------------------------------- #
#   DATA    Responsaveis      Comentarios
# 20101105  Fabio Brito       Edicao original
# 20111006  Fabio Brito       Migracao de todo o processo de OFI2 para OFI3
# 20111006  Fabio Brito       Adaptação para trabalhar com DeCS existente em tabs
#                             Adaptação para trabalhar com update/baseline
# 20111110  Fabio Brito       Adaptacao para ler arquivos XML a partir do diretorio fasea
# 20111111  Fabio Brito       Alteracao temporaria da indicacao do diretorio /tabs para /tabs.oficial
#                             sera necessario posterior alteracao quando isso estiver normalizado
# 20120202  Fabio Brito       Foi copiado decs.mst/xrf do processamento de 20111215 para /tabs em caixa alta
#                             ou seja, DECS.mst/xrf pois o decs.mst/xrf existente em /tabs o Marcelo utiliza para
#                             fazer indexacao.
# 20120202  Fabio Brito       Alteracao de onde estava /tabs.ofical para /tabs
# 20120203  Fabio Brito       Inclusao da criacao de mdlOK.flag ao final do processamento
# 20120628  Fabio Brito       verifica se pode realizar processamento atraves da
#                             analise da existencia de arquivos de flag.
#
#
#

# Sinaliza inicio de execucao
TPR="start"
. log

# ------------------------------------------------------------------------- #
# Anota hora de inicio de processamento
export HORA_INICIO=`date '+ %s'`
export HI="`date '+%Y.%m.%d %H:%M:%S'`"

echo "[TIME-STAMP] `date '+%Y.%m.%d %H:%M:%S'` [:INI:] Processa ${0} ${1}"
echo ""
# ------------------------------------------------------------------------- #

# Verificando parametros da chamada
if [ $# -lt 1 ]
then
	TPR="fatal"
	MSG="Use: ${0} [update|baseline]"
        . log
fi

# Verificando posicionamento correto para o processamento
LOCAL=`pwd`
if [ "${LOCAL}" != "/bases/mdlG4/fasea" ]
then
        TPR="fatal"
        MSG="Diretorio de execucao incorreto"
        . log
fi


# Verifica a existencia dos flag´s de processamento MEDLINE. Se algum desses arquivos existir
# não deverá ser realizado esse processamento. Esse arquivos indicam que no momento esta sendo
# realizado o merge dos anos e criacao do invertido.
# /bases/mdlG4/proc_MEDLINE_MergeAnos_em_curso.ok
# /bases/mdlG4/proc_MDL_ANOCORRENTE_em_curso.ok

if [ -f ../proc_MEDLINE_MergeAnos_em_curso.ok -o -f ../proc_MDL_ANOCORRENTE_em_curso.ok ]
then
   TPR="fatal"
   MSG="Erro: Processamento MEDLINE sendo realizado nesse momento!"
   . log
fi

# Determinado tipo de processamento
TIPO_PROC=`echo ${1} | tr [:lower:] [:upper:]`
# if [ "${TIPO_PROC}" = "UPDATE" -o "${TIPO_PROC}" = "BASELINE" ]
if [ "${TIPO_PROC}" = "UPDATE" -o "${TIPO_PROC}" = "BASELINE" -o "${TIPO_PROC}" = "TESTE" ]
then
	echo "Processamento TIPO : $TIPO_PROC"
	echo "=================================="
else
        TPR="fatal"
        MSG="Use: ${0} [update|baseline]"
	. log
fi


# Determinando diretorio
TIPO_PROCm=`echo ${TIPO_PROC} | tr [:upper:] [:lower:]`
DIR_XML_WRK="${TIPO_PROCm}_xml/wrk"
DIR_XML="${TIPO_PROCm}_xml"
DIR_ISIS="${TIPO_PROCm}_isis"

# Verificando existencia dos diretorios
if [ ! -d ${DIR_XML_WRK} -o ! ${DIR_XML} -o ! -d ${DIR_ISIS} ]
then
        TPR="fatal"
	MSG="ERRO.: Diretorios essencias faltantes ( Verificar : $DIR_XML_WRK, $DIR_XML ou $DIR_ISIS )"
        . log
fi

# Entrando no diretorio WRK para realizar processamento
cd ${DIR_XML_WRK}
echo
echo "** Operando agora em `pwd` **"
echo

# Apagando arquivo que mostra os arquivos convertidos do processamento anterior
[ -f conversoes.lst ] && rm conversoes.lst

# Verificando a existencia de arquivos XML para processamento
EXISTE=`ls *.xml | wc -l`
if [ ${EXISTE} -eq 0 ]
then
        TPR="fatal"
        MSG="ERRO.: Sem arquivos XML para processamento!"
        . log
else
	echo "Arquivos XMLs para converter: ${EXISTE}"
fi


echo "--> Trazendo base DECS para processamento"
echo "*****  UTILIZANDO DECS existente em TABS - checar a existencia de versao mais nova  ******"

# o processo utiliza o DECS criado a partir de /bases/mdlG4/tpl.mdl/gentabs.sh

cp ../../../tabs/DECS.mst decs.mst
cp ../../../tabs/DECS.xrf decs.xrf


# Cria campo v1500 apenas para ter o v3 sem acentuacao - objetivando criacao do v87 e v88 em ordem alfabetica correta
${FFIG4}/mx decs "proc='<1500 0>',v3,'</1500>'" create=decs1 -all now
${FFIG4}/mx decs1 "gizmo=$TABS/gansnaFFIG4,1500" create=decs2 -all now
[ -f decs1.mst ] && rm decs1.[xm][rs][ft]
[ -f decs.mst ] && rm decs.[xm][rs][ft]
mv decs2.mst decs.mst
mv decs2.xrf decs.xrf

# Criando FST
echo "1 0 v1/"          > decs.fst
echo "2 0 v1500/"      >> decs.fst
echo "14 0 mpl,|/|v14" >> decs.fst

echo "${FFIG4}/mx decs \"fst=@decs.fst\" fullinv=decs tell=5000"
TPR="iffatal"
MSG="${0} - Erro invertendo decs"
${FFIG4}/mx decs "fst=@decs.fst" fullinv=decs tell=5000
. log

echo "--> Gerando base de qualificadores para este processamento"
# Apaga arquivos do ultimo processamento
[ -f gqlfi.xrf ] && rm gqlfi.*
TPR="iffatal"
MSG="${0} - Erro criando base de qualificadores"
${FFIG4}/mx decs "proc='d*',if v1.1='/' then '<1>^2'v1*1'</1>','<2>^q'v14'</2>' fi" append=gqlfi -all now
. log

echo "--> Montando lista de arquivos XML para processamento..."
ls *.xml | sed s/"\.xml"//g > XMLs.lst
QTD_arqs_processar=`cat XMLs.lst | wc -l`

for i in `cat XMLs.lst`
do
        COUNT=`expr ${COUNT} + 1`
	echo "---------------------------------------------------------------------------------------------"
	echo "*** Arquivo de trabalho ( ${COUNT} / ${QTD_arqs_processar} ): ${i}.xml ***"
	TPR="iffatal"
	MSG="${0} - Chamando Conversao"
	../../../tpl.mdl/ConvXML2ISIS.sh ${i} `pwd`
	. log
done


# ------------------------------------------------------------------------- #
echo "[TIME-STAMP] `date '+%Y.%m.%d %H:%M:%S'` [:FIM:] Processa ${0} ${1}"
# ------------------------------------------------------------------------- #

echo ""
echo "RELATORIO DE PROCESSAMENTO"
echo "-------------------------------------------------------------------------"
QTD_arqs_processados=`cat conversoes.lst | wc -l`
echo " Arquivos para processamento: ${QTD_arqs_processar}"
echo " Arquivos processados:        ${QTD_arqs_processados}"
echo "-------------------------------------------------------------------------"


if [ ${QTD_arqs_processar} -eq ${QTD_arqs_processados} ]
then
        # deprecated - nao chegou a ser utilizado - Marcelo
	#echo " --> Copiando arquivos para /bases/mdlG4/m30.mdl"
        #cp ?md????b.* /bases/mdlG4/m30.mdl

	echo "  --> Levando processamento para ${DIR_ISIS}"
	mv ?md????b.* ../../${DIR_ISIS}

	echo "  --> Levando arquivos XMLs utilizados para ${DIR_XML}"
	mv *.xml ..

	# apagando relatorio de processados
	[ -f conversoes.lst ] && rm conversoes.lst
	[ -f XMLs.lst ] && rm XMLs.lst

	# grava mdlOK.flag
	if [ "${TIPO_PROC}" = "UPDATE" ]
	then
		cd ${LOCAL}
		echo "Conversoes realizadas - ${HI}" > mdlOK.flag
	fi
else
	echo "ALERTA!!!!"
	echo "Numero de arquivos processados inconsistente"
	echo "Analise arquivos \"conversoes.lst\" e \"XMLs.lst\""
	exit
fi


cd -


HORA_FIM=`date '+ %s'`
DURACAO=`expr ${HORA_FIM} - ${HORA_INICIO}`
HORAS=`expr ${DURACAO} / 60 / 60`
MINUTOS=`expr ${DURACAO} / 60 % 60`
SEGUNDOS=`expr ${DURACAO} % 60`


echo
echo "DURACAO DE PROCESSAMENTO"
echo "-------------------------------------------------------------------------"
echo " - Inicio:  ${HI}"
echo " - Termino: `date '+%Y.%m.%d %H:%M:%S'`"
echo
echo " Tempo de execucao: ${DURACAO} [s]"
echo " Ou ${HORAS}h ${MINUTOS}m ${SEGUNDOS}s"
echo

# Limpando area de trabalho
unset HI
unset HORA_INICIO
unset HORA_FIM
unset DURACAO
unset HORAS
unset MINUTOS
unset SEGUNDOS
unset LOCAL
unset QTD_arqs_processar
unset QTD_arqs_processados
unset COUNT
unset EXISTE
unset TIPO_PROCm
unset DIR_XML_WRK
unset DIR_XML
unset DIR_ISIS
[ -f decs.xrf ] && rm decs.*
[ -f gqlfi.xrf ] && rm gqlfi.*

TPR="end"
. log
