# -------------------------------------------------------------------------- #
# GENMERGINV - Template para a juncao dos indices (comuns e com traducao) 
#              de varios anos em um unico, geralmente os anos que compoem
#              um BACKFILE.
#   
# Marcelo  - 24/05/96
# Execucao - Produto-Edicao
# sintaxe:   genmerginv <"DP DP DP...">
#
# -------------------------------------------------------------------------- #

TPR="start"
. log

echo
echo "Inicio: genmerginv"
echo

if [ "$#" -ne 1 ]
then 
   TPR="fatal"
   MSG="use: genmerginv <\"DP DP DP...\">"
   . log 
fi

# --------------------------------------------------------------------------- #
# Verificacao da existencia de arquivos 
# --------------------------------------------------------------------------- #

# check existencia dos Master Files (mdl.mst e mdlbb<DP>.xrf)

for i in $1
do

    if  [ ! -f m$i.mdl/mdlbb$i.xrf ]
    then
      echo "nao encontrou m$i.mdl/mdlbb$i.xrf!!!"
      TPR="fatal"
      MSG="m$i.mdl/mdlbb$i.xrf not found"
      . log
    fi

    if  [ ! -f m$i.mdl/mdl.xrf ]
    then
      echo "nao encontrou m$i.mdl/mdl.xrf!!!"
      TPR="fatal"
      MSG="m$i.mdl/mdl.xrf not found"
      . log
    fi

# set variavel ANO_CORRENTE_2_digitos (no final do "for", ficara com o ano corrente
ANO_CORRENTE_2_digitos=`echo $i`

done

# set variavel NAME_DBN (o primeiro ano do parm1 concatenado com o ultimo ano do parm1)
NAME_DBN="`echo $1|tr -d \" \"|cut -c1-2`$ANO_CORRENTE_2_digitos"


# check existencia dos Inverted Files

for i in $1
do
    cd m$i.mdl
    for j in mdlmhi mdlmhe mdlmhp mdlmhc mdllii mdllie mdllip mdlab mdlau mdljr mdlot mdlti mdltw mdl_lnk mdlss mdlafunifesp medlineafi medlineafe medlineafp mdljdi mdljde mdljdp mdlicd mdlmp mdlScieloID mdlaf
    do
        if  [ ! -f $j.cnt -a ! -f $j.iy0 ]
        then
            TPR="fatal"
            MSG="mdl$i: $j inverted file not found"
            . log
        fi
     done
     cd ..
done

# check existencia de arquivos IYP

for i in $1
do
    cd m$i.mdl
    for j in mdlmhe mdlmhp mdlmhc 
    do
        if  [ ! -f $j.iyp -a ! -f $j.iy0 ]
        then
            TPR="iffatal"
            MSG="mdl$i: error cp $j.iyp"
	    cp mdlmhi.iyp $j.iyp
            . log
        fi
     done
     cd ..
done

# ------------------------------------------------------------------------- #
# check existencia dos Mater Files para Links - MDL_LNK.xrf (18/02/2003) 
# ------------------------------------------------------------------------- #

for i in $1
do
    if  [ ! -f m$i.mdl/mdl_lnk.xrf ]
    then
      TPR="fatal"
      MSG="m$i.mdl/mdl_lnk.xrf not found"
      . log
    fi
done


DIRPRODUTO=`pwd`
DIREDICAO=`echo $DIRPRODUTO|cut -f3 -d\/`

# --------------------------------------------------------------------------- #
# Criacao de diretorios no WRK
# --------------------------------------------------------------------------- #

if  [ ! -d /bases/$DIREDICAO ]
then 
      TPR="iffatal"
      MSG="erro na criacao do diretorio /bases/$DIREDICAO"
      mkdir /bases/$DIREDICAO
      . log
fi

if  [ ! -d /bases/$DIREDICAO/m$NAME_DBN.mdl ]
then 
      TPR="iffatal"
      MSG="erro na criacao do diretorio /bases/$DIREDICAO/m$NAME_DBN.mdl Master File"
      mkdir /bases/$DIREDICAO/m$NAME_DBN.mdl
      . log
      MSG="erro na criacao do diretorio /bases/$DIREDICAO/m$NAME_DBN.mdl de LOG"
      mkdir /bases/$DIREDICAO/m$NAME_DBN.mdl/log
      . log
else 
      if  [ ! -d /bases/$DIREDICAO/m$NAME_DBN.mdl/log ]
      then
          MSG="erro na criacao do diretorio /bases/$DIREDICAO/m$NAME_DBN.mdl de LOG"
          mkdir /bases/$DIREDICAO/m$NAME_DBN.mdl/log
          . log
      fi
fi

echo "ok" > /bases/$DIREDICAO/proc_MEDLINE_MergeAnos_em_curso.ok
#-----------------------------------------------------------------------
# Calculo do numero de registros de cada base e o total de todas juntas
#-----------------------------------------------------------------------

DBNTOT=0
PARM1=$1

echo
echo "fazendo merge de: "
echo  $PARM1

for i in $PARM1
do
       mx m$i.mdl/mdlbb$i +control count=1 now >mdlbbmax
       mx seq=mdlbbmax create=mdlbbmax -all now
       mx mdlbbmax from=3 pft=v1/ now >mdlbbmax
       MAXMFNTMP=`cut -c1-7 mdlbbmax`
       MAXMFNTMP=`expr $MAXMFNTMP - 1`
       DBNTOT=`expr $DBNTOT + $MAXMFNTMP`
       rm mdlbbmax*
done


# ------------------------------------------------------------------------- #
# join comum
# ------------------------------------------------------------------------- #

join_comum_background () {

echo "if  [ -f /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV.iy0 ]"                >$INV$$.mrg
echo "then"                                                          >>$INV$$.mrg
echo "    rm  /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV.iy0"                  >>$INV$$.mrg
echo "fi"                                                            >>$INV$$.mrg
echo "date   >/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log"              >>$INV$$.mrg
echo                                                                 >>$INV$$.mrg
echo "TPR=\"iffatal\""                                               >>$INV$$.mrg
echo "MSG=\"Erro: ifmerge /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV\""        >>$INV$$.mrg
echo "ifmerge /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV,$DBNTOT -balan  \\">>$INV$$.mrg

 for i in $PARM1
 do
       mx m$i.mdl/mdlbb$i +control count=1 now >mdlbbmax
       mx seq=mdlbbmax create=mdlbbmax -all now
       mx mdlbbmax from=3 pft=v1/ now >mdlbbmax
       MAXMFNTMP=`cut -c1-7 mdlbbmax`
       MAXMFNTMP=`expr $MAXMFNTMP - 1`
       echo $MAXMFNTMP > mfn_tmp.txt
       read MFN < mfn_tmp.txt
       rm mfn_tmp.txt mdlbbmax*

       echo "       m$i.mdl/$INV,$MFN \\"                          >>$INV$$.mrg
 done

echo "$MST tell=10000 >>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log \\" >>$INV$$.mrg 
echo "                2>>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log   ">>$INV$$.mrg
echo ". log"                                                              >>$INV$$.mrg
echo                                                                      >>$INV$$.mrg
echo "if  [ $INV = \"mdltw\" ]"                                           >>$INV$$.mrg
echo "then"                                                               >>$INV$$.mrg
echo "  rm /bases/$DIREDICAO/proc_MEDLINE_MergeAnos_em_curso.ok"          >>$INV$$.mrg
echo "fi"                                                                 >>$INV$$.mrg
echo "date  >>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log"              >>$INV$$.mrg

chmod 700 $INV$$.mrg
./$INV$$.mrg &
#rm $INV$$.mrg

}

# ------------------------------------------------------------------------- #
# join comum
# ------------------------------------------------------------------------- #

join_comum () {

echo "if  [ -f /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV.iy0 ]"                >$INV$$.mrg
echo "then"                                                          >>$INV$$.mrg
echo "    rm  /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV.iy0"                  >>$INV$$.mrg
echo "fi"                                                            >>$INV$$.mrg
echo "date   >/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log"              >>$INV$$.mrg
echo                                                                 >>$INV$$.mrg
echo "TPR=\"iffatal\""                                               >>$INV$$.mrg
echo "MSG=\"Erro: ifmerge /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV\""        >>$INV$$.mrg
echo "ifmerge /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV,$DBNTOT -balan  \\">>$INV$$.mrg

 for i in $PARM1
 do
       mx m$i.mdl/mdlbb$i +control count=1 now >mdlbbmax
       mx seq=mdlbbmax create=mdlbbmax -all now
       mx mdlbbmax from=3 pft=v1/ now >mdlbbmax
       MAXMFNTMP=`cut -c1-7 mdlbbmax`
       MAXMFNTMP=`expr $MAXMFNTMP - 1`
       echo $MAXMFNTMP > mfn_tmp.txt
       read MFN < mfn_tmp.txt
       rm mfn_tmp.txt mdlbbmax*

       echo "       m$i.mdl/$INV,$MFN \\"                          >>$INV$$.mrg
 done

echo "$MST tell=10000 >>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log \\" >>$INV$$.mrg 
echo "                2>>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log   ">>$INV$$.mrg
echo ". log"                                                         >>$INV$$.mrg
echo                                                                 >>$INV$$.mrg

echo "date  >>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log"              >>$INV$$.mrg

chmod 700 $INV$$.mrg
./$INV$$.mrg
rm $INV$$.mrg

}


# ------------------------------------------------------------------------- #
# join comum LIND
# ------------------------------------------------------------------------- #

join_comum_LIND () {

echo "if  [ -f /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV.iy0 ]"                >$INV$$.mrg
echo "then"                                                          >>$INV$$.mrg
echo "    rm  /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV.iy0"                  >>$INV$$.mrg
echo "fi"                                                            >>$INV$$.mrg
echo "date   >/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log"              >>$INV$$.mrg
echo                                                                 >>$INV$$.mrg
echo "TPR=\"iffatal\""                                               >>$INV$$.mrg
echo "MSG=\"Erro: ifmerge /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV\""        >>$INV$$.mrg
echo "$LIND/ifmerge /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV,$DBNTOT -balan  \\">>$INV$$.mrg

 for i in $PARM1
 do
       mx m$i.mdl/mdlbb$i +control count=1 now >mdlbbmax
       mx seq=mdlbbmax create=mdlbbmax -all now
       mx mdlbbmax from=3 pft=v1/ now >mdlbbmax
       MAXMFNTMP=`cut -c1-7 mdlbbmax`
       MAXMFNTMP=`expr $MAXMFNTMP - 1`
       echo $MAXMFNTMP > mfn_tmp.txt
       read MFN < mfn_tmp.txt
       rm mfn_tmp.txt mdlbbmax*

       echo "       m$i.mdl/$INV,$MFN \\"                          >>$INV$$.mrg
 done

echo "$MST tell=10000 >>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log \\" >>$INV$$.mrg
echo "                2>>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log   ">>$INV$$.mrg
echo ". log"                                                         >>$INV$$.mrg
echo                                                                 >>$INV$$.mrg

echo "date  >>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log"              >>$INV$$.mrg

chmod 700 $INV$$.mrg
./$INV$$.mrg
rm $INV$$.mrg

}


# ------------------------------------------------------------------------- #
# join traducao
# ------------------------------------------------------------------------- #

join_traducao () {

echo "if  [ -f /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV.iy0 ]"                >$INV$$.mrg
echo "then"                                                          >>$INV$$.mrg
echo "    rm  /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV.iy0"                  >>$INV$$.mrg
echo "fi"                                                            >>$INV$$.mrg
echo "date   >/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log"              >>$INV$$.mrg
echo                                                                 >>$INV$$.mrg
echo "TPR=\"iffatal\""                                               >>$INV$$.mrg
echo "MSG=\"Erro: ifmerge /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV\""        >>$INV$$.mrg
echo "ifmerge /bases/$DIREDICAO/m$NAME_DBN.mdl/$INV,$DBNTOT \\"           >>$INV$$.mrg

 for i in $PARM1
 do
       mx m$i.mdl/mdlbb$i +control count=1 now >mdlbbmax
       mx seq=mdlbbmax create=mdlbbmax -all now
       mx mdlbbmax from=3 pft=v1/ now >mdlbbmax
       MAXMFNTMP=`cut -c1-7 mdlbbmax`
       MAXMFNTMP=`expr $MAXMFNTMP - 1`
       echo $MAXMFNTMP > mfn_tmp.txt
       read MFN < mfn_tmp.txt
       rm mfn_tmp.txt mdlbbmax*

       echo "       m$i.mdl/$INV,$MFN \\"                          >>$INV$$.mrg
 done

echo " tell=10000  >>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log \\" >>$INV$$.mrg 
echo "                2>>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log   ">>$INV$$.mrg
echo ". log"                                                         >>$INV$$.mrg
echo                                                                 >>$INV$$.mrg
echo "date  >>/bases/$DIREDICAO/m$NAME_DBN.mdl/log/$INV.log"              >>$INV$$.mrg

chmod 700 $INV$$.mrg
./$INV$$.mrg
rm $INV$$.mrg

}

# ------------------------------------------------------------------------- #
# chamadas para os join's comuns (background)
# ------------------------------------------------------------------------- #

MST="+mstxrf"
for i in mdltw mdlot mdljr mdlti
do
  echo "Merging $i..."
  INV=$i
  join_comum_background
  MST=""
done   

# ------------------------------------------------------------------------- #
# chamadas para os join's comuns
# ------------------------------------------------------------------------- #

MST="+mstxrf"
for i in mdlab mdlau mdl_lnk mdlss mdlafunifesp medlineafi medlineafe medlineafp mdljdi mdljde mdljdp mdlicd mdlmp mdlScieloID mdlaf mdlcateg
do
  echo "Merging $i..."
  INV=$i
  join_comum
  MST=""
done   

# ------------------------------------------------------------------------- #
# chamadas para os join's comuns LIND
# ------------------------------------------------------------------------- #

#MST="+mstxrf"
#for i in mdl_lnkLIND
#do
#  echo "Merging $i..."
#  INV=$i
#  join_comum_LIND
#  MST=""
#done

# ------------------------------------------------------------------------- #
# chamadas para os join's com traducao
# ------------------------------------------------------------------------- #

for i in mdlmhi mdlmhe mdlmhp mdlmhc mdllii mdllie mdllip
do
  echo "Merging $i..."
  INV=$i
  join_traducao
done   

# ------------------------------------------------------------------------- #
# gera master file browse e mdlbb com todos os anos - 06/05/2011
# ------------------------------------------------------------------------- #

rm m$NAME_DBN.mdl/mdl.*
rm m$NAME_DBN.mdl/mdlbb*.*
echo "mstxl=64G" > mdlxl64.par
for i in $1
do

TPR="iffatal"
MSG="erro na geracao do mdl$NAME_DBN Master File"
echo "append mdl.xrf-$i em  m$NAME_DBN.mdl/mdl.mst..."
mx cipar=mdlxl64.par m$i.mdl/mdl append=m$NAME_DBN.mdl/mdl -all now tell=100000
. log

TPR="iffatal"
MSG="erro na geracao do mdlbb$NAME_DBN Master File"
echo "append mdlbb$i.mst em m$NAME_DBN.mdl/mdlbb$NAME_DBN.mst..."
mx cipar=mdlxl64.par m$i.mdl/mdlbb$i append=m$NAME_DBN.mdl/mdlbb$NAME_DBN -all now tell=100000
. log

done
rm mdlxl64.par

# ------------------------------------------------------------------------- #
# Geracao do Master File MDL_LNK para LINKS (18/02/2003)
# ------------------------------------------------------------------------- #

echo
echo "creating mdl$NAME_DBN Master File..."
echo

echo "mstxl=64G" > mdlxl.par
CIPAR=mdlxl.par
export CIPAR

TPR="iffatal"
MSG="erro na geracao do mdl$NAME_DBN/m$NAME_DBN.mdl/mdl_lnk Master File"
mx tmp count=0 now create=/bases/$DIREDICAO/m$NAME_DBN.mdl/mdl_lnk
. log

# IMPORTANTE TIRAR A VARIAVEL depois de usa-la
unset CIPAR

for i in $1
do
  TPR="iffatal"
  MSG="error: append mdl$i in mdl$NAME_DBN Master File"
  mx m$i.mdl/mdl_lnk append=/bases/$DIREDICAO/m$NAME_DBN.mdl/mdl_lnk tell=100000 -all now
  . log
done
rm mdlxl.par

# ------------------------------------------------------------------------- #
# MUDA PARA O DIRETORIO DE PROCESSAMENTO NO WRK
# ------------------------------------------------------------------------- #
cd /bases/$DIREDICAO/m$NAME_DBN.mdl

# Cria Master de Browse para apontamento
mv mdltw.mst mdl$NAME_DBN.mst
mv mdltw.xrf mdl$NAME_DBN.xrf

if [ ! -d /bases/lnkG4/m$NAME_DBN.new ]
then
   mkdir /bases/lnkG4/m$NAME_DBN.new
fi

# Move arquivos para processamento de LINKS
#mv mdl_lnk.mst /bases/lnk.000/m$NAME_DBN.new/m$NAME_DBN"_lnk".mst
#mv mdl_lnk.xrf /bases/lnk.000/m$NAME_DBN.new/m$NAME_DBN"_lnk".xrf
#mv mdl_lnkLIND.iyp /bases/lnk.000/m$NAME_DBN.new/m$NAME_DBN"_lnk".iyp
#mv mdl_lnkLIND.n01 /bases/lnk.000/m$NAME_DBN.new/m$NAME_DBN"_lnk".n01
#mv mdl_lnkLIND.n02 /bases/lnk.000/m$NAME_DBN.new/m$NAME_DBN"_lnk".n02
#mv mdl_lnkLIND.ly1 /bases/lnk.000/m$NAME_DBN.new/m$NAME_DBN"_lnk".ly1
#mv mdl_lnkLIND.ly2 /bases/lnk.000/m$NAME_DBN.new/m$NAME_DBN"_lnk".ly2
#mv mdl_lnkLIND.cnt /bases/lnk.000/m$NAME_DBN.new/m$NAME_DBN"_lnk".cnt
#rm mdl_lnkLIND.mst mdl_lnkLIND.xrf mdl_lnkLIND.pft


# ------------------------------------------------------------------------- #
# Contagem de MH e EX; geracao do DECST
# ------------------------------------------------------------------------- #

#echo
#echo "Processing COUNT..."
#echo


#APPD=""
#DBN_TREE=decst
#if [ -f /bases/$DIREDICAO/m$NAME_DBN.mdl/$DBN_TREE.iy0 ]
#then
#   rm /bases/$DIREDICAO/m$NAME_DBN.mdl/$DBN_TREE.iy0
#fi

#TPR="iffatal"
#MSG="Erro genmdlinv: gencount"
#../tpl.mdl/gencount mdlmhi mdlexi decs tdecs9a ux 
#. log
#mv gencateg.lst ./log

# ------------------------------------------------------------------------- #
# Geracao do DECS final
# ------------------------------------------------------------------------- #

#echo
#echo "Generating DECS..."
#echo
#TPR="iffatal"
#MSG="Erro  $0: gendecscd"
#../tpl.mdl/gendecscd decs ux 
#. log
 
TPR="iffatal"
MSG="Erro CP: kwic*"
cp ../m"$ANO_CORRENTE_2_digitos".mdl/kwic* .
. log

TPR="iffatal"
MSG="Erro: ../tpl.mdl/genmdl2sci.sh"
../tpl.mdl/genmdl2sci.sh $NAME_DBN
. log

TPR="iffatal"
MSG="$1 - Erro na geracao do iso gen_ntitle.sh"
../tpl.mdl/gen_ntitlemdl.sh
. log

#TPR="iffatal"
#MSG="Erro: ../tpl.mdl/genmdliy0.sh"
#../tpl.mdl/genmdliy0.sh
#. log


TPR="end"
. log
