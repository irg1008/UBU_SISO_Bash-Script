#!/bin/bash

# @title: FCFS - Según Necesidades - Memoria No Continua - Memoria No Reubicable
# @author: Iván Ruiz Gázquez <a>ivanaluubu@gmail.com</a>
# @version: 2019-2020
#
# El código se ha hecho de la forma más óptima para que la revisión del
# mismo sea lo más sencilla prosible, lo único que hay que hacer es ir bajando en las
# llamadas de las funciones para cambiar lo que se quiera. Se observará entonces que
# hay muchas variables que cambian la estética, como el tipo de marco, colores, etc.
# Esto es para testeo de distintas opciones pero si se quiere cambiar, se deja a gusto
# del siguiente programador :)
# pd:no hay variables globales, yihaaa!

######################## 1. ASIGNACION DE DATOS

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
      if [ "$i" == "2" ] || [ "$i" == "4" ]; then
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

######################## 2. MENU Y ENTRADA DE DATOS

# Funcion para elegir el tipo de entrada de datos
# @param archivo externo para la opcion de archivo
# ----------------------------------
function elegirTipoDeEntrada() {
  local tipo
  local opcionesEntrada
  opcionesEntrada=(
    "1.- Entrada manual por teclado"
    "2.- Entrada automática por archivo"
    "3.- Entrada automática con valores aleatorios"
    "4.- Ayuda"
    "0.- Salir"
  )

  centrarEnPantalla "$(imprimirCuadro "50" "default" "MENÚ PRINCIPAL")" | sacarHaciaArchivo "$archivoSalida" -a
  centrarEnPantalla "$(imprimirCuadro "50" "0" "${opcionesEntrada[@]}")" | sacarHaciaArchivo "$archivoSalida" -a
  read -r -p "-> " tipo

  while [[ ! "$tipo" =~ ^[0-4]+$ ]]; do
    centrarEnPantalla "$(imprimirCuadro "80" "error" "Inserta un valor numérico entre 0 y 4")"
    read -r -p "-> " tipo
  done

  # Funcion que imprime el tipo de asignacion al archivo,
  # para posterior conocimiento
  # ----------------------------------
  function guardaTipoEnArchivo() {
    centrarEnPantalla "$(imprimirCuadro "50" "6" "Asignación de datos $1")" >>"$archivoSalida"
  }

  case "$tipo" in
  1)
    guardaTipoEnArchivo "manual"
    asignarManual
    ;;
  2)
    guardaTipoEnArchivo "automática desde archivo"
    asignarDesdeArchivo "$1"
    ;;
  3)
    guardaTipoEnArchivo "aleatoria"
    asignarValoresAleatorios
    ;;
  4)
    imprimirAyuda
    ;;
  0)
    centrarEnPantalla "$(imprimirCuadro "60" "advertencia" "Ha salido del programa mediante el menú de opciones")" | sacarHaciaArchivo "$archivoSalida"
    exit 99
    ;;
  *)
    centrarEnPantalla "$(imprimirCuadro "100" "error" "Ha ocurrido algún tipo de error")" | sacarHaciaArchivo "$archivoSalida" -a
    exit 99
    ;;
  esac
}

# Asigna valores en el array de forma manual
# ----------------------------------
function asignarManual() {
  local masProcesos

  # Comprueba si la entrada pasada es un entero
  # @param Numero a comprobar
  # @param Minimo entero válido
  # ----------------------------------
  function entradaEsEntero() {
    if [[ "$1" =~ ^[$2-9]+$ ]]; then
      echo "true"
    fi
  }

  # Comprueba si la entrada pasada es un string valido
  # ----------------------------------
  function entradaEsStringValido() {
    if [[ "$1" =~ [A-Za-z] ]]; then
      echo "true"
    fi
  }

  # Imprime tabla limpia
  # ----------------------------------
  function comienzoPregunta() {
    clear
    centrarEnPantalla "$(imprimirCuadro "50" "6" "$2")"
    centrarEnPantalla "$(imprimirTabla "$1" "4")"
  }

  # Guarda el tamaño de la memoria
  # ----------------------------------
  function tamMemoria() {
    centrarEnPantalla "$(imprimirCuadro "50" "6" "Tamaño de la memoria")"
    read -r -p "-> " TAM_MEM

    while [[ $(entradaEsEntero "$TAM_MEM" "1") != "true" ]]; do
      centrarEnPantalla "$(imprimirCuadro "80" "error" "Valor de tamaño de memoria no válido, mayor que 0")"
      read -r -p "-> " TAM_MEM
    done
  }

  # Guarda el nombre del proceso i
  # ----------------------------------
  function guardarNombreDelProceso() {
    local nombre

    comienzoPregunta "$1" "Nombre del proceso $1"
    read -r -p "-> " nombre

    # Comprueba si el nombre esta repetido
    function estaRepetido() {
      local nombreRepetido="false"
      for ((i = 0; i < NUM_FIL; i++)); do
        if [ "$nombre" == "${array[1, $i]}" ]; then
          nombreRepetido="true"
        fi
      done

      echo "$nombreRepetido"
    }

    while [[ $(entradaEsStringValido "$nombre") != "true" ]] || [[ "$(estaRepetido)" == "true" ]]; do
      centrarEnPantalla "$(imprimirCuadro "80" "error" "Nombre del proceso erróneo, al menos una letra y no repetido")"
      read -r -p "-> " nombre
    done

    array[1, $1]="$nombre"
  }

  # Guarda el tiempo de llegada del proceso i
  # ----------------------------------
  function guardarLlegadaProceso() {
    local llegada

    comienzoPregunta "$1" "Llegada del proceso $1"
    read -r -p "-> " llegada

    while [[ $(entradaEsEntero "$llegada" "0") != "true" ]]; do
      centrarEnPantalla "$(imprimirCuadro "80" "error" "Valor de llegada del proceso no válido, entero 0 o mayor")"
      read -r -p "-> " llegada
    done

    array[2, $1]="$llegada"
  }

  # Guarda el tiempo de ejecucion del proceso i
  # ----------------------------------
  function guardarTiempoEjecucion() {
    local ejecucion

    comienzoPregunta "$1" "Tiempo ejecución proceso $1"
    read -r -p "-> " ejecucion

    while [[ $(entradaEsEntero "$ejecucion" "1") != "true" ]]; do
      centrarEnPantalla "$(imprimirCuadro "80" "error" "Valor de tiempo de ejecución no válido, entero mayor que 0")"
      read -r -p "-> " ejecucion
    done

    array[3, $1]="$ejecucion"
  }

  # Guarda el tiempo de ejecucion del proceso i
  # ----------------------------------
  function guardarTamMemoria() {
    local tam

    comienzoPregunta "$1" "Tamaño del proceso $1"
    read -r -p "-> " tam

    while [[ $(entradaEsEntero "$tam" "1") != "true" ]]; do
      centrarEnPantalla "$(imprimirCuadro "80" "error" "Valor de tiempo de tamaño no válido, entero mayor que 0")"
      read -r -p "-> " tam
    done

    array[4, $1]="$tam"
  }

  # Comprueba si queremos introducir más procesos
  # ----------------------------------
  function comprobarSiMasProcesos() {
    local temp

    comienzoPregunta "$1" "¿Quieres introducir otro proceso? [S/N]"
    read -r -p "-> " temp

    while [[ ! "$temp" =~ ^([sS][iI]|[sS]|[nN][oO]|[nN])$ ]]; do
      centrarEnPantalla "$(imprimirCuadro "80" "error" "Entrada de datos errónea")"
      read -r -p "-> " temp
    done

    if [[ $temp =~ [nN][oO]|[nN] ]]; then
      masProcesos="false"
    elif [[ $temp =~ [sS][iI]|[sS] ]]; then
      ((NUM_FIL++))
    fi
  }

  # Main de la asignación manual
  # ----------------------------------
  NUM_FIL="1"
  tamMemoria
  while [ "$masProcesos" != "false" ]; do
    guardarNombreDelProceso "$NUM_FIL"
    guardarLlegadaProceso "$NUM_FIL"
    guardarTiempoEjecucion "$NUM_FIL"
    guardarTamMemoria "$NUM_FIL"
    comprobarSiMasProcesos "$NUM_FIL"
  done
}

# Devuelve los datos del archivo de entrada en un array
# ----------------------------------
function asignarDesdeArchivo() {
  local archivo
  archivo=$(dirname "$0")
  archivo+="/$1"

  # Si hay algun error
  [ ! -f "$archivo" ] && {
    centrarEnPantalla "$(imprimirCuadro "100" "error" "Archivo no encontrado")" | sacarHaciaArchivo "$archivoSalida" -a
    avanzarAlgoritmo
    elegirTipoDeEntrada "$archivoEntrada"
  }

  # Leer todas las lineas y guardar los datos por columnas en el array
  # Valor -1 para saltarnos la primera linea
  local i
  i="-1"

  # Separador para leer datos
  IFS=","

  while read -r proceso llegada ejecucion tam; do

    if [ "$i" == "-1" ]; then
      TAM_MEM="$(cut -d "=" -f 2 <<<"$proceso")"
    elif [ "$i" -ge "1" ]; then
      array[1, $i]=$proceso
      array[2, $i]=$llegada
      array[3, $i]=$ejecucion
      array[4, $i]=$tam
    fi
    ((i++))
  done <"$archivo"

  # Leemos ultima linea
  array[1, $i]=$proceso
  array[2, $i]=$llegada
  array[3, $i]=$ejecucion
  array[4, $i]=$tam

  NUM_FIL="$((i))"
}

# Crea un array con valores aleatorio para fase desarrollo o entrada
# de datos automatica, (ni manual ni por archivo)
# @param Numero de filas a generar de manera aleatorio (num. proceos)
# ----------------------------------
function asignarValoresAleatorios() {
  local numValAleatorios

  # Tamaño de memoria aleatorio
  TAM_MEM=$(((RANDOM % 20) + 1))

  clear
  centrarEnPantalla "$(imprimirCuadro "50" "6" "¿Cuántos valores aleatorios quieres generar?")" | sacarHaciaArchivo "$archivoSalida" -a
  read -r -p "-> " numValAleatorios

  while [[ ! "$numValAleatorios" =~ ^[0-9]+$ || "$numValAleatorios" -lt "1" || "$numValAleatorios" -gt "100" ]]; do
    centrarEnPantalla "$(imprimirCuadro "80" "error" "Inserta un valor numérico entre 1 y 100, recomendamos menos de 30")"
    read -r -p "-> " numValAleatorios
  done

  NUM_FIL=$numValAleatorios

  # Solo ponemos aleatorios los 4 primeros atributos, que son los que meteria el usuario por teclado
  for ((i = 1; i <= 4; i++)); do
    for ((j = 1; j <= NUM_FIL; j++)); do
      case "$i" in
      1)
        array[$i, $j]="P"${j}
        ;;
      2)
        array[$i, $j]=$((RANDOM % 20)) # 0-20
        ;;
      *)
        array[$i, $j]=$(((RANDOM % 20) + 1)) # 1-20
        ;;
      esac
    done
  done
}

# Ayuda del algoritmo
# ----------------------------------
function imprimirAyuda() {
  local ayuda
  ayuda=(
    "El algoritmo de FCFS según necesidades con memoria no continua y no reubicable funciona tal que...
    Se pueden insertar los valores desde...
    Puedes elegir tiempo de... que hará...
    Si tienes alguna duda más consulta el manual externo"
  )

  clear
  centrarEnPantalla "$(imprimirCuadro "50" "default" "AYUDA")" | sacarHaciaArchivo "$archivoSalida" -a
  centrarEnPantalla "$(imprimirCuadro "150" "random" "${ayuda[@]}")" | sacarHaciaArchivo "$archivoSalida" -a
  read -r -p "$(centrarEnPantalla "$(imprimirCuadro "50" "default" "Pulsa intro para volver al menú")")"
  clear
  elegirTipoDeEntrada "$archivoEntrada"
}

# Elige el tipo de tiempo del algoritmo
# ----------------------------------
function elegirTipoDeTiempo() {
  local tiempo
  local tipoTiempo
  tipoTiempo=(
    "1.- Tiempo Real
    2.- Tiempo Acumulado"
  )

  clear
  centrarEnPantalla "$(imprimirCuadro "50" "default" "TIPO DE TIEMPO")" | sacarHaciaArchivo "$archivoSalida" -a
  centrarEnPantalla "$(imprimirCuadro "50" "0" "${tipoTiempo[@]}")" | sacarHaciaArchivo "$archivoSalida" -a
  read -r -p "-> " tiempo

  while [[ ! "$tiempo" =~ ^[1-2]+$ ]]; do
    centrarEnPantalla "$(imprimirCuadro "80" "error" "Inserta un valor numérico entre 1 y 2")"
    read -r -p "-> " tiempo
  done

  case "$tiempo" in
  1)
    tipoDeTiempo="real"
    ;;
  2)
    tipoDeTiempo="acumulado"
    ;;
  *)
    centrarEnPantalla "$(imprimirCuadro "100" "error" "Ha ocurrido algún tipo de error")" | sacarHaciaArchivo "$archivoSalida" -a
    exit 99
    ;;
  esac
}

######################## 3. ALGORITMO
# Imprime el uso de la memoria según los procesos en ella
# ----------------------------------
function imprimirMemoria() {
  local colorVacio
  local -A coloresMemoria
  local procesosEnMemoria

  # Asigna el número de procesos en memoria
  # ----------------------------------
  function asignarNumProcesos() {
    procesosEnMemoria="6"
  }

  # Guarda los colores aleatorio de la memoria
  # ----------------------------------
  function asignarColores() {
    colorVacio="$(cc Neg error)"
    for ((i = 1; i <= procesosEnMemoria; i++)); do
      coloresMemoria[$i]=$(cc Neg "$((i + 4))")
    done
  }

  # Imprime cuadro de memoria
  # ----------------------------------
  function imprimir() {
    # TODO -> Entender como hacer esto bien
    for ((i = 1; i <= procesosEnMemoria; i++)); do
      printf "${coloresMemoria[$i]}%s$(fc)" " P${i} "
    done
    printf "$colorVacio%s$(fc)" " Vacio "
  }

  # Main de cuadro de memoria
  # ----------------------------------
  asignarNumProcesos
  asignarColores
  imprimir
}

# Calcula el numero de instantes que tendrá el programa
function calcularNumInstantes() {
  local -i num

  for ((i=1; i<=NUM_FIL; i++));do
    num+=${array[3, $i]}
  done

  echo "$num"
}

######################## 4. OTRAS FUNCIONES UTILES USADAS EN TODO EL PROGRAMA

# Saca la información del comando que acompaña
# @param "-a" para append
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
# @param String del que queremos calcular la longitud
# ----------------------------------
function calcularLongitud() {
  local elementoArray # Elemento a ser centrado
  elementoArray=$1
  echo ${#elementoArray}
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
  local anchoCuadro
  local color

  # Asigna un estilo a la tabla, de doble linea, linea basica,
  # esquinas redondeadas, etc...
  # ----------------------------------
  function asignarEstiloCuadro() {
    local simboloHorizontal

    estilo=("${estiloGeneral[@]}")

    for ((i = 1; i <= anchoCuadro; i++)); do
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
    anchoCuadro="$1"

    if [ "$((anchoCuadro % 2))" == "1" ]; then
      ((anchoCuadro++))
    fi
  }

  # Imprime los elementos del array
  # ----------------------------------
  function imprimirTitulos() {

    IFS=$'\n' titulos=($@)
    local longitudArray # Para centrar en la tabla

    for ((i = 2; i < ${#titulos[@]}; i++)); do
      longitudArray=$(calcularLongitud "${titulos[$i]}")
      printf "$color%s" ""
      printf "${estilo[10]}%-*s" "$((anchoCuadro / 2 - longitudArray / 2))" ""
      printf "%s" "${titulos[$i]}" ""
      printf "%*s${estilo[10]}" "$((anchoCuadro / 2 - (longitudArray + 1) / 2))" ""
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

  # Main de cuadro
  # ----------------------------------
  asignarAncho "$1"
  asignacolor "$2"
  asignarEstiloCuadro
  imprimir "$@"
}

# Imprime una tabla según el tamaño del array de datos
# @param numeroFilasImprimir
# @param numeroColumnasImprimir
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

  # Asigna el titulo de la tabla
  # ----------------------------------
  function asignarTitulosYNumCol() {
    titulos=("Proceso" "Llegada" "Ejecución" "Tamaño" "Estado" "Respuesta" "Espera" "Restante")
  }

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
        coloresTabla[$i]=$(cc Neg "$((i + 4))")
      done
    fi
  }

  # Imprime los titulos de las columnas de datos
  # ----------------------------------
  function imprimirTitulos() {
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
    local longitudElemento
    filasImprimir="$1"
    columnasImprimir="$2"
    anchoCelda="12"

    if [ "$filasImprimir" -gt "$NUM_FIL" ]; then
      filasImprimir="$NUM_FIL"
    fi

    if [ "$columnasImprimir" -gt "$NUM_COL" ]; then
      columnasImprimir="$NUM_COL"
    fi

    for ((i = 1; i <= columnasImprimir; i++)); do
      for ((j = 1; j <= filasImprimir; j++)); do
        longitudElemento=$(calcularLongitud "${array[$i, $j]}")
        if [[ "$anchoCelda" -lt "$longitudElemento" ]]; then
          anchoCelda="$longitudElemento"
        fi
      done
    done

    if [ "$((anchoCelda % 2))" == "1" ]; then
      ((anchoCelda++))
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
  asignarTitulosYNumCol
  guardarColoresDeTabla
  asignarAnchoYFilasYColumnas "$1" "$2"
  asignarEstiloDeTabla
  imprimir
}

# Ordena el array según tiempo de llegada para mostrar la tabla
# ------------------------------------------------
function ordenarArray() {

  # Funcion que mueve la fila completa por la siguiente
  # ------------------------------------------------
  function moverFilaCompleta() {
    local temp

    for ((col = 1; col <= NUM_COL; col++)); do
      temp="${array[$col, $1]}"
      array[$col, $1]="${array[$col, $(($1 + 1))]}"
      array[$col, $(($1 + 1))]="$temp"
    done
  }

  # Ejecuta el algoritmo burbuja
  # ------------------------------------------------
  function burbuja() {
    local tempOrigen
    local tempDestino

    for ((i = 1; i <= NUM_FIL; i++)); do
      for ((j = 1; j < NUM_FIL; j++)); do
        tempOrigen="${array[2, $j]}"
        tempDestino="${array[2, $((j + 1))]}"

        if [ "$tempOrigen" -gt "$tempDestino" ]; then
          moverFilaCompleta "$j"
        fi
      done
    done
  }

  burbuja
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

  echo ""

  IFS=$'\n' string=($1)
  termwidth="$(tput cols)"
  padding="$(printf '%0.1s' ' '{1..500})"
  longitudElemento=$(calcularLongitud "${string[0]}")

  for ((i = 0; i < ${#string[@]}; i++)); do
    printf "%*.*s %s %*.*s\n" 0 "$(((termwidth - 2 - longitudElemento) / 2))" "$padding" "${string[$i]}" 0 "$(((termwidth - 1 - longitudElemento) / 2))" "$padding"
  done
}

# Funcion basica de avance de algoritmo
# ----------------------------------
function avanzarAlgoritmo() {
  # Pulsar tecla para avanzar al menu
  printf "%s\n\n\n" ""
  read -r -p "$(centrarEnPantalla "$(imprimirCuadro "50" "default" "Pulsa intro para avanzar")")"
  clear
}

######################## Main
# Main, eje central del algoritmo, única llamada en cuerpo
# ----------------------------------
function main() {
  # Variables globales de subfunciones
  # ----------------------------------
  declare estiloGeneral
  declare tipoDeTiempo
  declare -A array
  declare NUM_COL
  declare NUM_FIL
  declare TAM_MEM
  # Variables locales
  # ----------------------------------
  local configFile
  local introduccion
  local error
  local acierto
  local advertencia
  local archivoSalida
  local archivoEntrada
  local salirDePractica

  # Extraccion de variables del archivo de config
  # ------------------------------------------------
  function asignaciones() {
    configFile=$(dirname "$0")
    configFile+="/config.toml"
    introduccion=$(extraerDeConfig "introduccion")
    error=$(extraerDeConfig "error")
    acierto=$(extraerDeConfig "acierto")
    advertencia=$(extraerDeConfig "advertencia")
    archivoSalida=$(extraerDeConfig "archivoSalida")
    archivoEntrada=$(extraerDeConfig "archivoEntrada")
    # Elegimos el estilo de los marcos en el programa [1-3]
    asignarEstiloGeneral "2"
    # Asignamos el valor al numero de columnas, o titulos de la tabla. TODO-> mejorar esto asignando automaticamente
    NUM_COL="8"
  }
  # ------------------------------------------------

  # Introduccion
  # ------------------------------------------------
  function introduccion() {
    # Imprime introducción
    centrarEnPantalla "$(imprimirCuadro "50" "0" "$introduccion")" | sacarHaciaArchivo "$archivoSalida"
    # Imprime mensaje advertencia
    centrarEnPantalla "$(imprimirCuadro "100" "advertencia" "$advertencia")" | sacarHaciaArchivo "$archivoSalida" -a
    # Imprime mensaje error
    centrarEnPantalla "$(imprimirCuadro "100" "error" "$error")" | sacarHaciaArchivo "$archivoSalida" -a
    # Avanza de fase
    avanzarAlgoritmo
  }
  # ------------------------------------------------

  # Elección menú, entrada de datos y tipo de tiempo
  # ------------------------------------------------
  function menu() {
    elegirTipoDeEntrada "$archivoEntrada"
    elegirTipoDeTiempo
  }
  # ------------------------------------------------

  # Ejecuta Algoritmo
  # ------------------------------------------------
  function algoritmo() {
    # Imprime una cabecera muy simple
    # ------------------------------------------------
    function algCabecera() {
      clear
      centrarEnPantalla "$(imprimirCuadro "100" "acierto" "$acierto")" | sacarHaciaArchivo "$archivoSalida" -a
    }

    # Calcula los siguientes datos a mostrar
    # ------------------------------------------------
    function algCalcularSigIns() {
      centrarEnPantalla "$(imprimirCuadro "100" "3" "Instante $1 - Tamaño de memoria: $TAM_MEM")" | sacarHaciaArchivo "$archivoSalida" -a
    }

    # Funcion que calcula el tiempo y estado de todos los proceos en cada instante,
    # sirve para saber como colcarlos en memoria y calcular el tiempo medio final
    # ------------------------------------------------
    function algCalcularDatos() {
      # TODO -> Llamar a las funciones externas de forma ordenada
      echo "$tipoDeTiempo" >>res.log
    }

    # Imprime el dibujo de la tabla
    # ------------------------------------------------
    function algImprimirTabla() {
      centrarEnPantalla "$(imprimirCuadro "25" "default" "TABLA DE PROCESOS")" | sacarHaciaArchivo "$archivoSalida" -a
      centrarEnPantalla "$(imprimirTabla "$NUM_FIL" "10")" | sacarHaciaArchivo "$archivoSalida" -a
    }

    # Imprime la linea de tiempo
    # ------------------------------------------------
    function algImprimirLineaTiempo() {
      printf "\n\n%s" ""
      centrarEnPantalla "$(imprimirCuadro "25" "default" "LINEA DE TIEMPO")" | sacarHaciaArchivo "$archivoSalida" -a
      # TODO -> Llamada externa
    }

    # Imprime el dibujo de la memoria
    # ------------------------------------------------
    function algImprimirMemoria() {
      printf "\n\n%s" ""
      centrarEnPantalla "$(imprimirCuadro "25" "default" "USO DE MEMORIA")" | sacarHaciaArchivo "$archivoSalida" -a
      centrarEnPantalla "$(imprimirMemoria)" | sacarHaciaArchivo "$archivoSalida" -a
      # TODO -> Terminar esto
    }

    # Main de las llamadas de la parte de calculo de algoritmo
    # ------------------------------------------------
    ordenarArray
    for ((instante = 0; instante <= $(calcularNumInstantes); instante++)); do
      algCabecera
      algCalcularSigIns "$instante"
      algCalcularDatos
      algImprimirTabla
      algImprimirLineaTiempo
      algImprimirMemoria
      algAvanzarAlgoritmo
    done
  }
  # ------------------------------------------------

  # Pregunta al usuario si quiere salir del programa
  # ------------------------------------------------
  function preguntarSiQuiereInforme() {
    local temp

    clear
    centrarEnPantalla "$(imprimirCuadro "50" "default" "¿Quieres ver el informe? [S/N]")"
    read -r -p "-> " temp

    while [[ ! "$temp" =~ ^([sS][iI]|[sS]|[nN][oO]|[nN])$ ]]; do
      centrarEnPantalla "$(imprimirCuadro "80" "error" "Entrada de datos errónea")"
      read -r -p "-> " temp
    done

    if [[ $temp =~ [sS][iI]|[sS] ]]; then
      cat "$archivoSalida"
      avanzarAlgoritmo
    fi
  }
  # ------------------------------------------------

  # Pregunta al usuario si quiere sacar el informe
  # ------------------------------------------------
  function preguntarSiQuiereSalir() {
    local temp

    clear
    centrarEnPantalla "$(imprimirCuadro "50" "default" "¿Quieres volver a ejecutar el algoritmo? [S/N]")"
    read -r -p "-> " temp

    while [[ ! "$temp" =~ ^([sS][iI]|[sS]|[nN][oO]|[nN])$ ]]; do
      centrarEnPantalla "$(imprimirCuadro "80" "error" "Entrada de datos errónea")"
      read -r -p "-> " temp
    done

    if [[ $temp =~ [nN][oO]|[nN] ]]; then
      salirDePractica="true"
      centrarEnPantalla "$(imprimirCuadro "100" "acierto" "¡Gracias por usar nuestro algoritmo! Visita nuestro repo aquí abajo")" | sacarHaciaArchivo "$archivoSalida"
    elif [[ "$temp" =~ [sS][iI]|[sS] ]]; then
      array=()
    fi
  }
  # ------------------------------------------------

  # Saca spam
  # ------------------------------------------------
  function imprimirSpam() {
    local spam
    spam="
 ▄▄▄▄▄▄▄   ▄ ▄▄▄▄   ▄▄  ▄▄ ▄▄▄▄▄▄▄
 █ ▄▄▄ █ ▀ ▀ ▄█▀█▀ █ ▀▄█▄▀ █ ▄▄▄ █
 █ ███ █ ▀█▀ ▀ ▀█▄▀ █▄▄█▄  █ ███ █
 █▄▄▄▄▄█ █▀▄▀█ ▄ ▄ ▄ ▄ ▄ ▄ █▄▄▄▄▄█
 ▄▄▄▄▄ ▄▄▄█▀█  ▀ █▄█▀▄▀█ ▄▄ ▄ ▄ ▄ 
 ▀▄▄ ▀▄▄▄▄ █ ▀███▄█▀▀█▄ ▀▄ ▀▄▄▄▀█▀
 █▀██ ▄▄ ▄▄▄ █▀▄█ ▄ ▀ ▀█ ▄█▀▄█▄▀  
 █▄█ █ ▄ ██▄▄▄  ▀▀  ▀█▀▀  ▄██▄  █▀
 ▄▄▀▄██▄▄█▄▀█  ▀ ▀▄▀▀▄▀█  █▀█▄ ▀▄ 
  ▀▄▀▄█▄█ █▀ ▀███ ▄▄▀█ ▄▀▄▄█  █ █▀
 ▄▄▄  ▀▄█ █▀ █▀▄ ▀▄▀▄▀▀██▄▀  ▄ ▀▄ 
 █ █  █▄▄▀██▄▄  ▄█ ▀▀ █▀▀ ▄█▄ █ █▀
 █ ▄███▄▀█ ▄█  ▀█ ▄ ▄ ▀  █████▀▀ ▄
 ▄▄▄▄▄▄▄ █▀█ ▀██▄▀ ▀▀█▄▄▄█ ▄ ██▀▄▀
 █ ▄▄▄ █ ▄█▄ █▀▄▄█▄▄▀▄▀█▀█▄▄▄█▀▀█▀
 █ ███ █ █ █▄▄  ▄██▀▀█▀ ▄▄▀▄▀▀▄▄▀▀
 █▄▄▄▄▄█ █▄▄█  ▀▀     ▀▄█▄▄▀▀ █▀▄ 
    "

    centrarEnPantalla "$(imprimirCuadro "38" "default" "$spam")" | sacarHaciaArchivo "$archivoSalida"
  }
  # ------------------------------------------------

  # Main de main xD
  # ------------------------------------------------
  clear
  asignaciones
  introduccion
  while [[ "$salirDePractica" != "true" ]]; do
    menu
    algoritmo
    preguntarSiQuiereInforme
    preguntarSiQuiereSalir
  done
  imprimirSpam
}

main
