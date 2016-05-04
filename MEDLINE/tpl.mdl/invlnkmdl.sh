# ----------------------------------------------------------------------- #
# INVLNKMDL - Procedimento para inversao do Medline para busca com dados
#             da base de citacoes (bib4cit) do Scielo. O nome do Master MDL
#             a ser invertido tem de ser o mesmo que veio da BVS01.
#
# Criado por: Marcelo - em algum dia do passado
# Alterado por : Renato - 03/11/1999
# ----------------------------------------------------------------------- #

TPR="start"
. log

if [ "$#" -ne 2 ]
then
  TPR="fatal"
  MSG="use: $0 <dbn_in_mdl> <dbn_out_mdl>"
  . log
fi  

# ----------------------------------------------------------------------- #
# Verifica existencia das bases para processamento
# ----------------------------------------------------------------------- #
#for i in ndiac tab142b g850na
#do
#if 
#  [ ! -s ../tabs/$i.xrf ]
#then
#  TPR="fatal"
#  MSG="Error: $i".xrf" not found"
#  . log
#fi
#done

cat>$2.fst<<!
1 0 |IS |v999^4
1 0 |IS |v302
2 8 '|AU |'v999^s
3 8 '|TI |'v999^o
3 8 '|TI |'v999^y
4 0 |DP |v999^q.4/
5 0 "PG "d999^p,left(v999^p,instr(v999^p,'-')-1),
6 0 |VO |v999^w
7 0 'FA 'f(val(v999^t),1,0)
8 0 if v999^t:'Suppl' then 'SU ',f(val(right(v999^t,size(v999^t)-(instr(v999^t,'Suppl')+5))),1,0) fi 
!

# ------------------------------------------------------------------- #
# Inicio da extracao das chaves
# ------------------------------------------------------------------- #
echo mstxl=64G>mdlxl.par

echo "extracting keys ..."
TPR="iffatal"
MSG="error: extract keys"
mx cipar=mdlxl.par $1 "fst=@$2.fst" gizmo=../tabs/gansna ln1=$2.ln1 ln2=$2.ln2 +fix/m -all now tell=50000
. log
rm $2.fst mdlxl.par

# ------------------------------------------------------------------- #
# Classificacao das chaves - Geracao dos arquivos LK's
# ------------------------------------------------------------------- #
echo "sorting keys..."
TPR="iffatal"
MSG="Erro na classificacao das chaves LK1"
genlk -s $2.lk1 $2.ln1
. log
rm $2.ln1

TPR="iffatal"
MSG="Erro na classificacao das chaves LK2"
genlk -s $2.lk2 $2.ln2
. log
rm $2.ln2

# ------------------------------------------------------------------- #
# Carga da arvore de invertidos
# ------------------------------------------------------------------- #
# LINDG4
TPR="iffatal"
MSG="Erro na carga da arvore de invertido"
geninv $1 $2 $2
. log
rm $2.lk?

# master e invertido LIND
#cp mdl_lnk.mst mdl_lnkLIND.mst
#cp mdl_lnk.xrf mdl_lnkLIND.xrf
#
#cp $2.lk1 $2LIND.lk1
#cp $2.lk2 $2LIND.lk2
#TPR="iffatal"
#MSG="Erro na carga da arvore de invertido"
#geninvLIND $1 $2LIND $2LIND
#. log
#rm $2LIND.lk?

# -------------------------------------------------------------------

TPR="iffatal"
MSG="Erro na geracao da base $2"
mx $1 gizmo=../tabs/gansna "proc='d*','a969~'v999^3'~','a354~'v999^q.4'~'" create=$2 -all now tell=50000
. log

TPR="end"
. log
