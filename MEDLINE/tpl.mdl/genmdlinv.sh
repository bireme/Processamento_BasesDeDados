# ------------------------------------------------------------------------ #
# GENMDLINV - TEMPLATE para geracao dos seguintes Master Files e invertidos:
# 
#             1) AUtor            - procedimento GENMDLAU.
#             2) TW               - procedimento GENMDLTW.
#
#             3) EXplode          - procedimento GENMDLEX.
#             4) LImites          - procedimento GENMDLLI.
#             5) TItulo           - procedimento GENMDLTI.
#             6) OThers           - procedimento GENMDLOT.
#             7) JR               - procedimento GENMDLJR.
#             8) Contagem do DECS - procedimento GENCOUNT.
#             9) kwicMH           - procedimento GENKWICMH.
#            10) kwicTA           - procedimento GENKWICTA.
#            11) DECS             - procedimento GENDECSCD.
#
# Marcelo - 01/03/94
# Execucao - Processamento
# sintaxe: genmdlinv <loopcheck> <DP>
#    onde: 
#          <loopcheck> intervalo para checks.
#          <DP> data de publicacao.
#
# ------------------------------------------------------------------------ #

TPR="start"
. log

echo 
echo "Inicio: genmdlinv"
echo

if  [ "$#" -ne 2 ]
then
  TPR="fatal"
  MSG="Use: genmdlinv <loopcheck> <DP>"
  . log
fi

##############################  TW  ###############################

[ -f mdl$2.mst ] && mv mdl$2.mst mdl.mst
[ -f mdl$2.xrf ] && mv mdl$2.xrf mdl.xrf

echo
echo "Processing TW-$2..."
echo
echo "genmdltw" >> mdl$2.tim
TPR="iffatal"
MSG="Erro: genmdlinv: TW"
../tpl.mdl/genmdltw decs tdecs9a tdecs9b $1 $2 2> mdl$2.tmp
. log
echo "TW="$? >> mdl$2.err
grep "real" mdl$2.tmp|head -1 >> mdl$2.tim



###############################  AU  ##############################

echo
echo "Processing AU-$2..."
echo
TPR="iffatal"
MSG="Erro genmdlinv: AU"
../tpl.mdl/genmdlau mdlbb$2 $1 2> mdl$2.tmp
. log
echo "AU="$? > mdl$2.err
echo "genmdlau" > mdl$2.tim
grep "real" mdl$2.tmp >> mdl$2.tim


###############################  AB  ##############################

echo
echo "Processing AB-$2..."
echo
TPR="iffatal"
MSG="Erro genmdlinv: AB"
../tpl.mdl/genmdlab mdlab$2 $1 2> mdl$2.tmp
. log

##############################  MH  #################################

echo
echo "Processing MH-$2..."
echo
echo "   genmdlmh" >> mdl$5.tim
TPR="iffatal"
MSG="Erro genmdlinv: MH"
../tpl.mdl/genmdlmh mdlbb$2 decs tdecs9a tdecs9b 2> mdl$5.tmp
. log
echo "   `grep real mdl$5.tmp`" >> mdl$5.tim


##############################  EX  #################################

#echo
#echo "Processing DECSEX-$2..."
#echo
#TPR="iffatal"
#MSG="Erro genmdlinv: gendecsex"
#../tpl.mdl/genmdlex mdlbb$2 decsex decs mdlmh tdecs720 2> mdl$2.tmp
#. log
##echo "EX="$? >> mdl$2.err
#echo "genmdlex" >> mdl$2.tim
#grep "real" mdl$2.tmp >> mdl$2.tim

##############################  LI  ###############################

echo
echo "Processing LI-$2..."
echo
TPR="iffatal"
MSG="Erro: genmdlinv: LI"
../tpl.mdl/genmdlli mdlbb$2 ../tabs/decsct ../tabs/decsct $1 2> mdl$2.tmp
. log
#echo "LI="$? >> mdl$2.err
echo "genmdlli" >> mdl$2.tim
grep "real" mdl$2.tmp >> mdl$2.tim



##############################  TI  ###############################

echo
echo "Processing TI-$2..."
echo
TPR="iffatal"
MSG="Erro genmdlinv: TI"
../tpl.mdl/genmdlti mdlbb$2 $1 2> mdl$2.tmp
. log
#echo "TI="$? >> mdl$2.err
echo "genmdlti" >> mdl$2.tim
grep "real" mdl$2.tmp >> mdl$2.tim

##############################  OT  ###############################

echo
echo "Processing OT-$2..."
echo
TPR="iffatal"
MSG="Erro genmdlinv: OT"
../tpl.mdl/genmdlot mdlbb$2 $1 2> mdl$2.tmp
. log
#echo "OT="$? >> mdl$2.err
echo "genmdlot" >> mdl$2.tim
grep "real" mdl$2.tmp >> mdl$2.tim


##############################  SS  ###############################

echo
echo "Processing SS-$2..."
echo
TPR="iffatal"
MSG="Erro genmdlinv: SS"
../tpl.mdl/genmdlss mdlbb$2 $1 2> mdl$2.tmp
. log
#echo "OT="$? >> mdl$2.err
echo "genmdlss" >> mdl$2.tim
grep "real" mdl$2.tmp >> mdl$2.tim


###############################  JR  ##############################

echo
echo "Processing JR-$2..."
echo
TPR="iffatal"
MSG="Erro genmdlinv: JR"
../tpl.mdl/genmdljr mdlbb$2 $1 2> mdl$2.tmp
. log
#echo "JR="$? >> mdl$2.err
echo "genmdljr" >> mdl$2.tim
grep "real" mdl$2.tmp >> mdl$2.tim


##############################  Pais de Afiliacao  ###############################

echo
echo "Processing AFI-E-P-$2..."
echo
TPR="iffatal"
MSG="Erro - Processing AFI-E-P"
../tpl.mdl/genmdlpaisafil.sh $2
. log

##############################  JD  ###############################

echo
echo "Processing JOURNAL DESCRIPTOR-$2..."
echo
TPR="iffatal"
MSG="Erro - Processing JOURNAL DESCRIPTOR"
../tpl.mdl/genmdljd.sh $2
. log

############################## CATEG #####################################
echo
echo "Processing mdlcateg-$2..."
echo
TPR="iffatal"
MSG="Erro genmdlinv: BW"
../tpl.mdl/genmdlcateg.sh $2
. log

##################### Afiliacao UNIFESP ##############################

# comentado em 23/12/2014 - precisa gerar o arquivo de afiliacao.txt com o MEDLINE 2015 em OFI4
echo
echo "Processing AF - campo de afiliacao-$2..."
echo
TPR="iffatal"
MSG="Erro genmdlinv: AF"
../tpl.mdl/genmdlafunifesp.sh $2
. log


##################### MDLICD ##############################
echo
echo "Processing MDLICD-$2..."
echo
TPR="iffatal"
MSG="Erro: genmdlicd"
../tpl.mdl/genmdlicd.sh $2
. log

##################### MDLMP ##############################
echo
echo "Processing MDLMP-$2..."
echo
TPR="iffatal"
MSG="Erro: genmdlmp"
../tpl.mdl/genmdlmp.sh $2
. log

##################### inverte MDLBB ##############################
echo
echo "gerando indice mdlbb$2..."
echo

echo "969 0 v969/ " > mdlbb$2.fst
TPR="iffatal"
MSG="erro na geracao do Invertido - mdlbb$2"
mx mdlbb$2 "fst=@" fullinv/ansi=mdlbb$2 -all now tell=100000
. log

##################### mdlSciELOID ##############################
echo
echo "Processing mdlSciELOID-$2..."
echo
TPR="iffatal"
MSG="Erro: mdlSciELOID-$2"
../tpl.mdl/genmdlSciELOID.sh mdlbb$2 100000
. log

##############################  KMH  ##############################

echo
echo "Processing KMH..."
echo
TPR="iffatal"
MSG="Erro genmdlinv: Kwicmh"
../tpl.mdl/genkwicmh.sh decs decsex 2> mdl$2.tmp
. log
#echo "KMH="$? >> mdl$2.err
echo "genkwicmh" >> mdl$2.tim
grep "real" mdl$2.tmp >> mdl$2.tim

##############################  KTA  ##############################

#echo
#echo "Processing KTA..."
#echo
TPR="iffatal"
MSG="Erro genmdlinv: Kwicta"
../tpl.mdl/genkwicta.sh mdlserl 10000 $2 2> mdl$2.tmp
. log

##############################  MDL_LNK  ##############################

  # renomeia Master de browse

#   if  [ -f mdl$2.xrf ]
#   then
#       mv mdl$2.mst mdl.mst
#       mv mdl$2.xrf mdl.xrf
#   fi

echo
echo "Generating mdl_lnk..."
echo
TPR="iffatal"
MSG="Erro: invlnkmdl $2"
../tpl.mdl/invlnkmdl.sh mdl mdl_lnk
. log


##############################  AFILIACAO  ###############################

echo
echo "Processing MDL-Afiliacao..."
echo
TPR="iffatal"
MSG="Erro - Processing MDL-Afiliacao"
../tpl.mdl/genmdlaf.sh mdl
. log

##############################  ADOLEC  ##############################

echo
echo "Generating ADOMDL$2 to ADOLEC..."
echo
TPR="iffatal"
MSG="Erro  genmdlinv: prepadomdl.sh"
../tpl.mdl/prepadomdl.sh 2> mdl$2.tmp
. log

###########################  FINALIZA #################################

  chmod 666 *.*
  mkdir log 2> /dev/null
  mv *log *len *lst *tim *err ./log 2> /dev/null

  cd log
  TPR="iffatal"
  MSG="Erro: chklog ($i)"
  ../../tpl.mdl/chklog $2
  . log
  cd ../..


echo 
echo "Fim: genmdlinv"
echo

TPR="end"
. log
