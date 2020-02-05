#!/bin/bash

# ----------------------------------
# Colors
# ----------------------------------
NC='\033[0m'
LIGHTBLUE='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTLIGHTBLUE='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

# Variables TODO -> Cambiar cuando usemos los arrays de los proceoss
num_rows=4
num_columns=6
column_width=10 # Recomendamos dar un valor de 10 o más

#Arrays
declare -A array

# Funcion Crea Arrays Y Asigna Valores
function asignarValores() {
  for ((i = 1; i <= num_columns; i++)); do
    for ((j = 1; j <= num_rows; j++)); do
      array[$i, $j]=$RANDOM
    done
  done
}

# Funcion Imprime
function imprimirTabla() {

  # Crea el elemento separador
  local horizontalSymbol=""
  for ((i = 1; i <= column_width; i++)); do
    horizontalSymbol+="═"
  done

  local colorTabla=${LIGHTBLUE}

  local encabezado="╔"${horizontalSymbol}
  local pie="╚"${horizontalSymbol}
  local interline="╠"${horizontalSymbol}

  # Imprime Marcos
  marcos() {

    for ((i = 1; i < num_columns; i++)); do
      encabezado+="╦"${horizontalSymbol}
      pie+="╩"${horizontalSymbol}
      interline+="╬"${horizontalSymbol}
    done

    encabezado+="╗"
    pie+="╝"
    interline+="╣"

    printf "${colorTabla}%s\n${NC}" "$encabezado"

  }

  # Imprime Cuerpo
  cuerpo() {

    for ((i = 1; i <= num_columns; i++)); do
      printf "${colorTabla}║${NC}%-${column_width}s" " Array${i}"
    done
    printf "${colorTabla}║${NC}\n"

    for ((i = 1; i <= num_rows; i++)); do
      printf "${colorTabla}%s\n${NC}" $interline

      for ((j = 1; j <= num_columns; j++)); do
        printf "${colorTabla}║${NC}%${column_width}s" "${array[$j, $i]} "
      done

      printf "${colorTabla}║${NC}\n"
    done

    printf "${colorTabla}%s\n${NC}" "$pie"

  }

  marcos
  cuerpo

}

asignarValores
imprimirTabla
