#!/bin/bash

# -------------------------------------------------------------------------- #
# saneamento_colecionasus.sh - Efetua preparos especificos para ColecionaSUS #
# -------------------------------------------------------------------------- #
# Chamada : saneamento_colecionasus.sh [-V] <ID_FI>
# Exemplo : nohup ../saneamento_colecionasus.sh sus &> logs/$(date '+%Y%m%d')_saneaSUS.txt &
# ATENCAO : Assume como default a versao lindG4
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
vrs:  0.00 20160610, FJLopes
	- Edicao original
HISTORICO

# ========================================================================== #
#                                BIBLIOTECAS                                 #
# ========================================================================== #
# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infoini.inc

# Incorpora biblioteca de processos de coleta
source ../shs.lil/inc/coletas.inc

# Assume valores DEFAULT
NOERRO=0;	# Controla o modo "Ignore Erros"
DEBUG=0;	# Controla o nivel de depuracao

# Mensagem de HELP
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
AJUDA_USO="
Syntax: $TREXE [options] <InfoS>

Options:
 -V, --version       Displays the current version of program and stop

Parameters:
InfoS - Identifier of Information Source to process (in this case must be SUS)

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
				if test -z "$PARM1";  then PARM1=$1;  shift; shift; continue; fi
				if test -z "$PARM2";  then PARM2=$1;  shift; shift; continue; fi
			else
				echo "Not valid option ($1)"
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
echo "[s_sus]  1         - Inicia processamento de coleta por scp"
# -------------------------------------------------------------------------- #
# Garante que a o parametro 1 seja informado (sai com codigo de erro 2 - Syntax Error)
if [ "$PARM1" != "sus" ]; then
        #     1234567890123456789012345
        echo "[s_sus]  1.01      - Erro na chamada falta o parametro 1"
        echo
        echo "Syntax error:- Missing PARM1"
        echo "$AJUDA_USO"
        exit 2
fi
			
# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                            1234567890123456789012345
[ $N_DEB -ne 0 ]           && echo "[s_sus]  0.00.04   - Testa se ha tabela de configuracao"
[ ! -s "../tabs/coletas.tab" ] && echo "[s_sus]  1.01      - Configuration error:- COLETAS table not found" && exit 3

unset   SIGLA
# Garante existencia do FI indicada na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para processamento
#                         1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[s_sus]  0.00.05   - Testa se o indice eh valido"
IDFI=$(clANYTHING $PARM1)
[ $? -eq 0 ]     && SIGLA=$(clSIGLA $IDFI)
[ -z "$SIGLA" ]  && echo "[s_sus]  1.01      - PARM error:- PARM1 does not indicate a valid index" && exit 4

echo "[s_sus]  1.01      - Carrega definicoes da fonte para coleta de dados"
  TIPOC=$(clTYPE       $IDFI)
 DIRETO=$(clDIRETORIO  $IDFI)

# -------------------------------------------------------------------------- #
# Faz corrente o diretorio de processamento
echo "[s_sus]  1.02      - Faz corrente o diretorio de processamento"
cd $DIRETO

RSP=0
echo "[s_sus]  1.03      - Verifica disponibilidade do M/F sus_pre_saqneamento"
[ -f "${IDFI}_pre_saneamento.xrf" ] || RSP=1
[ -f "${IDFI}_pre_saneamento.mst" ] || RSP=1
chkError $RSP "ERRO: Base do Coleciona SUS nao encontrada"

echo "[s_sus]  1.04      - Verifica condicoes de processamento"
[ -f "../tabs/gV8ColSUS.xrf" ] || RSP=1
[ -f "../tabs/gV8ColSUS.xrf" ] || RSP=1
chkError $RSP "ERRO: Saneando ColecionaSUS"

echo "[s_sus]  2         - Efetua o saneamento de ColecionaSUS"
mx ${IDFI}_pre_saneamento gizmo=../tabs/gV8ColSUS,8 create=${IDFI}_lil_saneamento -all now tell=10000
RSP=$?; [ "$NOERRO" -eq 1 ] && RSP=0
chkError $RSP "ERRO: Saneando ColecionaSUS"

# -------------------------------------------------------------------------- #
# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infofim.inc

exit 0






cat > /dev/null <<COMMENT
.    Entrada : PARM1 com o identificador da ColecionaSUS
.      Saida : M/F sus_lil_saneada gerada no diretorio sus.lil
.   Corrente : nao determinado (deve ser compensado na chamada)
.    Chamada : /bases/lilG4/shs.lil/saneamento_colecionasus.sh sus
.Objetivo(s) : Garantir a existencia do M/F like LILACS para proxima etapa do processamento
.Comentarios : 
.Observacoes :
.Dependencia : Tabela coletas.tab deve estar presente em ../tabs
.               COLUNA  NOME                    COMENTARIOS
.                1      ID_FI               ID da Fonte de Informacao     (Identificador unico)
.                2      SIGLA FI            Nome humano da FI
.                3      DIRETORIO           Diretorio de entrega dos dados
.                4      TIPO                Tipo de coleta para aFI (valores: scp / ftp / rsync / oai / dSpace)
.                5      FONTE DE DADOS      (todos os subcampos devem ser declarados ainda que vazios)
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

COMMENT
cat >/dev/null <<SPICEDHAM
CHANGELOG
20160610 Edicao original
SPICEDHAM

