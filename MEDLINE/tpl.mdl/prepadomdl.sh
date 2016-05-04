# --------------------------------------------------------------------------
#
# Processamento de preparo da ADOLEC porcao MEDLINE
#
# Este procedimento devera ser executado apos o processamento normal do
# MEDLINE e dele resultara um ISO para uso no processamento da ADOLEC. Este
# Processamento e derivado da geracao da parte LILACS para ADOLEC.
#
# --------------------------------------------------------------------------
# Execucao:  diretorio de processamento
# Sintaxe:   prepadomdl.sh <DP>
# Data:      13/11/2001 - Chico/Marcelo
# --------------------------------------------------------------------------
# Este procedimento efetua as seguintes operacoes:
#  1- toma a base MEDLINE (mdlbb??.xrf) e sobre ele efetua um SEARCH obtendo
#     uma base de dados com os registros ADOLEC (base adomdl_<DP>.*)
#  2- Move arquivos para o diretorio indicado como parametro de chamada e 
#     limpa area dos arquivo auxiliares utilizados
# --------------------------------------------------------------------------

TPR="start"
. log

DP=`pwd|cut -f4 -d/|cut -c2-3`

# fazer procao MDL-ADOLEC apenas dos anos 1998 ate o ano corrente - 26/02/2010
if [ $DP != "60" -a $DP != "61" -a $DP != "62" -a $DP != "63" -a $DP != "64" -a $DP != "65" -a $DP != "66" -a $DP != "67" -a $DP != "68" -a $DP != "69" -a $DP != "70" -a $DP != "71" -a $DP != "72" -a $DP != "73" -a $DP != "74" -a $DP != "75" -a $DP != "76" -a $DP != "77" -a $DP != "78" -a $DP != "79" -a $DP != "80" -a $DP != "81" -a $DP != "82" -a $DP != "83" -a $DP != "84" -a $DP != "85" -a $DP != "86" -a $DP != "87" -a $DP != "88" -a $DP != "89" -a $DP != "90" -a $DP != "91" -a $DP != "92" -a $DP != "93" -a $DP != "94" -a $DP != "95" -a $DP != "96" -a $DP != "97" ]
then

# -------------------------------------------------------------------------

# Verifica a disponibilidade dos arquivos de entrada do processamento
# Base de dados MDLBB
if [ ! -f mdlbb$DP.xrf ]
then
   TPR="fatal"
   MSG="Erro: Falta a base de dados MDLBB$DP"
   . log
fi

# Base de dados BWS
if [ ! -f mdl.xrf ]
then
   TPR="fatal"
   MSG="Erro: Falta a base de dados MDL.xrf"
   . log
fi

# Base de dados ZDECSI
if [ ! -f ../tabs/zdecsi.xrf ]
then
   TPR="fatal"
   MSG="Erro: Falta a base de dados ZDECSI"
   . log
fi

# Arquivo com o argumento de pesquisa
if [ ! -f ../tabs/search.ado ]
then
   TPR="fatal"
   MSG="Erro: Falta o arquivo SEARCH.ADO com a pesquisa"
   . log
fi

# Gera a base DECOD para apontar para o ZDECSI
echo "!ID 000001">decoder.id
echo "!v001!../tabs/zdecsi">>decoder.id
echo "!v002!;">>decoder.id
echo "!v003!351">>decoder.id
id2i decoder.id create=decoder

# Gera p101 utilizado na pesquisa
echo "!ID 000001">p101.id
echo "!v101!^pMH ^ymdlmhi">>p101.id
echo "!v101!^pTI ^ymdlti">>p101.id
echo "!v101!^pTW ^ymdltw">>p101.id
echo "!v101!^pCT ^uLI ^ymdllii">>p101.id
id2i p101.id create=p101

# ITEM 1
# Efetua uma pesquisa na MEDLINE para extracao de registros ADOLEC

if [ -f adomdlmfn.xrf ]
then
   rm adomdlmfn.xrf
   rm adomdlmfn.mst
fi

TPR="iffatal"
MSG="Erro: Efetuando a pesquisa SEARCH.ADO"
mx mdlbb$DP invx=p101 "bool=@../tabs/search.ado" "proc='d*',|a969~|v969|~|" append=adomdlmfn now -all
. log

echo "969 0 (v969/)" > adomdlmfn.fst

TPR="iffatal"
MSG="Erro: invertendo adomdlmfn..."
gentree adomdlmfn adomdlmfn 100000 no
. log


TPR="iffatal"
MSG="Erro: join mdl X adomdlmfn"
#mx mdl decod=decoder gizmo=../tabs/tab142b gizmo=../tabs/diac "join=adomdlmfn,1999:999=v999^3/" "proc=if a(v32001^m) then 'd*' else 'd32001d1999' fi" iso=adomdl$DP.iso -all now tell=10000
mx mdl decod=decoder "join=adomdlmfn,1999:999=v999^3/" "proc=if a(v32001^m) then 'd*' else 'd32001d1999' fi" iso=adomdl$DP.iso -all now tell=10000
. log

rm adomdlmfn.*


TPR="iffatal"
MSG="Erro: MDL2LIL - convertendo de MDL p/ LIL"
../tpl.mdl/mdl2lil.sh adomdl$DP adolil$DP
. log

# ITEM 6
# Cria (se necessario) diretorio para receber o ISO
if [ ! -d ado ]
then
   mkdir ado
fi

# copia porcao MEDLINE da ADOLEC para /bases/lilG4/tabs
TPR="iffatal"
MSG="erro na copia de adolil$DP.iso para /bases/lilG4/tabs"
cp adolil$DP.iso /bases/lilG4/tabs
. log
mv adolil$DP.iso ado


# Limpa area
rm decoder.*
rm adomdl$DP.iso
rm p101.*

# FI referente ao IF no inicio do deste programa
else
   exit 0
fi


TPR="end"
. log
