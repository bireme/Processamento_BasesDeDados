#!/bin/bash

# -------------------------------------------------------------------------- #
# saneamento_his.sh - Preparo especifico da base SES para processamento iAH  #
# -------------------------------------------------------------------------- #
# Chamada : saneamento_his.sh [opcoes] <ID_FI>
# Exemplo : nohup ../shs.lil/saneamento_his.sh his &> logs/$(date '+%Y%m%d').txt &
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
vrs:  0.00 20160819, FJLopes
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
Syntax: $TREXE [options] <parm1>

Options:
 -V, --version       Displays the current version of program and stop

Parameters:
parm1 - Information Source identifier (in this case must be: his)

"

# Tratador de opcoes
while test -n "$1"
do
	case "$1" in

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
echo "[s_his]  1         - Inicia processamento de coleta por scp"
# -------------------------------------------------------------------------- #
# Garante que a o parametro 1 seja informado (sai com codigo de erro 2 - Syntax Error)
if [ "$PARM1" != "his" ]; then
        #     1234567890123456789012345
	echo "[s_his]  1.01      - Missing or wrong IS identifier (must be: ses)"
        echo
        echo "Syntax error:- Missing or wrong PARM1"
        echo "$AJUDA_USO"
        exit 2
fi
			
# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                            1234567890123456789012345
[ $N_DEB -ne 0 ]           && echo "[s_his]  0.00.04   - Testa se ha tabela de configuracao"
[ ! -s "../tabs/coletas.tab" ] && echo "[s_his]  1.01      - Configuration error:- COLETAS table not found" && exit 3

unset   SIGLA
# Garante existencia do FI indicada na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para processamento
#                         1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[s_his]  0.00.05   - Testa se o indice eh valido"
IDFI=$(clANYTHING $PARM1)
[ $? -eq 0 ]     && SIGLA=$(clSIGLA $IDFI)
[ -z "$SIGLA" ]  && echo "[s_his]  1.01      - PARM error:- PARM1 does not indicate a valid index" && exit 4

echo "[s_his]  1.01      - Carrega definicoes da fonte para coleta de dados"
 DIRETO=$(clDIRETORIO  $IDFI)

# -------------------------------------------------------------------------- #
# Faz corrente o diretorio de processamento
echo "[s_his]  1.02      - Faz corrente o diretorio de processamento"
cd $DIRETO

# Efetua a tomada dos dados

RSP=0
echo "[s_his]  1.03      - Verifica disponibilidade do M/F ses_pre_saneamento"
[ -f "${IDFI}_pre_saneamento.xrf" ] || RSP=1
[ -f "${IDFI}_pre_saneamento.mst" ] || RSP=1
chkError $RSP "ERRO: Base da Secretaria Estadual da Saude de Sao Paulo nao encontrada"

echo "[s_his]  1.04      - Verifica disponibilidade do gizmo de saneamento gCampo4"
[ -f "../tabs/gans850.xrf" ] || RSP=1
[ -f "../tabs/gans850.mst" ] || RSP=1
chkError $RSP "ERRO: Base gizmo gans850 nao pode ser localizada"

echo "[s_his]  2         - Saneamento da base HISA"
mx ${IDFI}_pre_saneamento "gizmo=../tabs/gans850" create=${IDFI}_lil_saneamento -all now tell=10000
RSP=$?; [ "$NOERRO" -eq 1 ] && RSP=0
chkError $RSP "ERRO: Saneando a base HISA"

# -------------------------------------------------------------------------- #
# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infofim.inc

exit 0






cat > /dev/null <<COMMENT
Comentarios gerais e documentacao podem ser colocados aqui

<MOREINFO
Informacao adicional
COMMENT
cat >/dev/null <<SPICEDHAM
CHANGELOG
20160623 Edicao original
SPICEDHAM

