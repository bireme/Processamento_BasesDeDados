# -------------------------------------------------------------------------- #
# fasemh - Procedimento para geracao de tipo LILACS
# -------------------------------------------------------------------------- #
# Chamada : fasemh.sh <ID_FI> <LOOPCHECK>
# Exemplo : fasemh.sh bde 10000
# Sintaxe : fasemh <dbn> <loopcheck>
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
vrs:  0.00 19940301, RenatoS
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
   MSG="use: fasemh <dbn> <loopcheck>"
   . log 
fi

TPR="start"
. log

#----------------------------------------------------------------------#
# Fase 1 
#----------------------------------------------------------------------#
echo "Executa genormh.sh"
TPR="iffatal"
MSG="Erro no genormh"
../shs.lil/genormh.sh $1 ../tabs/decsall 
. log

#----------------------------------------------------------------------#
# Fase 2 
#----------------------------------------------------------------------#
TPR="iffatal"
MSG="Erro no genlilct"
../tpl.lil/genothct $1de $2   
. log

#----------------------------------------------------------------------#
# Fase 3 
#----------------------------------------------------------------------#
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

# comentado em 09/11/2011
#TPR="iffatal"
#MSG="Erro no genlilex"
#../tpl.lil/genlilex $1de decsex decs $1deat categ
#. log

#TPR="iffatal"
#MSG="Erro no countex"
#../tpl.lil/countex $1exi decs ../tabs/decsex 830 840 ../tabs/tabex
#. log

TPR="iffatal"
MSG="Erro no genkwicmh"
../tpl.lil/genkwicmh.sh decs ../tabs/decsex $1
. log

#TPR="iffatal"
#MSG="Erro no gendecst.sh"
#../tpl.lil/gendecst.sh decs 1000 1000    ## Esse cara faz o gencateg
#. log

#----------------------------------------------------------------------#
# Fase 2 - Extracao campo 751 do DeCS (somente campo inteiro)
#----------------------------------------------------------------------#
TPR="iffatal"
MSG="Erro na geracao do invertido $1kw"
../tpl.lil/genlil751DeCS.sh $1 $2
. log

#----------------------------------------------------------------------#
# Fase 5 - Extracao de descritores para TW
#----------------------------------------------------------------------#

## Extracao das chaves da base com descritores invalidos (GENORMH) 
TPR="iffatal" 
MSG="Erro na extracao das chaves da base de erro $1er"
genln $1er $1er "1 4 (v870/)"
. log

for i in 1 2
do
  TPR="iffatal"
  MSG="Erro no sort das chaves da base de erro $1er"
  genlk -s $1er.lk$i $1er.ln$i
  . log
done

## MZ palavra/palavra de descritores a partir do invertido gerado na GENLILMH
for j in i e p
do
  TPR="iffatal"
  MSG="Erro no mz - $1mh1$j"
  mz $1mh$j key1=.0 key2=.ZZZZZ "fst=1 4 (v1/)" \
  ln1=$1mhw1$j.ln1 ln2=$1mhw1$j.ln2 gizmo=../tabs/gizqlf$j +fix/m now -all
  . log

  TPR="iffatal"
  MSG="Erro no mz - $1mh$j"
  mz $1mh$j key1=0 key2=ZZZZZ "fst=1 4 (v1/)" \
  ln1=$1mhw$j.ln1 ln2=$1mhw$j.ln2 gizmo=../tabs/gizqlf$j +fix/m now -all
  . log

  for i in 1 2
  do
    TPR="iffatal"
    MSG="Erro no append do arquivo $1mhw1$j.ln$i $1mhw$j.ln$i"
    cat $1mhw1$j.ln$i >>$1mhw$j.ln$i
    . log
  done
  rm $1mhw1?.ln*

  for i in 1 2
  do
    TPR="iffatal"
    MSG="Erro no genlk - $1mhw$j.ln$i"
    genlk -s $1mhw$j.lk$i $1mhw$j.ln$i
    . log
    rm $1mhw$j.ln$i
  done
done

## MZ campo inteiro de descritores a partir do invertido gerado na GENLILMH
for j in i e p
do
  TPR="iffatal"
  MSG="Erro no mz - $1mhd$j"
  mz $1mh$j "fst=1 0 (v1/)" ln1=$1mhd$j.lk1 ln2=$1mhd$j.lk2 +fix/m now -all
  . log
done


## MZ campo inteiro de descritores a partir do invertido gerado na GENLILMH (ac850XT.tab)
for j in i e p
do
  TPR="iffatal"
  MSG="Erro no mz - $1mhd$j"
  mz $1mh$j "fst=1 0 (v1/)" "actab=$TABS/ac850XT.tab" ln1=$1mhd2$j.lk1 ln2=$1mhd2$j.lk2 +fix/m now -all
  . log
done

# ----------------------------------------------------------------------------- #
# Geracao do indice Simbolo (SI) - para PAHO, mas extrai para todas 02/07/2007
# ----------------------------------------------------------------------------- #
cat>$1si.fst<<!
68 0 mpl,(v68/)
68 4 mpl,(v68/)
!

echo "extracting keys ..."
TPR="iffatal"
MSG="Erro na extracao das chaves LN's do PAHO-SI"
mx $1 "fst=@$1si.fst" actab=$TABS/ac850XT.tab ln1=$1si.ln1 ln2=$1si.ln2 +fix/m -all now tell=10000
. log

TPR="iffatal"
MSG="Erro na classificacao das chaves LK1 do PAHO-SI"
genlk -s $1si.lk1 $1si.ln1
. log

TPR="iffatal"
MSG="Erro na classificacao das chaves LK2 do PAHO-SI"
genlk -s $1si.lk2 $1si.ln2
. log

rm  $1si.fst
rm  $1si.ln1 $1si.ln2


## MERGE 
TPR="iffatal"
MSG="Erro no merge dos arquivos ww - lk1"
genlk -m $1ww.lk1 $1mhwp.lk1 $1mhwi.lk1 $1mhwe.lk1 $1mhdp.lk1 $1mhdi.lk1 $1mhde.lk1 $1er.lk1 $1si.lk1 $1mhd2i.lk1 $1mhd2e.lk1 $1mhd2p.lk1
. log
rm $1mhwp.lk1 $1mhwi.lk1 $1mhwe.lk1 $1mhdp.lk1 $1mhdi.lk1 $1mhde.lk1 $1er.lk1 $1si.lk1 $1mhd2$j.lk1 $1mhd2i.lk1 $1mhd2e.lk1 $1mhd2p.lk1

TPR="iffatal"
MSG="Erro no merge dos arquivos ww - lk2"
genlk -m $1ww.lk2 $1mhwp.lk2 $1mhwi.lk2 $1mhwe.lk2 $1mhdp.lk2 $1mhdi.lk2 $1mhde.lk2 $1er.lk2 $1si.lk2 $1mhd2$j.lk2 $1mhd2i.lk2 $1mhd2e.lk2 $1mhd2p.lk2
. log
rm $1mhwp.lk2 $1mhwi.lk2 $1mhwe.lk2 $1mhdp.lk2 $1mhdi.lk2 $1mhde.lk2 $1er.lk2 $1si.lk2 $1mhd2$j.lk2 $1mhd2i.lk2 $1mhd2e.lk2 $1mhd2p.lk2

#----------------------------------------------------------------------#
# Fase 6 
#----------------------------------------------------------------------#
TPR="iffatal"
MSG="Erro no genothtw"
../tpl.lil/genothtw $1
. log

echo "Limpa a area de trabalho"
apaga 'lil67*'
apaga '*lk1'
apaga '*lk2'
apaga '*ln1'
apaga '*ln2'
apaga '*.seq'
apaga '*.prc'

TPR="end"
. log
