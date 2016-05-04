#!/bin/bash
# -------------------------------------------------------------------------- #
# traz_mdl_baseline_files.sh - traz XMLs de NLM - baseline por FTP (COMPLETO DO ANO)
# -------------------------------------------------------------------------- #
#     Entrada : <ano com dois caracteres>
#       Saida : Arquivos XML no diretorio
#    Corrente : /bases/mdlG4/fasea
#    Chamadas : ../tpl.mdl/traz_mdl_baseline_files.sh <ano 2 caracteres>
#     Exemplo : nohup ../tpl.mdl/traz_mdl_baseline_files.sh <ano corrente> &> ../outs/proc_get_baseline.YYYYMMDD.out &
# Observacoes : Itens de entrada antecedidos por * sao OBRIGATORIOS
# -------------------------------------------------------------------------- #
# 20111006  Marcelo Bottura / Fabio Brito           Edicao Original
# -------------------------------------------------------------------------- #

# ----------------------------------------------------------------------- #
# verifica existencia dos diretorios BACK e SDI
# ----------------------------------------------------------------------- #

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
	MSG="use: $0 <ANO_Corrente_2_DIGITOS> Ex: 11"
	. log
fi

# Confere existencia de diretorio
DIR_WRK="baseline_xml/wrk"
if [ ! -d $DIR_WRK ]
then
   [ ! -d baseline_xml ] && mkdir baseline_xml
   [ ! -d $DIR_WRK ] && mkdir $DIR_WRK
fi

# Entrando no diretorio WRK para realizar processamento
cd $DIR_WRK
echo
echo "** Operando agora em `pwd` **"
echo


echo "Iniciando  FTP de NLM - baseline files"
echo "======================================"
echo "Inicio: `date '+ %Y%m%d %H%M%S'`"
export HORA_INICIO=`date '+ %s'`

echo
echo "Trazendo baseline files..."
echo
ftp -i -n ftp.nlm.nih.gov>nlm.tmp<<!
user anonymous botturam@paho.org
cd nlmdata/.medleasebaseline/gz/
mget medline"$1"n0???.xml.gz
bye
!


echo "Descompacando arquivos..."
ls *.gz > arquivosGZ.txt
for i in `cat arquivosGZ.txt`
do
  echo "Descompactando ${i}..."
  gunzip -v *.gz
done

echo
echo "Concluido..."
[ -f arquivosGZ.txt ] && rm arquivosGZ.txt

cd -

echo "Termino:`date '+ %Y%m%d %H%M%S'`"

HORA_FIM=`date '+ %s'`
DURACAO=`expr $HORA_FIM - $HORA_INICIO`
HORAS=`expr $DURACAO / 60 / 60`
MINUTOS=`expr $DURACAO  / 60 % 60`
SEGUNDOS=`expr $DURACAO % 60`
echo "Tempo transcorrido: $DURACAO [s]"
echo "Ou ${HORAS}h ${MINUTOS}m ${SEGUNDOS}s"
[ -f nlm.tmp ] && rm nlm.tmp

