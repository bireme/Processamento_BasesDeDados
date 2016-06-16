#!/bin/bash

# -------------------------------------------------------------------------- #
# poscoleta_his.sh - Prove transformacao no dado recebido para presaneamento #
# -------------------------------------------------------------------------- #
# Chamada : poscoleta_his.sh <ID_FI>
# Exemplo : poscoleta_his.sh his
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
NOERRO=0;	# Controla o modo de ignorar erros
DEBUG=0;	# Controla o nivel de depuracao

# ========================================================================== #
#                                  FUNCOES                                   #
# ========================================================================== #
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
 ID_FI - Identifier of Information Source to process (in this case must be bbo)

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
				if test -z "$PARM3"; then PARM3=$1; shift; shift; continue; fi
				if test -z "$PARM4"; then PARM4=$1; shift; shift; continue; fi
				if test -z "$PARM5"; then PARM5=$1; shift; shift; continue; fi
				if test -z "$PARM6"; then PARM6=$1; shift; shift; continue; fi
				if test -z "$PARM7"; then PARM7=$1; shift; shift; continue; fi
				if test -z "$PARM8"; then PARM8=$1; shift; shift; continue; fi
				if test -z "$PARM9"; then PARM9=$1; shift; shift; continue; fi
			else
				echo "Opções não válida ($1)"
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
echo "[pchis]  1         - Inicia processamento de pos coleta de BBO"
# -------------------------------------------------------------------------- #
# Garante que a o parametro 1 seja informado (sai com codigo de erro 2 - Syntax Error)
if [ "$PARM1" != "his" ]; then
        #     1234567890123456789012345
        echo "[pcbbo]  1.01      - Erro na chamada falta o parametro 1 ou esta errado"
        echo
        echo "Syntax error:- PARM1 missing or wrong"
        echo "$AJUDA_USO"
        exit 2
fi
			
# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                            1234567890123456789012345
[ ! -s "../tabs/coletas.tab" ] && echo "[pchis]  1.01      - Configuration error:- COLETAS table not found" && exit 3

unset   SIGLA
# Garante existencia do FI indicada na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para processamento
#                         1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[pchis]  0.00.01   - Testa se o indice eh valido"
IDFI=$(clANYTHING $PARM1)
[ $? -eq 0 ]     && SIGLA=$(clSIGLA $IDFI)
[ -z "$SIGLA" ]  && echo "[pchis]  1.01      - PARM error:- PARM1 does not indicate a valid index" && exit 4

echo "[pchis]  1.01      - Carrega definicoes da fonte para coleta de dados"
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

[ "$IDFI" != "his" ] && echo "[pchis]  1.02      - Com esta chamada so se processa $SIGLA, verifique!" && exit 2

# -------------------------------------------------------------------------- #
# Ajusta lista de arquivos conforme regras gerais

# Regra 1 se não ha especificacao deve ser M/F LILACS
[ -z $OBJETO ] && OBJETO="LILACS.xrf;LILACS.mst" && parseFL $OBJETO && echo "[pchis]  1.01.01   - Tentou o ajuste"

# Regra 2 se não especifica a extensao deve ser mst e xrf
egrep '\.' >/dev/null <<<$OBJETO
RSP=$?
if [ $RSP -ne 0 ]; then
	[ $TIPOC = "oai" -o $TIPOC = "dspace" ] || OBJETO=${OBJETO//;/\.\{mst,xrf\};}".{mst,xrf}" && echo "[pchis]  1.02.02   - Extensoes ajustadas"
fi

# -------------------------------------------------------------------------- #
echo "[pcbde]  1.02.03   - Obtem os arquivos componentes (se houver)"
parseFL $OBJETO

# Determina o numero de arquivos da lista
echo "[pcbde]  1.02.04   - Quantifica componentes a obter"

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
echo "[pchis]  1.02      - Faz corrente o diretorio de processamento"
cd $DIRETO

# Gera um Master File para HISA com o nome LILACS para proceguir no tratamento homogeneo 
echo "[pchis]  2         - Efetua a mudanca de ISO 2709 para M/F de ${FILES[0]}, e da outras tratativas"
echo "[pchis]  2.01      - Testa disponibilidade do arquivo ${FILES[0]}"
[ ! -f ${FILES[0]} ] && echo "[pchis]  2.01.01   - Arquivo ${FILES[0]} nao encontrado" && exit 1
echo "[bchis]  2.02      - Preventivamente executa uma conversao DOS para UNIX"
dos2unix -f ${FILES[0]}
echo "[pchis]  2.03      - Cria M/F para o restante do processamento"
$LINDG4/mx iso=${FILES[0]} create=LILACS -all now
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "ERROR: [pchis] Convertendo ISO-2709 em M/F de HISA"

echo "[pchis]  3         - Finaliza execucao de $TREXE"
# Armazena historicamente do ISO aqui tratado
echo "[pchis]  3.01      - Armazena ISO coletado em diretório apropriado"
echo "[pchis]  3.01.01   - Garante existencia do diretorio destino para arquivos ISO-2709"
[ -d "isos" ] || mkdir -p isos

echo "[pchis]  3.01.02   - Movimenta arquivo renomeando"
mv ${FILES[0]} isos/${FILES[0]}.$DTISO

# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infofim.inc
exit 0






cat > /dev/null <<COMMENT
.    Entrada : PARM1 com o identificador da HISA
.      Saida : M/F LILACS gerado no diretorio his.lil
.   Corrente : nao determinado (deve ser compensado na chamada)
.    Chamada : /bases/lilG4/shs.lil/poscoleta_his.sh his
.Objetivo(s) : Garantir a existencia do M/F LILACS para proxima etapa do processamento
.Comentarios : Após o tratamento com sucesso deposita o ISO utilizado no diretorio 'isos'
.              agregando a data de processamento para efeito histórico
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
.               ISIS       FFI4G4 - WXISF4G4   - Path para pacote
.               ISIS       FFI256 - WXISF256   - Path para pacote
.               ISIS     FFI512G4 - WXISF512G4 - Path para pacote

<MOREINFO
De forma geral caso ocorra iso_getval, coisa comum para a bbo, basta efetuar um dos2unix no ISO recebido.
COMMENT
cat >/dev/null <<SPICEDHAM
CHANGELOG
201606010 Edicao original
SPICEDHAM

