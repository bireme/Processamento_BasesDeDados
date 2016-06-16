#!/bin/bash

# -------------------------------------------------------------------------- #
# coleta_scp.sh - Efetua coleta de dados por security copy                   #
# -------------------------------------------------------------------------- #
# Chamada : coleta_scp.sh [-V] <FI>
# Exemplo : coleta_scp.sh bde
#           coleta_scp.sh -d 2 ibc
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
vrs:  0.00 20160519, FJLopes
	- Edicao original
vrs:  0.01 20160610, FJLopes
	- Limpa no codigo deixando so o essencial
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
parseFL(){
	# O separador usado eh o ponto e virgula apenas
	IFS=";" read -a FILES <<< "$1"
}

# Incorpora carregador de defaults padrao (não ignora erros; depuracao nao ativada)
unset NOERRO
OPC_ERRO=""
DEBUG=0
PARMD=""

# Mensagens de HELP
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
AJUDA_USO="
Efetua coleta de dados de FI por SCP conforme tabela coletas.tab
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
			# Opcao de exibir versao do programa em execucao
			# (esta opcao interrompe a execucao do programa)
			iVersao
			# A funcao iVersao esta no arquivo incluido infoini.inc (informacoes de inicio)
			echo
			exit 0
			;;

		*)
			if [ $(expr index $1 "-") -ne 1 ]; then
				# Nao contem hifen nao eh opcao eh parametro
				if test -z "$PARM1"; then PARM1=$1; shift; shift; continue; fi
				if test -z "$PARM2"; then PARM2=$1; shift; shift; continue; fi
			else
				# Eh opcao mas nao foi tratada, eh desconhecida
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
[ $((DEBUG & $_BIT3_)) -ne 0 ] && set -v
[ $((DEBUG & $_BIT4_)) -ne 0 ] && set -x
	# Bit3 - Ativa modo de depuracao V nativa do bash (exibe linhas a executar)
	# Bit4 - Ativa modo de depuracao X nativa do bash (exibe linhas executadas)

# ========================================================================== #

#     1234567890123456789012345
echo "[c_scp]  1         - Inicia processamento de coleta por scp"
# -------------------------------------------------------------------------- #
# Garante que a FI seja informada (sai com codigo de erro 2 - Syntax Error)
if [ -z "$PARM1" ]; then
        #     1234567890123456789012345
        echo "[c_scp]  1.01      - Erro na chamada falta o parametro 1"
        echo
        echo "Syntax error:- Missing PARM1"
        echo "$AJUDA_USO"
        exit 2
fi
			
# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                            1234567890123456789012345
[ $N_DEB -ne 0 ]               && echo "[c_scp]  0.00.04   - Testa se ha tabela de configuracao"
[ ! -s "../tabs/coletas.tab" ] && echo "[c_scp]  1.01      - Configuration error:- COLETAS table not found" && exit 3
unset   SIGLA
# -------------------------------------------------------------------------- #
# Garante existencia do FI indicada na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para processamento
#                         1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[c_scp]  0.00.05   - Testa se a FI eh valida"
IDFI=$(clANYTHING $PARM1)
[ $? -eq 0 ]     && SIGLA=$(clSIGLA $IDFI)
[ -z "$SIGLA" ]  && echo "[c_scp]  1.01      - PARM error:- PARM1 does not indicate a valid Information Source" && exit 4

echo "[c_scp]  1.01      - Carrega definicoes da fonte para coleta de dados"
  TIPOC=$(clTYPE       $IDFI)
 DIRETO=$(clDIRETORIO  $IDFI)
SSERVER=$(clSSERVER    $IDFI)
SDIRETO=$(clSDIRETORIO $IDFI)
 OBJETO=$(clOBJETOS    $IDFI)
  PORTA=$(clPORT       $IDFI)
 USERCL=$(clUSER       $IDFI)
 PASSCL=$(clPASSWD     $IDFI)
# -------------------------------------------------------------------------- #
# Garante que seja a rotina certa para o tipo de coleta da FI
[ "$TIPOC" != "scp" ] && echo "[c_scp]  1.02      - Configuration mismatch:- Only the scp method is supported by this program!" && exit 4

# -------------------------------------------------------------------------- #
# Ajusta lista de arquivos conforme regras gerais [:INI:]
# A lista de arquivos esta na quinta coluna elemento 'b' da tabela de coletas
echo "[c_scp]  1.02      - Efetua ajustamentos conforme regras implicitas"
# Regra 1 se nao ha especificacao deve ser M/F LILACS (soh sinaliza se o nivel de debug [N_DEB] for maior que zero)
[ -z $OBJETO ] && OBJETO="LILACS.xrf;LILACS.mst" && parseFL $OBJETO && [ "$N_DEB" -gt 0 ] && echo "[c_scp]  1.02.01   - Tentou efetuar ajuste"

# Regra 2 se não especificada a extensao do objeto de coleta deve ser mst e xrf
egrep '\.' >/dev/null <<<$OBJETO
RSP=$?
if [ $RSP -ne 0 ]; then
	OBJETO=${OBJETO//;/\.\{mst,xrf\};}".{mst,xrf}"
fi

# Parseia lista de objetos (resulta num array $FILES, usado como: ${FILES[idx]})
parseFL $OBJETO

# Determina o numero de arquivos da lista
i=0
while [ ! -z ${FILES[$i]} ]
do
	        i=$(expr $i + 1)
done

# Obtem o numero de arquivos passados na lista [0..[
MAXFILE=$(expr $i - 1)
# Ajusta lista de arquivos conforme regras gerais [:FIM:]
# -------------------------------------------------------------------------- #
# Mostra valores assumidos para execucao (se nivel de depuracao permitir)
if [ $N_DEB -ne 0 ]; then
        echo "==========================================================="
	echo " == COLATE SCP =="
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
echo "[c_scp]  1.03      - Faz corrente o diretorio de processamento"
[ -d "$DIRETO" ] || echo "[c_scp]  1.03.01   - Configuration mismatch:- Expected directory not found ($DIRETO)!"
[ -d "$DIRETO" ] || exit 4
cd $DIRETO

# Efetua a tomada dos dados
echo "[c_scp]  2         - Efetiva a transferencia de dados"
echo "[c_scp]  2.01      - Copia arquivos"

for i in $(seq 0 $MAXFILE)
do
	echo "[c_scp]  2.01.01.$i -  Copiando ${FILES[$i]} de $SIGLA para $PWD"
	egrep 'LILACS' >/dev/null <<<${FILES[$i]}
	RSP=$?
	if [ $RSP -eq 0 ]; then
		scp -P $PORTA $USERCL@$SSERVER:${SDIRETO/dbnotcertif/dbcertif}/${FILES[$i]} .
	else
		scp -P $PORTA $USERCL@$SSERVER:${SDIRETO}/${FILES[$i]} .
	fi
	RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
	chkError $RSP "Copiando ${FILES[$i]} de $SIGLA"
done

echo "[c_scp]  2.01.02    - Fixando permissoes dos arquivos recebidos"
find . -type f -iname "*.[mxi][sr][tof]" | xargs chmod 664

# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infofim.inc

# -------------------------------------------------------------------------- #
cat > /dev/null <<COMMENT
.    Entrada :  PARM1 identificando a FI a operar
.               Opcoes de execucao
. desabilitada   --changelog    Mostra historico de alteracoes
. desabilitada   -d, --debug    Nivel de depuracao [0..255]
. desabilitada   -e, --no-error Ignora detecao de erros
. desabilitada   -h, --help     Mostra o help
. desabilitada   -i, --info     Informacoes adicionais sobre o processo
.                -V, --versao   Mostra a versao
.      Saida :  Arquivos da Fonte de Informacao coletados
.               Codigos de retorno:
.                 0 - Ok operation
.                 1 - Non specific error
.                 2 - Syntax Error
.                 3 - Configuration error (coletas.tab not found)
.                 4 - Configuration failure (ID_FI unrecognized or wrong method)
.   Corrente :  inespecifico (sera alterado conforme coluna 3 de coletas.tab)
.    Chamada :  coleta_scp.sh [-V] <ID_FI>
.    Exemplo :  nohup ../shs.lil/coleta_scp.sh -d 2 ibc &> logs/YYYYMMDD.coleta.txt &
.Objetivo(s) :  1- Obter novos dados da Fonte de Informacao na origem
.Comentarios :  
.Observacoes :  DEBUG eh uma variavel mapeada por bit conforme
.                       _BIT0_  Aguarda tecla <ENTER> (suportada por rdBreak)
.                       _BIT1_  Nivel de depuracao (em conjunto com bit2)
.                       _BIT2_  Nivel de depuracao (em conjunto com bit1)
.                       _BIT3_  Modo debug de linhas   (-v do bash)
.                       _BIT4_  Modo debug de comandos (-x do bash)
.                       _BIT7_  Operacao em modo FAKE (nao realiza operacoes que provoquem mudancas irreversiveis em geral)
.      Notas :  
.Dependencia :  Tabela coletas.tab deve estar presente em ../tabs
.               COLUNA  NOME                    COMENTARIOS
.                1      ID_FI               ID da Fonte de Informacao     (Identificador unico)
.                2      SIGLA FI            Nome humano da FI (em geral sigla com tres letras)
.                3      DIRETORIO           Diretorio de execucao da coleta (em geral = entrega dos dados)
.                4      TIPO                Tipo de coleta para a FI (valores: scp / ftp / wget / rsync / oai / dspace)
.                5      FONTE DE DADOS      
.                	^h=                 HOSTNAME onde se encontram os dados
.                       ^d=                 Diretorio dos dados na fonte / para tipo dSpace diretorio de execucao
.                       ^l=                 PORT TCP/IP a ser utilizado (quando cabivel)
.                       ^p=                 Username a ser utilizado no processo
.                       ^s=                 Senha do ususario a ser empregada na autenticacao
.                       ^b=                 Lista de arquivos a coletar (separados por ;)
.               Variaveis de ambiente que devem estar previamente ajustadas:
.               geral           BIREME - Path para o diretorio com especificos da BIREME
.               geral             CRON - Path para o diretorio com rotinas de crontab
.               geral             MISC - Path para o diretorio de miscelaneas da BIREME
.               geral             TABS - Path para as tabelasde uso geral da BIREME
.               geral         TRANSFER - Usuario para troca de arquivos entre servidores
.               geral           _BIT0_ - 00000001b ou   1
.               geral           _BIT1_ - 00000010b ou   2
.               geral           _BIT2_ - 00000100b ou   4
.               geral           _BIT3_ - 00001000b ou   8
.               geral           _BIT4_ - 00010000b ou  16
.               geral           _BIT5_ - 00100000b ou  32
.               geral           _BIT6_ - 01000000b ou  64
.               geral           _BIT7_ - 10000000b ou 128
.               ISIS         ISIS - WXISI      - Path para pacote CISIS do sabor 10/30
.               ISIS     ISIS1660 - WXIS1660   - Path para pacote CISIS do sabor 16/60
.               ISIS        ISISG - WXISG      - Path para pacote CISIS do sabor 10/30 G (nao 4)
.               ISIS         LIND - WXISL      - Path para pacote CISIS do sabor Lind
.               ISIS      LIND512 - WXISL512   - Path para pacote CISIS do sabor Lind 16/512
.               ISIS       LINDG4 - WXISLG4    - Path para pacote CISIS do sabor Lind G4
.               ISIS    LIND512G4 - WXISL512G4 - Path para pacote CISIS do sabor Lind 16/512 G4
.               ISIS          FFI - WXISF      - Path para pacote CISIS do sabor Lind FFI
.               ISIS      FFI1660 - WXISF1660  - Path para pacote CISIS do sabor FFI 16/60
.               ISIS       FFI512 - WXISF512   - Path para pacote CISIS do sabor Lind 16/512 FFI
.               ISIS        FFIG4 - WXISFG4    - Path para pacote CISIS do sabor Lind G4 FFI
.               ISIS      FFIG4_4 - WXISFG4_4  - Path para pacote CISIS do sabor Lind G4 FFI 4M
.               ISIS     FFI512G4 - WXISF512G4 - Path para pacote CISIS do sabor Lind 16/512 G4 FFI
.               ISIS      BIGISIS - WXISBIG    - Path para pacote CISIS do sabor 16/256 G FFI
COMMENT
exit
cat > /dev/null <<COMMENT
<MOREINFO
Em funcao do que sera coletado mudam:
-servidor de origem dos dados
-diretorio de destinacao dos dados
-desempacotamento de dados

OFI FI  SIGLA         DIRETORIO                       Tipo    Configuracoes (h=host; d=diretorio; l=port; p=usuario; s=senha; b=objetos)
    ======================================================================================================================
 4  bde BDEnf        /bases/lilG4/tst.lil             scp     ^h=pr10vm.bireme.br^d=/home/apps/bvs.br/wp-enfermagem/bases/lildbi/dbcertif/lilacs^l=8022^p=transfer^s=102030	
 4  sus ColecionaSUS /bases/lilG4/sus.lil             scp     ^h=pr20dx.bireme.br^d=/home/aplicacoes/coleciona-sus/bases/lildbi/dbcertif/lilacs^l=8022^p=transfer^s=102030	
 4  mis MS           /bases/lilG4/mis.lil             scp     ^h=pr20dx.bireme.br^d=/home/aplicacoes/abcd-ms/bases/lildbi/dbcertif/lilacs^l=8022^p=transfer^s=102030	
 4  abr ADOLEC-BR    /bases/lilG4/abr.lil             scp     ^h=hm01dx.bireme.br^d=/home/aplicacoes-bvs/adolec-br/bases/lildbi/dbcertif/lilacs^l=22^p=transfer^s=102030	
 4  crt CRT/AIDS     /bases/lilG4/crt.lil             scp     ^h=hm02dx.bireme.br^d=/home/aplicacoes-bvs/crt-dst-aids/bases/iah/lilacs^l=22^p=transfer^s=102030	
 4  hom HOMEOIndex   /bases/lilG4/hom.lil             scp     ^h=hm01dx.bireme.br^d=/home/aplicacoes-bvs/homeopatia/bases/lildbi/dbcertif/lilacs^l=22^p=transfer^s=102030	
 4  lil LILACS       /bases/lilG4/lil.lil             scp     ^h=serverabd^d=/home/lilacs/www/bases/lildbi/dbcertif/lilacs^l=22^p=transfer^s=102030	
 4  ibc IBECS        /bases/ibcG4/ibc.lil/isos/bases  scp     ^h=pr10vm.bireme.br^d=/home/apps/bvsalud-org/lildbi-ibecs/bases/lildbi/dbnotcertif/lilacs^l=8022^p=transfer^s=102030^b=amalia;Anabel;jmg5;maribel2;marisol;LILACS	
 4  bbo BBO          /bases/lilG4/tst.lil             ftp     ^h=ftp.bireme.br^d=/home/ftp/BBO_ofi_^l=21^p=BBO_ofi_^s=BBO_ofi_^b=BBOv36b.iso	
 4  nml NMail        /bases/lilG4/tst.lil             rsync   ^h=quartzo2.bireme.br^d=/home/intranet/bases/nmail^l=22^p=transfer^s102030^b=nmail.fst;nmail.xrf;nmail.mst	
 4  tit TITLE        /usr/local/bireme/tabs           rsync   ^h=quartzo2.bireme.br^d=/home/intranet/bases/portal/newprocs/isos/^l=22^p=transfer^s=102030^b=title.iso	
 4  his HISA         /bases/lilG4/tst.lil	          wget    ^h=http://basehisa.coc.fiocruz.br/P/hisa.iso^d=/P^l=^p=^s=^b=hisa.iso	
 5  pnc peru         /bases/lilG4/pnc.lil             oai     ^h=http://www.bvs.org.pe/isis-oai-provider/^d=/bases/xml2isis/oai/isis^l=PORT^p=USER^s=PASSWD^b=nac
 5  pru bvsperu      /bases/lilG4/pru.lil             oai     ^h=http://bvs.minsa.gob.pe/isis-oai-provider/^d=/bases/xml2isis/oai/isis^l=PORT^p=USER^s=PASSWD^b=minsa
 5  fio fiocruz      /bases/lilG4/fio.lil             oai     ^h=http://www.bvsdip.icict.fiocruz.br/isis-oai-provider^d=/bases/xml2isis/oai/isis^l=PORT^p=USER^s=PASSWD^b=far;aro;bam;car;dip;eps;bps;bvs;teh;cla;cam;crr;ens;ilm;int;tes;the
 5  psa bivipsil     /bases/lilG4/psa.lil             oai     ^h=^d=/bases/xml2isis/oai/isis^l=^p=^s=^b=bivipsil
 5  cum cumed        /bases/lilG4/cum.lil             oai     ^h=^d=/bases/xml2isis/oai/tpl/cron_Harvest_CUMED_isis_oai_provider.sh^l=^p=^s=^b=cumed
 5  iec iec          /bases/lilG4/iac.lil             oai     ^h=^d=/bases/xml2isis/oai/tpl/cron_Harvest_IEC_isis_oai_provider.sh^l=^p=^s=^b=iecbvs
 5  bio bioetica     /bases/lilG4/bio.lil             dspace  ^h=^d=/bases/xml2isis/oai/tpl/cron_Harvest_BIOETICA_isis_oai_provider.sh^l=^p=^s=^b=
 5  vtt vetteses     /bases/lilG4/vtt.lil             oai     ^h=^d=/bases/xml2isis/oai/tpl^l=^p=^s=^b=
 5  vti vetindex     /bases/lilG4/vti.lil             oai     ^h=^d=/bases/xml2isis/oai/tpl^l=^p=^s=^b=
 5  arc ARCA         /bases/lilG4/arc.lil             dspace  ^h=^d=/bases/xml2isis/oai/tpl^l=^p=^s=^b=arcadim;arcamods
    
 5  mdl Medline	/bases/mdlG4/fasea	nlm	^h=^d=^l=^p=^s=^b=

Obs: para o Medline a chamada faz a tarefa de coleta ../tpl.mdl/traz_mdl_update_files.sh YY, YY eh o ano em dois algarismos

COMMENT
cat > /dev/null <<SPICEDHAM
CHANGELOG
20160513 Edição original
20160610 Enxugamento de codigo, mais comentarios diferenciados para fins de documentacao
SPICEDHAM

