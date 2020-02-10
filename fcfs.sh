#!/bin/bash

# Variables globales
# ----------------------------------
declare estiloGeneral # Estilo de los marcos
declare -A array
declare NUM_COL
declare NUM_FIL

# Crea un array con valores aleatorio para fase desarrollo o entrada
# de datos automatica, (ni manual ni por archivo)
# @param Numero de filas a generar de manera aleatorio (num. proceos)
# ----------------------------------
function asignarValoresAleatorios() {
  filasAGenerar="$1"

  for ((i = 1; i <= NUM_COL; i++)); do
    for ((j = 1; j <= filasAGenerar; j++)); do
      if [ $i == "1" ]; then
        array[$i, $j]="P"${j}
      else
        array[$i, $j]=$((RANDOM % 20))
      fi
    done
  done
}

# Saca la información del comando que acompaña
# ----------------------------------
function sacarHaciaArchivo() {
  local archivo
  archivo=$(dirname "$0")
  archivo+="/$1"

  if [ "$2" == "-a" ]; then
    tee -a "$archivo"
  else
    tee "$archivo"
  fi
}

# Devuelve los datos del archivo de entrada en un array
# ----------------------------------
function asignarDesdeArchivo() {
  local archivo
  archivo=$(dirname "$0")
  archivo+="/$1"

  # Separador
  IFS=","

  # Si hay algun error
  [ ! -f "$archivo" ] && {
    centrarEnPantalla "$(imprimirCuadro "100" "error" "Archivo no encontrado")" | sacarHaciaArchivo "$archivoSalida" -a
    exit 99
  }

  # Leer todas las lineas y guardar los datos por columnas en el array
  local i
  i="0"
  while read -r proceso llegada ejecucion; do
    if [ $i -ge "1" ]; then
      array[1, $i]=$proceso
      array[2, $i]=$llegada
      array[3, $i]=$ejecucion
    fi
    ((i++))
  done <"$archivo"

  # Lee la ultima fila
  array[1, $i]=$proceso
  array[2, $i]=$llegada
  array[3, $i]=$ejecucion
}

# Devuelve la expresión completa de color, pasándole los parámetros
# que queremos en orden
# @param tipoEspecial (Negrita=Neg, Subrayado=Sub, Normal=Nor, Parpadeo=Par)
# @param random (valor random, default,  error, acierto, fg aleatorio sobre bg negro
# olista de colores en orden)
# ----------------------------------
function cc() {

  # Devuelve un color de letra si se pide explicitamente,
  # o un color de fondo si no se pide
  # 0=N; 1=R; 2=G; 3=O; 4=B; 5=P; 6=C; 7=W
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

  case "$2" in
  random)
    salida+="$(generarColor fg_negro);$(generarColor bg)m"
    ;;
  default)
    salida+="$(($(generarColor fg_negro) + 7));$(generarColor bg_negro)m"
    ;;
  error)
    salida+="$(($(generarColor fg_negro) + 7));$(($(generarColor bg_negro) + 1))m"
    ;;
  acierto)
    salida+="$(($(generarColor fg_negro)));$(($(generarColor bg_negro) + 2))m"
    ;;
  advertencia)
    salida+="$(($(generarColor fg_negro)));$(($(generarColor bg_negro) + 3))m"
    ;;
  0)
    salida+="$(generarColor fg);$(generarColor bg_negro)m"
    ;;
  *)
    salida+="$(generarColor fg_negro);$(($(generarColor bg_negro) + 1 + $(($2 % 7))))m"
    ;;
  esac

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

# Almacen de los estilos de las tablas con sus códigos ASCII
# @param Numero de estilo
# ----------------------------------
function asignarEstiloGeneral() {
  local estilo1=("═" "╔" "╠" "╚" "╦" "╬" "╩" "╗" "╣" "╝" "║")
  local estilo2=("─" "╭" "├" "╰" "┬" "┼" "┴" "╮" "┤" "╯" "│")
  local estilo3=("━" "┏" "┣" "┗" "┳" "╋" "┻" "┓" "┫" "┛" "┃")

  case "$1" in
  1)
    estiloGeneral=("${estilo1[@]}")
    ;;
  2)
    estiloGeneral=("${estilo2[@]}")
    ;;
  3)
    estiloGeneral=("${estilo3[@]}")
    ;;
  *)
    estiloGeneral=("${estilo3[@]}")
    ;;
  esac
}

# Imprime la introduccion del programa
# @param Array del contenido del cuadro
# @param Ancho del cuadro
# ----------------------------------
function imprimirCuadro() {
  local estilo
  local titulos
  local encTabla
  local pieTabla
  local anchoCelda
  local color

  # Asigna un estilo a la tabla, de doble linea, linea basica,
  # esquinas redondeadas, etc...
  # ----------------------------------
  function asignarEstilo() {
    local simboloHorizontal

    estilo=("${estiloGeneral[@]}")

    for ((i = 1; i <= anchoCelda; i++)); do
      simboloHorizontal+=${estilo[0]}
    done

    encTabla=${estilo[1]}$simboloHorizontal
    pieTabla=${estilo[3]}$simboloHorizontal

    encTabla+=${estilo[7]}
    pieTabla+=${estilo[9]}
  }

  # Asigna el color principal de la introduccion
  function asignacolor() {
    color=$(cc Neg "$1")
  }

  # Asigna el ancho de la celda
  # ----------------------------------
  function asignarAncho() {
    anchoCelda="$1"
  }

  # Imprime los elementos del array
  # ----------------------------------
  function imprimirTitulos() {

    IFS=$'\n' titulos=($@)
    local longitudArray # Para centrar en la tabla

    for ((i = 2; i < ${#titulos[@]}; i++)); do
      longitudArray=$(calcularLongitud "${titulos[$i]}")
      printf "$color%s" ""
      printf "${estilo[10]}%-*s" "$((anchoCelda / 2 - longitudArray / 2))" ""
      printf "%s" "${titulos[$i]}" ""
      printf "%*s${estilo[10]}" "$((anchoCelda / 2 - (longitudArray + 1) / 2))" ""
      printf "$(fc)\n%s" ""
    done
  }

  # Imprime la tabla de introduccion
  # ----------------------------------
  function imprimir() {
    local longitudArray

    # Encabezado
    printf "$color%s" ""
    printf "%s" "$encTabla"
    printf "$(fc)\n%s" ""

    # Fila de titulos
    imprimirTitulos "$@"

    # Fila de pie
    printf "$color%s" ""
    printf "%s" "$pieTabla"
    printf "$(fc)\n%s" ""
  }

  asignarAncho "$1"
  asignacolor "$2"
  asignarEstilo
  imprimir "$@"
}

# Imprime una tabla según el tamaño del array de datos
# @param numeroFilasImprimir
# ----------------------------------
function imprimirTabla() {
  local titulos
  local colorEncabezado
  local -A coloresTabla
  local estiloTabla
  local anchoCelda
  local filasImprimir
  local columnasImprimir
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
    titulos=("Proceso" "Llegada" "Ejecución" "Espera" "Respuesta")

    local longitudArray # Para centrar en la tabla

    for ((i = 0; i < columnasImprimir; i++)); do
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
  function asignarAnchoYFilasYColumnas() {
    anchoCelda="12"
    filasImprimir="$1"
    columnasImprimir="$2"

    if [ "$filasImprimir" -gt "$NUM_FIL" ]; then
      filasImprimir=$NUM_FIL
    fi

    if [ "$columnasImprimir" -gt "$NUM_COL" ]; then
      columnasImprimir=$NUM_COL
    fi
  }

  # Asigna un estilo a la tabla, de doble linea, linea basica,
  # esquinas redondeadas, etc...
  # ----------------------------------
  function asignarEstiloDeTabla() {
    local simboloHorizontal

    estiloTabla=("${estiloGeneral[@]}")

    for ((i = 1; i <= anchoCelda; i++)); do
      simboloHorizontal+=${estiloTabla[0]}
    done

    encTabla=${estiloTabla[1]}$simboloHorizontal
    interTabla=${estiloTabla[2]}$simboloHorizontal
    pieTabla=${estiloTabla[3]}$simboloHorizontal

    for ((i = 1; i < columnasImprimir; i++)); do
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
      printf "%s" "$interTabla"
      printf "$(fc)\n%s" ""
      printf "${coloresTabla[$k]}%s" ""
      for ((j = 1; j <= columnasImprimir; j++)); do
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
  asignarAnchoYFilasYColumnas "$1" "$2"
  asignarEstiloDeTabla
  imprimir
}

# Centra en pantalla el valor pasado, si es un string, divide por saltos de
# linea y coloca cada linea en el centro
# @param string a centrar
# ----------------------------------
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

# Devuelve los datos extraidos del archivo de configuracion
# @param parametro a leer del config
# ----------------------------------
function extraerDeConfig() {
  local salida

  # Lee el config y devuelve la linea solicitada
  # ----------------------------------
  function leeConfig() {
    grep -o '".*"' "$configFile" | sed 's/"//g' | head -"$1" | tail -1
  }

  # Lee el config si es un array
  # ----------------------------------
  function leeConfigArray() {
    grep -o '".*"' "$configFile" | head -"$1" | tail -1 | tr -d ","
  }

  if [ "$1" == "introduccion" ]; then
    local salidaArray
    salida="$(leeConfigArray "1")"
    salida+=" "
    salida+="$(leeConfigArray "2")"

    declare -a "salidaArray=( $(echo "$salida" | tr '`$<>' '????') )"
    for ((i = 0; i < ${#salidaArray[@]}; i++)); do
      echo "${salidaArray[$i]}"
      if [ $((${#salidaArray[@]} / 2)) == "$i" ]; then
        echo " "
      fi
    done
  else
    case "$1" in
    error)
      salida=$(leeConfig "3")
      ;;
    acierto)
      salida=$(leeConfig "4")
      ;;
    advertencia)
      salida=$(leeConfig "5")
      ;;
    archivoSalida)
      salida=$(leeConfig "6")
      ;;
    archivoEntrada)
      salida=$(leeConfig "7")
      ;;
    esac

    echo "$salida"
  fi
}

# Main
# ----------------------------------
function main() {
  # Variables de titulos y mensaje, con función de máxima personalización
  local configFile
  configFile=$(dirname "$0")
  configFile+="/config.toml"

  local introduccion
  introduccion=$(extraerDeConfig "introduccion")
  local error
  error=$(extraerDeConfig "error")
  local acierto
  acierto=$(extraerDeConfig "acierto")
  local advertencia
  advertencia=$(extraerDeConfig "advertencia")
  local archivoSalida
  archivoSalida=$(extraerDeConfig "archivoSalida")
  local archivoEntrada
  archivoEntrada=$(extraerDeConfig "archivoEntrada")

  # Asignamos los tamaños de tabla tras saber datos a estudiar y número de procesos que quiere
  NUM_COL=5  # Fijo pues son los datos que se calculan, se puede cambiar esto si se implementan mas calculos
  NUM_FIL=6 # Fijo para desarrollo, cambiara con las distintas entradas de datos

  # Elegimos el estilo de los marcos en el programa
  asignarEstiloGeneral "2"

  # Imprime introducción
  centrarEnPantalla "$(imprimirCuadro "50" "random" "$introduccion")" | sacarHaciaArchivo "$archivoSalida"
  read -r -p "Pulsa enter para avanzar"

  # Imprime mensaje error
  centrarEnPantalla "$(imprimirCuadro "100" "error" "$error")" | sacarHaciaArchivo "$archivoSalida" -a

  # Imprime mensaje acierto
  centrarEnPantalla "$(imprimirCuadro "100" "acierto" "$acierto")" | sacarHaciaArchivo "$archivoSalida" -a

  # Imprime mensaje advertencia
  centrarEnPantalla "$(imprimirCuadro "100" "advertencia" "$advertencia")" | sacarHaciaArchivo "$archivoSalida" -a

  # Asigna los valores al array con datos aleatorios
  asignarValoresAleatorios "$NUM_FIL"

  # Asigna los valores desde el archivo
  # asignarDesdeArchivo "$archivoEntrada"

  # Asigna los datos del array de forma manual -> TODO

  # Ir imprimiendo las filas de la tabla según metemos los datos
  for ((fila = 1; fila <= NUM_FIL; fila++)); do
    clear
    centrarEnPantalla "$(imprimirTabla $fila "3")" | sacarHaciaArchivo "$archivoSalida" -a
    read -r -p "Pulsa enter para avanzar"
  done

  # Saca el resultado - TODO -> Algoritmo y uso de memoria medinate enter, calculo de tiempo medio, etc
  centrarEnPantalla "$(imprimirTabla "$NUM_FIL" "6")" | sacarHaciaArchivo "$archivoSalida" -a
}

main

# 1: Preguntar si quiere los datos de entrada por teclado, archivo o aleatorios, usando un menú junto a la introducción.
# 2.a: Si los quiere por teclado, comenzamos a introducirlos imprimiendo la tabla con cada dato.
# 2.b: Si los quiere de forma aleatoria, preguntamos cuantos procesos quiere generar.
# 3: Preguntamos si quiere tiempo real o acumulado.
# 4: Mostramos la tabla resultado en instante uno, asi como el uso de memoria.
# 5: Avanzamos hasta que acaba el ultimo instante.
# 6: Mostramos resumen y preguntamos si quiere ver el informe generado del ejercicio.
