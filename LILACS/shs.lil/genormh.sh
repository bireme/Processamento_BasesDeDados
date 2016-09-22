#!/bin/bash

# --------------------------------------------------------------------------- #
# GENORMH - Procedimento para normalizacao dos descritores.
#           Gera base de dados de descritores
#            e
#           base de dados com descritores decodificados
#
# Sintaxe: genormh <dbn> <decs_tree> [t89]
#   onde <dbn>       : base de dados
#        <decs_tree> : invertido usado no decs 
#
#        Atencao: esta cravado para os campos 71, 76, 87, 88 deve-se
#                 verificar o subcampo utilizado para descritores e qualif.
#
# -------------------------------------------------------------------------- #

# ========================================================================== #
#                                BIBLIOTECAS                                 #
# ========================================================================== #
source $MISC/infra/infoini.inc

# ========================================================================== #
#                                  FUNCOES                                   #
# ========================================================================== #
function apaga {
        [ $(ls $1 2> /dev/null | wc -l) -gt 0 ] && rm -f $1
}

if [ "$#" -lt 2 -o "$#" -gt 3 ]; then
   TPR="warning"
   MSG="use: genormh <dbn> <decs_tree> [t89]"
   . log
fi

# -------------------------------------------------------------------------- #
# Assume argumento de chamada por default
PARM1=${1:-lil}
PARM2=${2:-../tabs/decsall}
PARM3=${3}	# (PARM3 nao tem valor default pois eh opcional)
PARMq=${#}
[ "$PARMq" -eq 0 ] && PARMq=2
# -------------------------------------------------------------------------- #

echo "Apaga campo 87 dos registros LILACS EXPRESS"
TPR="iffatal"
MSG="Erro no mx LILACSEXPRESS da $1"
mx $PARM1 "proc=if v4:'LILACSEXPRESS' or v4:'LLXPEDT' and v87:'BIREME' then 'd87' fi" copy=$PARM1 -all now tell=55000
. log

# Faz apenas para REPIDISCA 
if [ ${PARM1} = 'rep' ]; then
   mx rep "proc='d870d880'" copy=rep -all now
fi

#  checa descritores e gera ${PARM1}er com descritores invalidos no campo 870 para uso em tw
if [ "$PARMq" -eq 3 ]; then
   echo "'d*',(if a(v32001^m) then 'a870'v32001^k''fi/),|a870|v89||" > de.prc
else
   echo "'d*',(if a(v32001^m) then 'a870'v32001^k''fi/)"                 > de.prc
fi
 
echo "Cria base com descritores errados (${PARM1}er)"
TPR="iffatal"
MSG="Erro no join para check de descritores e criacao de $1er"
mx ${PARM1} "jchk=${PARM2},89=mpu,(v71^*/),(v76^*/),(v87^*/),(v88^*/)" proc=@de.prc create=${PARM1}er now -all tell=10000
. log

echo "Gera base de descritores (encode ANSI) em uso anotando campo e MFN de aparicao"
# normaliza descritores 
# campos: v1=descritor, v2=tag, v3=mfn

cat>v8788.pft<<V8788
(if p(v71) then v71||,'71',mfn,'',/ fi)
(if p(v76) then v76||,'76',mfn,'',/ fi)
(if p(v87) then v87||,'87',mfn,'',/ fi)
(if p(v88) then v88||,'88',mfn,'',/ fi)
V8788

# guardar master de inversão antes de tirar os diacríticos dos Descritores - colocado 09/01/2007
cp ${PARM1}.mst ${PARM1}_asc850.mst
cp ${PARM1}.xrf ${PARM1}_asc850.xrf

TPR="iffatal"
MSG="Erro na geracao da lista de descritores - ${PARM1}.lst"
mx ${PARM1} lw=0 gizmo=../tabs/g850ans,87,88,71,76 gizmo=../tabs/actmail,87,88,71,76 pft=@v8788.pft now tell=10000 > ${PARM1}.lst
. log

# Gera base normalizada v8788
# Gera a estrutura da v8788

TPR="iffatal"
MSG="Erro na geracao da base de dados descritores a partir de $1.lst"
mx "seq=${PARM1}.lst" create=v8788 now -all tell=5000
. log

#   retag para facilitar procs no join com decs
cat >retag.tab<<!
1 1000
2 2000
3 3000
!
TPR="iffatal"
MSG="Erro no retag dos campos da base v8788"
retag v8788 retag.tab
. log

# para GHL: 07/08/2007
#mxcp v8788 create=v8788_tmp clean
#mv v8788_tmp.mst v8788.mst
#mv v8788_tmp.xrf v8788.xrf

# proc traduzindo descritor normalizado nos campos v2000|0
#      repete a origem quando nao faz join
# 900 categoria ( verificar letra usada para subcampo (default=s))
# 99  mfn da categoria no decs

cat > norm.prc<<NORM
 'd32001',mpu
 if p(v32001^m) then 
   'd1','a',v2000,'0^h',v1*0.56'',"a900"v1000^s""
   'a99'v32001^m''
 else 
   'a',v2000,'0^h',v1000^*,"^s"v1000^s,''
   "a900"v1000^s""
 fi
NORM

echo "Normaliza descritores"
TPR="iffatal"
MSG="Erro na traducao do descritor normalizado"
mx v8788 "join=${PARM2},1=mpu,v1000^*/" jmax=1 proc=@norm.prc create=v8788t now -all tell=5000
. log

# join por categoria: coloca mfn do decs no campo 990
# campo 999 com descritores que nao fizeram nenhum join
# campos v2000|1 com mfns para base decod
# campos v2000|0 com descritores e qualificadores autorizados
# cada registro e' um descritor, logo apenas um descritor presente"

cat>proc.prc<<PROCPRC
 'd32001d1400',
 if a(v32001^m) and a(v99) then
   'd'v2000'0'
   'a9999'v710,v760,v870,v880,''
   'a'v2000'1'v710^*,v760^*,v870^*,v880^*,'^0x',"^s"v900^*"^0y",''
 else if p(v32001^m) then
   'd'v2000'0'
   'a'v2000'0^h'v710^*,v760^*,v870^*,v880^*,'^s'v1400''
   'a990'v32001^m''
   'a'v2000'1'v99,'^s'v32001^m''
   if a(v99) then
     'a'v2000'1'v710^*,v760^*,v870^*,v880^*,'^0x','^s'v32001^m'' fi
   else
      if p(v99) then 'a'v2000'1'v99'' fi
 fi fi
PROCPRC

echo "Adiciona MFN do DeCS"
TPR="iffatal"
MSG="Erro na manipulacao da categoria e colocacao do mfn do decs"
mx v8788t "join=${PARM2},1400:14=mpu,|/|v900^*/"  "proc=@proc.prc" create=v8788x -all now tell=10000 
. log

echo "Inverte base de descritores tratada pelo MFN da origem"
#  gera invertido do mfn da base de origem
echo "1 0 v3000+|%|/" > v8788x.fst

TPR="iffatal"
MSG="Erro na carga do invertido da base v8788x"
gentree v8788x v8788x 10000 no
. log 

echo "Gera base de descritores ${PARM1}de"
# gera ${PARM1}de com descritores normalizados para decs9a
# Alterado 24/09/2004 para ordenar o 760, 870 e 880

echo " 'd*'"               >  prcnorm.prc
echo " |a171|v710||"   >> prcnorm.prc
echo " |a176|v760||"   >> prcnorm.prc
echo " |a880|v710||"   >> prcnorm.prc
echo " |a880|v760||"   >> prcnorm.prc
echo " |a870|v870||"   >> prcnorm.prc
echo " |a880|v880||"   >> prcnorm.prc
echo " |a83|v83*0.2||" >> prcnorm.prc
echo " |a04|v04||"     >> prcnorm.prc
echo " |a05|v05||"     >> prcnorm.prc
echo " |a06|v06||"     >> prcnorm.prc
echo " |a40|v40||"     >> prcnorm.prc
echo " |a41|v41||"     >> prcnorm.prc
echo " |a83|v83||"     >> prcnorm.prc
echo " |a993|v993||"   >> prcnorm.prc
echo " |a778|v778||"   >> prcnorm.prc

echo "join=v8788x,710,760,870,880=mfn/" >  norm1.in
echo "proc=@prcnorm.prc"                >> norm1.in
echo "proc='S870'"                      >> norm1.in
echo "proc='S880'"                      >> norm1.in
echo "now"                              >> norm1.in
echo "-all"                             >> norm1.in
echo "tell=1000"                        >> norm1.in

TPR="iffatal"
MSG="Erro na geracao da base de dados de descritores $1de"
mx ${PARM1} in=norm1.in create=${PARM1}de
. log

echo "Cria gizmo de subcampos"
echo "^s|^q" >  ${PARM1}degiz.seq
echo "^h|^H" >> ${PARM1}degiz.seq

TPR="iffatal"
MSG="Erro na geracao da base de gizmo $1degiz"
mx seq=${PARM1}degiz.seq create=${PARM1}degiz now -all
. log

echo "Acerta subcampos da base ${PARM1}de"

TPR="iffatal"
MSG="Erro no gizmo ${PARM1}degiz em ${PARM1}de"
mx ${PARM1}de gizmo=${PARM1}degiz copy=${PARM1}de -all now tell=10000
. log

[ -f ${PARM1}degiz.xrf ] && rm -f ${PARM1}degiz*
[ -f prcnorm.prc ]       && rm -f prcnorm.prc
[ -f norm1.in ]          && rm -f norm1.in

echo "Organiza (ordena) campos da base ${PARM1}de"

TPR="iffatal"
MSG="Erro na geracao da base de dados de descritores ${PARM1}de"
mx ${PARM1}de "proc='S760'" "proc='S870'" "proc='S880'" create=${PARM1}de_tmp -all now tell=100000
. log

mv ${PARM1}de_tmp.mst ${PARM1}de.mst
mv ${PARM1}de_tmp.xrf ${PARM1}de.xrf

echo " 'd32001d171d176d711d761d871d881d870d880d71d76d87d88'" >  glildecod.prc
echo " if p(v711) then 'a171',(|;|+v711),'' fi"          >> glildecod.prc
echo " if p(v761) then 'a176',(|;|+v761),'' fi"          >> glildecod.prc
echo " if p(v871) then 'a870^d',(|;^d|+v871),'' fi"      >> glildecod.prc
echo " if p(v881) then 'A880^d',(|;^d|+v881),'' fi"      >> glildecod.prc

echo "join=v8788x,711,761,871,881=mfn/" >  glildecod.in
echo "proc=@glildecod.prc"              >> glildecod.in
echo "now"                              >> glildecod.in
echo "-all"                             >> glildecod.in
echo "tell=10000"                       >> glildecod.in

# gera lilacs com decod para 171, 176, 870, 880
echo "Gera base LILACS com decod para os campos 171, 176, 870, e 880"
TPR="iffatal"
MSG="Erro na geracao da base de dados com descritor codificado lilacs"
mx ${PARM1} in=glildecod.in create=lilacs
. log

[ -f glildecod.prc ] && rm -f glildecod.prc
[ -f glildecos.in ]  && rm -f glildecid.in

# Cria tabela para retag de campos
echo "Corrige numeracao dos campos para 71, 76 87, e 88"
cat>${PARM1}cd.tag<<RETAG
171 71
176 76
870 87
880 88
RETAG

TPR="iffatal"
MSG="Erro no retag dos campos 176, 870 e 880"
retag lilacs ${PARM1}cd.tag tell=1000
. log

# Tira zeros do campo 2 (000006 -> 6) - 28/08/2003
# if [ $1 = 'lil' -o $1 = 'pah' ] Estava tirando o "a" do v2 da PAHO 04/02/2004
LOCAL=$(basename $PWD)

if [ ${PARM1} = 'lil' -a $LOCAL != "epm.lil" -a $LOCAL != "central.lil" ]; then
   TPR="iffatal"
   MSG="Erro: tira zeros do campo 2"
   mx lilacs "proc='d2','a2'f(val(v2),1,0)''" "proc='s'" copy=lilacs -all now tell=55000
   . log
fi

#----------------------------------------------------------------------#
# Gera base estatistica da base para CD-ROM antes da limpeza e compressao
#----------------------------------------------------------------------#
TPR="iffatal"
MSG="Erro na geracao da base estatistica da base para CD-ROM antes da limpeza e compressao"
dbstat lilacs
. log

#----------------------------------------------------------------------#
# Limpa caracteres ASCII padrao 850 do Master de Indexacao (28/11/2000)
#----------------------------------------------------------------------#
# devolver master de inversão com os diacríticos dos Descritores - colocado 09/01/2007

if [ ${PARM1} = lil ]; then
   TPR="iffatal"
   MSG="Erro: Limpa caracteres ASCII padrao 850 do Master de Indexacao"
   mx ${PARM1} gizmo=../tabs/g850na "proc='s'" copy=${PARM1} now -all tell=10000
   . log
fi

echo Limpa area de trabalho
unset CIPAR

apaga 'lilpar.*'
apaga 'de.prc'
apaga '*par'
apaga 'v8788*'
apaga '*prc'
apaga '*tab'
apaga "$1.lst"
apaga "${1}cd.tag"
apaga 'complil.* '

source $MISC/infra/infofim.inc
exit 0

