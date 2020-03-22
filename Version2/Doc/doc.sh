#!/bin/bash

# Pequeño documento para generar la documentacion en html, adoc y pdf en la carpeta doc/zsdoc

# Adoc
#------
function generarAdoc() {
    zsd --scomm --bash ../fcfs.sh --synopsis "FCFS según necesidades memoria no continua y no reubicable"
}

# HTML5
#------
function generarHTML() {
    asciidoctor zsdoc/fcfs.sh.adoc
}

# PDf
#------
function generarPDF() {
    asciidoctor -b pdf -r asciidoctor-pdf zsdoc/fcfs.sh.adoc
}

# DOC
#------
function generarDOC() {
    INPUT_ADOC="zsdoc/fcfs.sh.adoc"
    OUTPUT="zsdoc/fcfs.sh"
    asciidoctor --backend docbook --out-file - $INPUT_ADOC | pandoc --from docbook --to docx --output $OUTPUT.docx
}

# Main
#------
function main() {
    generarAdoc
    generarHTML
    generarPDF
    generarDOC
}

main
