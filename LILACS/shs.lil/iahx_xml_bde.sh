#!/bin/bash

# -------------------------------------------------------------------------- #
# nome_do_shell.sh - Descricao curta para o shell                            #
# -------------------------------------------------------------------------- #
# Chamada : nome_shell.sh <PARM1> <PARM2> [PARM3] [PARM4]
# Exemplo : nohup ./nome_shell.sh parm1 parm2 &> logs/$(date '+%Y%m%d').txt &
#           ./shs.lil/nome_shell.sh parm1 parm2 parm3
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
vrs:  0.00 YYYYMMDD, responsavel
	- Label da versao
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
Uso: $TREXE [options] <parm1> [parm2] ...

Options:
 -V, --version       Displays the current version of program and stop

Parameters:
 parm1 - Parameter one of the program call that defines something
 parm2 - Parameter two of the program call which defines else
 parm3 - Parameter three of the program calland so on...

"

# Tratador de opcoes
while test -n "$1"
do
	case "$1" in

		*)
			if [ $(expr index $1 "-") -ne 1 ]; then
				if test -z "$PARM1";  then PARM1=$1;  shift; shift; continue; fi
				if test -z "$PARM2";  then PARM2=$1;  shift; shift; continue; fi
				if test -z "$PARM3";  then PARM3=$1;  shift; shift; continue; fi
				if test -z "$PARM4";  then PARM4=$1;  shift; shift; continue; fi
				if test -z "$PARM5";  then PARM5=$1;  shift; shift; continue; fi
				if test -z "$PARM6";  then PARM6=$1;  shift; shift; continue; fi
				if test -z "$PARM7";  then PARM7=$1;  shift; shift; continue; fi
				if test -z "$PARM8";  then PARM8=$1;  shift; shift; continue; fi
				if test -z "$PARM9";  then PARM9=$1;  shift; shift; continue; fi
				if test -z "$PARM10"; then PARM10=$1; shift; shift; continue; fi
				if test -z "$PARM11"; then PARM11=$1; shift; shift; continue; fi
				if test -z "$PARM12"; then PARM12=$1; shift; shift; continue; fi
				if test -z "$PARM13"; then PARM13=$1; shift; shift; continue; fi
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
echo "[model]  1         - Inicia processamento de coleta por scp"
# -------------------------------------------------------------------------- #
# Garante que a o parametro 1 seja informado (sai com codigo de erro 2 - Syntax Error)
if [ -z "$PARM1" ]; then
        #     1234567890123456789012345
        echo "[model]  1.01      - Erro na chamada falta o parametro 1"
        echo
        echo "Syntax error:- Missing PARM1"
        echo "$AJUDA_USO"
        exit 2
fi
			
# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                            1234567890123456789012345
[ $N_DEB -ne 0 ]           && echo "[model]  0.00.04   - Testa se ha tabela de configuracao"
[ ! -s "../tabs/coletas.tab" ] && echo "[model]  1.01      - Configuration error:- COLETAS table not found" && exit 3

unset   SIGLA
# Garante existencia do FI indicada na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para processamento
#                         1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[model]  0.00.05   - Testa se o indice eh valido"
IDFI=$(clANYTHING $PARM1)
[ $? -eq 0 ]     && SIGLA=$(clSIGLA $IDFI)
[ -z "$SIGLA" ]  && echo "[model]  1.01      - PARM error:- PARM1 does not indicate a valid index" && exit 4

echo "[model]  1.01      - Carrega definicoes da fonte para coleta de dados"
  TIPOC=$(clTYPE       $IDFI)
 DIRETO=$(clDIRETORIO  $IDFI)

# -------------------------------------------------------------------------- #
# Faz corrente o diretorio de processamento
echo "[model]  1.02      - Faz corrente o diretorio de processamento"
cd $DIRETO

#----------------------------------------------------------------------#
# Monta os XML de IAHx possiveis com BDEnf

# APS
cd ../bvs.aps
MSG="Erro: execucao ./todasAPS.sh"
../tpl.lil/genlilbvsxml.sh bde BDENF aps "06-national"
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP $MSG

# DSS 
cd ../bvs.dss
MSG="Erro: execucao ./todasAPS.sh"
../tpl.lil/genlilbvsxml.sh bde BDENF dss
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP $MSG

# -------------------------------------------------------------------------- #
# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infofim.inc

exit 0






cat > /dev/null <<COMMENT
Comentarios gerais e documentacao podem ser colocados aqui

<MOREINFO
Comentarios que poderiam ser usados como informacao adicional podem ser colocados aqui em seguida ao marcador '<MOREINFO'
COMMENT
cat >/dev/null <<SPICEDHAM
CHANGELOG
YYYYMMDD Historico detalhado (ou nao) de alteracoes para a versao desta data
SPICEDHAM


