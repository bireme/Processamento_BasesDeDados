#!/bin/bash

# -------------------------------------------------------------------------- #
# coleta_scp.sh - Efetua coleta de dados por security copy                   #
# -------------------------------------------------------------------------- #
# Chamada : coleta_scp.sh [-h|-V|--changelog] [-d N] <FI>
# Exemplo : coleta_scp.sh bde
#           coleta_scp.sh -d 2 sus
# -------------------------------------------------------------------------- #
#  Centro Latino-Americano e do Caribe de Informação em Ciências da Saúde    #
#     é um centro especialidado da Organização Pan-Americana da Saúde,       #
#           escritório regional da Organização Mundial da Saúde              #
#                      BIREME / OPS / OMS (P)2012-14                         #
# -------------------------------------------------------------------------- #
# Historico
# Versao data, responsavel
#       - Descricao
cat > /dev/null <<HISTORICO
vrs:  0.00 20160511, FJLopes
	- Edicao original
HISTORICO

# ========================================================================== #
#                                BIBLIOTECAS                                 #
# ========================================================================== #
# Incorpora biblioteca de controle basico de processamento
#source $PATH_EXEC/inc/infi_exec.inc
source  $MISC/infra/infoini.inc
# Conta com as funcoes:
#  isNumber     PARM1   Retorna FALSE se PARM1 nao for numerico
#  iVersao      --      Exibe nome e versao do programa
#  rdConfig     PARM1   Item de configuracao a ser lido no arquivo
#                       variavel $CONFIG contem o FULL NAME do arquivo
#  rdBreak      --      Testa se deve interromper execucao com "pare"
#  hms          PARM1   Converte valor informado em segundos para HH:MM:SS
#  chkError     PARM1   codigo de retorno a testar
#               PARM2   Mensagem de erro se houver
#                       Retorna com o codigo de PARM1
#                       variavel $NOERRO qdo ajustada ignora erros
# Estabelece as variaveis:
#       HINIC   Tempo inicial em segundos desde 01/01/1970
#       HRINI   Hora de inicio no formato YYYYMMDD hh:mm:ss
#       DRINI   Diretorio inicial de execucao
#       _dow_   Dia da semana abreviado
#       _DOW_   Dia da semana de 0 (domingo) a 6 (sabado)
#       _DIA_   Dia calendario no formato DD
#       _MES_   Mes calendario no formato MM
#       _ANO_   Ano calendario no formato YYYY
#       TREXE   Demoninacao do programa em execucao
#       TRNAM   Denominacao do programa em execucao sem extensao
#       PRGDR   Path para o programa em execucao
#       LCORI   Linha de comando original da chamada
#       DTISO   Data calendario no formato YYYYMMDD
#       N_DEB   Nivel de debug

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

# Incorpora carregador de defaults padrao
unset NOERRO
OPC_ERRO=""
PARMD=""

# Mensagens de HELP
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
AJUDA_USO="
Uso: $TREXE [-h|-V|--changelog] [-d N] [-e] <InfoS>

Opções:
 --changelog         * Exibe o histórico de alterações
 -d, --debug NIVEL   Define nivel de depuracao com valor numerico positivo
 -e, --no-error      Ignora detecção de erros
 -h, --help          * Exibe este texto de ajuda a execucao
 -i, --info          * Exibe infomacoes sobre coletas
 -V, --version       * Exibe a versão corrente do programa

 * Interrompem a execução do programa
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
			 FAKE=$(expr $(($DEBIG & $_BIT7_)) / 128)
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
[ "$DEBUG" -ne "0" ] && PARMD="-d" $DEBUG
# Avalia o nivel de depuracao
[ $((DEBUG & $_BIT3_)) -ne 0 ] && -v
[ $((DEBUG & $_BIT4_)) -ne 0 ] && -x

# ========================================================================== #

#     1234567890123456789012345
echo "[c_scp]  1         - Inicia processamento de coleta por scp"
# -------------------------------------------------------------------------- #
# Garante que a FI seja informada (sai com codigo de erro 2 - Syntax Error)
if [ -z "$PARM1" ]; then
        #     1234567890123456789012345
        echo "[INDEX]  1.01      - Erro na chamada falta o parametro 1"
        echo
        echo "Syntax error:- Missing PARM1"
        echo "$AJUDA_USO"
        exit 2
fi
			
# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                            1234567890123456789012345
[ $N_DEB -ne 0 ]           && echo "[c_scp]  0.00.04   - Testa se ha tabela de configuracao"
[ ! -s "../tabs/coletas.tab" ] && echo "[c_scp]  1.01      - Configuration error:- COLETAS table not found" && exit 3

unset   SIGLA
# Garante existencia do FI indicada na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para processamento
#                         1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[c_scp]  0.00.05   - Testa se o indice eh valido"
IDFI=$(clANYTHING $PARM1)
[ $? -eq 0 ]     && SIGLA=$(clSIGLA $IDFI)
[ -z "$SIGLA" ]  && echo "[c_scp]  1.01      - PARM error:- PARM1 does not indicate a valid index" && exit 4

echo "[c_scp]  1.01      - Carrega definicoes da fonte para coleta de dados"
DIRETO=$(clDIRETORIO   $IDIF)
SSERVER=$(clSSERVER    $IDFI)
SDIRETO=$(clSDIRETORIO $IDFI)
  PORTA=$(clPORT       $IDFI)
 USERCL=$(clUSER       $IDFI)
 PASSCL=$(clPASSWD     $IDFI)
# -------------------------------------------------------------------------- #

# Faz corrente o diretorio de processamento
echo "[c_scp]  1.02      - Faz corrente o diretorio de processamento"
cd $DIRETO

# Efetua a tomada dos dados
echo "[c_scp]  2         - Efetiva a transferencia de dados"
echo "[c_scp]  2.01      -   Copia o LILACS.xrf"
scp -P $PORTA $USERCL@$SSERVER:$SDIRETO/LILACS.xrf .
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "Copiando LILACS.xrf de $SIGLA"

echo "[c_scp]  2.02      -   Copia o LILACS.mst"
scp -P $PORTA $USERCL@$SSERVER:$SDIRETO/LILACS.mst .
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
chkError $RSP "Copiando LILACS.mst de $SIGLA"

# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infofim.inc

# -------------------------------------------------------------------------- #
cat > /dev/null <<COMMENT
.    Entrada :  PARM1 identificando o indice a ser processado
.               Opcoes de execucao
.                -a             Fonte alternativa de dados para indexacao
.                --changelog    Mostra historico de alteracoes
.                -d, --debug    Nivel de depuracao [0..255]
.                -e, --no-error Ignora detecao de erros
.                -f, -F, --FULL Executa processamento 'FULL'
.                -h, --help     Mostra o help
.                -i, --no-input Ignora dados de entrada
.                -V, --versao   Mostra a versao
.      Saida :  Indice atualizado
.               Codigos de retorno:
.                 0 - Ok operation
.                 1 - Non specific error
.                 2 - Syntax Error
.                 3 - Configuration error (iAHx.tab not found)
.                 4 - Configuration failure (INDEX_ID unrecognized)
.                 5 - Wrong working directory ou Data directory empty
.                 6 - No connectivity
.                 7 - Failed to send data (transmission)
.                 8 - Failed to send data (remote MD5)
.                 9 - Failed to send data (comparison)
.                10 - Failed to send data (directory creation)
.                11 - Failed to send data (remote copy)
.                12 - Failed to send data (remote rename)
.               128 - Concurrent execution
.   Corrente :  /bases/iahx/proc/INSTANCIA/main/
.    Chamada :  1-index.sh [-h|-V|--changelog] [-a] [-d N] [-e] [-f] [-i] <ID_INDEX>
.    Exemplo :  nohup 1-index.sh -d 2 ghl &> logs/YYYYMMDD.index.txt &
.Objetivo(s) :  1- Atualizar indice de busca
.Comentarios :  Remonta opcoes de chamada para expansao de comando
.                          PARMD        Opcao que define o nivel de depuracao
.               NOXMT    OPC_XMT        Opcao que impede envio de dados
.               NOERRO  OPC_ERRO        Opcao que impede deteccao de erros
.               NOINCR  OPC_FULL        Opcao de solicita indexacao FULL
.               NOPROD  OPC_PROD        Opcao que impede envio para a producao
.               NOCOMM  OPC_COMM        Opcao que impede realizar o commit em homolog
.               NODATA  OPC_DATA        Opcao que ignora dados de entrada
.Observacoes :  DEBUG eh uma variavel mapeada por bit conforme
.                       _BIT0_  Aguarda tecla <ENTER>
.                       _BIT1_  Mostra mensagens de DEBUG
.                       _BIT2_  Modo verboso
.                       _BIT3_  Modo debug de linhas -v
.                       _BIT4_  Modo debug de linhas -x
.                       _BIT7_  Opera em modo FAKE
.      Notas :  Deve ser executado como usuario 'tomcat'
.Dependencia :  Tabela iAHx.tab deve estar presente em $PATH_EXEC/tabs
.               COLUNA  NOME                    COMENTARIOS
.                1      ID_INDICE               ID do indice                    (Identificador unico do indice para processamento)
.                2      NM_INDICE               nome do indice conforme o SOLR  (nome oficial do indice)
.                3      NM_INSTANCIA            nome interno da instancia
.                4      DIR_PROCESSAMENTO       diretorio de processamento      (caminho relativo a $PATH_PROC)
.                5      DIR_INDICE              caminho do indice               (caminho relativo)
.                6      RAIZ_INDICES            caminho comum dos indices       (caminho absoluto)
.                7      SRV_TESTE               HOSTNAME do servidor de teste de palicacao
.                8      SRV_HOMOLOG APP         HOSTNAME do servidor de homologacao de aplicacao
.                9      SRV_HOMOLOG DATA        HOSTNAME do servidor de homologacao de dados
.               10      SRV_PRODUCAO            HOSTNAME do servidor de producao
.               11      IAHX_SERVER             numero do IAHx-server utilizado (Teste/Homolog/Prod)
.               12      DIR_INBOX               nome do diretorio dos dados de entrada
.               13      NM_LILDBI               qualificacao total das bases de dados LILDBI-Web, separadas pelo sinal '^'
.               14      SITUACAO                estado do indice                (HOMOLOGACAO / ATIVO / INATIVO / ...)
.               15      PROCESSA                liberado para processar         (em operacao)
.               16-25   RESERVA_DE_OFI                                          (USO DE OPERACAO DE FONTE DE INFORMACAO)
.               26      TIPOPROC                escalacao do processamento      (manual / automatica)
.               27      PERIODICIDADE           intervalo entre processamento   (0/pedido 1/diario 2/alternado 3/bisemanal 4/semanal 5/quinzenal 6/mensal)
.               28      NM_PORTAL               nome oficial do portal
.               29      URL_DISPONIVEL          URL de aplicacao funcional      (P / H / PH / -)
.               30      URL                     Universal Resource Locator
.               31      PARAMETRO_URL           complemento de URL para acesso web
.               32      IDIOMAS                 versoes idiomaticas de interface
.               33      VERSAO_APP              versao do OPAC
.               34      OBSERVACAO              informações relevantes diversas
.               35      WIKI_EXPRESSAO          URL do wiki com a expressao de selecao de registros
.               36      LST_FISIDX              lista de FIs indexadas neste indice
.                       -Periodicidades:
.                               0 - a pedido
.                               1 - diario
.                               2 - dias alternados
.                               3 - 2 vezes na semana
.                               4 - semanal
.                               5 - quinzenal
.                               6 - mensal
.                       -URL funcionais
.                               P - Producao
.                               H - Homologacao
.                               - - none
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
.               iAHx             ADMIN - e-mail ofi@bireme.br
.               iAHx         PATH_IAHX - caminho para os executaveis do pcte
.               iAHx         ROOT_IAHX - topo da arvore de processamento
.               iAHx         PATH_PROC - caminho para a area de processamento
.               iAHx         PATH_EXEC - caminho para os executaveis de processamento
.               iAHx        PATH_INPUT - caminho para os dados de entrada
.               iAHx        INDEX_ROOT - Raiz dos indices de busca
.               iAHx            STiAHx - Hostname do servidor de teste
.               iAHx            SHiAHx - Hostname do servidor de homologacao
.               iAHx            SPiAHx - Hostname do servidor de producao
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
# Em funcao do que sera coletado mudam:
#	servidor de origem dos dados
#	diretorio de destinacao dos dados
#	desempacotamento de dados
#
<MOREINFO
FI             SIGLA    SERVER  DIRETORIO                        ROTINA ou TIPO DE
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

Sugestao  I de tabela de parametros de processamento para coleta (tabela unica)
================================================================
     FI|sigla| diretorio          | modo+parms |
    BBO| bbo |/bases/lilG4/bbo.lil|ftp^lftp.bireme.br^d/dbcertif/lilcas/^pbbo_ofi_^sbbo_ofi_|
  BDEnf| bde |/bases/lilG4/bde.lil|scp^lpr10vm.bireme.br^d/home/apps/bvs.br/wp-enfermagem/bases/lildbi/dbcertif/lilacs^ptransfer^s102030|
  title|title|$TABS               |rsync^lserverofi4^d$TABS|
     MS| mis |/bases/lilG4/mis.lil|scp^lpr20dx^d/home/aplicacoes/abcd-ms/bases/lildbi/dbcertif/lilacs/^ptransfer^s102030|
 LILACS| lil |/bases/lilG4/lil.lil|scp^lserverabd^d/home/lilacs/www/bases/lildbi/dbcertif/lilacs/^ptransfer^s102030|
MEDLINE| mdl |/bases/lilG4/fasea/exe^l^d^p^s^c../tpl.mdl/traz_mdl_update_files.sh $MDL_ANOCORRENTE2DIGITOS|

Sugestao II de tabela de parametros de processamento para coleta (tabela por FI)
================================================================
    FI | Diretorio          | modo|parms
    BBO|/bases/lilG4/bbo.lil|ftp  |^lftp.bireme.br^d/dbcertif/lilcas/^pbbo_ofi_^sbbo_ofi_|
  BDEnf|/bases/lilG4/bde.lil|scp  |^lpr10vm.bireme.br^d/home/apps/bvs.br/wp-enfermagem/bases/lildbi/dbcertif/lilacs^ptransfer^s102030|
  title|$TABS               |rsync|^lserverofi4^d$TABS|
     MS|/bases/lilG4/mis.lil|scp  |^lpr20dx^d/home/aplicacoes/abcd-ms/bases/lildbi/dbcertif/lilacs/^ptransfer^s102030|
 LILACS|/bases/lilG4/lil.lil|scp  |^lserverabd^d/home/lilacs/www/bases/lildbi/dbcertif/lilacs/^ptransfer^s102030|
MEDLINE|/bases/lilG4/fasea/ |exe  |^l^d^p^s^c../tpl.mdl/traz_mdl_update_files.sh $MDL_ANOCORRENTE2DIGITOS|
	      

COMMENT
cat > /dev/null <<SPICEDHAM
CHANGELOG
20160513 Edição original
SPICEDHAM

