#!/bin/bash
# ------------------------------------------------------------------------- #
# Xml2Isis.sh - Programa para extracao de meta-dados do XML da NLM
# ------------------------------------------------------------------------- #
#      Entrada: sem parametros
#        Saida: masteres
#     Corrente: /bases/???.???/bases
#      Chamada: ../tpl.xml2isis/Xml2Isis.sh fileDir=../xmls xmlRegExp=${OUTDB}.xml convTable=../tabs/mdl.tab outDb=${OUTDB} --createMissingFields --createFileNameField fileEncoding=utf-8 dbEncoding=utf-8
#
#  Observacoes: A estrutura de diretorios esperada eh:
#                       /bases/???.???
#                               |
#                               +--- outs
#                               +--- tabs
#                               +--- tpl.xml2isis
#                               +--- bases
#
# Dependencias:
#
# ==> tpl.xml2isis/GenBasesCISIS.sh
#    - bases/decs.mst-xrf-fst
#    - bases/gqlfi.mst-xrf
#    - bases/XMLs.lst
#    ==> tpl.xml2isis/ConvXML2ISIS.sh
#       ==> tpl.xml2isis/Xml2Isis.sh
#              - xmls (diretorio)
#              - tabs/mdl.tab
#       ==> tpl.xml2isis/Medline.sh
#
#       - tabs/ixmlmdl.prc
#       - $TABS/gutf8ansFFIG4
#       - $TABS/gansnaFFIG4"
#       - $TABS/ghtmlansFFIG4
#       - gqlfi
#       - tabs/decs.prc
#       - tabs/bxmlmdl.prc
#       - tabs/DeleteCitation.tab
#       - id.fst
#
#
# ------------------------------------------------------------------------- #
#   DATA    Responsaveis                      Comentarios
# 20101105  Heitor Barbieri/Fabio Brito       Edicao original
#


java -Xms512m -Xmx2g -cp /usr/local/bireme/java/Xml2Isis/dist/Xml2Isis.jar:/usr/local/bireme/java/Xml2Isis/dist/lib/zeusIII.jar:/usr/local/bireme/java/Xml2Isis/dist/lib/Utils.jar br.bireme.xml2isis.Xml2Isis $1 $2 $3 $4 $5 $6 $7 $8 $9
