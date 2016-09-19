#!/bin/bash

# -------------------------------------------------------------------------- #
# pos_coleta_ibc.sh - Transforma o dado recebido para presaneamento          #
# -------------------------------------------------------------------------- #
# Chamada : pos_coleta_ibc.sh <ID_FI>
# Exemplo : pos_coleta_ibc.sh ibc
# ATENCAO : Deste procedimento sai um M/F denominado <ID_FI>_LILACS
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
vrs:  0.00 20160817, FJLopes
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
NOERRO=0;	# Controla o modo de ignorar erros
DEBUG=0;	# Controla o nivel de depuracao
RSP=0		# Pressupoe que tudo tudo tudo vai dar pe

# ========================================================================== #
#                                  FUNCOES                                   #
# ========================================================================== #
# Parse File List
parseFL(){
        IFS=";" read -a FILES <<< "$1"
}
	
# Mensagens de HELP
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
AJUDA_USO="
Syntax: $TREXE <ID_FI>

Options:
 -V, --version       * Displays the current version of program

Parameters:
 ID_FI - Identifier of Information Source to process (in this case must be ibc)

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
echo "[pcibc]  1         - Inicia processamento de pos coleta de Medcarib"
# -------------------------------------------------------------------------- #
# Garante que a o parametro 1 seja informado (sai com codigo de erro 2 - Syntax Error)
if [ "$PARM1" != "ibc" ]; then
        #     1234567890123456789012345
        echo "[pcibc]  1.01      - Erro na chamada falta o parametro 1 ou esta errado"
        echo
        echo "Syntax error:- PARM1 missing or wrong"
        echo "$AJUDA_USO"
        exit 2
fi
			
# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                            1234567890123456789012345
[ ! -s "../tabs/coletas.tab" ] && echo "[pcibc]  1.01      - Configuration error:- COLETAS table not found" && exit 3

unset   SIGLA
# Garante existencia do FI indicada na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para processamento
#                         1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[pcibc]  0.00.01   - Testa se o indice eh valido"
IDFI=$(clANYTHING $PARM1)
[ $? -eq 0 ]     && SIGLA=$(clSIGLA $IDFI)
[ -z "$SIGLA" ]  && echo "[pcibc]  1.01      - PARM error:- PARM1 does not indicate a valid index" && exit 4

echo "[pcibc]  1.01      - Carrega definicoes da fonte para coleta de dados"
  TIPOC=$(clTYPE       $IDFI)
 DIRETO=$(clDIRETORIO  $IDFI)
SSERVER=$(clSSERVER    $IDFI)
SDIRETO=$(clSDIRETORIO $IDFI)
 OBJETO=$(clOBJETOS    $IDFI)
  PORTA=$(clPORT       $IDFI)
 USERCL=$(clUSER       $IDFI)
 PASSCL=$(clPASSWD     $IDFI)

# -------------------------------------------------------------------------- #
# Garante que a rotina certa para a FI

[ "$IDFI" != "ibc" ] && echo '[pcibc]  1.02      - Syntax error:- Only the Medcarib I.S. can be treated by this program. $SIGLA cannot!' && exit 2

# -------------------------------------------------------------------------- #
# Ajusta lista de arquivos conforme regras gerais

# Regra 1 se não ha especificacao deve ser M/F LILACS
[ -z $OBJETO ] && OBJETO="LILACS.xrf;LILACS.mst" && parseFL $OBJETO && echo "[pcibc]  1.02.01   - Tentou o ajuste"

# Regra 2 se não especifica a extensao deve ser mst e xrf
egrep '\.' >/dev/null <<<$OBJETO
RSP=$?
if [ $RSP -ne 0 ]; then
	[ $TIPOC = "oai" -o $TIPOC = "dspace" ] || OBJETO=${OBJETO//;/\.\{mst,xrf\};}".{mst,xrf}" && echo "[pcibc]  1.02.02   - Extensoes ajustadas"
fi

# -------------------------------------------------------------------------- #
echo "[pcibc]  1.02.03   - Obtem os arquivos componentes (se houver)"
parseFL $OBJETO

# Determina o numero de arquivos da lista
echo "[pcibc]  1.02.04   - Quantifica componentes a obter"
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
	echo " Tipo de coleta da FI     [TIPOC]: $TIPOC"
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
	echo
	echo "                        [MAXFILE]: $MAXFILE"
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
echo "[pcibc]  1.02      - Faz corrente o diretorio de processamento"
cd $DIRETO

# Gera um Master File para Medcarib com o nome ibc_LILACS para prosseguir no tratamento homogeneo 
echo "[pcibc]  2         - Efetua a mudanca de ISO 2709 para M/F de ${FILES[0]}, e da outras tratativas"
[ ! -s ${FILES[0]} ] && RSP=1
chkError $RSP "ERROR: [pcibc] File of addition not found"
echo "[pcibc]  2.01      - Preventivamente executa uma conversao DOS para UNIX"
dos2unix -q -f ${FILES[0]}
echo "[pcibc]  2.02      - Cria M/F para o restante do processamento"
echo "[pcibc]  2.02.01   - Carrega adicional recebido"
[ -s ${FILES[0]} ] && mx iso=${FILES[0]} create=intercooler -all now
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "ERROR: [pcibc] Loading file of addition"

echo "[pcibc]  2.02.02   - Carrega MedCarib existente"
[ ${IDFI}_LILACS.xrf ]   && rm -f ${IDFI}_LILACS.*
[ -s isos/medcarib.xrf ] && mx isos/medcarib append=${IDFI}_LILACS -all now
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "ERROR: [pcibc] Loading MedCarib pre existing"
QTDEBEFORE=$(mx ${IDFI}_LILACS count=1 "pft=f(maxmfn,1,0)/")

echo "[pcibc]  2.02.03   - Adiciona nova porcao obtida"
[ -s intercooler.xrf ]   && mx intercooler append=${IDFI}_LILACS -all now
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "ERROR: [pcibc] Consolidating medcarib"
QTDEAFTER=$(mx ${IDFI}_LILACS count=1 "pft=f(maxmfn,1,0)/")

echo "[pcibc]  2.02.04   - Armazena nova base medcarib acumulada"
mx ${IDFI}_LILACS create=isos/medcarib -all now
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "ERROR: [pcibc] Storing consolidated medcarib"

# Relata crescimento da FI
echo "[pcibc]  2.03      - Alteracao do numero de documentos na base (final - inicial): $(($QTDEAFTER - $QTDEBEFORE))"

echo "[pcibc]  3         - Finaliza execucao de $TREXE"
[ -f "intercooler.xrf" ] && mv ${FILES[0]} isos/${FILES[0]}.$(date '+%Y%m%d_%H%M%S')
[ -f "intercooler.xrf" ] && rm -f intercooler.*

# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infofim.inc
exit 0






cat > /dev/null <<COMMENT
.    Entrada : PARM1 com o identificador da Medcarib
.      Saida : M/F ibc_LILACS gerado no diretorio ibc.lil
.   Corrente : nao determinado, desde que compensado na chamada
.    Chamada : /bases/lilG4/shs.lil/pos_coleta_ibc.sh ibc
.Objetivo(s) : Garantir a existencia do M/F LILACS para proxima etapa do processamento
.Comentarios : Após o tratamento com sucesso deposita o ISO utilizado no diretorio 'isos'
.              agregando a data de processamento para efeito histórico
.Observacoes : A tabela coletas.tab deve ser atualizada em funcao do nome do arquivo
.              disponibilizado pela Biblioteca da Odontologia
.Dependencia :  Tabela coletas.tab deve estar presente em ../tabs
.               COLUNA  NOME                    COMENTARIOS
.                1      ID_FI               ID da Fonte de Informacao     (Identificador unico)
.                2      SIGLA FI            Nome humano da FI
.                3      DIRETORIO           Diretorio de entrega dos dados
.                4      TIPO                Tipo de coleta para aFI (valores: scp / ftp / rsync / oai / dSpace)
.                5      FONTE DE DADOS      (todos os componentes devem ser declarados mesmo que vazios)
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
.               ISIS       FFI4G4 - WXISF4G4   - Path para pacote
.               ISIS       FFI256 - WXISF256   - Path para pacote
.               ISIS     FFI512G4 - WXISF512G4 - Path para pacote

<MOREINFO
Informacoes Adicionais
COMMENT
cat >/dev/null <<SPICEDHAM
CHANGELOG
20160817 Edicao original
SPICEDHAM

