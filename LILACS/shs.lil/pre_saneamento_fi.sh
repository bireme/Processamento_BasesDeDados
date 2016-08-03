#!/bin/bash

# -------------------------------------------------------------------------- #
# pre_saneamento_fi.sh - Prove pre-saneamento generico para as FIs           #
# -------------------------------------------------------------------------- #
# Chamada : pre_saneamento_fi.sh <ID_FI>
# Exemplo : pre_saneamento_fi.sh bde
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
vrs:  0.01 20160614, FJLopes
	- Adicao de tratamento de URL em pre_sano1.in
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
 -V, --version       Displays the current version of program and stop

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
echo "[ps_fi]  1         - Inicia processamento de pre saneamento"
# -------------------------------------------------------------------------- #
# Garante que a o parametro 1 seja informado (sai com codigo de erro 2 - Syntax Error)
if [ -z "$PARM1" ]; then
        #     1234567890123456789012345
        echo "[ps_fi]  1.01      - Erro na chamada falta o parametro 1 ou esta errado"
        echo
        echo "Syntax error:- PARM1 missing or wrong"
        echo "$AJUDA_USO"
        exit 2
fi
			
# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                            1234567890123456789012345
[ ! -s "../tabs/coletas.tab" ] && echo "[ps_fi]  1.01      - Configuration error:- COLETAS table not found" && exit 3

unset   SIGLA
# Garante existencia do FI indicada na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para processamento
#                         1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[ps_fi]  0.00.01   - Testa se o indice eh valido"
IDFI=$(clANYTHING $PARM1)
[ $? -eq 0 ]     && SIGLA=$(clSIGLA $IDFI)
[ -z "$SIGLA" ]  && echo "[ps_fi]  1.01      - PARM error:- PARM1 does not indicate a valid index" && exit 4

echo "[ps_fi]  1.01      - Carrega definicoes da fonte para coleta de dados"
  TIPOC=$(clTYPE       $IDFI)
 DIRETO=$(clDIRETORIO  $IDFI)
SSERVER=$(clSSERVER    $IDFI)
SDIRETO=$(clSDIRETORIO $IDFI)
 OBJETO=$(clOBJETOS    $IDFI)
  PORTA=$(clPORT       $IDFI)
 USERCL=$(clUSER       $IDFI)
 PASSCL=$(clPASSWD     $IDFI)

# -------------------------------------------------------------------------- #
# Ajusta lista de arquivos conforme regras gerais

# Regra 1 se não ha especificacao deve ser M/F LILACS
[ -z $OBJETO ] && OBJETO="LILACS.xrf;LILACS.mst" && parseFL $OBJETO && echo "[ps_fi]  1.02.01   - Tentou o ajuste"

# Regra 2 se não especifica a extensao deve ser mst e xrf
egrep '\.' >/dev/null <<<$OBJETO
RSP=$?
if [ $RSP -ne 0 ]; then
        [ $TIPOC = "oai" -o $TIPOC = "dspace" ] || OBJETO=${OBJETO//;/\.\{mst,xrf\};}".{mst,xrf}" && echo "[ps_fi]  1.02.02   - Extensoes ajustadas"
fi

# -------------------------------------------------------------------------- #
echo "[ps_fi]  1.02.03   - Obtem os arquivos componentes (se houver)"
parseFL $OBJETO

# Determina o numero de arquivos da lista
echo "[ps_fi]  1.02.04   - Quantifica componentes a obter"
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
echo "[ps_fi]  2         - Faz corrente o diretorio de processamento"
cd $DIRETO

# Compatibiliza o nome do M/F de entrada
echo "[ps_fi]  2.01      - Normaliza denominacao do M/F de entrada"
[ -f "${IDFI}_LILACS.mst" ] || mv LILACS.mst ${IDFI}_LILACS.mst
[ -f "${IDFI}_LILACS.xrf" ] || mv LILACS.xrf ${IDFI}_LILACS.xrf

echo "[ps_fi]  2.02      - Normaliza campos de descritores, URL internet e limpa campos de temas (etapa 1/4)"

if [ ! -s "../tabs/norm_v8.prc" ]; then
	echo " 'd8'"                                          >  ../tabs/norm_v8.prc
	echo " if v8>'' then"                                 >> ../tabs/norm_v8.prc
	echo "   'a8'"                                      >> ../tabs/norm_v8.prc
	echo "   if p(v8^u) then |Internet^i|v8^u else v8 fi" >> ../tabs/norm_v8.prc
	echo "   if p(v8^q) then |^q|v8^q fi"                 >> ../tabs/norm_v8.prc
	echo "   if p(v8^y) then |^y|v8^y fi"                 >> ../tabs/norm_v8.prc
	echo "   ''"                                        >> ../tabs/norm_v8.prc
	echo " fi"                                            >> ../tabs/norm_v8.prc
fi

echo "gizmo=../tabs/g87,87,88"    >  pre_sano1.in;	# normaliza campos descr para sub-d e sub-s como devido
echo "gizmo=../tabs/gV8homolog,8" >> pre_sano1.in;	# Retira .homologo do URL para texto completo
echo "proc='d870d880'"            >> pre_sano1.in;	# Libera campo para temas
echo "proc=@../tabs/norm_v8.prc"  >> pre_sano1.in;	# Normaliza v8 para padrao de endereco de Internet
echo "proc='s'"                   >> pre_sano1.in;	# Ordena campos do registro
echo "now"                        >> pre_sano1.in
echo "-all"                       >> pre_sano1.in
echo "tell=50000"                 >> pre_sano1.in

mx ${IDFI}_LILACS in=pre_sano1.in create=tmp_trash
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
mv tmp_trash.mst ${IDFI}.mst
mv tmp_trash.xrf ${IDFI}.xrf
chkError $RSP "ERROR: [ps_fi] Etapa 1 de 4"

# Nao sera executado, so faz numero ate ser liberado para execucao
echo "[ps_fi]  2.03      - Aplica gizmos em descritores e reversao de metodologia (etapa 2/4)"

echo "gizmo=../tabs/g87,87,88"      >  pre_sano2.in;	# normaliza campos descr para sub-d e sub-s como devido
echo "proc=@../tabs/lilnew2old.prc" >> pre_sano2.in;	# Coloca a base em conformidade com a antiga metodologia LILACS
echo "proc='d235'"                  >> pre_sano2.in;	# Promove limpeza de campos
echo "-all"                         >> pre_sano2.in
echo "now"                          >> pre_sano2.in
echo "tell=50000"                   >> pre_sano2.in
cat > /dev/null <<COMMENT
mx ${IDFI} in=pre_sano2.in create=tmp_trash
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
mv tmp_trash.mst ${IDFI}.mst
mv tmp_trash.xrf ${IDFI}.xrf
chkError $RSP "ERROR: [ps_fi] Etapa 2 de 4"
COMMENT

echo "[ps_fi]  2.04      - Aplica gizmos de pontuacao tipografica (etapa 3/4)"
mx ${IDFI} gizmo=../tabs/gansent_hom -all now create=tmp_trash tell=50000
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
mv tmp_trash.mst ${IDFI}.mst
mv tmp_trash.xrf ${IDFI}.xrf
chkError $RSP "ERROR: [ps_fi] Etapa 3 de 4"

# Eh desejavel que esta seja a ultima etapa do pre saneamento das bases de dados CDS/ISIS
echo "[ps_fi]  2.05      - Efetua uma copia limpa da base com MXCP (etapa 4/4)"
mxcp ${IDFI} create=tmp_trash clean period=. log=${IDFI}.mxcp.log tell=50000
RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
mv tmp_trash.mst ${IDFI}_pre_saneamento.mst
mv tmp_trash.xrf ${IDFI}_pre_saneamento.xrf
chkError $RSP "ERROR: [ps_fi] Etapa 4 de 4"

# -------------------------------------------------------------------------- #
echo "[ps_fi]  3         - M/F pre-saneado, limpa a area de trabalho"
[ -f "pre_sano1.in" ] && rm -f pre_sano1.in
[ -f "pre_sano2.in" ] && rm -f pre_sano2.in

# Incorpora biblioteca de controle basico de processamento
source  $MISC/infra/infofim.inc
exit 0






cat > /dev/null <<COMMENT
.    Entrada : PARM1 com o identificador da FI (<IDFI>)
.      Saida : M/F <IDFI>_pre_saneamento gerado no diretorio <IDFI>.lil
.   Corrente : nao determinado (deve ser compensado na chamada)
.    Chamada : ../shs.lil/pre_saneamento_fi [-V] <IDFI>
.Objetivo(s) : Garantir a existencia do M/F <IDFI>_pre_saneamento para proxima etapa do processamento
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

= Versoes de proc de normalizacao do V8 historicas
echo "proc='d8',if p(v8^u) then |a8Internet^i|v8^u|| else |a8|v8|| fi" >> pre_sano1.in
echo "proc='d8',if p(v8^u) then |a8Internet^i|v8^u|^q|v8^q|^y|v8^y|| else |a8|v8|| fi" >> pre_sano1.in
echo "proc='d8' if v8>'' then 'a8' if p(v8^u) then  |Internet^i|v8^u else v8 fi if p(v8^q) then |^q|v8^q fi if p(v8^y) then |^y|v8^y fi '' fi" >> pre_sano1.in

<MOREINFO
Comentarios adicionais caem bem aqui.
COMMENT
cat >/dev/null <<SPICEDHAM
CHANGELOG
20160610 Edicao original
20160614 Adicao de tratamento mais detalhado da normalizacao de endereco de Internet em pre_sano1.in
SPICEDHAM

