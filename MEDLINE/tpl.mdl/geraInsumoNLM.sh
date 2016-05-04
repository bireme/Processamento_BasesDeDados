#!/bin/bash
# -------------------------------------------------------------------------- #
# geraInsumoNLM.sh - traz XMLs de NLM e converte criando arquivos isis
# -------------------------------------------------------------------------- #
#     Entrada : nenhuma
#       Saida : Arquivos XMLs e arquivos ISIS
#    Corrente : /bases/mdlG4/fasea
#    Chamadas : ../tpl.mdl/geraInsumoNLM.sh
#     Exemplo : nohup ../tpl.mdl/geraInsumoNLM.sh &> ../outs/proc_geraInsumoNLM.YYYYMMDD.out &
# Observacoes : Processo coordena o processo de transferencia dos XMLs e depois cria os registros em
#               formato isis
#
# -------------------------------------------------------------------------- #
# 20140730    Fabio Brito           Edicao Original
# -------------------------------------------------------------------------- #


# echo "========================="
# echo "  Ambiente de execucao"
# echo "========================="
# set
# echo "========================="

. /usr/local/bireme/misc/profile.sh
PATH=$PATH:$HOME/bin:/usr/local/bin:$LINDG4:$CISIS:/usr/local/bireme/misc:/usr/local/bireme/procs:/bases/mdlG4/tpl.mdl
export PATH


data=`date '+%d/%m/%y %H:%M'`

TPR="start"
. log

# Verificando posicionamento correto para o processamento
LOCAL=`pwd`
if [ "${LOCAL}" != "/bases/mdlG4/fasea" ]
then
    cd /bases/mdlG4/fasea
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


echo "-> Realizando a coleta de XMLs da NLM..."
echo "./tpl.mdl/traz_mdl_update_files.sh $MDL_ANOCORRENTE2DIGITOS"
../tpl.mdl/traz_mdl_update_files.sh $MDL_ANOCORRENTE2DIGITOS
if [ "$?" -ne 0 ]
then
    echo "$0 - Erro de processamento!"
    echo "<html><pre><font face=\"Courier New,Courier, monospace\"> " > mensagem_coleta.txt
    echo "Ocorreu erro na coleta de arquivos XML da NLM." >> mensagem_coleta.txt
    echo "" >> mensagem_coleta.txt
    echo "" >> mensagem_coleta.txt
    echo "--------------------------------------------------------------------------------------" >> mensagem_coleta.txt
    echo "# Informacao dessa chamada:" >> mensagem_coleta.txt
    echo "  serverofi5:$0" >> mensagem_coleta.txt
    echo "--------------------------------------------------------------------------------------" >> mensagem_coleta.txt
    echo "</font></pre></html> " >> mensagem_coleta.txt
    sendemail -u "CRON-serverofi5 - XMLs NLM coleta e conversao" -f serverofi5@bireme.org -t ofi@bireme.org -s esmeralda.bireme.br -xu $SENDER_MAIL -xp bir@2012# -o message-file=mensagem_coleta.txt
    [ -f mensagem_coleta.txt ] && rm mensagem_coleta.txt
    exit 1
fi


echo "  -> Verificando se existem arquivos para converter..."
cd update_xml/wrk
# Apagando arquivo que mostra os arquivos convertidos do processamento anterior
[ -f conversoes.lst ] && rm conversoes.lst

# Verificando a existencia de arquivos XML para processamento
EXISTE=`ls *.xml | wc -l`
if [ ${EXISTE} -eq 0 ]
then
    echo "$0 - Sem arquivos XML para processamento!"
    echo "<html><pre><font face=\"Courier New,Courier, monospace\"> " > mensagem_coleta.txt
    echo "Nao existem arquivos XML para processamento. Estamos atualizados." >> mensagem_coleta.txt
    echo "" >> mensagem_coleta.txt
    echo "" >> mensagem_coleta.txt
    echo "--------------------------------------------------------------------------------------" >> mensagem_coleta.txt
    echo "# Informacao dessa chamada:" >> mensagem_coleta.txt
    echo "  serverofi5:$0" >> mensagem_coleta.txt
    echo "--------------------------------------------------------------------------------------" >> mensagem_coleta.txt
    echo "</font></pre></html> " >> mensagem_coleta.txt

    # para Fabio e Marcelo
    sendemail -u "CRON-serverofi5 - XMLs NLM coleta e conversao" -f serverofi5@bireme.org -t ofi@bireme.org -s esmeralda.bireme.br -xu $SENDER_MAIL -xp bir@2012# -o message-file=mensagem_coleta.txt
    [ -f mensagem_coleta.txt ] && rm mensagem_coleta.txt

    exit 0

else
    echo "Arquivos XMLs para converter: ${EXISTE}"

    # Informacao para e-mail
    arquivos_xml="`ls *.xml`" 

fi
 
# voltando a fasea
cd -

echo "-> Realizando a conversao de XML para ISIS..."
echo "../tpl.mdl/GenBasesCISIS.sh update"
../tpl.mdl/GenBasesCISIS.sh update
if [ "$?" -ne 0 ]
then
    echo "$0 - Erro de processamento!"
    echo "<html><pre><font face=\"Courier New,Courier, monospace\"> " > mensagem_coleta.txt
    echo "Ocorreu erro na conversao de arquivos XML para ISIS." >> mensagem_coleta.txt
    echo "" >> mensagem_coleta.txt
    echo "" >> mensagem_coleta.txt
    echo "--------------------------------------------------------------------------------------" >> mensagem_coleta.txt
    echo "# Informacao dessa chamada:" >> mensagem_coleta.txt
    echo "  serverofi5:$0" >> mensagem_coleta.txt
    echo "--------------------------------------------------------------------------------------" >> mensagem_coleta.txt
    echo "</font></pre></html> " >> mensagem_coleta.txt
    sendemail -u "CRON-serverofi5 - XMLs NLM coleta e conversao" -f serverofi5@bireme.org -t ofi@bireme.org -s esmeralda.bireme.br -xu $SENDER_MAIL -xp bir@2012# -o message-file=mensagem_coleta.txt
    [ -f mensagem_coleta.txt ] && rm mensagem_coleta.txt
    exit 1
fi


# Mensagem resumo
echo
echo "<html><pre><font face=\"Courier New,Courier, monospace\"> " > mensagem_coleta.txt
echo "Foi realizada a coleta e conversao de $EXISTE arquivo XML da NLM." >> mensagem_coleta.txt
echo "" >> mensagem_coleta.txt
echo "$arquivos_xml" >> mensagem_coleta.txt
echo "" >> mensagem_coleta.txt
echo "--------------------------------------------------------------------------------------" >> mensagem_coleta.txt
echo "# Informacao dessa chamada:" >> mensagem_coleta.txt
echo "  serverofi5:$0" >> mensagem_coleta.txt
echo "--------------------------------------------------------------------------------------" >> mensagem_coleta.txt
echo "</font></pre></html> " >> mensagem_coleta.txt


# para Fabio e Marcelo
sendemail -u "CRON-serverofi5 - XMLs NLM coleta e conversao" -f serverofi5@bireme.org -t ofi@bireme.org -s esmeralda.bireme.br -xu $SENDER_MAIL -xp bir@2012# -o message-file=mensagem_coleta.txt
[ -f mensagem_coleta.txt ] && rm mensagem_coleta.txt



echo
echo "FIM do processo agendado."
echo "$0"


# Limpando area de trabalho
unset data LOCAL EXISTE arquivos_xml


