#!/bin/bash

# Pequeño documento para generar la documentacion en html, adoc y pdf en la carpeta doc/zsdoc

# Simple función de entrada
# @param Pregunta de si no
# @param Dato a guardar respuesta
#------
function entradaSiNo() {
    echo -n "$1 [S/N]: "
    read
    until [[ "${REPLY}" =~ ^([sS][iI]|[sS]|[nN][oO]|[nN])$ ]]; do
        entradaSiNo "$1" "$2"
    done
    eval ${2}="${REPLY}"
}

# Comprueba el script de entrada
#------
function comprobarScript() {
    local nombre_script="$(echo "$path_script" | sed 's:.*/::')"

    # Comprobamos si el script existe
    if [[ ! -f "$path_script" ]]; then
        echo "¡No existe el script pasado!. Búscalo anda..."
        exit 1
    else
        adoc_path="./zsdoc/$nombre_script.adoc"
    fi
}

# Muestra las instrucciones para que el usuario instale todo lo necesario
#------
function mostrarInstrucciones() {
    local install_path="./info/instalar_zsdoc.md"
    local mostrarInstrucciones

    # Control de error hasta entrada correcta de ver instrucciones
    entradaSiNo "¿Quieres ver las instrucciones de instalación?" mostrarInstrucciones

    # Mostramos las instrucciones si se quiere y existen
    if [[ "$mostrarInstrucciones" =~ [sS][iI]|[sS] ]]; then
        if [[ ! -f "$install_path" ]]; then
            echo "No tienes el archivo de instrucciones. Si no tienes instalada alguna dependencia saltará un error."
        else
            less "$install_path"
            clear
        fi
    else
        clear
    fi
}

# Reemplaza la cabecera del ADOC
#------
function reemplazarCabecera() {
    local cabecera_path="./info/cabecera_personalizada.txt"
    local cambiarCabecera

    # Control de error hasta entrada correcta de querer cabecera
    entradaSiNo "¿Quieres cambiar la cabecera por una personalizada?" cambiarCabecera

    # Mostramos las instrucciones si se quiere y existen
    if [[ "$cambiarCabecera" =~ [sS][iI]|[sS] ]]; then
        if [[ ! -f "$cabecera_path" ]]; then
            echo "No tienes el archivo de cabecera personalizada."
        else
            # Eliminamos la cabecera(12 lineas) del adoc, para reemplazarla
            sed -i 1,12d "$adoc_path"
            local temp="./zsdoc/temp.temp"
            cat "$cabecera_path" >"$temp"
            cat "$adoc_path" >>"$temp"
            cat "$temp" >"$adoc_path"
            rm "$temp"
        fi
    else
        echo "Dejando cabecera por defecto"
    fi
}

# Mueve los archivos de documentacion
#------
function moverArchivos() {
    # Eliminamos la subcarpeta data primero
    rm -rf ./zsdoc/data

    # Copiamos el contenido
    if [[ ! -d "./documentacion" ]]; then
        mkdir documentacion
    fi
    cp -rf ./zsdoc/. ./documentacion/

    # Eliminamos carpeta
    rm -rf ./zsdoc/
}

# Genera los documentos
#------
function generando() {
    echo "Generando $1..."
}

# ADOC
#------
function generarAdoc() {
    generando "ADOC" & zsd --scomm --bash "$path_script" >/dev/null
}
# HTML5
#------
function generarHTML() {
    generando "HTML" & asciidoctor "$adoc_path" >/dev/null
}
# PDF
#------
function generarPDF() {
    generando "PDF" & asciidoctor -b pdf -r asciidoctor-pdf "$adoc_path" >/dev/null
}
# DOC
#------
function generarDOC() {
    local doc_name=${path_script##*/}
    generando "DOC" & asciidoctor --backend docbook --out-file - "$adoc_path" | pandoc --from docbook --to docx --output "./zsdoc/$doc_name.docx" >/dev/null
}

# Main
# @param Script a documentar
#------
function main() {

    clear

    # Comprobamos que el script es válido
    comprobarScript

    # Mostramos instrucciones
    mostrarInstrucciones

    # Generamos adoc
    generarAdoc

    # Reemplazamos cabecera
    reemplazarCabecera

    # Documentamos
    generarHTML
    generarDOC
    generarPDF

    # Movemos archivos
    moverArchivos

    echo "Documentación generada"
}

declare path_script="$1"
declare adoc_path

# Si no pasamos ningún parámetro usamos el script original
if [[ "$1" == "" ]]; then
    path_script="../fcfs.sh"
fi
main
