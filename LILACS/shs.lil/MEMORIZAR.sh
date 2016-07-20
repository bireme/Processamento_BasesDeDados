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

# ========================================================================== #
#                                  FUNCOES                                   #
# ========================================================================== #
parseFL(){
	        IFS=";" read -a FILES <<< "$1"
}

# -------------------------------------------------------------------------- #
cat > /dev/null <<COMMENT
.    Entrada :  PARM1 identificando o indice a ser processado
.               PARM2 segundo parametro e assim por diante
.      Saida :  Bla
.               Codigos de retorno:
.                 0 - Ok operation
.                 1 - Non specific error
.                 2 - Syntax Error
.                 3 - Configuration error (iAHx.tab not found)
.                 4 - Configuration failure (INDEX_ID unrecognized)
.   Corrente :  /bases/lilG4/INSTANCIA/
.    Chamada :  MODELO.sh <FI> <PARM2>
.    Exemplo :  nohup ../shs.lil/MODELO.sh lil &> logs/YYYYMMDD.modelo.txt &
.Objetivo(s) :
.Comentarios :
.Observacoes :  DEBUG eh uma variavel mapeada por bit conforme (profile ajusta)
.                       _BIT0_  Aguarda tecla <ENTER>
.                       _BIT1_  Mostra mensagens de DEBUG
.                       _BIT2_  Modo verboso
.                       _BIT3_  Modo debug de linhas -v
.                       _BIT4_  Modo debug de linhas -x
.                       _BIT7_  Opera em modo FAKE
.      Notas :  Deve ser executado como usuario 'xyz'
.Dependencia :  Tabela iAHx.tab deve estar presente em $PATH_EXEC/tabs
.               COLUNA  NOME                    COMENTARIOS
.                1      ID_INDICE               ID do indice                    (Identificador unico do indice para processamento)
.                2      NM_INDICE               nome do indice conforme o SOLR  (nome oficial do indice)
.                .
.                .
.                .
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
cat > /dev/null <<SPICEDHAM
CHANGELOG
20160513 Edição original
SPICEDHAM

