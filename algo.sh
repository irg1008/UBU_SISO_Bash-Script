#!/bin/bash

# TODO -> Poner colores aleatorios para cada fila
# TODO -> Cambiar las variables de filas y columnas cuando implementemos el algoritmo

# Colores
# ----------------------------------
# Tipo de uso de colores
declare -r BOLD="1"; declare -r NORMAL="0"; declare -r UNDERLINE="4"; declare -r BLINKING="5"; declare -r REVERSE="7"
# FG color # BG color # Equivalente
declare -r FG_BLACK="30"; declare -r BG_BLACK="40" # - 0: Black - 1: Dark Gray
declare -r FG_RED="31"; declare -r BG_RED="41" # - 0: Red - 1: Light Red
declare -r FG_GREEN="32"; declare -r BG_GREEN="42" # - 0: Green - 1: Light Green
declare -r FG_BROWN="33"; declare -r BG_BROWN="43" # - 0: Brown - 1: Yellow
declare -r FG_BLUE="34"; declare -r BG_BLUE="44" # - 0: Blue - 1: Light Blue
declare -r FG_PURPLE="35"; declare -r BG_PURPLE="45" # - 0: Purple - 1: Light Purple
declare -r FG_CYAN="36"; declare -r BG_CYAN="46" # - 0: Cyan - 1: Light Cyan
declare -r FG_WHITE="37"; declare -r BG_WHITE="47" # - 0: Light Gray - 1: White
# Inicio color # Fin de color # Separador # No color
declare -r COM="\e["; declare FIN="m"; declare -r SEP=";"; declare -r NC="\033[0m"
# ----------------------------------

# Variables
# ----------------------------------
NUM_ROWS=8
NUM_COLUMNS=8
# ----------------------------------

#Array bidimensional con todos los datos
# ----------------------------------
declare -A array
# ----------------------------------

# Crea arrays y asigna valores
# ----------------------------------
function asignarValores() {
  for ((i = 1; i <= NUM_COLUMNS; i++)); do
    for ((j = 1; j <= NUM_ROWS; j++)); do
      array[$i, $j]=$RANDOM
      array[1, $j]="P "${j}
    done
  done
}
# ----------------------------------

# Imprime la tabla pasandole el argumento del ancho de tabla
# @arg ancho
# ----------------------------------
function imprimirTabla() {

  # Titulos de las columnas, la tabla tendrá tantas columnas como titulos pasados
  local titulos=("" Datos{1..20})

  # Numero de columnas y filas. Se calculará al saber cuantos datos almacena al array DATOS. De momento usamos la variable global
  local numeroColumnas=$NUM_COLUMNS
  local filaComienzo=$2
  local numeroFilas=$((filaComienzo + $3 - 1))

  if [ "$filaComienzo" -gt "$NUM_ROWS" ]; then
    filaComienzo=$NUM_ROWS
    numeroFilas=$NUM_ROWS
  fi

  # Tamaño de tabla, pasado por valor
  local column_width=$1

  # Crea el elemento separador
  local horizontalSymbol=""
  for ((i = 1; i <= column_width; i++)); do
    horizontalSymbol+="═"
  done

  # Variables marco
  local encabezado="╔"${horizontalSymbol}
  local interline="╠"${horizontalSymbol}
  local pie="╚"${horizontalSymbol}

  # Imprime marcos
  marcos() {

    # Valores de las intersecciones en el encabezado, pie, y interfila
    for ((i = 1; i < numeroColumnas; i++)); do
      encabezado+="╦"${horizontalSymbol}
      pie+="╩"${horizontalSymbol}
      interline+="╬"${horizontalSymbol}
    done

    encabezado+="╗"
    pie+="╝"
    interline+="╣"

    # Encabezado de la tabla
    printf "%s\n" "$encabezado"

  }

  # Imprime cuerpo
  cuerpo() {

    for ((i = 0; i < numeroColumnas; i++)); do
      # Títulos de los array a desplegar, por columna
      printf "║%-${column_width}s" " ${titulos[$i]}"
    done
    # Divisor lateral final de primera fila
    printf "║\n"

    for ((i = filaComienzo; i <= numeroFilas && i <=NUM_ROWS; i++)); do
      # Divisor de filas
      printf "%s\n" $interline

      for ((j = 1; j <= numeroColumnas; j++)); do
        # Celda
        printf "║%${column_width}s" "${array[$j, $i]} "
      done

      # Divisor lateral final de fila
      printf "║\n"
    done

    # Imprime el pie de tabla
    printf "%s\n" "$pie"

  }

  # Color de tabla y de letra de tabla
  printf "${COM}${BLINKING}${SEP}${BOLD}${SEP}${FG_WHITE}${SEP}${BG_RED}${FIN}"
  marcos # Imprime marcos de la tabla
  cuerpo # Imprime el cuerpo de la tabla
  printf "${NC}"

}
# ----------------------------------

# Main
# ----------------------------------
asignarValores # Asignamos valores al array que contiene TODOS los datos
# Imprime (Ancho de celda, Fila comienzo (Si pones mas de las que hay coge la ultima), Filas a mostrar (Si te has pasado en la anterior, solo muestra la ultima))
imprimirTabla 12 1 ${NUM_ROWS}
# ----------------------------------
