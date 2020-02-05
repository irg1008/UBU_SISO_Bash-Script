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

#Arrays
declare -A array

# Funcion Crea Arrays Y Asigna Valores
function asignarValores() {
  for ((i = 1; i <= num_columns; i++)); do
    for ((j = 1; j <= num_rows; j++)); do
      array[$i,$j]=$RANDOM
    done
  done
}

# Funcion Imprime
function imprimirTabla() {

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
      for ((j = 1; j <= num_columns; j++)); do
        printf "${LIGHTBLUE}║${NC}%10s" "${array[$j,$i]} "
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
