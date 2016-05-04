#----------------------------------------------------------------------#
# GENKWICMH - Procedimento para geracao das bases de kwic MH nos 3 
#             idiomas (kwici, kwice e kwicp).
#
# Marcelo - 24/02/94   update - 24/10/2001
# Chico - EM TESTE VERSAO SEM KWIC - 02/10/2001
# Sintaxe: genkwicmh <dbn_decs_cd> <dbn_decsex>
#    onde:
#          <dbn_decs_cd> base de dados DECS com as contagens dos MH's e
#                        EX's feitas.
#          <dbn_decsex> base de dados decsex.
#
#----------------------------------------------------------------------#

TPR="start"
. log

echo 
echo "Inicio: genkwicmh"
echo

if [ "$#" -ne 2 ]
then 
   TPR="fatal"
   MSG="use: genkwicmh <dbn_decs_cd> <dbn_decsex>" 
   . log 
fi

# -------------------------------------------------------------------- #
# Gera sequencial
# -------------------------------------------------------------------- # 

TPR="iffatal"
MSG="Erro na geracao do sequencial decs.lst"
#mx $1 "pft=if p(v810) or p(v820) then mfn/ fi" now tell=1000 >decs810.lst
#. log
#mx $1 "pft=if p(v830) or p(v840) then mfn/ fi" now tell=1000 >decs830.lst
#. log
mx ../tabs/$1 "pft=mfn/" now tell=1000 >decs810.lst
. log
mx ../tabs/$1 "pft=mfn/" now tell=1000 >decs830.lst
. log

TPR="iffatal"
MSG="Erro na geracao DECSEX auxiliar" 
mx ../tabs/$2 "proc='='v99" create=decsex_aux -all now 
. log

TPR="iffatal"
MSG="Erro no join com decsex" 
mx ../tabs/$1 "join=decsex_aux,801:701,802:702,803:703='mfn='mfn" \
"proc='d32001'" copy=$1 -all now tell=1000
. log
rm decsex_aux.mst decsex_aux.xrf

# -------------------------------------------------------------------- #
# Gera bases auxiliares 
# -------------------------------------------------------------------- # 

for J in i e p
do
  case $J in 
    i) K=1
    ;;
    e) K=2
    ;;
    p) K=3
    ;;
  esac

  # Tag 1: descritor no idioma
  # Tag 2: descritor em ingles

  TPR="iffatal"
  MSG="Erro na geracao da base auxiliar kwmh$J" 

   mx seq=decs810.lst "join=$1,1001:1,1002:2,1003:3,50='mfn='v1/" "proc='='v1,'D*',mpu,|A1|v100$K||,|A1|v50^$J||" create=kwmh$J -all now tell=1000
  . log
  # Modificado, mas com defeito 23/07/2004
  #mx seq=decs810.lst "join=$1,1001:701,1002:702,1003:703,750='mfn='v1/" "proc='='v1,'D*',mpu,|A1|v100$K||,|A1|v50^$J||" create=kwmh$J -all now tell=1000

  TPR="iffatal"
  MSG="Erro na geracao da base auxiliar kwmhq$J" 
  mx seq=decs830.lst "join=$1,1001:801,1002:802,1003:803='mfn='v1/" \
  "proc='='v1,'D*',mpu,|A1|v100$K||," \
  create=kwmhq$J -all now tell=1000
  . log

done

rm decs810.lst
rm decs830.lst


# -------------------------------------------------------------------- #
# Gera as bases de KWIC 
# -------------------------------------------------------------------- # 

for j in i e p
do
  cat>kwic.pft<<!
  ,e1:=1
  ,e2:=nocc(v1001)

  ,while e1 <= e2 (
     '^f'
    ( if p(v1001^*) and iocc = e1 then if e1=1 then '^l' else ' ^l' fi,v1001^* else | |+v1001^* fi)('^m'v2)/
    e1:=e1+1
  ,)
!

 TPR="iffatal"
 MSG="Erro na geracao do kwmh$j.seq"
 mx kwmh$j lw=9999 "pft=if p(v1) then (v1,'|',mfn(1)/) fi" now tell=10000 > kwmh$j.seq
 . log

 TPR="iffatal"
 MSG="Erro na geracao do Master kwmh$j"
 mx seq=kwmh$j.seq "actab=../tabs/acKWIC437.tab" "fst=1001 4 v1" -all now tell=10000 create=kwmh$j
 . log
 rm kwmh$j.seq

 TPR="iffatal"
 MSG="Erro na geracao do kwmhtemp$j.seq"
 mx kwmh$j lw=9999  pft=@kwic.pft now tell=10000 |sort -u > kwmhtemp$j.seq
 . log
 rm kwmh$j.*

 TPR="iffatal"
 MSG="Erro na geracao do Master kwic$j"
 mx seq=kwmhtemp$j.seq -all now tell=10000 create=kwic$j
 . log
 rm kwmhtemp$j.seq

# -------------------------------------------------------------------- #
# Gera as bases de KWIC ( PX e SX)
# -------------------------------------------------------------------- # 

 TPR="iffatal"
 MSG="Erro na geracao do kwmhq$j.seq"
 mx kwmhq$j "pft=if p(v1) then (v1,'|',mfn(1)/) fi" now tell=10000>kwmhq$j.seq
 . log

 TPR="iffatal"
 MSG="Erro na geracao do Master kwmhq$j"
 mx seq=kwmhq$j.seq "actab=../tabs/acKWIC437.tab" "fst=1001 4 v1" -all now tell=10000 create=kwmhq$j
 . log
 rm kwmhq$j.seq

 TPR="iffatal"
 MSG="Erro na geracao do kwic kwmhqtemp$j.seq"
 mx kwmhq$j pft=@kwic.pft now tell=10000 |sort -u > kwmhqtemp$j.seq
 . log
 rm kwmhq$j.*

 TPR="iffatal"
 MSG="Erro na geracao do Master kwicq$j"
 mx seq=kwmhqtemp$j.seq -all now tell=10000 create=kwicq$j
 . log
 rm kwmhqtemp$j.seq

# -------------------------------------------------------------------- #
# Append das 2 bases de kwic
# -------------------------------------------------------------------- # 

  TPR="iffatal"
  MSG="error: append das 2 bases de kwic$j"
  mx kwicq$j append=kwic$j -all now
  . log
  rm kwicq$j.mst kwicq$j.xrf

# ------------------------------------------------------------------- #
# Classificacao dos termos
# ------------------------------------------------------------------- #

  TPR="iffatal"
  MSG="error: msrt can not sort terms"
  msrt kwic$j 60 "mpu,v1^l,'',v1^f" tell=1000 +del  > /dev/null
  . log

# ------------------------------------------------------------------- #
# Inversao da base kwic
# ------------------------------------------------------------------- #

  echo "1 0 v1^l">kwic$j.fst

  TPR="iffatal"
  MSG="error: Load invert tree kwic"
  gentree kwic$j kwic$j 1000
  . log
  rm kwic$j.fst
  rm kwic$j.ln? kwic$j.lk?

# ------------------------------------------------------------------- #
# Adiciona campo 2 (v1 truncado em 56 caracteres)
# ------------------------------------------------------------------- #

  TPR="iffatal"
  MSG="erro: adicionando campo 2 na base kwic$j"
  mx kwic$j "proc='a2'left(s(v1^f,v1^l),56)''" copy=kwic$j -all now tell=20000
  . log
  rm kwic$j.fst
  rm kwic$j.ln? kwic$j.lk?

# ------------------------------------------------------------------- #
# Crunch da base kwic
# ------------------------------------------------------------------- #

  TPR="iffatal"
  MSG="error: crunch kwic$j"
  crunch kwic$j mst
  . log

done

rm kwic.pft

echo 
echo "Fim: genkwicmh"
echo

TPR="end"
. log
