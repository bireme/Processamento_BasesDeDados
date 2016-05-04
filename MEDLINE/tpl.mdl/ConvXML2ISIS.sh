#!/bin/bash
# ------------------------------------------------------------------------- #
# ConvXML2ISIS.sh - Extrai elementos de XML da NLM para base CISIS (MEDLINE)
# ------------------------------------------------------------------------- #
#      Entrada: PARM1 nome do arquivo XML sem a extensao
#               PARM2 diretorio origem o qual serao lido os arquivos XML
#        Saida: masteres de inversao e browser
#     Corrente: /bases/mdlG4/fasea
#      Chamada: ../../../tpl.???/ConvXML2ISIS.sh <arquivo XML sem extensao> <diretorio dos XMLs>
#      Exemplo: nohup ../../../tpl.mdl/ConvXML2ISIS.sh medline10n0999 [updata_xml|baseline_xml] &> ../../../outs/proc.YYYYMMDD.out &
#  Objetivo(s): Criar bases CISIS com elementos de XML da NLM para processamento MEDLINE
#  Comentarios:
#  Observacoes: A estrutura de diretorios esperada eh:
#                       /bases/???.???
#                               |
#                               +--- outs
#                               +--- tabs
#                               +--- tpl.mdl
#                               +--- fasea
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
#       - tabs/decs87_88.prc
#       - tabs/bxmlmdl.prc
#       - tabs/DeleteCitation.tab
#       - id.fst
#
#
# ------------------------------------------------------------------------- #
#   DATA    Responsaveis      Comentarios
# 20101105  Fabio Brito       Edicao original
# 20111011  Fabio Brito       Adaptacao para trabalhar com update e baseline
# 20111110  Fabio Brito       Adaptacao para ler arquivos XML a partir do diretorio fasea
# 20111111  Fabio Brito       Alteracao temporaria da indicacao do diretorio /tabs para /tabs.oficial
#                             sera necessario posterior alteracao quando isso estiver normalizado
# 20120202  Fabio Brito       Retorno de /tabs.oficial para /tabs
# 20120202  Fabio Brito       Inclusao do campo 375 na truncagem do numero de ocorrencias
# 20120809  Fabio Brito       Apos ocorrer o erro (fatal: recxref/read) foi necessario realizar a inclusao
#                             de um processo para criar uma base "tratada" com todos os registros.
# 20151113  Fabio Brito       Inclusao do gizmo /tabs/gmdl352 para corrigir ^ nos campos v352 e v380.
#                             aplicado na criacao do master de browser.
#

# Sinaliza inicio de execucao
TPR="start"
. log

#echo "---------------------------------------------------------------------------------------------"
echo "[TIME-STAMP] `date '+%Y.%m.%d %H:%M:%S'` [:INI:] Processa ${0} ${1}"
echo "---------------------------------------------------------------------------------------------"

# Verifica a passagem dos parametros
if [ "$#" -ne 2 ]
then
   TPR="fatal"
   MSG="use: ConvXML2ISIS.sh <arquivo XML sem extensao>
                        Ex. ./ConvXML2ISIS.sh medline10n0999"
   . log
fi

# Gera a estrutura do MST de BROWSE
echo "mstxl=64G" > mdlxl.par
CIPAR=mdlxl.par
export CIPAR

OUTDB=`echo ${1} | cut -d/ -f3-3`
#OUTDB=`echo ${1} | cut -d/ -f4-4`

DIR_XML=${2}

# Apagando processamento anterior
[ -f ${OUTDB}.xrf ] && rm ${OUTDB}.[mx][sr][tf]
[ -f tmp1_${OUTDB}.xrf ] && rm tmp1_${OUTDB}.[mx][sr][tf]
[ -f tmp1_${OUTDB}_tratada.xrf ] && rm tmp1_${OUTDB}_tratada.[mx][sr][tf]
[ -f tmp2_${OUTDB}.xrf ] && rm tmp2_${OUTDB}.[mx][sr][tf]
[ -f tmp3_${OUTDB}.xrf ] && rm tmp3_${OUTDB}.[mx][sr][tf]
[ -f tmp4_${OUTDB}.xrf ] && rm tmp4_${OUTDB}.[mx][sr][tf]
[ -f tmp5_${OUTDB}.xrf ] && rm tmp5_${OUTDB}.[mx][sr][tf]
[ -f tmp6_${OUTDB}.xrf ] && rm tmp6_${OUTDB}.[mx][sr][tf]
[ -f tmp6_PT_${OUTDB}.xrf ] && rm tmp6_PT_${OUTDB}.[mx][sr][tf]
[ -f tmp6_PT_NOACENT_${OUTDB}.xrf ] && rm tmp6_PT_NOACENT_${OUTDB}.[mx][sr][tf]
[ -f tmp7_${OUTDB}.xrf ] && rm tmp7_${OUTDB}.[mx][sr][tf]
[ -f tmp8_${OUTDB}.xrf ] && rm tmp8_${OUTDB}.[mx][sr][tf]
[ -f Del_${OUTDB}.xrf ] && rm Del_${OUTDB}.[mx][sr][tf]
[ -f Delete_${OUTDB}.xrf ] && rm Delete_${OUTDB}.[mx][sr][tf]


# ------------------------------------------------------------------------- #
echo "[${0}] 1 - Criando Master de Inversao..."
# ------------------------------------------------------------------------- #
echo "Extraindo elementos"

# echo "../../../tpl.mdl/Xml2Isis.sh fileDir=${DIR_XML} xmlRegExp=${OUTDB}.xml convTable=../../../tabs/mdl.tab outDb=${OUTDB} --createMissingFields --createFileNameField fileEncoding=utf-8 dbEncoding=utf-8"
TPR="iffatal"
MSG="${0} - Extraindo elementos"
../../../tpl.mdl/Xml2Isis.sh fileDir=${DIR_XML} xmlRegExp=${OUTDB}.xml convTable=../../../tabs/mdl.tab outDb=${OUTDB} --createMissingFields --createFileNameField fileEncoding=utf-8 dbEncoding=utf-8
. log

echo "Sincronizando descritores"
TPR="iffatal"
MSG="${0} - Sincronizando descritores"
../../../tpl.mdl/Medline.sh ${OUTDB} utf-8 tmp1_${OUTDB}
. log

# Tratando erro ocasionado na criacao de ${OUTDB} para tmp1_${OUTDB} - Fabio Brito - 20120809
# fatal: recxref/read
TOTAL=`${FFIG4}/mx ${OUTDB} "pft=mfn/" now | wc -l`
${FFIG4}/mx tmp1_${OUTDB} from=1 to=${TOTAL} create=tmp1_${OUTDB}_tratada -all now
unset TOTAL


echo "Preparando base Isis - formato, gizmos"
# Monta campos de acordo com processamento MEDLINE
TPR="iffatal"
MSG="${0} - Preparando base Isis - formato, gizmos"
echo "${FFIG4}/mx tmp1_${OUTDB}_tratada \"proc=@../../../tabs/ixmlmdl.prc\" \"proc='d701'\" \"gizmo=$TABS/gutf8ansFFIG4\" create=tmp2_${OUTDB} -all now tell=5000"
${FFIG4}/mx tmp1_${OUTDB}_tratada "proc=@../../../tabs/ixmlmdl.prc" "proc='d701'" "gizmo=$TABS/gutf8ansFFIG4" create=tmp2_${OUTDB} -all now tell=5000
. log


echo "Trata campo 370 - Abstract"
# ------------------------------------------------------------------------- #
# O campo 370 nesse momento, vem com um espaco no primeiro caracter, entao foi necessario fazer esses procedimentos.
# Cria campo 370 com somente 1 ocorrencia caso seja repetitivo
TPR="iffatal"
MSG="${0} - Trara campo 370 - step 1"
${FFIG4}/mx tmp2_${OUTDB} "proc='d*',if p(v370) then '<370>',v370,'</370><969>',v969,'</969>', fi" create=tmp370_${OUTDB} -all now tell=5000
. log

# Limpa base tmp370 retirando o espaco no inicio do campo
TPR="iffatal"
MSG="${0} - Trara campo 370 - step 2"
${FFIG4}/mxcp tmp370_${OUTDB} create=tmp370_clean_${OUTDB} clean > /dev/null
. log

# Inverte para possibilitar join
TPR="iffatal"
MSG="${0} - Trara campo 370 - step 3"
${FFIG4}/mx tmp370_clean_${OUTDB} "fst='1 0 v969/'" fullinv=tmp370_clean_${OUTDB} -all now tell=5000
. log

# Cria base sem campo 370
TPR="iffatal"
MSG="${0} - Trara campo 370 - step 4"
${FFIG4}/mx tmp2_${OUTDB} "proc='d370'" create=tmp2_s370_${OUTDB} -all now tell=5000
. log


# Realiza join trazendo campo 370 limpo
TPR="iffatal"
MSG="${0} - Trara campo 370 - step 5"
${FFIG4}/mx tmp2_s370_${OUTDB} "join=tmp370_clean_${OUTDB},370,1=v969" "proc='d32001'" create=tmp3_${OUTDB} -all now tell=5000
. log
# ------------------------------------------------------------------------- #



# Trata entidades HTML
TPR="iffatal"
MSG="${0} - Trata entidades HTML"
${FFIG4}/mx tmp3_${OUTDB} "gizmo=$TABS/ghtmlansFFIG4" create=tmp4_${OUTDB} -all now tell=5000
. log

# Altera nomenclatura dos qualificadores
TPR="iffatal"
MSG="${0} - Altera nomenclatura dos qualificadores"
${FFIG4}/mx tmp4_${OUTDB} "gizmo=gqlfi,870,880" create=tmp5_${OUTDB} -all now tell=5000
. log

# Criando nome para arquivo final
TPR="iffatal"
MSG="${0} - Criando nome para arquivo final"
nome_arquivo=`echo ${OUTDB}.xml | cut -c11-14`
. log

# Tira repetitivos para o campo de descritor 870
TPR="iffatal"
MSG="${0} - Tira repetitivos para o campo de descritor 870"
${FFIG4}/mx tmp5_${OUTDB} "proc='s870'" "proc='d870',(if p(v870) then if v870=s0 then else '<870 0>',v870,'</870>',s0:=(v870) fi fi)" create=tmp6_${OUTDB} -all now tell=5000
. log

# Cria campos 873 e 883 - Descritores em portugues - ordenado
TPR="iffatal"
MSG="${0} - Cria campos 873 e 883 - Descritores em portugues - ordenado"
${FFIG4}/mx tmp6_${OUTDB} "proc=(if p(v870) then '<873>^h'ref->decs(l->decs(v870^h/),v3),if p(v870^q) then '^q',v870^q,fi,if p(v870^3) then '^3',v870^3,fi '</873>' fi)" "proc=(if p(v880) then '<883>^h'ref->decs(l->decs(v880^h/),v3),if p(v880^q) then '^q',v880^q,fi,if p(v880^3) then '^3',v880^3,fi '</883>' fi)" "proc='s873'" "proc='s883'" create=tmp6_PT_${OUTDB} -all now tell=5000

# Retira acentuacao do v873 e v888
${FFIG4}/mx tmp6_PT_${OUTDB} "gizmo=$TABS/gansnaFFIG4,873,883" create=tmp6_PT_NOACENT_${OUTDB} -all now tell=5000


# Cria campos 87 e 88 com mfn relativas ao DECS - baseado em 873 e 883
TPR="iffatal"
MSG="${0} - Cria campos 87 e 88 com mfn relativas ao DeCS - baseado em 873 e 883"
${FFIG4}/mx tmp6_PT_NOACENT_${OUTDB} "proc='s873'" "proc='s883'" "proc=@../../../tabs/decs87_88.prc" create=tmp7_${OUTDB} -all now tell=5000
. log

# Variavel para TRUNCAR quantidade de OCORRENCIAS em v372, 374 e 375
# CommentsCorrectionsList em 440 e
# DataBankList em 701
# Necessario para poder gerar o registro em LINDG4.
# Cria registro com no maximo 100 ocorrencias.
# export OCCMAX=100
export OCCMAX=50
# Alterado em 20140707 pois estava estourando no XML medline14n0940.xml



TPR="iffatal"
MSG="${0} - Ajusta campos 87, 88, 372, 374, 375, 440 e 701"
${FFIG4}/mx tmp7_${OUTDB} "proc='d87',if p(v87) then '<87 0>',(v87+|;|),'</87>' fi" "proc='d88',if p(v88) then '<88 0>',(v88+|;|),'</88>' fi" "proc='d372',if p(v372) then (if iocc > $OCCMAX then break else '<372 0>',v372,'</372>' fi),fi" "proc='d374',if p(v374) then (if iocc > $OCCMAX then break else '<374 0>',v374,'</374>' fi),fi" "proc='d375',if p(v375) then (if iocc > $OCCMAX then break else '<375 0>',v375,'</375>' fi),fi" "proc='d440',if p(v440) then (if iocc > $OCCMAX then break else '<440 0>',v440,'</440>' fi),fi" "proc='d701',if p(v701) then (if iocc > $OCCMAX then break else '<701 0>',v701,'</701>' fi),fi" create=tmp8_adj_${OUTDB} -all now
. log

[ -f imd${nome_arquivo}b.xrf ] && rm imd${nome_arquivo}b.[mx][sr][tf]
mv tmp8_adj_${OUTDB}.mst imd${nome_arquivo}b.mst
mv tmp8_adj_${OUTDB}.xrf imd${nome_arquivo}b.xrf


echo
echo
# ------------------------------------------------------------------------- #
echo "[${0}] 2 - Criando Master de Browser..."
# ------------------------------------------------------------------------- #
# echo "${FFIG4}/mx imd${nome_arquivo}b "gizmo=../../../tabs/gmdl352FFIG4,352,380" "proc=@../../../tabs/bxmlmdl.prc" create=bmd${nome_arquivo}b -all now tell=5000"
TPR="iffatal"
MSG="${0} - Criando Master de Browser..."
${FFIG4}/mx imd${nome_arquivo}b "gizmo=../../../tabs/gmdl352FFIG4,352,380" "proc=@../../../tabs/bxmlmdl.prc" create=bmd${nome_arquivo}b -all now tell=5000
. log

echo
echo
# ------------------------------------------------------------------------- #
echo "[${0}] 3 - Extraindo casos de DeleteCitation caso existam..."
# ------------------------------------------------------------------------- #
EXISTE=`grep DeleteCitation ${1}.xml | wc -l`
if [ ${EXISTE} != 0 ]
then
# echo "../../../tpl.mdl/Xml2Isis.sh fileDir=${DIR_XML} xmlRegExp=${OUTDB}.xml convTable=../../../tabs/DeleteCitation.tab outDb=Del_${OUTDB} --createMissingFields --createFileNameField fileEncoding=utf-8 dbEncoding=utf-8"
TPR="iffatal"
MSG="${0} - Extraindo casos de DeleteCitation - step 1"
../../../tpl.mdl/Xml2Isis.sh fileDir=${DIR_XML} xmlRegExp=${OUTDB}.xml convTable=../../../tabs/DeleteCitation.tab outDb=Del_${OUTDB} --createMissingFields --createFileNameField fileEncoding=utf-8 dbEncoding=utf-8
. log

        export OCCMAXDELETED=500
	# Limitado pois estourou - 2014/11/07

	TPR="iffatal"
	MSG="${0} - Extraindo casos de DeleteCitation - step 2"
	# ${FFIG4}/mx Del_${OUTDB} "proc='d*',(if p(v667) then '<667>',v667,'</667>' fi)" append=Delete_${OUTDB} -all now
	${FFIG4}/mx Del_${OUTDB} "proc='d*',if p(v667) then (if iocc > $OCCMAXDELETED then break else '<667 0>',v667,'</667>' fi),fi" append=Delete_${OUTDB} -all now
	. log

	echo "Juntando elementos de DeleteCitation ao master de Inversao"
	TPR="iffatal"
	MSG="${0} - Extraindo casos de DeleteCitation - step 3"
	${FFIG4}/mx Delete_${OUTDB} append=imd${nome_arquivo}b -all now tell=5000
	. log

else
        echo " --> Sem ocorrencia de DeleteCitation"
fi


if [ ${EXISTE} != 0 ]
then
        echo "Juntando elementos de DeleteCitation ao master de Browser"
	TPR="iffatal"
	MSG="${0} - Juntando elementos de DeleteCitation ao master de Browser"
	${FFIG4}/mx Delete_${OUTDB} append=bmd${nome_arquivo}b -all now tell=5000
	. log

fi
echo
echo


# ------------------------------------------------------------------------- #
echo " --> Retirando acentuacao da base de indice"
# ------------------------------------------------------------------------- #
TPR="iffatal"
MSG="${0} - Retirando acentuacao da base de indice e excluindo campos v873 e v883"
${FFIG4}/mx imd${nome_arquivo}b "gizmo=$TABS/gansnaFFIG4" "proc='d873d883'" create=imd${nome_arquivo}b_noACENT -all now tell=5000
. log

[ -f imd${nome_arquivo}b ] && rm imd${nome_arquivo}b.[xm][rs][ft]
mv imd${nome_arquivo}b_noACENT.mst imd${nome_arquivo}b.mst
mv imd${nome_arquivo}b_noACENT.xrf imd${nome_arquivo}b.xrf
echo

# ------------------------------------------------------------------------- #
echo "[${0}] 4 - Criando arquivos de indice de ID e DeleteCitation, para master de Inversao e Browser"
# ------------------------------------------------------------------------- #

# Criando FST para inversao de ID e DeletedCitation
echo "969 0 v969/"             > id.fst
echo "667 0 mpl,(|DL=|v667/)" >> id.fst

# Verificar necessidade visto que o invertido da base de inversao criara o mesmo resultado
# Criando FST para inversao de ID e DeletedCitation - para Browser
# echo "969 0 v999^3/"           > idb.fst
# echo "667 0 mpl,(|DL=|v667/)" >> idb.fst



echo " --> Realizando CRUNCH de FFIG4 para LINDG4 das bases de Inversao e Browser"
echo "   --> Base Inversao..."
TPR="iffatal"
MSG="${0} - Realizando CRUNCH de FFIG4 para LINDG4 - step 1"
${FFIG4}/crunchmf imd${nome_arquivo}b imd${nome_arquivo}bLINDG4 target=same format=isis tell=5000
. log

[ -f imd${nome_arquivo}b.xrf ] && rm imd${nome_arquivo}b.[xm][rs][ft]
mv imd${nome_arquivo}bLINDG4.mst imd${nome_arquivo}b.mst
mv imd${nome_arquivo}bLINDG4.xrf imd${nome_arquivo}b.xrf

echo "   --> Base Browser..."
TPR="iffatal"
MSG="${0} - Realizando CRUNCH de FFIG4 para LINDG4 - step 2"
${FFIG4}/crunchmf bmd${nome_arquivo}b bmd${nome_arquivo}bLINDG4 target=same format=isis tell=5000
. log

[ -f bmd${nome_arquivo}b.xrf ] && rm bmd${nome_arquivo}b.[xm][rs][ft]
mv bmd${nome_arquivo}bLINDG4.mst bmd${nome_arquivo}b.mst
mv bmd${nome_arquivo}bLINDG4.xrf bmd${nome_arquivo}b.xrf

echo
echo " --> Invertendo master de Inversao"
TPR="iffatal"
MSG="${0} - Invertendo master de Inversao"
${LINDG4}/mx imd${nome_arquivo}b "fst=@id.fst" fullinv=imd${nome_arquivo}b tell=5000
. log

echo
echo " --> Invertendo master de Browser"
TPR="iffatal"
MSG="${0} - Invertendo master de Browser"
#${LINDG4}/mx bmd${nome_arquivo}b "fst=@idb.fst" fullinv=bmd${nome_arquivo}b tell=5000
${LINDG4}/mx bmd${nome_arquivo}b "fst=@id.fst" fullinv=bmd${nome_arquivo}b tell=5000
. log

# Atualiza arquivo de conversoes realizadas
echo ${1}.xml >> conversoes.lst

# Conferindo total de registros de master de Inversao e Browser
. scrmax imd${nome_arquivo}b
MFNBWS=${MAXMFN}
. scrmax bmd${nome_arquivo}b
MFNBB=${MAXMFN}

if [ ! ${MFNBWS} = ${MFNBB} ]
then
   TPR='fatal'
   MSG="Error: imd${nome_arquivo}b X bmd${nome_arquivo}b recs is not equal"
   . log
fi



# Limpeza da area de trabalho
unset MFNBWS
unset MFNBB

# DEBUG 
LIMPA_TEMPORARIOS=TRUE
if [ ${LIMPA_TEMPORARIOS} ]
then
   [ -f ${OUTDB}.xrf ] && rm ${OUTDB}.[mx][sr][tf]
   [ -f tmp1_${OUTDB}.xrf ] && rm tmp1_${OUTDB}.[mx][sr][tf]
   [ -f tmp1_${OUTDB}_tratada.xrf ] && rm tmp1_${OUTDB}_tratada.[mx][sr][tf]
   [ -f tmp2_${OUTDB}.xrf ] && rm tmp2_${OUTDB}.[mx][sr][tf]
   [ -f tmp2_s370_${OUTDB}.xrf ] && rm tmp2_s370_${OUTDB}.[mx][sr][tf]
   [ -f tmp370_clean_${OUTDB}.xrf ] && rm tmp370_clean_${OUTDB}.*
   [ -f tmp370_${OUTDB}.xrf ] && rm tmp370_${OUTDB}.[mx][sr][tf]
   [ -f tmp3_${OUTDB}.xrf ] && rm tmp3_${OUTDB}.[mx][sr][tf]
   [ -f tmp4_${OUTDB}.xrf ] && rm tmp4_${OUTDB}.[mx][sr][tf]
   [ -f tmp5_${OUTDB}.xrf ] && rm tmp5_${OUTDB}.[mx][sr][tf]
   [ -f tmp6_${OUTDB}.xrf ] && rm tmp6_${OUTDB}.[mx][sr][tf]
   [ -f tmp6_PT_${OUTDB}.xrf ] && rm tmp6_PT_${OUTDB}.[mx][sr][tf]
   [ -f tmp6_PT_NOACENT_${OUTDB}.xrf ] && rm tmp6_PT_NOACENT_${OUTDB}.[mx][sr][tf]
   [ -f tmp7_${OUTDB}.xrf ] && rm tmp7_${OUTDB}.[mx][sr][tf]
   [ -f tmp8_${OUTDB}.xrf ] && rm tmp8_${OUTDB}.[mx][sr][tf]
   [ -f Del_${OUTDB}.xrf ] && rm Del_${OUTDB}.[mx][sr][tf]
   [ -f Delete_${OUTDB}.xrf ] && rm Delete_${OUTDB}.[mx][sr][tf]
   [ -f id.fst ] && rm id.fst
#   [ -f idb.fst ] && rm idb.fst
fi

# ------------------------------------------------------------------------- #
echo "[TIME-STAMP] `date '+%Y.%m.%d %H:%M:%S'` [:FIM:] Processa ${0} ${1}"
echo
# ------------------------------------------------------------------------- #

TPR="end"
. log
