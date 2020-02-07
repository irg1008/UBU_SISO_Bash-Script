#!/bin/bash

# Crea un array con valores aleatorio para fase desarrollo
# ----------------------------------
declare -A array
NUM_COL=6
NUM_FIL=10
function asignarValores() {
  for ((i = 1; i <= NUM_COL; i++)); do
    for ((j = 1; j <= NUM_FIL; j++)); do
      if [ $i == "1" ]; then
        array[$i, $j]="Fila "${j}
      else
        array[$i, $j]=$((RANDOM % 20))
      fi
    done
  done
}

# Devuelve la expresión completa de color, pasándole los parámetros
# que queremos en orden
# @param tipoEspecial (Negrita=Neg, Subrayado=Sub, Normal=Nor, Parpadeo=Par)
# @param random (valor random, ruleta o default de sistema)
# ----------------------------------
function cc() {

  # Devuelve un color de letra si se pide explicitamente,
  # o un color de fondo si no se pide
  # ----------------------------------
  function generarColor() {
    if [ "$1" == "fg" ]; then
      echo $((RANDOM % 7 + 31))
    elif [ "$1" == "fg_negro" ]; then
      echo "30"
    elif [ "$1" == "bg" ]; then
      echo $((RANDOM % 7 + 41))
    elif [ "$1" == "bg_negro" ]; then
      echo "40"
    fi
  }

  local salida
  salida="\e["

  case "$1" in
  Neg)
    salida+="1;"
    ;;
  Sub)
    salida+="4;"
    ;;
  Nor)
    salida+="0;"
    ;;
  Par)
    salida+="5;"
    ;;
  esac

  if [ "$2" == "random" ]; then
    salida+="$(generarColor fg_negro);$(generarColor bg)m"
  elif [ "$2" == "default" ]; then
    salida+="$(($(generarColor fg_negro) + 7));$(generarColor bg_negro)m"
  elif [ "$2" == "0" ]; then
    salida+="$(generarColor fg);$(generarColor bg_negro)m"
  else
    salida+="$(generarColor fg_negro);$(($(generarColor bg_negro) + 1 + $(($2 % 7))))m"
  fi

  echo "$salida"
}

# Finaliza el uso de colores
# ----------------------------------
function fc() {
  echo "\033[0m"
}

# Devuelve la longitud del string
# ----------------------------------
function calcularLongitud() {
  local elementoArray # Elemento a ser centrado
  elementoArray=$1
  echo ${#elementoArray}
}

# Imprime una tabla según el tamaño del array de datos
# @param numeroFilasImprimir
# @param numeroTabulaciones
# ----------------------------------
function imprimirTabla() {
  local titulos
  local colorEncabezado
  local -A coloresTabla
  local estiloTabla
  local anchoCelda
  local filasImprimir
  local encTabla
  local interTabla
  local pieTabla

  # Guarda los colores aleatorio de la tabla
  # ----------------------------------
  function guardarColoresDeTabla() {
    local random="false"

    if [ "$random" == "true" ]; then
      colorEncabezado=$(cc Neg)
      for ((i = 1; i <= NUM_FIL; i++)); do
        coloresTabla[$i]=$(cc Neg random)
      done
    else
      colorEncabezado=$(cc Neg default)
      for ((i = 1; i <= NUM_FIL; i++)); do
        coloresTabla[$i]=$(cc Neg "$i")
      done
    fi
  }

  # Imprime los titulos de las columnas de datos
  # ----------------------------------
  function imprimirTitulos() {
    titulos=("NumFila" "Datos "{A..Z})

    local longitudArray # Para centrar en la tabla

    for ((i = 0; i < NUM_COL; i++)); do
      longitudArray=$(calcularLongitud "${titulos[$i]}")
      printf "${estiloTabla[10]}%-*s" "$((anchoCelda / 2 - longitudArray / 2))" ""
      printf "%s" "${titulos[$i]}" ""
      printf "%*s" "$((anchoCelda / 2 - (longitudArray + 1) / 2))" ""
    done

    printf "${estiloTabla[10]}%s" ""
  }

  # Asigna el ancho de la celda y el numero de filas a mostrar
  # desde el indice
  # ----------------------------------
  function asignarAnchoYFilasMostrar() {
    anchoCelda="20"
    filasImprimir="$1"

    if [ "$filasImprimir" -gt "$NUM_FIL" ]; then
      filasImprimir=$NUM_FIL
    fi
  }

  # Asigna un estilo a la tabla, de doble linea, linea basica,
  # esquinas redondeadas, etc...
  # ----------------------------------
  function asignarEstiloDeTabla() {
    #local estiloTabla1=("═" "╔" "╠" "╚" "╦" "╬" "╩" "╗" "╣" "╝" "║")
    local estiloTabla2=("─" "╭" "├" "╰" "┬" "┼" "┴" "╮" "┤" "╯" "│")
    #local estiloTabla3=("━" "┏" "┣" "┗" "┳" "╋" "┻" "┓" "┫" "┛" "┃")
    local simboloHorizontal

    estiloTabla=("${estiloTabla2[@]}")

    for ((i = 1; i <= anchoCelda; i++)); do
      simboloHorizontal+=${estiloTabla[0]}
    done

    encTabla=${estiloTabla[1]}$simboloHorizontal
    interTabla=${estiloTabla[2]}$simboloHorizontal
    pieTabla=${estiloTabla[3]}$simboloHorizontal

    for ((i = 1; i < NUM_COL; i++)); do
      encTabla+=${estiloTabla[4]}$simboloHorizontal
      interTabla+=${estiloTabla[5]}$simboloHorizontal
      pieTabla+=${estiloTabla[6]}$simboloHorizontal
    done

    encTabla+=${estiloTabla[7]}
    interTabla+=${estiloTabla[8]}
    pieTabla+=${estiloTabla[9]}
  }

  # Imprime la tabla final en orden
  # ----------------------------------
  function imprimir() {
    local longitudArray

    # Encabezado
    printf "$colorEncabezado%s" ""
    printf "%s" "$encTabla"
    printf "$(fc)\n%s" ""

    # Fila de titulos
    printf "$colorEncabezado%s" ""
    printf "%s" ""
    imprimirTitulos
    printf "$(fc)\n%s" ""

    for ((k = 1; k <= filasImprimir; k++)); do
      # Fila de datos
      printf "${coloresTabla[$k]}%s" ""
      printf "%s\n" "$interTabla"
      for ((j = 1; j <= NUM_COL; j++)); do
        # Celda
        longitudArray=$(calcularLongitud "${array[$j, $k]}")
        printf "${estiloTabla[10]}%-*s" "$((anchoCelda / 2 - longitudArray / 2))" ""
        printf "%s" "${array[$j, $k]}" ""
        printf "%*s" "$((anchoCelda / 2 - (longitudArray + 1) / 2))" ""
      done
      printf "${estiloTabla[10]}%s" ""
      printf "$(fc)\n%s" ""
      if [ "$k" == "$filasImprimir" ]; then
        # Fila de pie
        printf "${coloresTabla[$k]}%s" ""
        printf "%s" "$pieTabla"
        printf "$(fc)\n%s" ""
      fi
    done
  }

  # Main de impresion
  # ----------------------------------
  guardarColoresDeTabla
  asignarAnchoYFilasMostrar "$1"
  asignarEstiloDeTabla
  imprimir
}

# Centra en pantalla el valor pasado, si es un string, divide por saltos de
# linea y coloca cada linea en el centro
# @param string a centrar
function centrarEnPantalla() {
  local string
  local termwidth
  local padding
  local longitudElemento

  IFS=$'\n' string=($1)
  termwidth="$(tput cols)"
  padding="$(printf '%0.1s' ' '{1..500})"
  longitudElemento=$(calcularLongitud "${string[0]}")

  for ((i = 0; i < ${#string[@]}; i++)); do
    printf "%*.*s %s %*.*s\n" 0 "$(((termwidth - 2 - longitudElemento) / 2))" "$padding" "${string[$i]}" 0 "$(((termwidth - 1 - longitudElemento) / 2))" "$padding"
  done
}

# Main
# ----------------------------------
function main() {
  asignarValores
  for ((fila = 1; fila <= NUM_FIL; fila++)); do
    clear
    centrarEnPantalla "TÍTULO DE LA TABLA CENTRADOOOO CON SOLO UNA LLAMADA A FUNCION"
    centrarEnPantalla "$(imprimirTabla $fila)"
    read -r -p "Pulsa enter para avanzar"
  done
}

main
