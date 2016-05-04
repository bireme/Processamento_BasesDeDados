# ------------------------------------------------------------------------ #
# GENMDLMENSAL.SH - procedimento exclusivamente para gerar o MDL mensal.
#
# Marcelo - 16/08/2002
# Execucao - Produto-Edicao (/base?/mdlG4)
# sintaxe: "genmdlmensal.sh <DE>"
#    onde: <DE> - Ano corrente
#
# -------------------------------------------------------------------------- #

TPR="start"
. log

#if [ "$#" -ne 1 ]
#then
#  TPR="fatal"
#  MSG="Use: genmdlmensal.sh <DE>"
# . log
#fi

# ----------------------------------------------------------------------- #
# verifica condicoes iniciais para processamento
# ----------------------------------------------------------------------- #


# Local da execucao
LOCAL=`pwd`
if [ $LOCAL != "/bases/mdlG4" ]
then
  TPR="fatal"
  MSG="GENMDLMENSAL.SH - Diretorio correto de execucao: /bases/mdlG4"
  . log
fi

if [ -f proc_MEDLINE_MergeAnos_em_curso.ok -o -f proc_MDL_ANOCORRENTE_em_curso.ok ]
then
#  TPR="fatal"
#  MSG="Deve haver processamento ja em curso!!! checar arquivos: proc_MEDLINE_MergeAnos_em_curso.ok e proc_MDL_ANOCORRENTE_em_curso.ok"
#  . log
  echo "apagando proc_MDL_ANOCORRENTE_em_curso.ok"
  rm proc_MDL_ANOCORRENTE_em_curso.ok
  echo "apagando proc_MEDLINE_MergeAnos_em_curso.ok"
  rm proc_MEDLINE_MergeAnos_em_curso.ok
fi

if [ ! -d m$MDL_ANOCORRENTE2DIGITOS.mdl ]
then
   mkdir m$MDL_ANOCORRENTE2DIGITOS.mdl
fi

# Existencia do arquivo de FLAG autorizando a execucao - Marcelo 25/03/2008
if [ ! -f ./fasea/mdlOK.flag ]
then
  TPR="fatal"
  MSG="nao encontrou ./fasea/mdlOK.flag - Nova tentativa em 1 semana"
  . log
fi

# Suscetivel a alteracao conforme o conjunto de anos agrupados
if [ ! -s tabs/pmid/pmid.iyp ]
then
     TPR="fatal"
     MSG="Error: tabs/pmid/pmid.iyp nao encontrado"
     . log
fi

ls fasea/update_isis/bmd*mst |sed "s/fasea\/update_isis\///"|cut -f1 -d\. > fasea/update_isis/labsdi$MDL_ANOCORRENTE2DIGITOS"b"
ls fasea/update_isis/imd*mst |sed "s/fasea\/update_isis\///"|cut -f1 -d\. > fasea/update_isis/labsdi$MDL_ANOCORRENTE2DIGITOS"i"

#if [ ! -s fasea/update_isis/mdlupdate.txt ]
#  then
     cd fasea/update_isis
     TPR="iffatal"
     MSG="Erro: Geracao de fasea/update_isis/mdlupdate.txt (Execucao do ../../tpl.mdl/GENDP.SH"
     ../../tpl.mdl/gendp.sh update $MDL_ANOCORRENTE2DIGITOS
     . log
     cd ../..
#fi

# Check se os arquivos XML sao os mesmos dos MST
PAR_XML=`ls fasea/update_isis/?md?????.???|tail -1|cut -f3 -d\/|cut -c4-7`
PAR_SDI=`ls fasea/update_xml/*.xml|tail -1|cut -f3 -d\/|cut -c11-14`

if [ "$PAR_XML" -ne "$PAR_SDI" ]
then
   TPR="fatal"
   MSG="Error:XML=$PAR_XML diferente SDI=$PAR_SDI - check se o processamento Windows esta correto"
   . log
fi

#
# ----------------------------------------------------------------------- #
# Inicia processamento
# ----------------------------------------------------------------------- #
#
echo "ok" > proc_MDL_ANOCORRENTE_em_curso.ok

TPR="iffatal"
MSG="Erro: genmdlxmlI - master INVERSAO"
./tpl.mdl/genmdlxmli.sh $MDL_ANOCORRENTE4DIGITOS labsdi$MDL_ANOCORRENTE2DIGITOS"i" DE
. log

TPR="iffatal"
MSG="Erro: genmdlxmlB - master BROWSE"
./tpl.mdl/genmdlxmlb.sh $MDL_ANOCORRENTE4DIGITOS labsdi$MDL_ANOCORRENTE2DIGITOS"b" DE
. log

cd m$MDL_ANOCORRENTE2DIGITOS.mdl


TPR="iffatal"
MSG="Erro: mdlmensal2.sh"
../tpl.mdl/mdlmensal2.sh mdl$MDL_ANOCORRENTE2DIGITOS
. log

TPR="iffatal"
MSG="Erro: mdlmensal3.sh"
../tpl.mdl/mdlmensal3.sh mdl$MDL_ANOCORRENTE2DIGITOS pmid
. log

TPR="iffatal"
MSG="Erro: mdlmensal4.sh"
../tpl.mdl/mdlmensal4.sh mdlbb$MDL_ANOCORRENTE2DIGITOS
. log

TPR="iffatal"
MSG="Erro: mdlmensal4.sh"
../tpl.mdl/mdlmensal4.sh mdlab$MDL_ANOCORRENTE2DIGITOS
. log

# tira os mdlbb que nao estao em mdl
TPR="iffatal"
MSG="Erro: mdlmensal6.sh - BB"
../tpl.mdl/mdlmensal6.sh mdl$MDL_ANOCORRENTE2DIGITOS mdlbb$MDL_ANOCORRENTE2DIGITOS
. log

TPR="iffatal"
MSG="Erro: mdlmensal6.sh - AB"
../tpl.mdl/mdlmensal6.sh mdl$MDL_ANOCORRENTE2DIGITOS mdlab$MDL_ANOCORRENTE2DIGITOS
. log


. scrmax mdl$MDL_ANOCORRENTE2DIGITOS
MFNBWS=$MAXMFN
. scrmax mdlbb$MDL_ANOCORRENTE2DIGITOS
MFNBB=$MAXMFN

if [ ! $MFNBWS = $MFNBB ]
then
   TPR='fatal'
   MSG="Error: MDL$MDL_ANOCORRENTE2DIGITOS X MDLBB$MDL_ANOCORRENTE2DIGITOS recs is not equal"
   . log
fi


# Geracao de indices 
TPR="iffatal"
MSG="Erro: genmdlinv"
../tpl.mdl/genmdlinv.sh 100000 $MDL_ANOCORRENTE2DIGITOS
. log

# renomeia Master de browse, se preciso

if  [ -f mdl$MDL_ANOCORRENTE2DIGITOS.xrf ]
 then
    mv mdl$MDL_ANOCORRENTE2DIGITOS.mst mdl.mst
    mv mdl$MDL_ANOCORRENTE2DIGITOS.xrf mdl.xrf
fi

# gerar o indice MDL_LNK
echo
echo "Generating mdl_lnk..."
echo
TPR="iffatal"
MSG="Erro: invlnkmdl $MDL_ANOCORRENTE2DIGITOS"
../tpl.mdl/invlnkmdl.sh mdl mdl_lnk
. log

#copia processamento para OFI4 - 2016
TPR="iffatal"
MSG="Erro: copia proc ano corrente para OFI4"
scp *.* serverofi4:/bases/mdlG4/m16.mdl
. log

# indica para o processamento LILACS que a geracao dos masteres terminou
rm ../proc_MDL_ANOCORRENTE_em_curso.ok


#####################
# MERGE mdl corrente
#####################

echo
echo "Merge MEDLINE-$MDL_BASELINE2DIGITOS $MDL_ANOCORRENTE2DIGITOS..."
echo
cd ..
TPR="iffatal"
MSG="Erro: genmerginv.sh - $MDL_BASELINE2DIGITOS $MDL_ANOCORRENTE2DIGITOS"
./tpl.mdl/genmerginv.sh "$MDL_BASELINE2DIGITOS $MDL_ANOCORRENTE2DIGITOS"
. log

rm mdltw.pft

# gera IY0 dos invertidos
MDL_66ANOCORRENTE="`echo $MDL_BASELINE2DIGITOS| cut -c1-2`$MDL_ANOCORRENTE2DIGITOS"

# espera terminar o merge do TW para continuar (os demais ja estao prontos ha algum tempo)
while [ -f /bases/mdlG4/proc_MEDLINE_MergeAnos_em_curso.ok ]
do
  sleep 60m
done

cd m$MDL_66ANOCORRENTE.mdl
TPR="iffatal"
MSG="Erro: ../tpl.mdl/genmdliy0.sh"
../tpl.mdl/genmdliy0.sh
. log
cd - 

# tranferencia por scp
cd m$MDL_66ANOCORRENTE.mdl
#copia processamento para OFI4 - 2016
TPR="iffatal"
MSG="Erro: copia proc ano corrente para OFI4"
scp *.* serverofi4:/bases/mdlG4/m6616.mdl
. log

ssh $TRANSFER@serverw "mkdir /home/basesG4/mdl/m$MDL_66ANOCORRENTE.mdl"
scp kwic?.mst mdl.mst kwicta.mst $TRANSFER@serverw:/home/basesG4/mdl/m$MDL_66ANOCORRENTE.mdl
scp kwic?.xrf mdl.xrf kwicta.xrf $TRANSFER@serverw:/home/basesG4/mdl/m$MDL_66ANOCORRENTE.mdl
cd iy0
scp *.* $TRANSFER@serverw:/home/basesG4/mdl/m$MDL_66ANOCORRENTE.mdl
scp ntitle.iy0 $TRANSFER@serverw:/home/basesG4/mdl/auxs
cd -

# Apaga arquivo de FLAG liberando FASEA para nova execucao
rm ./fasea/mdlOK.flag
rm mdl*.mrg

# Envia aviso de fim de processamento e MFN enviado pelo DFI
TPR="iffatal"
MSG="Erro: E-mail de fim de proc. para OFI"
sendemail -f appofi@bireme.org -u "FIM do Proc. MedLINE - `date`" -m "terminou sem erros" -t ofi@bireme.org -s esmeralda.bireme.br -xu $SENDER_MAIL -xp bir@2012#
. log
echo
echo "FIM do Proc. MedLINE - `date`"

# envia email de atualizacao de IAH-MEDLINE para ITI; neste caso, apenas para o precessamento de 3f
TPR="iffatal"
MSG="Erro: /usr/local/bireme/procs/emailITI.sh mdl"
/usr/local/bireme/procs/emailITI.sh mdl
. log


# Geracao de estatistica para OFI - Fabio Brito - 20100329
cd /bases/mdlG4
tpl.mdl/gerestMST.sh $MDL_66ANOCORRENTE


TPR="end"
. log
