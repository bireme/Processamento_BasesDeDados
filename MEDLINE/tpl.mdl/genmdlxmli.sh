if [ "$#" -ne 3 ]
then
  TPR="fatal"
  MSG="Use: genmdlxmli <ANO_4digitos> <file_label_bak_sdi> <DP/DE>" 
  . log
fi

echo "executando $0"
LOCAL=`pwd`
if [ $LOCAL != "/bases/mdlG4" ]
then
  TPR="fatal"
  MSG="$0 - local de execucao deve ser em /bases/mdlG4"
  . log
fi


if [ "$3" = "DE" ]
then
   DIR_FASEA="update_isis"
else
   DIR_FASEA="baseline_isis"
fi

# ----------------------------------------------------------------------- #
# verifica existencia dos diretorios update_isis ou baseline_isis
# ----------------------------------------------------------------------- #
if [ ! -d fasea/$DIR_FASEA ]
then
  TPR="fatal"
  MSG="Error: Diretorio nao localizado : $DIR_FASEA"
  . log
fi

# ------------------------------------------------------------------------- #
# validacao de parametros  
# ------------------------------------------------------------------------- #
ANO=`echo $2|cut -c7-8`

# verifica existencia do arquivo de rotulos em FASEA
if [ ! -s ./fasea/$DIR_FASEA/$2 ]
then
  TPR="fatal"
  MSG="Erro: ./fasea/$DIR_FASEA/$2 nao encontrado"
  . log
else
  if  [ "$3" = "DE" ]
  then
    TODOS=`cat ./fasea/$DIR_FASEA/labsdi"$ANO"i|tr -d " "|wc -l`
    TIPO=`grep "imd" ./fasea/$DIR_FASEA/$2|tr -d " "|wc -l`
    if [ "$TIPO" -ne "$TODOS" ]
    then
      TPR="fatal"
      MSG="Conteudo do arquivo LAB incompativel (Browse/Index)"
      . log
    fi
  fi
fi
 
# verifica existencia do arquivo MDLBACK.TXT ou MDLSDI.TXT em FASEA
if [ "$3" = "DE" ]
then
   if [ ! -s ./fasea/$DIR_FASEA/mdlupdate.txt ]
   then
      TPR="fatal"
      MSG="Erro: ./fasea/$DIR_FASEA/mdlupdate.txt nao encontrado"
      . log
   fi
else
   if [ ! -s ./fasea/$DIR_FASEA/mdlbaseline.txt ]
   then
      TPR="fatal"
      MSG="Erro: ./fasea/$DIR_FASEA/mdlbaseline.txt nao encontrado"
      . log
   fi
fi

# ----------------------------------------------------------------------- #
# Verifica se todos os arquivos do arquivo de LABEL estao presentes  
# ----------------------------------------------------------------------- #
COUNT=1
LEN=`wc -l ./fasea/$DIR_FASEA/$2|tr -d " "|cut -d"." -f1`
while
     [ $COUNT -le $LEN ]
do
     NAMEIN=`head -$COUNT ./fasea/$DIR_FASEA/$2|tail -1`
     TPR="iffatal"
     MSG="./fasea/$DIR_FASEA/$NAMEIN.xrf not found"
     if  [ -f ./fasea/$DIR_FASEA/$NAMEIN.xrf ]
     then
         echo "Cheking ./fasea/$DIR_FASEA/$NAMEIN...  OK"
     else
         . log
     fi
     COUNT=`expr $COUNT + 1`
done
unset COUNT


echo
echo "Gerando Master de Inversao (mdlab/mdlbb) - $ANO..."
echo

# ---------------------------------------------------------------------- #
# geracao do MASTER de indexacao
# ---------------------------------------------------------------------- #

  if  [ ! -d m$ANO.mdl ]
  then
      mkdir m$ANO.mdl
  fi
  cd m$ANO.mdl

# Gera a estrutura do MST de INDEX
  echo "mstxl=64G" > mdlxl.par
  CIPAR=mdlxl.par
  export CIPAR

  TPR="iffatal"
  MSG="erro na geracao da estrutura do Master de INVERSAO"
  mx tmp count=0 now create=mdlbb$ANO
  . log
  mx tmp count=0 now create=mdlab$ANO
  . log

# Processa fitas para geracao do MST de INDEX
  TPR="iffatal"
  MSG="Erro na geracao MDL sem AB"
  if  [ "$3" = "DE" ]
  then
  
      COUNT=1
      LEN=`wc -l ../fasea/$DIR_FASEA/$2|tr -d " "|cut -d"." -f1`
      while
          [ $COUNT -le $LEN ]
      do
          NAMEIN=`head -$COUNT ../fasea/$DIR_FASEA/$2|tail -1|cut -d"|" -f1`
          NAMEIN=`echo "../fasea/$DIR_FASEA/$2"|sed "s/$2/$NAMEIN/"`
          echo "Processando $NAMEIN - $ANO"
          TPR="iffatal"
          MSG="Erro no processamento BB: $NAMEIN - $3"
          #mx $NAMEIN "proc=if p(v667) or s(mpu,v668):'OLDMEDLINE' or v354.4 < '1966' or s(mpu,v668):'IN-DATA-REVIEW' then 'd*' fi" "proc='d370',if p(v370) then 'a370~YES~' fi" append=mdlbb$ANO -all now tell=10000
          #mx $NAMEIN "proc=if p(v667) or s(mpu,v668):'OLDMEDLINE' or v354.4 < '1966' then 'd*' fi" "proc='d370',if p(v370) then 'a370~YES~' fi" append=mdlbb$ANO -all now tell=10000 "proc=if mfn=1 and p(v354) then putenv('DATE='date) fi" "proc=if p(v354) then 'a1354|'replace(v354,'-',' ')'|' fi" "proc=if p(v354) then 'Gsplit=1354= ' fi" "proc='d1354',if p(v354) then '<854>'s1:=(v1354[1].4),e1:=l(['../tabs/tab354']v1354[2]),s2:=(if e1>0 then ref(['../tabs/tab354']e1,v2) fi),,,e1:=(val(s(getenv('DATE')).4)-1900)*12+val(s(getenv('DATE'))*4.2),e2:=(val(s1)-1900)*12+val(s2),,,s1,s2'</854>','<855>'replace(f(e1-e2,4,0),' ','0')'</855>' fi"
          mx $NAMEIN "proc=if p(v667) or s(mpu,v668):'OLDMEDLINE' or v354.4 < '1966' then 'd*' fi" "proc='d370',if p(v370) then 'a370YES' fi" append=mdlbb$ANO -all now tell=10000 "proc=if mfn=1 and p(v354) then putenv('DATE='date) fi" "proc=if p(v354) then 'a1354|'replace(v354,'-',' ')'|' fi" "proc=if p(v354) then 'Gsplit=1354= ' fi" "proc='d1354d854d855',if p(v354) then '<854>'s1:=(v1354[1].4),e1:=l(['../tabs/tab354']v1354[2]),s2:=(if e1>0 then ref(['../tabs/tab354']e1,v2) fi),,,e1:=(val(s(date).4)-1900)*12+val(s(date)*4.2),e2:=(val(s1)-1900)*12+val(s2),,,s1,s2'</854>','<855>'replace(f(e1-e2,4,0),' ','0')'</855>' fi"
          . log
          TPR="iffatal"
          MSG="Erro no processamento AB: $NAMEIN - $3"
          #$LINDG/mx $NAMEIN "proc=if p(v667) or s(mpu,v668):'OLDMEDLINE' or v354.4 < '1966' or s(mpu,v668):'IN-DATA-REVIEW' then 'd*' fi" "proc='d*',|a370|v370||,'a969'v969''" "proc=if p(v967) then 'd967',(if v967:'Available' then '<967>'left(v967^*,instr(v967^*,' ')-1)'^a'v967^a'</967>' else '<967>'v967'</967>' fi),fi" append=mdlab$ANO -all now tell=10000
          mx $NAMEIN "proc=if p(v667) or s(mpu,v668):'OLDMEDLINE' or v354.4 < '1966' then 'd*' fi" "proc='d*',|a370|v370||,'a969'v969''" "proc=if p(v967) then 'd967',(if v967:'Available' then '<967>'left(v967^*,instr(v967^*,' ')-1)'^a'v967^a'</967>' else '<967>'v967'</967>' fi),fi" append=mdlab$ANO -all now tell=10000
          . log

          COUNT=`expr $COUNT + 1`
      done

  else
      
     for j in $1
     do
        COUNT=1
        LEN=`wc -l ../fasea/$DIR_FASEA/$2|tr -d " "|cut -d"." -f1`
        while
            [ $COUNT -le $LEN ]
        do
            NAMEIN=`head -$COUNT ../fasea/$DIR_FASEA/$2|tail -1|cut -d"|" -f1`
            NAMEIN=`echo "../fasea/$DIR_FASEA/$2"|sed "s/$2/$NAMEIN/"`
            echo "Processando $NAMEIN - $j"
            echo $NAMEIN
            TPR="iffatal"
            MSG="Erro no processamento BB: $NAMEIN - $3"
            mx $NAMEIN "proc=if v354.4<>'$j' then 'd*' else if p(v370) then 'd370','a370YES' fi fi" append=mdlbb$ANO -all now tell=10000 "proc=if mfn=1 and p(v354) then putenv('DATE='date) fi" "proc=if p(v354) then 'a1354|'replace(v354,'-',' ')'|' fi" "proc=if p(v354) then 'Gsplit=1354= ' fi" "proc='d1354d854d855',if p(v354) then '<854>'s1:=(v1354[1].4),e1:=l(['../tabs/tab354']v1354[2]),s2:=(if e1>0 then ref(['../tabs/tab354']e1,v2) fi),,,e1:=(val(s(date).4)-1900)*12+val(s(date)*4.2),e2:=(val(s1)-1900)*12+val(s2),,,s1,s2'</854>','<855>'replace(f(e1-e2,4,0),' ','0')'</855>'fi"
            . log
            TPR="iffatal"
            MSG="Erro no processamento AB: $NAMEIN - $3"
            mx $NAMEIN "proc='d*',if v354.4<>'$j' then 'd*' else |a370|v370||,'a969'v969'' fi" "proc=if p(v967) then 'd967',(if v967:'Available' then '<967>'left(v967^*,instr(v967^*,' ')-1)'^a'v967^a'</967>' else '<967>'v967'</967>' fi),fi" append=mdlab$ANO -all now tell=10000
            . log
            COUNT=`expr $COUNT + 1`
        done

     done

     TPR="iffatal"
     MSG="Erro no processamento BB: $NAMEIN - $3"
     ../tpl.mdl/repetidos_mdl.sh mdlbb$ANO
     . log

     TPR="iffatal"
     MSG="Erro no processamento BB: $NAMEIN - $3"
     ../tpl.mdl/repetidos_mdl.sh mdlab$ANO
     . log

  fi
  . log

TPR="iffatal"
MSG="Erro ../tpl.mdl/cria968apartirIAHlinks.sh - "
../tpl.mdl/cria968apartirIAHlinks.sh $ANO
. log

# Confere o numero de resgistros do Master gerado MDLBB com o arquivo MDLBACK.TXT (só processamento BACKFILE)


exit


if [ ! "$3" = "DE" ]
then

  SOMA_ANO=0
  for j in $1
  do
      NRO_ANO=`grep "$j " ../fasea/$DIR_FASEA/mdlbaseline.txt|cut -f2 -d\| |tr -d " "`
      SOMA_ANO=`expr $SOMA_ANO + $NRO_ANO`
  done

  NRO_MST=`mx mdlbb$ANO +control now count=0|tail -1|cut -c1-7 |tr -d " "`
  NRO_MST=`expr $NRO_MST - 1`

  echo "soma_ano=" $SOMA_ANO
  echo "NRO_MST=" $NRO_MST

  if [ $SOMA_ANO -ne $NRO_MST ]
     then
        TPR="fatal"
        MSG="Erro: Nro de registros nao equivalente entre mdlbaseline.txt e m$ANO.mdl/mdlbb$ANO"
        . log
  fi

      echo Conferindo mdlbb$ANO... OK!!!
fi

rm mdlxl.par
