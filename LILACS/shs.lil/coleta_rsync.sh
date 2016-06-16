#!/bin/bash

# -------------------------------------------------------------------------- #
# coleta_rsync.sh - Efetua coleta de dados por remote syncronism - rsync     #
# -------------------------------------------------------------------------- #
# Chamada : coleta_rsync.sh [-V] <FI>
# Exemplo : coleta_rsync.sh tit
#           coleta_rsync.sh nml
# -------------------------------------------------------------------------- #
#  Centro Latino-Americano e do Caribe de Informação em Ciências da Saúde    #
#     é um centro especialidado da Organização Pan-Americana da Saúde,       #
#           escritório regional da Organização Mundial da Saúde              #
#                      BIREME / OPS / OMS (P)2012-16                         #
# -------------------------------------------------------------------------- #
# Historico
# Versao data, responsavel
#       - Descricao
cat > /dev/null <<HISTORICO
vrs:  0.00 20160519, FJLopes
	- Edicao original
vrs:  0.00 20160610, FJLopes
	- Limpeza de codigo e comentarios
HISTORICO

# ========================================================================== #
#                                BIBLIOTECAS                                 #
# ========================================================================== #
# Incorpora biblioteca de controle basico de processamento
#source $PATH_EXEC/inc/infi_exec.inc
source  $MISC/infra/infoini.inc

# Incorpora biblioteca de processos de coleta
source ../shs.lil/inc/coletas.inc
# Conta com as funcoes:
#  clANYTHING   PARM1   Retorna o ID da FI
#  clDIRETORIO  PARM1   Retorna o diretorio de trabalho para a FI
#  clSIGLA      PARM1   Retorna a sigla humana da FI
#  clTYPE       PARM1   Retorna o tipo de coleta da FI
#  clSSERVER    PARM1   Retorna o SOURCE SERVER da FI
#  clSDIRETORIO PARM1   Retorna o diretorio dos dados no SSERVER
#  clUSER       PARM1   Retorna username para tomar dados da FI no SSERVER
#  clPASSWD     PARM1   Retorna password
#  clTODAS      PARM1   Retorna a lista de FIs (se PARM1 sera o arquivo)
#  clLIB                Retorna a informacao geral da library
#  clSTATUS     PARM1   Retorna false / true (ID da FI) se ativa
#  clINFO       PARM1   Exibe a configuracao da FI
#

# ========================================================================== #
#                                  FUNCOES                                   #
# ========================================================================== #
parseFL(){
	IFS=";" read -a FILES <<< "$1"
}

# Incorpora carregador de defaults padrao
unset NOERRO
OPC_ERRO=""
DEBUG=0
PARMD=""

# Mensagens de HELP
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
AJUDA_USO="
Uso: $TREXE [-V] <InfoS>

Opções:
 -V, --version       * Exibe a versão corrente do programa
     * Se usada interrompe a execução do programa

Parâmetros:
 InfoS  Identificador da Fonte de Informacao
"

# Tratador de opcoes
while test -n "$1"
do
	case "$1" in
		-V | --version)
			iVersao
			echo
			exit 0
			;;

		*)
			if [ $(expr index $1 "-") -ne 1 ]; then
				if test -z "$PARM1"; then PARM1=$1; shift; shift; continue; fi
				if test -z "$PARM2"; then PARM2=$1; shift; shift; continue; fi
			else
				echo "Opção não válida! ($1)"
			fi
			;;
	esac
	# Argumento tratado, desloca os parametros e trata o proximo (se existir)
	shift
done
# Avalia o nivel de depuracao
[ $((DEBUG & $_BIT3_)) -ne 0 ] && set -v
[ $((DEBUG & $_BIT4_)) -ne 0 ] && set -x

# ========================================================================== #

#     1234567890123456789012345
echo "[c_rsy]  1         - Inicia processamento de coleta por rsync"
# -------------------------------------------------------------------------- #
# Garante que a FI seja informada (sai com codigo de erro 2 - Syntax Error)
if [ -z "$PARM1" ]; then
        #     1234567890123456789012345
        echo "[c_rsy]  1.01      - Erro na chamada falta o parametro 1"
        echo
        echo "Syntax error:- Missing PARM1"
        echo "$AJUDA_USO"
        exit 2
fi
			
# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                            1234567890123456789012345
[ $N_DEB -ne 0 ]               && echo "[c_rsy]  0.00.04   - Testa se ha tabela de configuracao"
[ ! -s "../tabs/coletas.tab" ] && echo "[c_rsy]  1.01      - Configuration error:- COLETAS table not found" && exit 3
unset   SIGLA
# Garante existencia do FI indicada na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para processamento
#                         1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[c_rsy]  0.00.05   - Testa se o indice eh valido"
IDFI=$(clANYTHING $PARM1)
[ $? -eq 0 ]     && SIGLA=$(clSIGLA $IDFI)
[ -z "$SIGLA" ]  && echo "[c_rsy]  1.01      - PARM error:- PARM1 does not indicate a valid index" && exit 4

echo "[c_rsy]  1.01      - Carrega definicoes da fonte para coleta de dados"
  TIPOC=$(clTYPE       $IDFI)
 DIRETO=$(clDIRETORIO  $IDFI)
SSERVER=$(clSSERVER    $IDFI)
SDIRETO=$(clSDIRETORIO $IDFI)
 OBJETO=$(clOBJETOS    $IDFI)
  PORTA=$(clPORT       $IDFI)
 USERCL=$(clUSER       $IDFI)
 PASSCL=$(clPASSWD     $IDFI)
# -------------------------------------------------------------------------- #
# Garante que a rotina certa para o tipo de coleta da FI
[ "$TIPOC" != "rsync" ] && echo "[c_rsy]  1.02      - Configuration mismatch:- Only the rsync method is supported by this program!" && exit 4

# -------------------------------------------------------------------------- #
# Ajusta lista de arquivos conforme regras gerais
echo "[c_rsy]  1.02      - Efetua ajustamentos conforme regras implicitas"
# Regra 1 se nao ha especificacao deve ser M/F LILACS
[ -z $OBJETO ] && OBJETO="LILACS.xrf;LILACS.mst" && parseFL $OBJETO && echo "Tentou o ajuste"
# Regra 2 se não especifica a extensao deve ser mst e xrf
egrep '\.' >/dev/null <<<$OBJETO
RSP=$?
if [ $RSP -ne 0 ]; then
	OBJETO=${OBJETO//;/\.\{mst,xrf\};}".{mst,xrf}"
fi

parseFL $OBJETO

# Determina o numero de arquivos da lista
i=0
while [ ! -z ${FILES[$i]} ]
do
	i=$(expr $i + 1)
done
# Obtem o numero de arquivos passados na lista [0..[
MAXFILE=$(expr $i - 1)
# -------------------------------------------------------------------------- #

if [ $N_DEB -ne 0 ]; then
	echo "==========================================================="
	echo "  == COLETA RSYNC =="
	echo "==========================================================="
	echo " Identificador da FI       [IDFI]: $IDFI"
	echo " Sigla humana da FI       [SIGLA]: $SIGLA"
	echo " Diretorio de trabalho   [DIRETO]: $DIRETO"
	echo " Servidor fonte         [SSERVER]: $SSERVER"
	echo " Diretorio na fonte     [SDIRETO]: $SDIRETO"
	echo " Lista de arquivos       [OBJETO]: $OBJETO"
	echo " Quantidade de arquivos [MAXFILE]: $MAXFILE"
	echo " Port TCP/IP a usar       [PORTA]: $PORTA"
	echo " Usuario para a coleta   [USERCL]: $USERCL"
	echo " Senha do usuario        [PASSCL]: $PASSCL"
	echo " Identificador da FI       [IDFI]: $IDFI"
	echo "========================================="
	i=0
	while [ ${i} -le $MAXFILE ]
	do
		echo "  Arq.$(expr $i + 1): ${FILES[$i]}"
		i=$(expr $i + 1)
	done
	echo "==========================================================="
fi
# -------------------------------------------------------------------------- #

# Faz corrente o diretorio de processamento
echo "[c_rsy]  1.03      - Faz corrente o diretorio de processamento"
cd $DIRETO

# Efetua a tomada dos dados
echo "[c_rsy]  2         - Efetiva a transferencia de dados"
echo "[c_rsy]  2.01      - Sincroniza arquivos"
for i in $(seq 0 $MAXFILE)
do
	echo "[c_rsy]  2.01.0$i   -  Copiando ${FILES[$i]} de $SIGLA"
	egrep 'LILACS' >/dev/null <<<${FILES[$i]}
	RSP=$?
	if [ $RSP -eq 0 ]; then
		rsync -rav $USERCL@$SSERVER:${SDIRETO/dbnotcertif/dbcertif}/${FILES[$i]} .
	else
		rsync -rav $USERCL@$SSERVER:$SDIRETO/${FILES[$i]} .
	fi
	RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
	chkError $RSP "Sincronizando ${FILES[$i]} de $SIGLA"
	# Fica permissoes do arquivo recebido
	chmod ug=rw ${FILES[$i]}
	chmod  o=r  ${FILES[$i]}
done

# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infofim.inc

# -------------------------------------------------------------------------- #
cat > /dev/null <<COMMENT
.    Entrada :  PARM1 identificando a FI a operar
.               Opcoes de execucao
.                -V, --versao   Mostra a versao
.      Saida :  Arquivos da Fonte de Informacao coletados
.               Codigos de retorno:
.                 0 - Ok operation
.                 1 - Non specific error
.                 2 - Syntax Error
.                 3 - Configuration error (iAHx.tab not found)
.                 4 - Configuration failure (INDEX_ID unrecognized; wrong method; ...)
.   Corrente :  --
.    Chamada :  coleta_rsync.sh [-V] <ID_FI>
.    Exemplo :  nohup ../shs.lil/coleta_rsync.sh tit &> logs/YYYYMMDD.colRSY.txt &
.Objetivo(s) :  1- Atualizar Fonte de Informacao
.Comentarios :
.Observacoes :  DEBUG eh uma variavel mapeada por bit conforme
.                       _BIT0_  Aguarda tecla <ENTER>
.                       _BIT1_  Mostra mensagens de DEBUG
.                       _BIT2_  Modo verboso
.                       _BIT3_  Modo debug de linhas -v
.                       _BIT4_  Modo debug de linhas -x
.                       _BIT7_  Opera em modo FAKE
.      Notas :
.Dependencia :  Tabela coletas.tab deve estar presente em ../tabs
.               COLUNA  NOME                    COMENTARIOS
.                1      ID_FI               ID da Fonte de Informacao     (Identificador unico)
.                2      SIGLA FI            Nome humano da FI
.                3      DIRETORIO           Diretorio de entrega dos dados
.                4      TIPO                Tipo de coleta para aFI (valores: scp / ftp / rsync / oai / dSpace)
.                5      FONTE DE DADOS
.                       ^h=                 HOSTNAME onde se encontram os dados
.                       ^d=                 Diretorio dos dados na fonte
.                       ^l=                 PORT TCP/IP a ser utilizado (quando cabivel)
.                       ^p=                 Username a ser utilizado no processo
.                       ^s=                 Senha do ususario a ser empregada na autenticacao
.                       ^b=                 Lista de arquivos (separados por ;) a coletar
.               Variaveis de ambiente que devem estar previamente ajustadas:
.               geral           BIREME - Path para o diretorio com especificos da BIREME
.               geral             CRON - Path para o diretorio com rotinas de crontab
.               geral             MISC - Path para o diretorio de miscelaneas da BIREME
.               geral             TABS - Path para as tabelasde uso geral da BIREME
.               geral         TRANSFER - Usuario para troca de arquivos entre servidores
.               geral           _BIT0_ - 00000001b
.               geral           _BIT1_ - 00000010b
.               geral           _BIT2_ - 00000100b
.               geral           _BIT3_ - 00001000b
.               geral           _BIT4_ - 00010000b
.               geral           _BIT5_ - 00100000b
.               geral           _BIT6_ - 01000000b
.               geral           _BIT7_ - 10000000b
.               ISIS         ISIS - WXISI      - Path para pacote
.               ISIS     ISIS1660 - WXIS1660   - Path para pacote
.               ISIS        ISISG - WXISG      - Path para pacote
.               ISIS         LIND - WXISL      - Path para pacote
.               ISIS      LIND512 - WXISL512   - Path para pacote
.               ISIS       LINDG4 - WXISLG4    - Path para pacote
.               ISIS    LIND512G4 - WXISL512G4 - Path para pacote
.               ISIS          FFI - WXISF      - Path para pacote
.               ISIS      FFI1660 - WXISF1660  - Path para pacote
.               ISIS       FFI512 - WXISF512   - Path para pacote
.               ISIS        FFIG4 - WXISFG4    - Path para pacote
.               ISIS       FFI256 - WXISF256   - Path para pacote
.               ISIS     FFI512G4 - WXISF512G4 - Path para pacote

<MOREINFO
Códigos de retorno do rsync
.    0  Success
.    1  Syntax or usage error
.    2  Protocol incompatibility
.    3  Errors selecting input/output files, dirs
.    4  Requested action not supported: an attempt was made to manipulate 64-bit files on a platform that cannot support them;  or  an  option  was
.       specified that is supported by the client and not by the server.
.    5  Error starting client-server protocol
.    6  Daemon unable to append to log-file
.   10  Error in socket I/O
.   11  Error in file I/O
.   12  Error in rsync protocol data stream
.   13  Errors with program diagnostics
.   14  Error in IPC code
.   20  Received SIGUSR1 or SIGINT
.   21  Some error returned by waitpid()
.   22  Error allocating core memory buffers
.   23  Partial transfer due to error
.   24  Partial transfer due to vanished source files
.   25  The --max-delete limit stopped deletions
.   30  Timeout in data send/receive
.   35  Timeout waiting for daemon connection

COMMENT
exit
cat > /dev/null <<SPICEDHAM
CHANGELOG
20160513 Edição original
20160610 Enxugamento de codigo e comentarios
SPICEDHAM

