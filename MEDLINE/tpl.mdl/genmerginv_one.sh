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

# ------------------------------------------------------------------------- #
# chamadas para os join's comuns
# ------------------------------------------------------------------------- #

MST="+mstxrf"
for i in mdlafIB
do
  echo "Merging $i..."
  INV=$i
  join_comum
  MST=""
done   

# ------------------------------------------------------------------------- #
# chamadas para os join's com traducao
# ------------------------------------------------------------------------- #

#for i in mdlmhi mdlmhe mdlmhp mdlmhc mdlexi mdlexe mdlexp mdllii mdllie mdllip
#do
#  echo "Merging $i..."
#  INV=$i
#  join_traducao
#done   

rm mdlxl64.par

