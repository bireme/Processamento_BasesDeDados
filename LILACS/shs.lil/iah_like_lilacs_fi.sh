#!/bin/bash

# -------------------------------------------------------------------------- #
# iah_like_lilacs_fi.sh - Processamento basico de FI para iAH                #
# -------------------------------------------------------------------------- #
# Chamada : iah_like_lilacs_fi.sh [-V] <ID_FI>
# Exemplo : nohup ../shs.lil/iah_like_lilacs_fi.sh bde &> logs/$(date '+%Y%m%d').IAH.txt &
# ATENCAO : Aceita entrada nas mascaras: ???_pre_saneamento
#                                        ???_lil_saneada
#                                        ???_lil_pos_saneada
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
vrs:  0.01 20160615, FJLopes
	- Aceita multiplos nomes de entrada
vrs:  0.02 20160919, FJLopes / MBottura
	- Processa nmail especifica para REPIDISCA
HISTORICO

# ========================================================================== #
#                                BIBLIOTECAS                                 #
# ========================================================================== #
# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infoini.inc

# Incorpora biblioteca de processos de coleta
source ../shs.lil/inc/coletas.inc

# ========================================================================== #
#                                  FUNCOES                                   #
# ========================================================================== #
function apaga {
        [ $(ls $1 2> /dev/null | wc -l) -gt 0 ] && rm -f $1
}

# Assume valores DEFAULT
NOERRO=0;	# Controla o modo "Ignore Erros"
DEBUG=0;	# Controla o nivel de depuracao

# Mensagem de HELP
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
AJUDA_USO="
This process generates the basic indexes for uso with iAH.
Uso: $TREXE <ID_FI>

Options:
 -V, --version       Displays the current version of program and stop

Parameters:
ID_FI - Identifier of Information Source to process 

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
echo "[iahfi]  1         - Inicia processamento de geracao de indices iah basicos"
# -------------------------------------------------------------------------- #
# Garante que a o parametro 1 seja informado (sai com codigo de erro 2 - Syntax Error)
if [ -z "$PARM1" ]; then
        #     1234567890123456789012345
        echo "[iahfi]  1.01      - Erro na chamada falta o parametro 1"
        echo
        echo "Syntax error:- Missing PARM1"
        echo "$AJUDA_USO"
        exit 2
fi
			
# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                            1234567890123456789012345
[ $N_DEB -ne 0 ]           && echo "[iahfi]  0.00.04   - Testa se ha tabela de configuracao"
[ ! -s "../tabs/coletas.tab" ] && echo "[iahfi]  1.01      - Configuration error:- COLETAS table not found" && exit 3

unset   SIGLA
# Garante existencia do FI indicada na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para processamento
#                         1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[iahfi]  0.00.05   - Testa se o indice eh valido"
IDFI=$(clANYTHING $PARM1)
[ $? -eq 0 ]     && SIGLA=$(clSIGLA $IDFI)
[ -z "$SIGLA" ]  && echo "[iahfi]  1.01      - PARM error:- PARM1 does not indicate a valid index" && exit 4

echo "[iahfi]  1.01      - Carrega definicoes da fonte para coleta de dados"
  TIPOC=$(clTYPE       $IDFI)
 DIRETO=$(clDIRETORIO  $IDFI)
SSERVER=$(clSSERVER    $IDFI)
SDIRETO=$(clSDIRETORIO $IDFI)
 OBJETO=$(clOBJETOS    $IDFI)
  PORTA=$(clPORT       $IDFI)
 USERCL=$(clUSER       $IDFI)
 PASSCL=$(clPASSWD     $IDFI)

# -------------------------------------------------------------------------- #
# Faz corrente o diretorio de processamento
echo "[iahfi]  1.02      - Faz corrente o diretorio de processamento"
cd $DIRETO

echo "[iahfi]  1.03      - Normaliza denominacao da M/F de entrada"
# Verifica se existe ${IDFI}_pre_saneamento.mst ou ${IDFI}_saneada.mst ou ${IDFI}_saneada2.mst, caso nenhuma exista eh erro
RSP=0; [ ! -f ${IDFI}_pre_saneamento.xrf -a ! -f ${IDFI}_lil_saneada.xrf -a ! -f ${IDFI}_lil_saneada2.xrf ] && RSP=7
[ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "${IDFI} master file is unavailable or unreachable"

echo "[iahfi]  1.03.01   - Seleciona M/F a usar entre pre_saneamento / lil_saneamento / pos_saneamento"
[   -f "${IDFI}_pos_saneamento.mst" -a   -f "${IDFI}_lil_saneamento.mst" -a -f "${IDFI}_pre_saneamento.mst" ] &&  cp ${IDFI}_pos_saneamento.mst lil.mst
[   -f "${IDFI}_pos_saneamento.xrf" -a   -f "${IDFI}_lil_saneamento.xrf" -a -f "${IDFI}_pre_saneamento.xrf" ] &&  cp ${IDFI}_pos_saneamento.xrf lil.xrf
[ ! -f "${IDFI}_pos_saneamento.mst" -a   -f "${IDFI}_lil_saneamento.mst" -a -f "${IDFI}_pre_saneamento.mst" ] &&  cp ${IDFI}_lil_saneamento.mst lil.mst
[ ! -f "${IDFI}_pos_saneamento.xrf" -a   -f "${IDFI}_lil_saneamento.xrf" -a -f "${IDFI}_pre_saneamento.xrf" ] &&  cp ${IDFI}_lil_saneamento.xrf lil.xrf
[ ! -f "${IDFI}_pos_saneamento.mst" -a ! -f "${IDFI}_lil_saneamento.mst" -a -f "${IDFI}_pre_saneamento.mst" ] &&  cp ${IDFI}_pre_saneamento.mst lil.mst
[ ! -f "${IDFI}_pos_saneamento.xrf" -a ! -f "${IDFI}_lil_saneamento.xrf" -a -f "${IDFI}_pre_saneamento.xrf" ] &&  cp ${IDFI}_pre_saneamento.xrf lil.xrf

#----------------------------------------------------------------------#
# IMPORTANTE: a entrada deste processo eh a base de dados "lil.mst" (representa a LILACS.mst ao final do saneamento)
# Gera a base de dados de mail para processamento

echo "[iahfi]  2         - Normaliza denominacao da M/F de entrada"

echo "[iahfi]  2.01      - Geracao de mail para ${IDFI}"
MSG="Erro na geracao do mail"
if [ "$IDFI" = "rep" ]; then
 ../shs.lil/genrepmail.sh $TABS/redir.iso
else
 ../tpl.lil/genlilmail.sh lil ../tpl.mail/nmail mail
fi
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "$MSG"

#----------------------------------------------------------------------#
# Inicializa o processo geracao dos invertidos MH

echo "[iahfi]  2.01      - Faselilmh - Geracao de invertidos de MH para ${IDFI}"
MSG="Erro na Faselilmh"
 ../shs.lil/faselilmh.sh lil 50000
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "$MSG"

#----------------------------------------------------------------------#
# Inicializa o processo geracao dos invertidos de TEXT WORD - TW

echo "[iahfi]  2.02      - Faseliltw - Geracao de invertidos de TEXT WORK  (TW) para ${IDFI}"
MSG="Erro na Faseliltw"
 ../tpl.lil/faseliltw lil 50000
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "$MSG"

#----------------------------------------------------------------------#
# Inicializa o processo geracao dos outros invertidos simples.

echo "[iahfi]  2.03      - Faseliln - Geracao de outros invertidos para ${IDFI}"
MSG="Erro na Faseliln"
 ../tpl.lil/faseliln.sh lil
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "$MSG"

# -------------------------------------------------------------------- #
# Acertos finais nos indices gerados e limpeza de area de trabalho
echo "[iahfi]  3         - Finalizacao do processamento de ${IDFI}"

# Gera IY0 - 21/05/2007
echo "[iahfi]  3.01      - Compactacao de indices de ${IDFI}"
MSG="Erro: GENIY0ALL.SH"
 ../shs.lil/geniy0all.sh lil ${IDFI}
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "$MSG"

echo "[iahfi]  3.02      - Retira M/F de entrada intermediaria daqui"
[ -d input ] || mkdir -p input
[ -f ${IDFI}_pre_saneamento.xrf ] && mv ${IDFI}_pre*      input
[ -f ${IDFI}_LILACS.xrf ]         && mv ${IDFI}_LILACS*   input
[ -f ${IDFI}_lil.xrf ]            && mv ${IDFI}_lil*      input
[ -f ${IDFI}.xrf ]                && mv ${IDFI}.{mst,xrf} input

echo "[iahfi]  3.03      - Limpeza do diretorio"
apaga '*.tag'
apaga '*.par'
apaga '*.srt'
apaga '*.log'
apaga '*fst'
apaga '*lk?'
apaga '*ln?'
apaga '*lst'
apaga '*sta'
apaga '$1er.*'
apaga '$1pd.*'
apaga '$1x.*'
apaga '$1deat.*'
apaga '$1dect.*'
apaga '$1de.*'
apaga 'gizct.*'
apaga '$1"67".*'
apaga 'decspar'
apaga 'decsctpar'
apaga '$1ctc*'
apaga 'actmail.*'
apaga '*comp*'
apaga 'lser*'
apaga 'autor*'
apaga 'ntitle.*'
apaga 'gisolil.*'
apaga 'lil89.*'
apaga '$1_asc850.*'
apaga '$1_xml.xml'
apaga 'decs.iyp'
apaga 'decs.cnt'
apaga 'decs.n0?'
apaga 'decs.ly?'
# -------------------------------------------------------------------------- #
# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infofim.inc

exit 0






cat > /dev/null <<COMMENT
.    Entrada : PARM1 com o identificador da FI (<IDFI>)
.      Saida : M/F e I/F para uso com iAH
.   Corrente : --
.    Chamada : ../shs.lil/iah_fi.sh [-V] <IDFI>
.Objetivo(s) : Criar o minimo necessario de M/F e I/F para uso em iAH
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

<MOREINFO
Comentarios adicionais caem bem aqui.
COMMENT
cat >/dev/null <<SPICEDHAM
CHANGELOG
20160610 Edicao original do processamento fatorado de LILACS para iAH
20160615 Julga qual base usar entre pre_saneamento, lil_saneada, e pos_saneada, preferindo pos sobre lil sobre pre
20160719 Movimenta residous de entrada para diretorio especifico (input)
20160919 Criada a decisao de processar nmail com genlilmail ou genrepmail qdo for repidisca
         Incluida internamente a limpeza de subprodutos do processamento (e nao mais em shell externo)
SPICEDHAM

