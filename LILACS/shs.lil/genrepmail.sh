#!/bin/bash

# -------------------------------------------------------------------------- #
# genrepmail.sh - Procedimento para geracao da base MAIL de REPIDISCA
# -------------------------------------------------------------------------- #
#    Corrente : /bases/lilG4/xxx.lil
#     Chamada : genrepmail.sh <ISO_FILE>
#     Exemplo : ../shs.lil/genrelmail.sh $TABS/redir.iso
# Objetivo(s) : Gerar a base mail de REPIDISCA
#  IMPORTANTE : deve ser executado com user do grupo operacao
# -------------------------------------------------------------------------- #
#   Centro Latino-Americano e do Caribe de Informação em Ciências da Saúde
#      é um centro especialidado da Organização Pan-Americana da Saúde,
#            escritório regional da Organização Mundial da Saúde
#                       BIREME / OPS / OMS (P)2014-16
# -------------------------------------------------------------------------- #
# Historico
# versao data, Responsavel
#       - Descricao
cat > /dev/null <<HISTORICO
vrs:  0.00 19940301, Renato Sousa
        - Edicao original
vrs:  0.01 20160922, FJLopes
	- Adequacao ao novo padrao de processamento
HISTORICO
# ========================================================================== #
#                                BIBLIOTECAS                                 #
# ========================================================================== #
# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infoini.inc

# -------------------------------------------------------------------------- #
# Verifica se o arquivo iso existe no diretorio 

echo "[genrepmail.sh] Gerando mail repidisca"
if [ ! -f $1 ]; then
   TPR="warning"
   MSG="use: $0 $TABS/redir.iso"
   . log
fi

# -------------------------------------------------------------------------- #
# Assume argumento de chamada por default
PARM1=${1:-$TABS/redir.iso}

# -------------------------------------------------------------------------- #
# Carga do arquivo MAIL.ISO

del mail.mst mail.xrf mail.l* mail.n0* mail.cnt mail.iyp	# funcao contida em infoini.inc
TPR="iffatal"
MSG="Erro na geracao do iso MAIL.ISO" 
cat > mail.prc<<MAILPRC
 'd*'
 if p(v30) then
   |a805~|v30|~|
   |a810~|v40|~|
   |a810~|v50|~|
   |a810~|v60|~|
   |a815~|v90|~|
   |a820~|v100|~|
   |a835~|v130|~|
   |a840~|v140|~|
   |a845~|v150|~|
   |a850~|v160|~|
   |a855~|v165|~|
   |a860~|v110|~|
 fi
MAILPRC

echo "[genrepmail.sh] Altera campos dos dados"
mx iso=${PARM1} iso=mail.iso proc=@mail.prc now -all tell=10
. log

echo "[genrepmail.sh] Carrega a base mail"
TPR="iffatal"
MSG="Erro na geracao da base MAIL"
loadiso mail mail create clean
. log

# -------------------------------------------------------------------------- #
# MAIL.FST

cat>mail.fst<<MAILFST
805 0 mpl,v805
MAILFST

# -------------------------------------------------------------------------- #
# Carga do invertido mail

echo "[genrepmail.sh] Inverte a base mail"
TPR="iffatal"
MSG="Erro na geracao do invertido MAIL"
gentree mail mail 100 no
. log


echo "[genrepmail.sh] Limpa area de trabalho"
del mail.l*
del mail.fst
del mail.prc

source $MISC/infra/infofim.inc
exit 0







# -------------------------------------------------------------------------- #
cat > /dev/null <<COMMENT
# GENREPMAIL - Procedimento para geracao da base mail de repidisca
#
# Sintaxe: genrepmail file.iso 
# -------------------------------------------------------------------------- #
.    Entrada :  ISO-file a ser carregado
.      Saida :  M/F+I/F mail
.   Corrente :  .../rep.lil
.    Chamada :  genrepmail.sh <ISO_FILE>
.    Exemplo :  ../shs/genrepmail.sh $TABS/redir.iso
.Objetivo(s) :  Gerar a base e o invertido MAIL de REPIDISCA
.Comentarios :  
.Observacoes :  DEBUG eh uma variavel mapeada por bit conforme
.               _BIT0_  Aguarda tecla <ENTER>
.               _BIT1_  Mostra mensagens de DEBUG
.               _BIT2_  Modo verboso
.               _BIT3_  Modo debug de linha -v
.               _BIT4_  Modo debug de linha -x
.               _BIT7_  Execucao FAKE
.      Notas :  
Dependencias :	Variaveis de ambiente que devem estar previamente ajustadas:
.               geral       BIREME - Path para o diretorio com especificos de BIREME
.               geral         CRON - Path para o diretorio com rotinas de crontab
.               geral         MISC - Path para o diretorio de miscelaneas de BIREME
.               geral        PROCS - Path para as subrotinas de processamento tradicionais
.               geral         TABS - Path para as tabelas de uso geral da BIREME
.               geral     TRANSFER - Usuario para troca arquivos entre servidores
.               geral       _BIT0_ - 00000001b
.               geral       _BIT1_ - 00000010b
.               geral       _BIT2_ - 00000100b
.               geral       _BIT3_ - 00001000b
.               geral       _BIT4_ - 00010000b
.               geral       _BIT5_ - 00100000b
.               geral       _BIT6_ - 01000000b
.               geral       _BIT7_ - 10000000b
.               geral   MDL_ANOCORRENTE2DIGITOS - Ano corrente para efeito de processamento
.               geral   MDL_ANOCORRENTE4DIGITOS - Ano corrente para efeito de processamento
.               geral      MDL_BASELINE2DIGITOS - Lista de anos do Medline
.               geral      MDL_BASELINE4DIGITOS - Lista de anos do Medline
.               ISIS          ISIS - WXISI      - Path para pacote CISIS compilado em 10/30 normal
.               ISIS      ISIS1660 - WXIS1660   - Path para pacote CISIS compilado em 16/60 normal
.               ISIS         ISISG - WXISG      - Path para pacote CISIS compilado em 10/30 BIG-FILES
.               ISIS          LIND - WXISL      - Path para pacote CISIS compilado em Lind 16/10 normal
.               ISIS       LIND512 - WXISL512   - Path para pacote CISIS compilado em Lind 16/512 normal
.               ISIS        LINDG4 - WXISLG4    - Path para pacote CISIS compilado em Lind 16/60 BIG-FILES 4G registros
.               ISIS     LIND512G4 - WXISL512G4 - Path para pacote CISIS compilado em Lind 16/512 BIG-FILES 4G registros
.               ISIS           FFI - WXISF      - Path para pacote CISIS compilado em FFI Lind 16/60
.               ISIS       FFI1660 - WXISF1660  - Path para pacote CISIS compilado em FFI 16/60
.               ISIS        FFI512 - WXISF512   - Path para pacote CISIS compilado em FFI Lind 16/512
.               ISIS         FFIG4 - WXISFG4    - Path para pacote CISIS compilado em FFI Lind 16/60 BIG-FILES 4G registros
.               ISIS        FFI4G4 - WXISF4G4   - Path para pacote CISIS compilado em FFI 4M Lind 16/60 BIG-FILES 4G registros
.               ISIS        FFI256 - WXISF256   - Path para pacote CISIS compilado em FFI 16/256 BIG-FILES
.               ISIS      FFI512G4 - WXISF512G4 - Path para pacote CISIS compilado em FFI Lind 16/512 BIG-FILES 4G registros
COMMENT
# --------------------------------------------------------------------------- #
cat > /dev/null <<SPICEDHAM
CHANGELOG
19940301 Edição original
20160922 Adequacao ao novo padrao de processamento
SPICEDHAM

