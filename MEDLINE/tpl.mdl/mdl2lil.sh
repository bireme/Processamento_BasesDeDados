# Convdescr-Procedimento para conversao de descritores do Medline para Lilacs
# 
# Sintaxe: $0 <ISO2709 Medline> <Base Lilacs>
#
# Onde   : <ISO2709 Medline> eh o Iso gerado a partir de uma pesquisa no
#          Medline CD-ROM
#          <Base Lilacs> Base convertida para Metodologia Lilacas. Estarah
#      	   disponivel no subdiretorio "pc" do diretorio corrente.
#
# Renato - 02/03/99
#

########################################################################
# FASE 1 - CRIACAO DA BASE DE DADOS 
########################################################################

TPR="start"
. log

if [ "$#" -ne 2  ]
then
  TPR="fatal"
  MSG="Sintaxe: $0 <dbn_mdl> <dbn_lil>"
  . log
fi  


#
# Checa condicoes para execucao

# verifica existencia do arquivo de entrada 
if  [ ! -s $1.iso ] 
then
  TPR="fatal"
  MSG="Erro: $1.iso não encontrado ou vazio"
  . log
fi

echo 
echo "Tirando caracteres invalidos do MS-DOS de $1.iso..."
TPR="iffatal"
MSG="Erro: tr $i.iso"
cat $1.iso |tr -d \\015 > $1"tmp".iso
. log

mv $1"tmp".iso $1.iso

# ------------------------------------------------------------------- #
# Conversao do ISO do Medline para Metodologia Lilacs
# ------------------------------------------------------------------- #

# ------------------------------------------------------------------- #
# Validacao de parametros
# ------------------------------------------------------------------- #


# ------------------------------------------------------------------- #
# Copia DECS e Indexa
# ------------------------------------------------------------------- #
if  [ ! -f decs.xrf ] 
then
  cp ../tabs/decs.mst decs.mst
  cp ../tabs/decs.xrf decs.xrf
fi

cat>decs.tag<<!
10 20
!

TPR="iffatal"
MSG="Erro no retag dos campos de descritores"
retag decs decs.tag tell=1000
. log

# Geracao dos campos 701, 702, 703, 750, 751 do DECS  
cat>tpgiz.seq<<!
 (PUBLICATION TYPE)|
 (TIPO DE PUBLICACION)|
 (TIPO DE PUBLICA€AO)|
 (TIPO DE PUBLICACAO)|
 [PUBLICATION TYPE]|
 [TIPO DE PUBLICACION]|
 [TIPO DE PUBLICA€AO]|
 [TIPO DE PUBLICACAO]|
 (DECS)|
!

TPR="iffatal"
MSG="Erro na criacao do gizmo de Tipo de Publicacao"
mx seq=tpgiz.seq create=tpgiz now -all
. log

TPR="iffatal"
MSG="Erro no gizmo de Tipo de Publicacao"
mx decs gizmo=tpgiz,1,2,3,701,702,703,50,750,51,751 now -all copy=decs tell=1500
. log

# Geracao da FST de extracao  
#
# decs FST
echo "1 0 mpl,if not v105:'T' then v01/ fi" > decs.fst
echo "14 0 mpl,|/|v14" >> decs.fst

# Geracao dos invertidos
#
# decs
TPR="iffatal"
MSG="Erro na geracao da arvore tdecs9a"
gentree decs decs 15000 no
. log

rm *.fst
rm *.lk*
rm tpgiz.*


# ---------------------------------------------------------------------- #
# Geracao do Master File 
# ---------------------------------------------------------------------- #

cat>$1.prc<<!
'd*',
'a1BR1.1'
|a2|v999^3||,
'a4LILACS',
'a4MEDLINE',
'a5S',
'a6as',
'a92MDL',
if p(v999^s) then |a10|v999^s|| fi,

if p(v999^y) then |a12|v999^y|| fi,
if p(v999^o) then |a12|v999^o|| fi,

if p(v999^p) and v999^p:'-' then 'a14~^f's(left(v999^p,instr(v999^p,'-')-1))'^l's(right(v999^p,size(v999^p)-(instr(v999^p,'-'))))'~' else if p(v999^p) then |a14|v999^p|| fi fi,

if p(v999^v) then |a378|v999^v|| fi,

if p(v999^5) then |a30|v999^5|| fi,
if p(v999^w) then |a31|v999^w|| fi,
if p(v999^t) then |a32|v999^t|| fi,
if p(v999^4) then |a35|v999^4|| fi,

if p(v999^h) then |a40|v999^h|| fi,
if p(v999^q) then |a64|v999^q|| fi,
if p(v999^q) then |a65|v999^q.4|0000| fi,

if p(v999^x) then |a78|v999^x|| fi,
if p(v370) and size(v370) > 2500 then |a83|v370.2495| (AU)| else if p(v370) then |a83|v370|| fi fi,
if p(v351) then |a87|v351|| fi,

if v999*12.1= '1' then |a9119|v999*12.6|| else |a9120|v999*12.6|| fi,
if p(v999^2) then |a61|v999^2|| fi,
if p(v999^u) then |a72|v999^u|| fi
!

#|a320|v999*18.3||,

TPR="iffatal"
MSG="Error: mx creating Master File"
mx iso=$1.iso "proc=@$1.prc" create=filein0 -all now tell=1000
. log

TPR="iffatal"
MSG="Error: mxcp"
mxcp filein0 create=filein1 repeat=\;,10 > /dev/null
. log

TPR="iffatal"
MSG="Error: v10^a tag Master File"
mx filein1 "proc=if p(v378) and p(v10) then 'd378d10/1',|a1010|v10[1]|^a|v378|| fi" create=filein0 -all now tell=1000
. log

TPR="iffatal"
MSG="Error: v10^a tag Master File"
mx filein0 "proc='d10d1010',if p(v1010) and p(v10) then |a10|v1010||,|a10|v10|| else if p(v1010) then |a10|v1010|| fi, fi" create=filein2 -all now tell=1000
. log
rm filein0.*

cat>g30.seq<<!
Acta Gastroenterol Latinoam|Acta gastroenterol. latinoam
Acta Physiol Pharmacol Ther Latinoam|Acta physiol. pharmacol. ther. latinoam
An Acad Bras Cienc|An. Acad. Bras. Cinc
Arch Cardiol Mex|Arch. cardiol. mx
Arch Latinoam Nutr|Arch. latinoam. nutr
Arq Bras Cardiol|Arq. bras. cardiol
Arq Gastroenterol|Arq. gastroenterol
Arq Neuropsiquiatr|Arq. neuropsiquiatr
Biol Res|Biol. res
Biomedica (Bogota)|Biomdica (Bogot )
Braz Dent J|Braz. dent J
Braz J Infect Dis|Braz. j. infect. dis
Braz J Med Biol Res|Braz. j. med. biol. res
Cad Saude Publica|Cad. sa£de p£blica
Gac Med Mex|Gac. md. Mx
Ginecol Obstet Mex|Ginecol. obstet. Mx
Invest Clin|Invest. Cl¡n
Medicina (B Aires)|Medicina (B.Aires)
Mem Inst Oswaldo Cruz|Mem. Inst. Oswaldo Cruz
Rev Alerg Mex|Alergia Mx
Rev Argent Microbiol|Rev. argent. microbiol
Rev Assoc Med Bras|Rev. Assoc. Med. Bras. (1992)
Rev Biol Trop|Rev. biol. trop
Rev Bras Enferm|Rev. bras. enfermagem
Rev Cubana Med Trop|Rev. cuba. med. trop
Rev Fac Cien Med Univ Nac Cordoba|Rev. Fac. Cienc. Md. (C¢rdoba)
Rev Gastroenterol Mex|Rev. gastroenterol. Mx
Rev Gaucha Enferm|Rev. g ucha enferm
Rev Hosp Clin Fac Med Sao Paulo|Rev. Hosp. Clin. Fac. Med. Univ. SÆo Paulo
Rev Inst Med Trop Sao Paulo|Rev. Inst. Med. Trop. SÆo Paulo
Rev Invest Clin|Rev. invest. cl¡n
Rev Med Chil|Rev. md. Chile
Rev Paul Med|SÆo Paulo med. j
Rev Saude Publica|Rev. sa£de p£blica
Rev Soc Bras Med Trop|Rev. Soc. Bras. Med. Trop
Salud Publica Mex|Salud p£blica mx
West Indian Med J|West Indian med. j
!

TPR="iffatal"
MSG="Erro na criacao do gizmo de Tipo de Publicacao"
mx seq=g30.seq create=g30 now -all
. log

TPR="iffatal"
MSG="Erro no gizmo de Tipo de Publicacao"
mx filein2 gizmo=g30,30 now -all copy=filein2 tell=1777777700
. log
rm g30.*

TPR="iffatal"
MSG="Error: sort tags Master File"
mx filein2 "proc='S'" iso=trab1.iso -all now tell=1000
. log 

# ------------------------------------------------------------------- #
# Geracao do LST de trabalho
# ------------------------------------------------------------------- #
TPR="iffatal"
MSG="Erro na geracao da base lst"
mx iso=trab1.iso "pft=(mfn,'|',v87/)" now >trab1.lst
. log

# ------------------------------------------------------------------- #
# Carga do arquivo LST em uma base MicroIsis
# ------------------------------------------------------------------- #
TPR="iffatal"
MSG="Erro na carga da base lst"
mx seq=trab1.lst create=trab1 -all now
. log

# ------------------------------------------------------------------- #
# Quebra do campo 2
# ------------------------------------------------------------------- #
TPR="iffatal"
MSG="Erro na quebra do campo 2"
mxcp trab1 create=trab2 repeat=/,2 tell=1000
. log

# ------------------------------------------------------------------- #
# Retag da primeira ocorrencia do campo 2 para campo 3
# ------------------------------------------------------------------- #
TPR="iffatal"
MSG="Erro no retag da primeira ocorrencia do campo 2 para campo 3"
mx trab2 "proc='d2/1','a3'v2[1]''" create=trab1 -all now tell=1000
. log

# ------------------------------------------------------------------- #
# Proc para conversao de descritores com qualificadores
# ------------------------------------------------------------------- #
cat>trab1.prc<<!
if p(v2) then,
   (if v2='*' then,
      'a87'v3[1]'',
   else, 
      if v2:'*' then,
         'a87'v3[1]'^s'v2*1'',
      else,
         'a88'v3[1]'^s'v2''
      fi,
  ,fi,)       
else,
     select s(v3)
          case 'RELATO DE CASO':     'a76RELATO DE CASO'
          case 'ESTUDO COMPARATIVO': 'a76ESTUDO COMPARATIVO'
          case 'HUMANOS':             'a76HUMANO'
          case 'ANIMAL':             'a76ANIMAL'
          case 'MASCULINO':             'a76MASCULINO'
          case 'FEMININO':             'a76FEMININO'
          case 'GRAVIDEZ':             'a76GRAVIDEZ'
          case 'RECEM-NASCIDO':             'a76RECEM-NASCIDO'
          case 'LACTENTE':             'a76LACTENTE'
          case 'PRE-ESCOLAR':             'a76PRE-ESCOLAR'
          case 'CRIANCA':             'a76CRIANCA'
          case 'ADOLESCENTE':             'a76ADOLESCENTE'
          case 'ADULTO':             'a76ADULTO'
          case 'MEIA-IDADE':             'a76MEIA-IDADE'
          case 'IDOSO':             'a76IDOSO'
          case 'GATOS':             'a76GATOS'
          case 'BOVINOS':             'a76BOVINOS'
          case 'EMBRIAO DE GALINHA':             'a76EMBRIAO DE GALINHA'
          case 'CAES':             'a76CAES'
          case 'COBAIAS':             'a76COBAIAS'
          case 'HAMSTERS':             'a76HAMSTERS'
          case 'CAMUNDONGOS':             'a76CAMUNDONGOS'
          case 'COELHOS':             'a76COELHOS'
          case 'RATOS':             'a76RATOS'
          case 'IN VITRO':             'a76IN VITRO'
          case 'HISTORIA DA MEDICINA ANTIGA':             'a76HISTORIA DA MEDICINA ANTIGA'
          case 'HISTORIA DA MEDICINA MEDIEVAL':             'a76HISTORIA DA MEDICINA MEDIEVAL'
          case 'HISTORIA DA MEDICINA MODERNA':             'a76HISTORIA DA MEDICINA MODERNA'
          case 'HISTORIA DA MEDICINA DO SECULO 15':             'a76HISTORIA DA MEDICINA DO SECULO 15'
          case 'HISTORIA DA MEDICINA DO SECULO 16':             'a76HISTORIA DA MEDICINA DO SECULO 16'
          case 'HISTORIA DA MEDICINA DO SECULO 17':             'a76HISTORIA DA MEDICINA DO SECULO 17'
          case 'HISTORIA DA MEDICINA DO SECULO 18':             'a76HISTORIA DA MEDICINA DO SECULO 18'
          case 'HISTORIA DA MEDICINA DO SECULO 19':             'a76HISTORIA DA MEDICINA DO SECULO 19'
          case 'HISTORIA DA MEDICINA DO SECULO 20':             'a76HISTORIA DA MEDICINA DO SECULO 20'
          case 'SUPPORT, NON-U.S. GOV´T':             'a76SUPPORT, NON-U.S. GOV´T'
          case 'SUPPORT, U.S. GOV´T, NON-P.H.S.':             'a76SUPPORT, U.S. GOV´T, NON-P.H.S.'
          case 'SUPPORT, U.S. GOV´T, P.H.S.':             'a76SUPPORT, U.S. GOV´T, P.H.S.'
          elsecase 'a89'v3''
     endsel,
fi,
!

TPR="iffatal"
MSG="Erro na proc para conversao de descritores com qualificadores" 
mx trab1 "proc=@trab1.prc" create=trab2 -all now tell=1000
. log

#cat>decs.cip<<!
#decs.mst=decs.mst
#decs.xrf=decs.xrf
#decs.cnt=decs.cnt
#decs.iyp=decs.iyp
#decs.ly1=decs.ly1
#decs.ly2=decs.ly2
#decs.n01=decs.n01
#decs.n02=decs.n02
#!
#CIPAR=decs.cip
#export CIPAR

cat>proc89.prc<<!
'd89d100d105d106d32001',
if v100=v89 then,
   if v105:'T' then,
      'a71'v89'', 
   else,
      if v106:'c' then, 
	 'a76'v89'', 
      else,
	 'a88'v89'',
      fi,
   fi,
else,
   'a88'v89'',
fi,
!

TPR="iffatal"
MSG="Erro no join com o DECS"
mx trab2 "join=decs,100:1,105,106=mpu,(v89/)" jmax=1 proc=@proc89.prc create=trab1 -all now
. log

echo "1 0 v1/" >trab1.fst
TPR="iffatal"
MSG="Erro na inversao de trab1"
gentree trab1 trab1 1000 no
. log

cat>trab2.prc<<!
'd87d88d870d880d32001',
|a87|v870||,
|a88|v880||,
!

TPR="iffatal"
MSG="Erro no join com a base de trabalho" 
mx iso=trab1.iso "join=trab1,870:87,880:88,71,76=mfn/" "proc=@trab2.prc" create=trab2 -all now tell=1000
. log

cat>lang.prc<<!
'd40d400d32001',
(if p(v400) then,
    'a40!'v400'!',
 else,
    'a40!'v40'!',
fi),
if p(v83) then,
   if p(v400) then,
      'a41!',v400[1],'!',
   else,
      'a41!',v40[1],'!',
   fi,
fi,
!

TPR="iffatal"
MSG="Erro na traducao dos campos 40 e 41"
mx trab2 "join=../tabs/lang,400:100=mpu,(v40/)" "proc=@lang.prc" create=trab1 -all now tell=115
. log

TPR="iffatal"
MSG="Erro na criacao do arquivo SEQ para gizmo de qualificadores"
mx decs "pft=if v105:'Q' then '^s',v14,'|^s',v11*1/ fi" tell=1000 now >qualif.seq
. log

TPR="iffatal"
MSG="Erro na criacao do master de gizmo de qualificadores"
mx seq=qualif.seq create=gizqual -all now tell=100
. log

TPR="iffatal"
MSG="Erro na criacao do master de gizmo de qualificadores"
mx trab1 gizmo=gizqual,87,88 iso=$2.iso -all now tell=1025
. log


rm trab*.*
rm filein* qualif.seq gizqual.* *.prc
rm decs.tag decs.iyp decs.cnt decs.n01 decs.n02 decs.ly1 decs.ly2
#rm $2.*
#rm $1.*
#rm trab*.*
#rm filein* qualif.seq gizqual.* *.prc
#rm decs.*

TPR="end"
. log
