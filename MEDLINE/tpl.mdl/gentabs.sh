# --------------------------------------------------------------------------- #
# GENTABS - Procedimento para geracao das tabelas utilizadas no processamento. 
#           Este procedimento engloba:
#           
#          1) conversao de notacao de subcampo (^i, ^e, ^p) para upper case.
#          2) geracao dos ZDECS.
#          3) normalizacao do campo 20 (programa gennorm).
#          4) geracao dos invertidos tdecs9a e tdecs9b do DECS.
#          5) geracao do invertido decsex de DECSEX.
#          6) geracao da base auxiliar TABEX que relaciona DECS com DECSEX.
#          7) geracao do invertido decsct do DECSCT.
#          8) geracao dos invertidos serlnewjc e serloldjc da SERLINE.
#          9) crunch das tabelas DIAC e TAB130.
#
# Marcelo - 10/02/94  update - 06/10/94
# Execucao - Produto-Edicao/TABS
# Sintaxe: gentabs <dbn_decs>  
#   onde:
#          <dbn_decs> e o nome da base de dados DECS.
# -------------------------------------------------------------------------- #

TPR="start"
. log

echo
echo "Inicio: gentabs"
echo

#if [ "$#" -ne 1 ]
#then
#  TPR="fatal"
#  MSG="use: gentabs <dbn_decs_ISO>"
#  . log
#fi

# Verifica existencia dos parametros

#for i in decsex.xrf decsct.xrf papa.seq pamh.seq
#for i in decsex.xrf decsct.xrf papa.seq decs.iso
for i in decsct.xrf decs.iso
do
    if 
      [ ! -f $i ]
    then
      TPR="fatal"
      MSG="$i nao encontrado"
      . log
    fi
done

# -------------------------------------------------------------------------- #
# Carrega DeCS com loadiso
# -------------------------------------------------------------------------- #

TPR="iffatal"
MSG="Erro carga DeCS"
#loadiso $1 decs tag_mfn=99 create
loadiso decs decs tag_mfn=99 create
. log

mxcp decs create=decs_tmp clean
mv decs_tmp.mst decs.mst
mv decs_tmp.xrf decs.xrf

# -------------------------------------------------------------------------- #
# Retag do campo 10 nos registros de qualificadores
# -------------------------------------------------------------------------- #

echo "10 20" > decs20.tab

TPR="iffatal"
MSG="Erro retag no campo 10"
retag decs decs20.tab
. log

rm decs20.tab

# -------------------------------------------------------------------------- #
# crunch DeCS para versao FFI para conversao XML2ISIS
# -------------------------------------------------------------------------- #
TPR="iffatal"
MSG="Erro crunchmf decs "
crunchmf decs DECS target=same format=cisisX
. log


# -------------------------------------------------------------------------- #
# Geracao ZDECS (ANSI)
# -------------------------------------------------------------------------- #

echo
echo "Creating zdecs..."
echo

TPR="iffatal"
MSG="Erro na geracao do zdecsi"
mx decs "proc='d*',|a1|v1||" create=zdecsi -all now
. log

TPR="iffatal"
MSG="Erro na geracao do zdecsi"
mx decs "proc='d*',|a2|v2||" create=zdecse -all now
. log

TPR="iffatal"
MSG="Erro na geracao do zdecsi"
mx decs "proc='d*',|a3|v3||" create=zdecsp -all now
. log

# -------------------------------------------------------------------------- #
# roda gizmo GANSUC no DeCS
# -------------------------------------------------------------------------- #

TPR="iffatal"
MSG="Erro gizmo GANSNA em DeCS"
mx decs gizmo=../tabs/gansna copy=decs -all now tell=1000
. log

# -------------------------------------------------------------------------- #
# Geracao dos campos 1, 2, 3, 50, 750 em caixa alta (upper case)
# -------------------------------------------------------------------------- #

echo
echo "Passando campos do DECS para upper case..."
echo

cat>700.prc<<!
'D1D2D3D50D51D701D702D703D750D751d760',mpu, 
|A1|v1||,|A2|v2||,|A3|v3||, 
|A701|v1*0.56||,|A702|v2*0.56||,|A703|v3*0.56||, 
if p(v50) then ('A50',|^i|v50^i,|^e|v50^e,|^p|v50^p,'') fi,
if p(v50) then ('A750',|^i|v50^i*0.56,|^e|v50^e*0.56,|^p|v50^p*0.56,'') fi,
if p(v51) then ('A51',|^i|v51^i,|^e|v51^e,|^p|v51^p,'') fi, mpl,
if p(v51) then ('A751',|^i|v51^i*0.56,|^e|v51^e*0.56,|^p|v51^p*0.56,'') fi, mpl,
(if p(v60^i) and (a(v60^t) or v60^t:'H') then,'a760',|^i|v60^i*0.56, |^e|v60^e*0.56, |^p|v60^p*0.56, '',fi),
if p(v20) then |a720|v20|| fi,
!

TPR="iffatal"
MSG="Erro na geracao do campo 701, 702, 703, 750, 751"
mx decs "proc=@700.prc" copy=decs -all now tell=15000
. log

rm 700.prc

# comentado em 03/12/2012
#TPR="iffatal"
#MSG="Erro na execucao gendecspa.sh"
#../tpl.mdl/gendecspa.sh 
#. log

TPR="iffatal"
MSG="Erro na geracao do campo 720"
mx decs "proc='d720',if p(v20) then |a720|v20|| fi" copy=decs -all now tell=15000
. log

# -------------------------------------------------------------------------- #
# DeCS - Gizmo PT
# -------------------------------------------------------------------------- #
#
#cat>gpt.seq<<!
# (PUBLICATION TYPE)|
# (TIPO DE PUBLICACION)|
# (TIPO DE PUBLICACAO)|
# [PUBLICATION TYPE]|
# [TIPO DE PUBLICACION]|
# [TIPO DE PUBLICACAO]|
# (DECS)|
#!
#mx seq=gpt.seq create=gpt -all now
#
#TPR="iffatal"
#MSG="Erro: DeCS - gizmo GPT"
#mx decs gizmo=gpt -all now copy=decs tell=10000
#. log
#
#rm gpt.*

# -------------------------------------------------------------------------- #
# DeCS - Gizmo PD
# -------------------------------------------------------------------------- #

cat>ggeo.seq<<!
 (GEOGRAFICO)|
!
mx seq=ggeo.seq create=ggeo -all now

TPR="iffatal"
MSG="Erro: DeCS - gizmo GGEO"
mx decs gizmo=ggeo -all now copy=decs tell=10000
. log

rm ggeo.*

# -------------------------------------------------------------------------- #
# Geracao dos invertidos do DECS - tdecs9a e tdecs9b   
# -------------------------------------------------------------------------- #


# FST Generation 

# tdecs9a
echo "1 0 mpl,v01/"      > tdecs9a.fst
echo "14 0 mpl,|/|v14" >> tdecs9a.fst

# tdecs9b
echo "1 0 mpl,v701"     > tdecs9b.fst
echo "14 0 mpl,|/|v14" >> tdecs9b.fst

# tdecs720
echo "720 0 mpl,(v720/)" > tdecs720.fst

# decs
echo "1 0 (v1/),(v2/),(v3/),(v11/),(v12/),(v13/),(v14/),(|/|v14/)" > decs.fst
echo "50 0 mpl,(v50^i/),(v50^e/),(v50^p/)" >> decs.fst

# Inverted File Generation

# tdecs9a
TPR="iffatal"
MSG="Erro na geracao da arvore tdecs9a"
gentree decs tdecs9a 3000 no
. log
rm tdecs9a.lk*

# tdecs9b
TPR="iffatal"
MSG="Erro na geracao da arvore tdecs9b"
gentree decs tdecs9b 3000 no
. log
rm tdecs9b.lk*

# tdecs720
TPR="iffatal"
MSG="Erro na geracao da arvore tdecs720"
gentree decs tdecs720 3000 no
. log
rm tdecs720.lk*

rm tdecs*.fst

# decs
TPR="iffatal"
MSG="Erro na geracao da arvore decs"
gentree decs decs 10000 no
. log

# -------------------------------------------------------------------------- #
# check de duplicacao - tdecs9a e tdecs9b
# -------------------------------------------------------------------------- #

# FST Generation 

# chk9a
#echo "1 0 mpl,v01/"        > chk9a.fst
##echo "50 1 mpl,(v50^i/)"  >> chk9a.fst
#echo "14 0 mpl,|/|v14"    >> chk9a.fst
#echo "20 0 mpl,(v20/)"    >> chk9a.fst

# chk9b
#echo "1 0 mpl,v701"         > chk9b.fst
##echo "750 1 mpl,(v750^i/)" >> chk9b.fst
#echo "14 0 mpl,|/|v14"     >> chk9b.fst
#echo "720 0 mpl,(v720/)"   >> chk9b.fst


# Inverted File Generation

# chk9a
#TPR="iffatal"
#MSG="Erro na geracao da arvore chk9a"
#gentree decs chk9a 3000 no
#. log
#mz chk9a +posts now > chk9a.doc
#grep -v "./1" chk9a.doc > terms9a.dpl
#if  [ "$?" -eq 0 ]
#then 
#    TPR="fatal"
#    MSG="Duplicate terms in DECS"
#    . log
#fi
#rm terms9a.dpl
#rm chk9a*

# chk9b
#TPR="iffatal"
#MSG="Erro na geracao da arvore chk9b"
#gentree decs chk9b 3000 no
#. log
#mz chk9b +posts now > chk9b.doc
#grep -v "./1" chk9b.doc > terms9b.dpl
#if  [ "$?" -eq 0 ]
#then 
#    TPR="fatal"
#    MSG="Duplicate terms in DECS"
#    . log
#fi
#rm terms9b.dpl
#rm chk9b.*

# acrescentado 22/12/2003
TPR="iffatal"
MSG="Erro na geracao do arquivo mdlmhiappd.lst"
../tpl.mdl/gen950lst decs
. log

# -------------------------------------------------------------------------- #
# Geracao do invertido do DECSCT - decsct   
# -------------------------------------------------------------------------- #

# FST Genaration

# decsct
echo "90 0 mpl,(v90/)">decsct.fst

# Inverted File Generation

# decsct
TPR="iffatal"
MSG="Erro na geracao da arvore tdecs9a"
gentree decsct decsct 100 no
. log

rm decsct.lk*
rm decsct.fst

mz decsct +posts now > decsct.doc
grep -v "./1" decsct.doc > termsct.dpl
if  [ "$?" -eq 0 ]
then 
    TPR="fatal"
    MSG="Duplicate terms in DECSCT"
    . log
fi
rm termsct.dpl
rm decsct.doc

# -------------------------------------------------------------------------- #
# Geracao ZDECS sem acento para PC
# -------------------------------------------------------------------------- #

echo
echo "Creating zdecs..."
echo

TPR="iffatal"
MSG="Erro CRUNCH zdecsi"
crunch zdecsi mst
. log

TPR="iffatal"
MSG="Erro CRUNCH zdecsi"
crunch zdecse mst
. log

TPR="iffatal"
MSG="Erro CRUNCH zdecsi"
crunch zdecsp mst
. log



TPR="end"
. log
