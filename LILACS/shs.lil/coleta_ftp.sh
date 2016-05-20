#!/bin/bash

# -------------------------------------------------------------------------- #
# coleta_ftp.sh - Efetua coleta de dados por remote syncronism             #
# -------------------------------------------------------------------------- #
# Chamada : coleta_ftp.sh [-h|-i|-V|--changelog] [-d N] <FI>
# Exemplo : coleta_ftp.sh tit
#           coleta_ftp.sh -d 2 nml
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
vrs:  0.00 20180519, FJLopes
	- Edicao original
HISTORICO

# ========================================================================== #
#                                BIBLIOTECAS                                 #
# ========================================================================== #
# Incorpora biblioteca de controle basico de processamento
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
PARMD=""

# Mensagens de HELP
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
AJUDA_USO="
Uso: $TREXE [-h|-i|-V|--changelog] [-d N] [-e] <InfoS>

Opções:
 --changelog         * Exibe o histórico de alterações
 -d, --debug NIVEL   Define nivel de depuracao com valor numerico positivo
 -e, --no-error      Ignora detecção de erros
 -h, --help          * Exibe este texto de ajuda a execucao
 -i, --info          * Exibe infomacoes sobre coletas
 -V, --version       * Exibe a versão corrente do programa

 * Interrompem a execução do programa

Parâmetros:
 InfoS  Identificador da Fonte de Informacao
"

# Tratador de opcoes
while test -n "$1"
do
	case "$1" in
		--changelog)
			TOTLN=$(wc -l $0 | awk '{ print $1 }')
			INILN=$(grep -n "<SPICEDHAM" $0 | tail -1 | cut -d ":" -f "1")
			LINHAI=$(expr $TOTLN - $INILN)
			LINHAF=$(expr $LINHAI - 2)
			iVersao
			#echo -e -n "\n$TREXE "
			#grep '^vrs: ' $PRGDR/$TREXE | tail -1
			echo -n "==> "
			tail -$LINHAI $0 | head -$LINHAF
			echo
			exit
			;;

		-d | --debug)
			shift
			isNumber $1
			[ $? -ne 0 ] && echo -e "\n$TREXE: O argumento da opção DEBUG deve ser numérico.\n$AJUDA_USO" && exit 2
			DEBUG=$1
			N_DEB=$(expr $(($DEBUG & 6)) / 2)
			 FAKE=$(expr $(($DEBUG & $_BIT7_)) / 128)
			;;

		-e | --no-error)
			NOERRO="1"
			OPC_ERRO="-e"
			;;

		-h | --help)
			iVersao
			echo "$AJUDA_USO"
			exit 0
			;;

		-i | --info)
			DUMMY=$(egrep -n "^<MOREINFO" $0 | tail -1 | cut -d ":" -f "1")
			INILN=${DUMMY:-0}
			FIMLN=$(grep -n "<SPICEDHAM" $0 | tail -1 | cut -d ":" -f "1")
			TOTLN=$(wc -l $0 | awk '{ print $1 }')
			LINHAI=$(expr $TOTLN - $INILN)
			QTDELN=$(expr $LINHAI - 6)
			iVersao
			echo
			if [ $INILN -ne 0 ]; then
				tail -$LINHAI $0 | head -$QTDELN
			else
				echo -e "Não há informações a exibir.\n"
			fi
			exit 0
			;;

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
			else
				echo "Opção não válida! ($1)"
			fi
			;;
	esac
	# Argumento tratado, desloca os parametros e trata o proximo (se existir)
	shift
done
# Para DEBUG assume o valor DEFAULT antecipadamente
isNumber $DEBUG
[ $? -ne 0 ] && DEBUG="0"
[ "$DEBUG" -ne "0" ] && PARMD="-d $DEBUG"
# Avalia o nivel de depuracao
[ $((DEBUG & $_BIT3_)) -ne 0 ] && -v
[ $((DEBUG & $_BIT4_)) -ne 0 ] && -x

# ========================================================================== #

#     1234567890123456789012345
echo "[c_ftp]  1         - Inicia processamento de coleta por ftp"
# -------------------------------------------------------------------------- #
# Garante que a FI seja informada (sai com codigo de erro 2 - Syntax Error)
if [ -z "$PARM1" ]; then
        #     1234567890123456789012345
        echo "[c_ftp]  1.01      - Erro na chamada falta o parametro 1"
        echo
        echo "Syntax error:- Missing PARM1"
        echo "$AJUDA_USO"
        exit 2
fi
			
# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                            1234567890123456789012345
[ $N_DEB -ne 0 ]               && echo "[c_ftp]  0.00.04   - Testa se ha tabela de configuracao"
[ ! -s "../tabs/coletas.tab" ] && echo "[c_ftp]  1.01      - Configuration error:- COLETAS table not found" && exit 3

unset   SIGLA
# Garante existencia da FI indicada na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para processamento
#                         1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[c_ftp]  0.00.05   - Testa se a FI eh valido"
IDFI=$(clANYTHING $PARM1)
[ $? -eq 0 ]     && SIGLA=$(clSIGLA $IDFI)
[ -z "$SIGLA" ]  && echo "[c_ftp]  1.01      - PARM error:- PARM1 does not indicate a valid FI" && exit 4

echo "[c_ftp]  1.01      - Carrega definicoes da fonte para coleta de dados"
 DIRETO=$(clDIRETORIO  $IDFI)
SSERVER=$(clSSERVER    $IDFI)
SDIRETO=$(clSDIRETORIO $IDFI)
 OBJETO=$(clOBJETOS    $IDFI)
  PORTA=$(clPORT       $IDFI)
 USERCL=$(clUSER       $IDFI)
 PASSCL=$(clPASSWD     $IDFI)

# -------------------------------------------------------------------------- #
# Ajusta lista de arquivos conforme regras gerais

echo "[c_ftp]  1.02      - Efetua ajustamentos conforme regras implicitas"
# Regra 1 se nao ha especificacao deve ser M/F LILACS
[ -z $OBJETO ] && OBJETO="LILACS.xrf;LILACS.mst" && parseFL $OBJETO && echo "Tentou o ajuste"

# Regra 2 se não especifica a extensao deve ser mst e xrf
egrep '\.' >/dev/null <<<$OBJETO
RSP=$?
if [ $RSP -ne 0 ]; then
	OBJETO=${OBJETO//;/\.\{mst,xrf\};}".{mst,xrf}"
fi

# -------------------------------------------------------------------------- #
parseFL $OBJETO

# Determina o numero de arquivos da lista
i=0
while [ ! -z ${FILES[$i]} ]
do
	i=$(expr $i + 1)
done
# Obtem o numero de arquivos passados na lista [0..[
MAXFILE=$(expr $i - 1)

if [ $N_DEB -ne 0 ]; then
	echo "==========================================================="
	echo " == COLETA FTP =="
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
echo "[c_ftp]  1.03      - Faz corrente o diretorio de processamento"
cd $DIRETO

# Efetua a tomada dos dados
echo "[c_ftp]  2         - Efetiva a transferencia de dados"

[ -d "logs" ] || mkdir logs
echo "[c_ftp]  2.01      - Monta arquivo de controle de sessao"
echo "open $SSERVER"        >  coleta.ftp
echo "user $USERCL $PASSCL" >> coleta.ftp
echo "cd $SDIRETO"          >> coleta.ftp
echo "bin"                  >> coleta.ftp
echo "hash"                 >> coleta.ftp
echo "lcd $DIRETO"          >> coleta.ftp
for i in $(seq 0 $MAXFILE)
do

	echo "[c_rsy]  2.01.0$i   -  Incluindo ${FILES[$i]} de $SIGLA"
	egrep 'LILACS' >/dev/null <<<${FILES[$i]}
	RSP=$?
	if [ $RSP -eq 0 ]; then
		echo "get ${FILES[$i]}" >> coleta.ftp
	else
		echo "get ${FILES[$i]}" >> coleta.ftp
	fi
	RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
	chkError $RSP "Sincronizando ${FILES[$i]} de $SIGLA"

done

echo "bye"                  >> coleta.ftp

echo "[c_ftp]  2.02      - Recebe arquivos"
ftp -i -v -n < coleta.ftp > logs/${IDFI}-${DTISO}.txt

echo "[c_ftp]  2.03      - Limpa area de trabalho"
mv coleta.ftp logs/${IDFI}-${DTISO}.coleta.ftp

# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infofim.inc

# -------------------------------------------------------------------------- #
cat > /dev/null <<COMMENT
.    Entrada :  PARM1 identificando a FI a operar
.               Opcoes de execucao
.                --changelog    Mostra historico de alteracoes
.                -d, --debug    Nivel de depuracao [0..255]
.                -e, --no-error Ignora detecao de erros
.                -h, --help     Mostra o help
.                -i, --info     Informacoes adicionais sobre o processo
.                -V, --versao   Mostra a versao
.      Saida :  Arquivos da Fonte de Informacao coletados
.               Codigos de retorno:
.                 0 - Ok operation
.                 1 - Non specific error
.                 2 - Syntax Error
.                 3 - Configuration error (iAHx.tab not found)
.                 4 - Configuration failure (INDEX_ID unrecognized)
.   Corrente :  /bases/lilG4//FI_DIR/
.    Chamada :  coleta_ftp.sh [-h|-V|-i|--changelog] [-d N] [-e] <ID_FI>
.    Exemplo :  nohup 1-index.sh -d 2 ghl &> logs/YYYYMMDD.index.txt &
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
.               ISIS       FFI4G4 - WXISF4G4   - Path para pacote
.               ISIS       FFI256 - WXISF256   - Path para pacote
.               ISIS     FFI512G4 - WXISF512G4 - Path para pacote
COMMENT
exit
cat > /dev/null <<COMMENT
REINFO
Em funcao do que sera coletado mudam:
-servidor de origem dos dados
-diretorio de destinacao dos dados
-desempacotamento de dados

FI             SIGLA    SERVER  DIRETORIO                        ROTINA ou TIPO DE
======================================================================================================================
HISA           his       OFI4   /bases/lilG4/his.lil             wget (http://basehisa.coc.fiocruz.br/P/hisa.iso)
BBO            bbo       OFI4   /bases/lilG4/bbo.lil             ftp ftp.xxxxxx.br/home/bbo/bases/lildbi/dbcertif/lilacs/ user: ??? senha: ???
ADOLEC-BR      abr       OFI4   /bases/lilG4/abr.lil             scp hm01dx /home/aplicacoes-bvs/adolec-br/bases/lildbi/dbcertif/lilacs/LILACS
BDEnf          bde       OFI4   /bases/lilG4/bde.lil             scp pr10vm /home/apps/bvs.br/wp-enfermagem/bases/lildbi/dbcertif/lilacs/LILACS
ColecionaSUS   sus       OFI4   /bases/lilG4/sus.lil             scp pr20dx.bireme.br /home/aplicacoes/coleciona-sus/bases/lildbi/dbcertif/lilacs/LILACS
CRT/AIDS       crt       OFI4   /bases/lilG4/crt.lil             scp hm02dx /home/aplicacoes-bvs/crt-dst-aids/bases/iah/lilacs
HOMEOINDEX     hom       OFI4   /bases/lilG4/hom.lil             scp hm01dx /home/aplicacoes-bvs/homeopatia/bases/lildbi/dbcertif/lilacs/LILACS
LILACS         lil       OFI4   /bases/lilG4/lil.lil             scp serverabd /home/lilacs/www/bases/lildbi/dbcertif/lilacs/LILACS
MS             mis       OFI4   /bases/lilG4/mis.lil             scp pr20dx.bireme.br /home/aplicacoes/abcd-ms/bases/lildbi/dbcertif/lilacs/LILACS
IBECS          ibc       OFI4   /bases/ibcG4/ibc.lil/isos/bases  scp pv10vm /home/apps/bvsalud-org/lildbi-ibecs/bases/lildbi/dbnotcertif/lilacs/amalia
.                                                                           /home/apps/bvsalud-org/lildbi-ibecs/bases/lildbi/dbnotcertif/lilacs/Anabel
.                                                                           /home/apps/bvsalud-org/lildbi-ibecs/bases/lildbi/dbnotcertif/lilacs/jmg5
.                                                                           /home/apps/bvsalud-org/lildbi-ibecs/bases/lildbi/dbnotcertif/lilacs/maribel2
.                                                                           /home/apps/bvsalud-org/lildbi-ibecs/bases/lildbi/dbnotcertif/lilacs/marisol
.                                                                           /home/apps/bvsalud-org/lildbi-ibecs/bases/lildbi/dbnotcertif/lilacs/LILACS
NMail          nmail     OFI4   /bases/lilG4/tpl.mail            rsync quartzo2 /home/intranet/bases/nmail/nmail
TITLE          title     OFI4   $TABS                            rsync quartzo2 /home/intranet/bases/portal/newprocs/isos/title.iso
BIOETICA       bioetica  OFI5   /bases/xml2isis/oai/isis         ../tpl/0_Processa.sh bioetica
BIVIPSIL       bivipsil  OFI5   /bases/xml2isis/oai/isis         ../tpl/0_Processa.sh bivipsil bivipsil
CUMED          cumed     OFI5   /bases/xml2isis/oai/isis         ../tpl/0_Processa.sh cumed cumed
FIOCRUZ        fiocruz   OFI5   /bases/xml2isis/oai/isis         ../tpl/0_Processa.sh fiocruz
IEC            iec       OFI5   /bases/xml2isis/oai/isis         ../tpl/0_Procerssa.sh iac iacbvs
Peru MinSA     bvsperu   OFI5   /bases/xml2isis/oai/isis         ../tpl/0_Processa.sh bvsperu minsa
Peru Nacional  peru      OFI5   /bases/xml2isis/oai/isis         ../tpl/0_Processa.sh peru nac
VETERINARIA              OFI5   /bases/xml2isis/oai/tpl          0_Processa.sh vetteses
.                                                                0_Processa.sh vetindex
ARCA                     OFI5   /bases/xml2isis/oai/tpl          ../tpl.lil/0_Processa.sh arcadim
.                                                                ../tpl.lil/0_Processa.sh arcamodis
Medline        mdl       OFI5   /bases/mdlG4/fasea               ../tpl.mdl/traz_mdl_update_files.sh YY


COMMENT
cat > /dev/null <<SPICEDHAM
CHANGELOG
20160513 Edição original
SPICEDHAM

