#!/bin/bash
# ----------------------------------------------------------------------------------- #
# traz_mdl_update_files.sh - traz XMLs de NLM - update files por FTP (COMPLETO DO ANO)
# ----------------------------------------------------------------------------------- #
#     Entrada : <ano com dois caracteres>
#       Saida : Arquivos no formato XML no diretorio
#    Chamadas : ../tpl.mdl/traz_mdl_update_files.sh <ano 2 caracteres>
#    Corrente : /bases/mdlG4/fasea
#     Exemplo : nohup ../tpl.mdl/traz_mdl_update_files.sh <ano 2 caracteres> &> ../outs/proc_get_update.YYYYMMDD.out &
# Observacoes : 
# ----------------------------------------------------------------------------------- #
# 20111006  Marcelo Bottura / Fabio Brito      Edicao Original
# 20120628  Fabio Brito / Marcelo Bottura      verifica se pode realizar processamento atraves da
#                                              analise da existencia de arquivos de flag.
# ----------------------------------------------------------------------------------- #

TPR="start"
. log

# Verificando posicionamento correto para o processamento
LOCAL=`pwd`
if [ "${LOCAL}" != "/bases/mdlG4/fasea" ]
then
   TPR="fatal"
   MSG="Erro: Diretorio correto: /bases/mdlG4/fasea"
   . log
fi
unset LOCAL

if [ "$#" -ne 1 ]
then
  TPR="fatal"
  MSG="use: pre_mdl.sh <ANO_corrente_2_DIGITOS>"
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

# Confere existencia de diretorio
DIR_WRK="update_xml/wrk"
if [ ! -d $DIR_WRK ]
then
   [ ! -d update_xml ] && mkdir update_xml
   [ ! -d $DIR_WRK ] && mkdir $DIR_WRK
fi

# Entrando no diretorio WRK para realizar processamento
cd $DIR_WRK
echo
echo "** Operando agora em `pwd` **"
echo

echo "Iniciando  FTP de NLM - update files"
echo "===================================="
echo "Inicio: `date '+ %Y%m%d %H%M%S'`"
export HORA_INICIO=`date '+ %s'`

ftp -i -n ftp.nlm.nih.gov>nlm.tmp<<!
user anonymous botturam@paho.org
cd nlmdata/.medlease/gz
ls medline"$1"n????.xml.gz
bye
!

NRO_ARQUIVOS_EM_XML=`ls ../*.xml |wc -l`
echo $NRO_ARQUIVOS_EM_XML
if [ "$NRO_ARQUIVOS_EM_XML" -eq 0 ] 
then 
   echo "Nao ha arquivos em /update_xml"
   echo "Baixando todos..."
   wc -l nlm.tmp|cut -d "`expr substr nlm.tmp 1 1`" -f "1" | tr -d " " > todos_xml.seq
   read QTD_DOWNLOAD < todos_xml.seq
   rm todos_xml.seq
else
   LASTBIR=`ls ../medline??n????.xml|cut -f2 -d\/|tail -1`
   echo "ultima fita:" $LASTBIR

   QTD_BIR=`grep -n "$LASTBIR" nlm.tmp|cut -f1 -d\:`
   echo "Qtde BIREME..." $QTD_BIR

   wc -l nlm.tmp|sed "s/$$//" > tmp
   mx seq=tmp "pft=f(val(v1),1,0)/" now > tmp1
   read QTD_NLM < tmp1
   echo "Qtde NLM..." $QTD_NLM

   QTD_DOWNLOAD=`expr $QTD_NLM - $QTD_BIR`
   echo "Diferenca..." $QTD_DOWNLOAD

   #if [ "$QTD_DOWNLOAD" -lt "4" ]
   #   then
   #     echo "pouca Qtde de arquivos ($QTD_DOWNLOAD). Nova tentativa sera feita em 24hs!!!"
   #     rm nlm.tmp tmp tmp1
   #     exit 0
   #   else
   #     echo "Qtde minima de arquivos atingida... $QTD_DOWNLOAD"
        # Apaga arquivo de FLAG para execucao do proc MDL (genmdlmensal.sh)
	[ -f mdlOK.flag ] && rm mdlOK.flag
   #fi

fi


if [ "$QTD_DOWNLOAD" -eq "0" ]
then
   rm nlm.tmp tmp tmp1
   TPR="fatal"
   MSG="AVISO!!! Nao ha arquivos para Download!"
   . log
fi

FITAS=`tail -$QTD_DOWNLOAD nlm.tmp|cut -c56-73`
echo

echo "Trazendo arquivos MEDLINE da NLM..."
echo "ftp -i -n ftp.nlm.nih.gov<<!" > nlm_download.sh
echo "user anonymous botturam@paho.org" >> nlm_download.sh
echo "cd nlmdata/.medlease/gz" >> nlm_download.sh
for i in $FITAS
do
  echo "mget $i.gz" >> nlm_download.sh
  echo "mget $i.gz.md5" >> nlm_download.sh
done
echo "bye" >> nlm_download.sh
echo "!" >> nlm_download.sh

chmod 755 nlm_download.sh
./nlm_download.sh
rm nlm_download.sh nlm.tmp tmp tmp1


# Faz check MD5 para nos arquivos MEDLINE

ls medline??n????.xml.gz.md5 > labmd5

COUNT=1
wc -l labmd5 > tmp1
mx seq=tmp1 "pft=f(val(v1),1,0)/" now>tmp
read LEN < tmp
rm tmp tmp1

while
     [ $COUNT -le $LEN ]
do
     NAMEIN=`tail -$COUNT labmd5|head -1`
     echo $NAMEIN
     if  [ ! -f $NAMEIN ]
     then
         TPR="fatal"
         MSG="$NAMEIN nao encontrado"
         . log
     fi
     COUNT=`expr $COUNT + 1`
done

unset LEN
unset COUNT
unset NAMEIN
[ -f labmd5 ] && rm labmd5

# Descomprime GZ dos arquivos MEDLINE
TPR="iffatal"
MSG="Erro descompressao dos GZs"
gunzip -v *.gz
. log

rm *.md5

echo
echo "Concluido."
echo "Termino:`date '+ %Y%m%d %H%M%S'`"

HORA_FIM=`date '+ %s'`
DURACAO=`expr $HORA_FIM - $HORA_INICIO`
HORAS=`expr $DURACAO / 60 / 60`
MINUTOS=`expr $DURACAO  / 60 % 60`
SEGUNDOS=`expr $DURACAO % 60`
echo "Tempo transcorrido: $DURACAO [s]"
echo "Ou ${HORAS}h ${MINUTOS}m ${SEGUNDOS}s"

