#!/bin/bash

# Crea un array con valores aleatorio para fase desarrollo
# ----------------------------------
declare -A array
NUM_COL=8
NUM_FIL=6
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

  salida+="$(generarColor fg_negro);$(generarColor bg)m"

  echo "$salida"
}

# Finaliza el uso de colores
# ----------------------------------
function fc() {
  echo "\033[0m"
}

# Imprime una tabla según el tamaño del array de datos
# @param numeroFilasImprimir
# ----------------------------------
function imprimirTabla() {
  local titulos
  local colorEncabezado
  local -A coloresTabla
  local anchoCelda
  local filasImprimir
  local encTabla
  local interTabla
  local pieTabla

  # Guarda los colores aleatorio de la tabla
  # ----------------------------------
  function guardarColoresDeTabla() {
    colorEncabezado=$(cc Neg)
    for ((i = 1; i <= NUM_FIL; i++)); do
      coloresTabla[i]=$(cc Neg)
      echo ${coloresTabla[i]}
    done
    echo "${coloresTabla[*]}"
  }

  # Imprime los titulos de las columnas de datos
  # ----------------------------------
  function imprimirTitulos() {
    titulos=("NumFila" "Datos "{A..Z})

    for ((i = 0; i < NUM_COL; i++)); do
      printf "║%-*s" "$anchoCelda" "${titulos[$i]}"
    done

    printf "║"
  }

  # Asigna el ancho de la celda y el numero de filas a mostrar
  # desde el indice
  # ----------------------------------
  function asignarAnchoYFilasMostrar() {
    anchoCelda="12"
    filasImprimir="$1"

    if [ "$filasImprimir" -gt "$NUM_FIL" ]; then
      filasImprimir=$NUM_FIL
    fi
  }

  # Asigna un estilo a la tabla, de doble linea, linea basica,
  # esquinas redondeadas, etc...
  # ----------------------------------
  function asignarEstiloDeTabla() {
    local simboloHorizontal
    local estiloTabla
    estiloTabla=("═" "╔" "╠" "╚" "╦" "╬" "╩" "╗" "╣" "╝")

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
    # Encabezado
    printf "$colorEncabezado%s" ""
    printf "%s" "$encTabla"
    printf "$(fc)\n%s" ""

    # Fila de titulos
    printf "$colorEncabezado%s" ""
    imprimirTitulos
    printf "$(fc)\n%s" ""

    for ((k = 1; k <= filasImprimir; k++)); do
      # Fila de datos
      printf "${coloresTabla[k]}%s" ""
      printf "%s\n" "$interTabla"
      for ((j = 1; j <= NUM_COL; j++)); do
        # Celda
        printf "║%*s" "$anchoCelda" "${array[$j, $k]} "
      done
      printf "║$(fc)\n%s" ""
      if [ "$k" == "$filasImprimir" ]; then
        # Fila de pie
        printf "${coloresTabla[i]}%s" ""
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

# Main
# ----------------------------------
asignarValores
imprimirTabla 6
