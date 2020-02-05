#!/bin/bash



# Colors = '\e[<tipo de caracter>;<FG o BG>'
# FG = [30, 37]; BG = [40, 47]
# Tipo de caracter:
#     - 0: Normal
#     - 1: Bold
#     - 4: Undelrine
#     - 5: Blinking
#     - 7: Reverse video
# Colores:
#     - 0: Black - 1: Dark Gray
#     - 0: Red - 1: Light Red
#     - 0: Green - 1: Light Green
#     - 0: Brown - 1: Yellow
#     - 0: Blue - 1: Light Blue
#     - 0: Purple - 1: Light Purple
#     - 0: Cyan - 1: Light Cyan
#     - 0: Light Gray - 1: White
# No color: \033[0m
# ----------------------------------
#
# Esto siempre
declare -r COM="\e["
# Más uno de estos
declare -r BOLD="1"
declare -r NORMAL="0"
declare -r UNDERLINE="4"
declare -r BLINKING="5"
declare -r REVERSE_VIDEO="7"
# Más uno de estos [Opcional] - FG
declare -r FG_BLACK='30'
declare -r FG_RED='31'
declare -r FG_GREEN='32'
declare -r FG_BROWN='33'
declare -r FG_BLUE='34'
declare -r FG_PURPLE="35"
declare -r FG_CYAN="36"
declare -r FG_WHITE="37"
# Más uno de estos [Opcional] - BG
declare -r BG_BLACK='40'
declare -r BG_RED='41'
declare -r BG_GREEN='42'
declare -r BG_BROWN='43'
declare -r BG_BLUE='44'
declare -r BG_PURPLE="45"
declare -r BG_CYAN="46"
declare -r BG_WHITE="47"
# Esto siempre
declare FIN="m"
# Más el separador
declare -r SEP=";"

# No color
declare -r NC='\033[0m'
# ----------------------------------



# Variables TODO -> Cambiar cuando usemos los arrays de los procesos, eliminar las dos variables, ya que podremos sacarlas del tamaño del array con #, ver so (stackoverflow)
# ----------------------------------
num_rows=8
num_columns=8
# ----------------------------------



#Array bidimensional con todos los datos
# ----------------------------------
declare -A array
# ----------------------------------



# Crea arrays y asigna valores
# ----------------------------------
function asignarValores() {
  for ((i = 1; i <= num_columns; i++)); do
    for ((j = 1; j <= num_rows; j++)); do
      array[$i, $j]=$RANDOM
    done
  done
}
# ----------------------------------



# Imprime la tabla pasandole el argumento del ancho de tabla
# @arg ancho
# ----------------------------------
function imprimirTabla() {

  # Titulos de las columnas, la tabla tendrá tantas columnas como titulos pasados
  local titulos=("$@")

  # Numero de columnas y filas. Se calculará al saber cuantos datos almacena al array DATOS. De momento usamos la variable global
  local numeroColumnas
  local numeroFilas

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
    for ((i = 1; i < num_columns; i++)); do
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

    for ((i = 1; i <= num_columns; i++)); do
      # Títulos de los array a desplegar, por columna
      printf "║%-${column_width}s" "> ${titulos[$i]}"
    done
    # Divisor lateral final de primera fila
    printf "║\n"

    for ((i = 1; i <= num_rows; i++)); do
      # Divisor de filas
      printf "%s\n" $interline

      for ((j = 1; j <= num_columns; j++)); do
        # Celda
        printf "║%${column_width}s" "${array[$j, $i]} <"
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
asignarValores   # Asignamos valores al array que contiene TODOS los datos
imprimirTabla 12 Array{1..20} # Creamos una tabla con un tamaño específico junto a titulos para cada columna en orden, si se pasan menos titulos que el tamaño del array de datos se dará un valor predeterminado
# ----------------------------------
