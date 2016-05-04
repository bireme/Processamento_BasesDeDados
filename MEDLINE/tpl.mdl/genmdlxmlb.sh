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
# verifica existencia dos diretorios BACK e SDI 
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

# verifica existencia da base de dados MDLBB
if [ ! -f m$ANO.mdl/mdlbb$ANO.xrf ]
then
   TPR="fatal"
   MSG="Erro: Falta a base de dados m$ANO.mdl/MDLBB$ANO"
   . log
fi

# verifica existencia do arquivo de rotulos em FASEA
if [ ! -s ./fasea/$DIR_FASEA/$2 ]
then
  TPR="fatal"
  MSG="Erro: ./fasea/$DIR_FASEA/$2 nao encontrado"
  . log
else
  if  [ "$3" = "DE" ]
  then
    TODOS=`cat ./fasea/$DIR_FASEA/labsdi"$ANO"b|tr -d " "|wc -l`
    TIPO=`grep "bmd" ./fasea/$DIR_FASEA/$2|tr -d " "|wc -l`
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
echo "Gerando Master de Browse (mdl) - $ANO..."
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
  MSG="erro na geracao da estrutura do Master de Browse"
  mx tmp count=0 now create=mdl$ANO
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
          MSG="Erro no processamento: $NAMEIN - $3"
          # revisar aqui
          #mx $NAMEIN "proc=if p(v667) or s(mpu,v668):'OLDMEDLINE' or v999^q.4 < '1966' then 'd*' fi" "proc='G../tabs/tab142a'" append=mdl$ANO -all now tell=10000
          mx $NAMEIN "proc=if p(v667) or s(mpu,v668):'OLDMEDLINE' or v999^q.4 < '1966' then 'd*' fi" append=mdl$ANO -all now tell=10000
          . log
          COUNT=`expr $COUNT + 1`
      done

  else
      
     for j in $1
     do
        mv mdl$ANO.mst mdltmp$ANO.mst
        mv mdl$ANO.xrf mdltmp$ANO.xrf
        COUNT=1
        LEN=`wc -l ../fasea/$DIR_FASEA/$2|tr -d " "|cut -d"." -f1`
        while
            [ $COUNT -le $LEN ]
        do
            NAMEIN=`head -$COUNT ../fasea/$DIR_FASEA/$2|tail -1|cut -d"|" -f1`
            NAMEIN=`echo "../fasea/$DIR_FASEA/$2"|sed "s/$2/$NAMEIN/"`
            echo "Processando $NAMEIN - $j"
            TPR="iffatal"
            MSG="Erro no processamento: $NAMEIN - $3"
            mx $NAMEIN "proc=if v999^q.4<>'$j' then 'd*' fi" append=mdltmp$ANO -all now tell=10000
            . log
            COUNT=`expr $COUNT + 1`
        done

            echo
            TPR="iffatal"
            MSG="Erro no processamento: $NAMEIN - $3"
            #mx mdltmp$ANO "gizmo=../tabs/tab142a" create=mdl$ANO -all now tell=10000
            mx mdltmp$ANO create=mdl$ANO -all now tell=10000
            . log
	    rm mdltmp$ANO.*

     done

     TPR="iffatal"
     MSG="Erro no processamento BB: $NAMEIN - $3"
     ../tpl.mdl/repetidos_mdl.sh mdl$ANO
     . log


  fi
  . log


# Confere o numero de resgistros do Master gerado MDL com o arquivo MDLBACK.TXT (soh processamento BACKFILE)

#if [ ! "$3" = "DE" ]
#then
#
#  SOMA_ANO=0
#  for j in $1
#  do
#      NRO_ANO=`grep "$j " ../fasea/$DIR_FASEA/mdlbaseline.txt|cut -f2 -d\| |tr -d " "`
#      SOMA_ANO=`expr $SOMA_ANO + $NRO_ANO`
#  done
#
#  NRO_MST=`mx mdl$ANO +control now count=0|tail -1|cut -c1-7 |tr -d " "`
#  NRO_MST=`expr $NRO_MST - 1`
#
#    if [ $SOMA_ANO -ne $NRO_MST ]
#       then
#          TPR="fatal"
#          MSG="Erro: Nro de registros nao equivalente entre MDLFULL.TXT e m$ANO.mdl/mdl$ANO"
#          . log
#    fi
#
#        echo Conferindo mdl$ANO... OK!!!
#fi

#rm mdlxl.par


############################## cria v8 (v866) no MedLINE ################
#pwd
#cd m$ANO.mdl
echo
echo "Criando campo v866 (links para SciELO) atraves do v968^a='pii'..."
echo
TPR="iffatal"
MSG="Erro: ../tpl.mdl/criaV8mdl.sh $ANO"
../tpl.mdl/criaV8mdl.sh $ANO
. log
cd -

