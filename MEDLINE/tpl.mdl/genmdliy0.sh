
# Apaga arquivo que anota conferencias
[ -f chk_iy0.lst ] && rm chk_iy0.lst


# cria subdiretorio iy0
if [ -d iy0 ]
then
   echo "Apagando iy0..."
   rm -r iy0
fi
mkdir iy0

# mdlfe.iy0 vazio da erro. Por isso nao gerei
# mdltw nao mais verificado pois a criacao do seu iy0 nao fica pronta quando é chamado essa analise, entao eh enviado
# e-mail de problema de invertido sempre. -  Fabio Brito/Marcelo Bottura - 20120628.
for i in mdllii mdlmhi kwice mdlau mdllip mdlmhp mdlti ntitle ntitleG4 kwici mdljr mdlmhc mdlot kwicp mdllie mdlmhe mdlss kwicta medlineafp medlineafe medlineafi mdlafunifesp mdlfe mdljdi mdljde mdljdp mdlcateg mdlicd mdlmp mdlScieloID mdlaf mdlab mdltw
do
  if [ -f $i.cnt ]
  then
    echo "gerando $i.iy0..."
    TPR="iffatal"
    MSG="mkiy0: $i.iy0"
    mkiy0 $i
    . log

    mv $i.iy0 iy0



# Inicio da checagem ##############################################################################
    if [ "${i}" = "mdlafunifesp" -o "${i}" = "mdlfe" ]
    then
        echo "Nao faz checagem"
    else
        if [ `mx dict=iy0/${i} "pft=v1^k/" count=10 -all now | wc -l` != 10 ]
        then
            echo "        **** Erro : Invertido iy0/${i}.iy0 mal formado!"
            echo "${i}.iy0" >> chk_iy0.lst
        fi
    fi
        #rm $i $i.iyp $i.n01 $i.n02 $i.ly1 $i.ly2
        echo

  else
    echo "arquivo não encontrado - $i"
  fi

done

# Checa se eh preciso enviar e-mail
if [ -e chk_iy0.lst ]
then
    if [ `wc -l chk_iy0.lst | tr -s " " | cut -d" " -f "1"` == 1 ]
    then
        QtdArqs="Foi verificado que ocorreu problema com o arquivo abaixo."
    else
        QtdArqs="Foi verificado que ocorreu problema com os arquivos abaixo."
    fi

    cat >mensagem.txt <<!
A equipe OFI,

${QtdArqs}

Verificar:
`cat chk_iy0.lst`

Informacoes dessa chamada:
`hostname`:`pwd` $ $0 $1 $2 $3 $4



!

sendemail -f appofi@bireme.org -u "MEDLINE - Checagem de Invertidos iy0 [`hostname`] `date '+%d/%m/%y %H:%M:%S'`" -o message-file=mensagem.txt -t ofi@bireme.org -s esmeralda.bireme.br -xu $SENDER_MAIL -xp bir@2012#

fi

# Termino da checagem ##############################################################################

[ -f ntitle.xrf ] && rm ntitle.[mx][sr][tf]

# Limpa area de trabalho
[ -f chk_iy0.lst ] && rm chk_iy0.lst
[ -f mensagem.txt ] && rm mensagem.txt
unset QtdArqs


