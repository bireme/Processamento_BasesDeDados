#!/bin/bash
# ------------------------------------------------------------------------- #
# gerestMST.sh - Geracao de estatistica das bases MEDLINE
# ------------------------------------------------------------------------- #
#      Entrada: <bloco>
#        Saida: arquivos xml no servidor serverofi
#     Corrente: /bases/mdlG4
#      Chamada: gerestMST.sh <bloco>
#      Exemplo: tpl.mdl/gerestMST.sh 6611
#  Objetivo(s): Gerar arquivo XML no servidor SERVEROFI com numeros referente
#               a atualizacao da base a cada processamento.
#  Comentarios: Todo e qualquer comentario sobre algoritmo, metodos,
#                 descricao de arquivos e etc.
#  Observacoes: Observacoes relevantes para o processamento
# Dependencias: Relacoes de dependencia para execucao, como arquivos
#                 auxiliares esperados, estrutura de diretorios, etc.
#               NECESSARIAMENTE entre o servidor de trigramas e esta maquina
#                 deve haver uma CHAVE PUBLICA DE AUTENTICACAO, de forma que
#                 seja dispensada a interacao com operador para os processos
#                 de transferencia de arquivos.
# ------------------------------------------------------------------------- #
#   DATA    Responsaveis             Comentarios
# 20100326  Fabio Brito              Edicao original
# 20100705  Fabio Brito              Inclusao da extracao de dados de texto completo
# 20100809  Fabio Brito              Incluindo condicional para certificar se recolheu valores
#                                    corretamente dos blocos
# 20101122  Fabio Brito              Melhoria na verificacao da existencia dos blocos
#                                    - Verifica o 1o bloco, se nao existir atribui valores fixos
#                                    - Varifica o 2o bloco, se nao existir nao cria estatistica
# 20110131  Fabio Brito              Alteracao no processo para trabalhar apenas com 1 bloco
# 20120208  Fabio Brito              Melhoramento na extracao da data de criacao
# 20130226  Fabio Brito              Comentado trecho que envia XML para servdiro serverofi.bireme.br
# 20130226  Fabio Brito              Envio do XML realizado agora por shell /bases/lilG4/tpl.lil/Envia_TS01DX.sh
#                                    ao servidor com Wordpress - TS01DX.
# ------------------------------------------------------------------------- #

TPR="start"
. log

# Verifica a passagem dos parametros
if [ "$#" -ne 1 ]
then
   TPR="fatal"
   MSG="use: gerestMST.sh <bloco>
	                <bloco> = bloco de Medline - ex. 6611"
   . log
fi


# Entra no bloco 1 para recolher dados
echo "#########################################################################"
echo "           Levantamento Estatistico de Medline"
echo "#########################################################################"
echo


echo "Verificando existencia do bloco m${1}.mdl"

if [ -d m${1}.mdl ]
then

echo "Processando bloco ( m${1}.mdl )"
# Tamanho do resultado de processamento
tamanho_bloco=`du -s m${1}.mdl | tail -1 | cut -f1`
echo "Tamanho em disco bytes: ${tamanho_bloco}"


# Quantidade de registros Ativos
cd  m${1}.mdl
registros_bloco=`mx mdl${1} "pft=v32701/" now | wc -l`
echo "Total de registros: $registros_bloco"

# Quantidade de link com texto completo - full text
ft_bloco_INTERNET=`${LINDG4}/mz mdlot "key1=FT " -posts count=10 now | grep "FT " | grep "FT INTERNET" | cut -d "/" -f "2"`
ft_bloco_PMC=`${LINDG4}/mz mdlot "key1=FT " -posts count=10 now | grep "FT " | grep "FT PMC" | cut -d "/" -f "2"`
ft_bloco_SCIELO=`${LINDG4}/mz mdlot "key1=FT " -posts count=10 now | grep "FT " | grep "FT SCIELO" | cut -d "/" -f "2"`

echo "full text bloco:"
echo " - INTERNET: ${ft_bloco_INTERNET}"
echo " - PMC: ${ft_bloco_PMC}"
echo " - SCIELO: ${ft_bloco_SCIELO}"
echo


###############################################################################
# DATA DE ATUALIZACAO
###############################################################################
# Recupera data de ultima atualizacao
ARQUIVO=`ls -l --full-time ntitle.iso`

ANO=`echo ${ARQUIVO} | awk {' print $6 '} | cut -d '-' -f '1'`
MES=`echo ${ARQUIVO} | awk {' print $6 '} | cut -d '-' -f '2'`
DIA=`echo ${ARQUIVO} | awk {' print $6 '} | cut -d '-' -f '3'`

# Montando a data para MASTER
DT="${ANO}${MES}${DIA}"
echo "data de processamento: $DT"
echo

echo
# Totalizando
tot_reg="${registros_bloco}"
tot_tam="${tamanho_bloco}"
FT_INTERNET="${ft_bloco_INTERNET}"
FT_PMC="${ft_bloco_PMC}"
FT_SCIELO="${ft_bloco_SCIELO}"


## Transformando em Gigabytes
#tot_tam=`expr "(${tot_tam} / 1024 ) / 1024" | bc -l` # em Giga
tot_tam=`expr "${tot_tam} / 1024 " | bc -l` # em Mega
tot_tam=`printf "%.2f\n" ${tot_tam}`


echo "Recolhendo total de registros do ultimo processamento"
tot_old=`tail -1 ../tabs/mdl_est.txt | cut -d" " -f1`
tot_week=`expr $tot_reg - $tot_old`

echo "Recolhendo total de registros full text (INTERNET) do ultimo processamento"
tot_ft_INTERNET_old=`tail -1 ../tabs/mdl_est.txt | cut -d" " -f3`
ft_INTERNET_week=`expr $FT_INTERNET - $tot_ft_INTERNET_old`

echo "Recolhendo total de registros full text (PMC) do ultimo processamento"
tot_ft_PMC_old=`tail -1 ../tabs/mdl_est.txt | cut -d" " -f4`
ft_PMC_week=`expr $FT_PMC - $tot_ft_PMC_old`

echo "Recolhendo total de registros full text (SCIELO) do ultimo processamento"
tot_ft_SCIELO_old=`tail -1 ../tabs/mdl_est.txt | cut -d" " -f5`
ft_SCIELO_week=`expr $FT_SCIELO - $tot_ft_SCIELO_old`

echo
echo "Tamanho em disco (Gb): ${tot_tam}"
echo "Total de registros: ${tot_reg}"
echo "Total inserido no ultimo processamento: ${tot_week}"

if [ ${tot_old} = ${tot_reg} -o $registros_bloco = 0 ]
then
	echo "Nao houve inclusao de registros, verificar"
else
	echo "Inserindo total do ultimo processamento em arquivo"
	echo "${tot_reg} ${DT} ${FT_INTERNET} ${FT_PMC} ${FT_SCIELO}" >> ../tabs/mdl_est.txt
fi


# ESCREVE XML COM DADOS RECOLHIDOS
##################################

# Recolhe informacoes descritivas da FI
cp $TABS/FI_descricao.id .
id2i FI_descricao.id create=FI_descricao
echo "  + Titulo"
TITULO="mx FI_descricao lw=0 \"pft=if v1='mdl_full.xml' then v2/ fi\" -all now"
TITULO=`${TITULO}`

echo "  + Descricao"
DESCRICAO="mx FI_descricao lw=0 \"pft=if v1='mdl_full.xml' then v3/ fi\" -all now"
DESCRICAO=`${DESCRICAO}`

[ -f  FI_descricao.id ] && rm  FI_descricao.id
[ -f  FI_descricao.xrf ] && rm  FI_descricao.{mst,xrf}

#mdl_full.xml
[ -f ../mdl_full.xml ] && rm ../mdl_full.xml
echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"                               >> ../mdl_full.xml
echo "   <INFO_SRC>"                                                                 >> ../mdl_full.xml
echo "      <INFO_SRC_NAME FREQ=\"s\">mdl_full</INFO_SRC_NAME>"                      >> ../mdl_full.xml
echo "      <REC_NUMBER>${tot_reg}</REC_NUMBER>"                                     >> ../mdl_full.xml
echo "      <DISK_SPACE UNIT=\"Mbytes\">${tot_tam}</DISK_SPACE>"                     >> ../mdl_full.xml
echo "      <PROCESSING_TIME UNIT=\"human\">720:00:00</PROCESSING_TIME>"             >> ../mdl_full.xml
echo "      <LAST_UPDATE>${DT}</LAST_UPDATE>"                                        >> ../mdl_full.xml
echo "      <FULL_TEXT_INTERNET>${FT_INTERNET}</FULL_TEXT_INTERNET>"                 >> ../mdl_full.xml
echo "      <FULL_TEXT_PMC>${FT_PMC}</FULL_TEXT_PMC>"                                >> ../mdl_full.xml
echo "      <FULL_TEXT_SCIELO>${FT_SCIELO}</FULL_TEXT_SCIELO>"                       >> ../mdl_full.xml

echo "      <TP_PERIODICAL>${tot_reg}</TP_PERIODICAL>"                               >> ../mdl_full.xml
echo "      <TP_MONOGRAPH>${TP_MONOGRAFIA}</TP_MONOGRAPH>"                           >> ../mdl_full.xml
echo "      <TP_THESIS>${TP_TESE}</TP_THESIS>"                                       >> ../mdl_full.xml
echo "      <TP_UNCONVENTIONAL>${TP_NCONVENCIONAL}</TP_UNCONVENTIONAL>"              >> ../mdl_full.xml

echo "      <TITLE_FI>${TITULO}</TITLE_FI>"                                          >> ../mdl_full.xml
echo "      <DESCRIPTION_FI>${DESCRICAO}</DESCRIPTION_FI>"                           >> ../mdl_full.xml

echo "   </INFO_SRC>"                                                                >> ../mdl_full.xml


#mdl_week.xml
[ -f ../mdl_week.xml ] && rm ../mdl_week.xml
echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"                               >> ../mdl_week.xml
echo "   <INFO_SRC>"                                                                 >> ../mdl_week.xml
echo "      <INFO_SRC_NAME FREQ=\"s\">mdl_week</INFO_SRC_NAME>"                      >> ../mdl_week.xml
echo "      <REC_NUMBER>${tot_week}</REC_NUMBER>"                                    >> ../mdl_week.xml
echo "      <DISK_SPACE UNIT=\"Mbytes\"></DISK_SPACE>"                               >> ../mdl_week.xml
echo "      <PROCESSING_TIME UNIT=\"human\">24:00:00</PROCESSING_TIME>"              >> ../mdl_week.xml
echo "      <LAST_UPDATE>${DT}</LAST_UPDATE>"                                        >> ../mdl_week.xml
echo "      <FULL_TEXT_INTERNET>${ft_INTERNET_week}</FULL_TEXT_INTERNET>"            >> ../mdl_week.xml
echo "      <FULL_TEXT_PMC>${ft_PMC_week}</FULL_TEXT_PMC>"                           >> ../mdl_week.xml
echo "      <FULL_TEXT_SCIELO>${ft_SCIELO_week}</FULL_TEXT_SCIELO>"                  >> ../mdl_week.xml
echo "   </INFO_SRC>"                                                                >> ../mdl_week.xml

cd ..
echo "Agora em `pwd`"
echo

# ------------------------------------------------------------------------- #
# ENVIA XML PARA SERVIDOR TS01DX
################################
/bases/lilG4/tpl.lil/Envia_TS01DX.sh mdl_full.xml 
/bases/lilG4/tpl.lil/Envia_TS01DX.sh mdl_week.xml

# ------------------------------------------------------------------------- #

# Limpando area de trabalho
unset registros_bloco tamanho_bloco
unset ARQ_MST DATA_ANALISE DATA_ANALISE1
unset ARQ_MST DIA_MST MES_MST
unset HORA_MST DOIS_PONTOS
unset ANO DT
unset tot_tam tot_reg tot_old tot_week
unset FT_INTERNET FT_PMC FT_SCIELO
unset ft_INTERNET_week ft_PMC_week ft_SCIELO_week
unset TP_PERIODICO
unset TP_MONOGRAFIA
unset TP_TESE
unset TP_NCONVENCIONAL

[ -f mdl_week.xml ] && rm mdl_week.xml
[ -f mdl_full.xml ] && rm mdl_full.xml

echo
echo "Fim da geracao dos XMLs de estatistica OFI"
echo 

fi

###############################################################################################################
exit

