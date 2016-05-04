#!/bin/bash
# ------------------------------------------------------------------------- #
# Medline.sh - Programa para sincronizacao de descritores
# ------------------------------------------------------------------------- #
#      Entrada: sem parametros
#        Saida: masteres
#     Corrente: /bases/???.???/bases
#      Chamada: ../tpl.xml2isis/Medline.sh OUTDB_IN utf-8 OUTDB_OUT
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

java -cp /usr/local/bireme/java/Xml2Isis/dist/Xml2Isis.jar:/usr/local/bireme/java/Xml2Isis/dist/lib/zeusIII.jar:/usr/local/bireme/java/Xml2Isis/dist/lib/Utils.jar br.bireme.xml2isis.Medline $1 $2 $3 

