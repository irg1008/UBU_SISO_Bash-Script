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

# Variables
num_rows=4
num_columns=6

#Arrays
declare -A array1
declare -A array2
declare -A array3
declare -A array4
declare -A array5
declare -A array6

# Funcion Crea Arrays Y Asigna Valores
function asignarValores() {
  for ((i = 1; i <= num_rows; i++)); do
    array1[$i]=$RANDOM
    array2[$i]=$RANDOM
    array3[$i]=$RANDOM
    array4[$i]=$RANDOM
    array5[$i]=$RANDOM
    array6[$i]=$RANDOM
  done
}

# Funcion Imprime
function imprimirTabla() {

  local array1=array1
  local array2=array2
  local array3=array
  local array4=array3
  local array5=array4
  local array6=array5

  local encabezado="╔══════════╦══════════╦══════════╦══════════╦══════════╦══════════╗"
  local pie="╚══════════╩══════════╩══════════╩══════════╩══════════╩══════════╝"
  local interline="╠══════════╬══════════╬══════════╬══════════╬══════════╬══════════╣"

  cuerpo() {
    for ((i = 1; i <= num_columns; i++)); do
      printf "${LIGHTBLUE}║${NC}%-10s" " Array${i}"
    done
    printf "${LIGHTBLUE}║${NC}\n"

    for ((i = 1; i <= num_rows; i++)); do
      printf "${LIGHTBLUE}%s\n${NC}" $interline
      for ((j = 1; j <= 6; j++)); do
        looped="array${j}[$i]"
        printf "${LIGHTBLUE}║${NC}%10s" "${!looped} "
      done
      printf "${LIGHTBLUE}║${NC}\n"
    done
  }

  printf "${LIGHTBLUE}%s\n${NC}" "$encabezado"
  cuerpo
  printf "${LIGHTBLUE}%s\n${NC}" "$pie"
}

asignarValores
imprimirTabla
