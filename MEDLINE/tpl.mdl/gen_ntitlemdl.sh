#------------------------------------------------------------------------#
# GENLSER - Procedimento para geracao da base de seriados e seu invertido
#
# Sintaxe: genntitle 
#   
#-----------------------------------------------------------------------#

TPR="start"
. log
echo "Gerando arvore ntitle"

# -------------------------------------------------------------------- #
# Verifica se o arquivo existe 
# -------------------------------------------------------------------- #
if [ ! -f /usr/local/bireme/tabs/ntitle.iso ]
then
   TPR="fatal"
   MSG="Arquivo ntitle.iso nao encontrado (/usr/local/bireme/tabs/ntitle.iso)"
   . log
fi

# -------------------------------------------------------------------- #
# Gerando proc ntitle.prc 
# -------------------------------------------------------------------- #
cat>ntitle.prc<<!
'd*',
'a304~'v100," "v110," "v120," "v130'~',
'a305~'v150'~',
'a309~'v180'~',
|a308~|v310|~|,
!

TPR="iffatal"
MSG="Erro na geracao da LSER.ISO"
mx iso=/usr/local/bireme/tabs/ntitle.iso proc=@ntitle.prc iso=ntitle.iso now -all tell=1000
. log
rm ntitle.prc

# -------------------------------------------------------------------- #
# Carga do arquivo LSER.ISO
# -------------------------------------------------------------------- #
TPR="iffatal"
MSG="Erro na carga do iso LSER.ISO" 
rm ntitle.mst ntitle.xrf ntitle.l* ntitle.n0* ntitle.cnt ntitle.iyp
loadiso ntitle ntitle 
. log

# -------------------------------------------------------------------- #
# LSER.FST 
# -------------------------------------------------------------------- #
cat>ntitle.fst<<!
305 0 mpl,v305
309 0 mpl,v309
!

# -------------------------------------------------------------------- #
# Carga do invertido ntitle 
# -------------------------------------------------------------------- #
TPR="iffatal"
MSG="Erro na geracao do invertido LSER"
gentree ntitle ntitle 100 no
. log

#rm ntitle.lk* ntitle.fst ntitle.iso

TPR="end"
. log
