#!/bin/bash

# -------------------------------------------------------------------------- #
# faselilmh - Procedimento para geracao da LILACS
# -------------------------------------------------------------------------- #
# Chamada : faselilmh.sh <ID_FI> <LOOPCHECK>
# Exemplo : faselilmh.sh bde 10000
# Sintaxe : faselilmh <dbn> <loopcheck>
# -------------------------------------------------------------------------- #
#  Centro Latino-Americano e do Caribe de Informação em Ciências da Saúde    #
#     é um centro especialidado da Organização Pan-Americana da Saúde,       #
#           escritório regional da Organização Mundial da Saúde              #
#                     BIREME / OPS / OMS (P)1994-2016                        #
# -------------------------------------------------------------------------- #
# Historico
# Versao data, responsavel
#       - Descricao
cat > /dev/null <<HISTORICO
vrs:  0.00 19940301, Renato Sousa
        - Edicao original
vrs:  0.01 20160919, FJLopes
	- Efetua chamada especifica de genormh.sh sem lilcd intermediario
HISTORICO

# ========================================================================== #
#                                  FUNCOES                                   #
# ========================================================================== #
function apaga {
        [ $(ls $1 2> /dev/null | wc -l) -gt 0 ] && rm -f $1
}

TPR="start"
. log

if [ "$#" -ne 2 ]
then 
   TPR="fatal"
   MSG="use: faselilmh <dbn> <loopcheck>"
   . log 
fi

# -------------------------------------------------------------------------- #
# Fase 1 
# Nesta fase foi gerada a base LILDE para a fase 2
# -------------------------------------------------------------------------- #
echo "Fase 1 - Executa genormh.sh $1 ../tabs/decsall"

TPR="iffatal"
MSG="Erro no genormh"
../shs.lil/genormh.sh $1 ../tabs/decsall
. log

# -------------------------------------------------------------------------- #
# Fase 2 
# -------------------------------------------------------------------------- #
echo "Fase 2 - Executa genlilct.sh"

TPR="iffatal"
MSG="Erro no genlilct"
../tpl.lil/genlilct.sh $1de $2
. log

# -------------------------------------------------------------------------- #
# Fase 3 
# -------------------------------------------------------------------------- #
echo "Fase 3 - Executa genlilmh"

TPR="iffatal"
MSG="Erro no genlilmh"
../tpl.lil/genlilmh $1de $2
. log

#----------------------------------------------------------------------#
# Fase 4 
#----------------------------------------------------------------------#
#TPR="iffatal"
#MSG="Erro no countmh"
#../tpl.lil/countmh $1mhi decs 810 820  ## Quando houver PX mais 830 e 840
#. log

#----------------------------------------------------------------------#
# Fase 5 
#----------------------------------------------------------------------#
# comentado em 09/05/2011
#TPR="iffatal"
#MSG="Erro no genlilex"
#../tpl.lil/genlilex $1de decsex decs $1deat categ
#. log

# comentado em 09/05/2011
#TPR="iffatal"
#MSG="Erro no countex"
#../tpl.lil/countex $1exi decs ../tabs/decsex 830 840 ../tabs/tabex
#. log

echo "Executa genkwicmh.sh"
TPR="iffatal"
MSG="Erro no genkwicmh"
../tpl.lil/genkwicmh.sh decs ../tabs/decsex $1
. log

#TPR="iffatal"
#MSG="Erro no gendecst.sh"
#../tpl.lil/gendecst.sh decs 1000 1000    ## Esse cara faz o gencateg
#. log

# -------------------------------------------------------------------------- #
# Geracao das bases de dados ZDECS. Essas bases contem os descritores
# principais por idioma (campos 1, 2 e 3) que serao utilizados nas in-
# faces de recuperacao de dados
# -------------------------------------------------------------------------- #

echo "Executa genzdecs"
TPR="iffatal"
MSG="Erro na geracao das bases zdecs's"
../tpl.lil/genzdecs decs
. log


#TPR="iffatal"
#MSG="Erro na compressao da base $1de"
#compress -fv $1de.mst $1de.xrf
#. log

# rm kwmh* *.prc *.tab *.par *.seq wmhi* lserok* $167

echo "Limpa a area de trabalho"
apaga '*ln1'
apaga '*ln2'
apaga '*lk1'
apaga '*lk2'

TPR="end"
. log
