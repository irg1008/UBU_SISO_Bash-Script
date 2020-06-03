#!/bin/bash

# @title FCFS - Según Necesidades - Memoria No Continua - Memoria No Reubicable
# @author Iván Ruiz Gázquez <a>ivanaluubu@gmail.com</a>
# @version 2019-2020
#
# El código se ha hecho de la forma más óptima para que la revisión del
# mismo sea lo más sencilla prosible, lo único que hay que hacer es ir bajando en las
# llamadas de las funciones para cambiar lo que se quiera. Se observará entonces que
# hay muchas variables que cambian la estética, como el tipo de marco, colores, etc.
# Esto es para testeo de distintas opciones pero si se quiere cambiar, se deja a gusto
# del siguiente programador :)
# pd:no hay variables globales, yihaaa! +-
#
# Consejo útil, en VSCODE usa ctr + k + 0 para hacer collapse de las funciones
# y ctr + k + j para hacer expand

######################## 1. ASIGNACION DE DATOS

# Almacen de los estilos de las tablas con sus códigos ASCII
# @param Numero de estilo
# ----------------------------------
function asignarEstiloGeneral() {
  local estilo1=("═" "╔" "╠" "╚" "╦" "╬" "╩" "╗" "╣" "╝" "║")
  local estilo2=("─" "╭" "├" "╰" "┬" "┼" "┴" "╮" "┤" "╯" "│")
  local estilo3=("━" "┏" "┣" "┗" "┳" "╋" "┻" "┓" "┫" "┛" "┃")
  local estilo4=("─" "┌" "├" "└" "┬" "┼" "┴" "┐" "┤" "┘" "│")

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
  4)
    estiloGeneral=("${estilo4[@]}")
    ;;
  *)
    estiloGeneral=("${estilo4[@]}")
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
    salida+=" "
    salida+="$(leeConfigArray "3")"

    declare -a "salidaArray=( $(echo "$salida" | tr '`$<>' '????') )"
    for ((i = 0; i < ${#salidaArray[@]}; i++)); do
      echo "${salidaArray[$i]}"
      if [[ "$i" == "2" || "$i" == "3" ]]; then
        echo " "
      fi
    done
  else
    case "$1" in
    error)
      salida=$(leeConfig "4")
      ;;
    acierto)
      salida=$(leeConfig "5")
      ;;
    advertencia)
      salida=$(leeConfig "6")
      ;;
    archivoSalida)
      salida=$(leeConfig "7")
      ;;
    archivoSalidaBN)
      salida=$(leeConfig "8")
      ;;
    archivoEntrada)
      salida=$(leeConfig "9")
      ;;
    esac

    echo "$salida"
  fi
}

######################## 2. MENU Y ENTRADA DE DATOS

# Funcion tipo de entrada de datos comun a todas las peticiones del programa
# ----------------------------------
function recibirEntrada() {
  local mensaje
  mensaje="$(printf "$(cc Neg blanco)%15s$(fc)" "Respuesta: ")"

  read -r -p "$mensaje "
  echo "$REPLY"
}

# Funcion que elimina las lineas de datos no validas.
# Estas son las que tienen procesos cuyo tamaño es mayor a la memoria.
# ----------------------------------
function eliminarProcesosNoValidos() {

  # Funcion que mueve la fila completa por la siguiente
  # ----------------------------------
  function eliminarFila() {
    for ((fil = "$1"; fil < NUM_FIL; fil++)); do
      for ((col = 1; col <= NUM_COL; col++)); do
        array[$col, $fil]="${array[$col, $((fil + 1))]}"
      done
    done
  }

  # Imprime el mensaje con el dato pasado
  # ----------------------------------
  function mensaje() {
    printf "La fila de datos %s  no ha podido añadirse\nporque algun dato es inválido" "$1"
  }

  # Devuelve true si alguna linea de procesos esta vacia
  # @param Linea a comprobar
  # @return Si la linea tiene algun dato vacio.
  # ----------------------------------
  function procesoEstaVacio() {
    local lineaAlgoVacia="false"

    for ((col = 2; col <= 4; col++)); do
      if [ "${array[$col, $1]}" == "" ]; then
        lineaAlgoVacia="true"
      fi
    done

    echo "$lineaAlgoVacia"
  }

  # Ejecuta el algoritmo burbuja
  # ----------------------------------
  function eliminarNoValido() {
    for ((i = 1; i <= NUM_FIL; i++)); do
      if [[ "${array[$PROC_TAM, $i]}" -gt "$MEM_TAM" || "$(procesoEstaVacio "$i")" == "true" ]]; then
        eliminarFila "$i"
        if [[ "$(procesoEstaVacio "$i")" != "true" ]]; then
          centrarEnPantalla "$(imprimirCuadro "50" "advertencia" "$(mensaje "$i")")" "n" >>"$archivoSalida"
        fi
        ((NUM_FIL--))
      fi
    done
  }

  eliminarNoValido
}

# Asigna los colores usados en todo el algoritmo
# @param Desde una posicion(n) o desde el principio("")
# ----------------------------------
function asignarColores() {
  local -i pos="1"
  local -i posFinal="$NUM_FIL"

  if [[ "$1" != "" ]]; then
    pos="$1"
    posFinal="$1"
  fi

  for ((i = pos; i <= posFinal; i++)); do
    serieColores[$i]=$(cc Nor "$((i + 4))")
    serieColores_FG[$i]=$(cc Nor "$((i + 4))" "fg")
  done
}

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

  centrarEnPantalla "$(imprimirCuadro "50" "default" "MENÚ PRINCIPAL")" "n" | sacarHaciaArchivo "$archivoSalida" -a
  centrarEnPantalla "$(imprimirCuadro "50" "default" "${opcionesEntrada[@]}")" "n" | sacarHaciaArchivo "$archivoSalida" -a
  tipo=$(recibirEntrada)

  while [[ ! "$tipo" =~ ^[0-4]$ ]]; do
    printf "\n"
    centrarEnPantalla "$(imprimirCuadro "50" "error" "Inserta un valor numérico entre 0 y 4")" "n"
    tipo=$(recibirEntrada)
  done

  # Funcion que imprime el tipo de asignacion al archivo,
  # para posterior conocimiento
  # ----------------------------------
  function guardaTipoEnArchivo() {
    centrarEnPantalla "$(imprimirCuadro "50" "blanco" "Asignación de datos $1")" "n" >>"$archivoSalida"
  }

  # Funcion que vuelca los datos nuevos al archivo para su posterior reutilización
  # @param Archivo
  # ----------------------------------
  function volcarDatosHaciaArchivo() {
    printf "Memoria=%s" "$MEM_TAM" >"$1"
    printf "\nLlegada,Ejecución,Tamaño" >>"$1"
    for ((i = 1; i <= NUM_FIL; i++)); do
      printf "\n%s,%s,%s" "${array[2, $i]}" "${array[3, $i]}" "${array[4, $i]}" >>"$1"
    done

  }

  case "$tipo" in
  1)
    guardaTipoEnArchivo "manual"
    asignarManual
    volcarDatosHaciaArchivo "$1"
    ;;
  2)
    guardaTipoEnArchivo "automática desde archivo"
    asignarDesdeArchivo "$1"
    eliminarProcesosNoValidos
    colocarNombreAProcesos
    asignarColores
    ;;
  3)
    guardaTipoEnArchivo "aleatoria"
    asignarValoresAleatorios
    volcarDatosHaciaArchivo "$1"
    colocarNombreAProcesos
    asignarColores
    ;;
  4)
    imprimirAyuda
    ;;
  0)
    printf "\n"
    centrarEnPantalla "$(imprimirCuadro "50" "advertencia" "$(printf "Ha salido del programa\nmediante el menú de opciones")")" "n" | sacarHaciaArchivo "$archivoSalida"
    exit 99
    ;;
  *)
    printf "\n"
    centrarEnPantalla "$(imprimirCuadro "50" "error" "Ha ocurrido algún tipo de error")" "n" | sacarHaciaArchivo "$archivoSalida" -a
    exit 99
    ;;
  esac
}

# Funcion que pone los nombres a los procesos con el estándar pedido
# ----------------------------------
function colocarNombreAProcesos() {
  for ((j = 1; j <= NUM_FIL; j++)); do
    if [[ "$j" -lt "10" ]]; then
      array[$PROC_NUM, $j]="P0"${j}
    else
      array[$PROC_NUM, $j]="P"${j}
    fi
  done
}

# Asigna valores en el array de forma manual
# ----------------------------------
function asignarManual() {
  local masProcesos

  # Comprueba si la entrada pasada es entero
  # @param Numero a comprobar
  # @param Minimo entero válido
  # ----------------------------------
  function entradaEsEntero() {
    if [[ "$1" =~ ^[0-9]+$ ]] && [[ "$1" -ge "$2" ]]; then
      echo "true"
    fi
  }

  # Imprime tabla limpia
  # ----------------------------------
  function comienzoPregunta() {
    clear
    centrarEnPantalla "$(imprimirCuadro "50" "blanco" "$1")" "n" | sacarHaciaArchivo "$archivoSalida" -a
    centrarEnPantalla "$(imprimirTabla "4" "1")" "n" | sacarHaciaArchivo "$archivoSalida" -a
  }

  # Guarda el tamaño de la memoria
  # ----------------------------------
  function tamMemoria() {
    local memTemp

    clear
    centrarEnPantalla "$(imprimirCuadro "50" "blanco" "Tamaño de la memoria")" "n"
    memTemp=$(recibirEntrada)

    while [[ $(entradaEsEntero "$memTemp" "1") != "true" ]]; do
      printf "\n"
      centrarEnPantalla "$(imprimirCuadro "50" "error" "$(printf "Valor de tamaño de memoria no\nválido, mayor o igual que 1")")" "n"
      memTemp=$(recibirEntrada)
    done

    MEM_TAM="$memTemp"
  }

  # Coloca el nombre al proceso intrducido
  # ----------------------------------
  function colocarNombreAlProceso() {
    if [[ "$1" -lt "10" ]]; then
      array[$PROC_NUM, $1]="P0"${1}
    else
      array[$PROC_NUM, $1]="P"${1}
    fi
  }

  # Guarda el tiempo de llegada del proceso i
  # ----------------------------------
  function guardarLlegadaProceso() {
    local llegada

    comienzoPregunta "Llegada del proceso $1"
    llegada=$(recibirEntrada)

    while [[ $(entradaEsEntero "$llegada" "0") != "true" ]]; do
      printf "\n"
      centrarEnPantalla "$(imprimirCuadro "50" "error" "$(printf "Valor de llegada del proceso\nno válido, entero 1 o mayor")")" "n"
      llegada=$(recibirEntrada)
    done

    array[$PROC_LLE, $1]="$llegada"
  }

  # Guarda el tiempo de ejecucion del proceso i
  # ----------------------------------
  function guardarTiempoEjecucion() {
    local ejecucion

    comienzoPregunta "Tiempo ejecución proceso $1"
    ejecucion=$(recibirEntrada)

    while [[ $(entradaEsEntero "$ejecucion" "1") != "true" ]]; do
      printf "\n"
      centrarEnPantalla "$(imprimirCuadro "50" "error" "$(printf "Valor de tiempo de ejecución\nno válido, entero mayor que 0")")" "n"
      ejecucion=$(recibirEntrada)
    done

    array[$PROC_EJE, $1]="$ejecucion"
  }

  # Guarda el tiempo de ejecucion del proceso i
  # ----------------------------------
  function guardarTamMemoria() {
    local tam
    local mensaje1=(
      "¡El tamaño del proceso es mayor"
      "que la memoria! No podrá ejecutarse"
    )
    local mensaje2=(
      "Valor de tiempo de tamaño no"
      "válido, entero mayor que 0"
    )

    comienzoPregunta "Tamaño del proceso $1 - (Memoria: $MEM_TAM)"
    tam=$(recibirEntrada)

    while [[ $(entradaEsEntero "$tam" "1") != "true" || "$tam" -gt "$MEM_TAM" ]]; do
      if [[ "$tam" -gt "$MEM_TAM" ]]; then
        printf "\n"
        centrarEnPantalla "$(imprimirCuadro "50" "error" "${mensaje1[@]}")" "n"
      else
        printf "\n"
        centrarEnPantalla "$(imprimirCuadro "50" "error" "${mensaje2[@]}")" "n"
      fi
      tam=$(recibirEntrada)
    done

    array[$PROC_TAM, $1]="$tam"
  }

  # Comprueba si queremos introducir más procesos
  # ----------------------------------
  function comprobarSiMasProcesos() {
    local temp

    comienzoPregunta "¿Quieres introducir otro proceso? [S/N]"
    temp=$(recibirEntrada)

    while [[ ! "$temp" =~ ^([sS][iI]|[sS]|[nN][oO]|[nN])$ ]]; do
      printf "\n"
      centrarEnPantalla "$(imprimirCuadro "50" "error" "Entrada de datos errónea")" "n"
      temp=$(recibirEntrada)
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
  while [[ "$masProcesos" != "false" && "$NUM_FIL" -lt "100" ]]; do
    asignarColores "$NUM_FIL"
    colocarNombreAlProceso "$NUM_FIL"
    guardarLlegadaProceso "$NUM_FIL"
    guardarTiempoEjecucion "$NUM_FIL"
    guardarTamMemoria "$NUM_FIL"
    ordenarArray -c
    comprobarSiMasProcesos
  done
}

# Devuelve los datos del archivo de entrada en un array
# ----------------------------------
function asignarDesdeArchivo() {
  local archivo
  archivo+="$1"

  # Si hay algun error
  [ ! -f "$archivo" ] && {
    clear
    printf "\n"
    centrarEnPantalla "$(imprimirCuadro "50" "error" "Archivo no encontrado")" "n" | sacarHaciaArchivo "$archivoSalida" -a
    avanzarAlgoritmo
    elegirTipoDeEntrada "$archivoEntrada"
  }

  # Leer todas las lineas y guardar los datos por columnas en el array
  # Valor -1 para saltarnos la primera linea
  local i
  i="-1"

  # Separador para leer datos
  IFS=","

  while read -r llegada ejecucion tam; do

    if [ "$i" == "-1" ]; then
      MEM_TAM="$(cut -d "=" -f 2 <<<"$llegada")"
    elif [[ "$i" -ge "1" && "$i" -lt "100" ]]; then
      array[$PROC_LLE, $i]=$llegada
      array[$PROC_EJE, $i]=$ejecucion
      array[$PROC_TAM, $i]=$tam
    fi
    ((i++))
  done <"$archivo"

  # Leemos ultima linea
  array[$PROC_LLE, $i]=$llegada
  array[$PROC_EJE, $i]=$ejecucion
  array[$PROC_TAM, $i]=$tam

  NUM_FIL="$((i))"
}

# Crea un array con valores aleatorio para fase desarrollo o entrada
# de datos automatica, (ni manual ni por archivo)
# @param Numero de filas a generar de manera aleatorio (num. proceos)
# ----------------------------------
function asignarValoresAleatorios() {
  local numValAleatorios

  # Tamaño de memoria aleatorio
  MEM_TAM=$(((RANDOM % 40) + 5)) # 5-20

  clear
  centrarEnPantalla "$(imprimirCuadro "50" "blanco" "¿Cuántos valores aleatorios quieres generar?")" "n"
  numValAleatorios=$(recibirEntrada)

  while [[ ! "$numValAleatorios" =~ ^[0-9]+$ || "$numValAleatorios" -lt "1" || "$numValAleatorios" -ge "100" ]]; do
    printf "\n"
    centrarEnPantalla "$(imprimirCuadro "50" "error" "$(printf "Inserta un valor numérico entre\n1 y 99, recomendamos menos de 30")")" "n"
    numValAleatorios=$(recibirEntrada)
  done

  NUM_FIL=$numValAleatorios

  # Solo ponemos aleatorios los 4 primeros atributos, que son los que meteria el usuario por teclado
  for ((i = 2; i <= 4; i++)); do
    for ((j = 1; j <= NUM_FIL; j++)); do
      case "$i" in
      2)
        array[$i, $j]=$(((RANDOM % 20) + 0))
        ;;
      4)
        array[$i, $j]=$(((RANDOM % MEM_TAM) + 1)) # Tamaño
        ;;
      *)
        array[$i, $j]=$(((RANDOM % 20) + 1))
        ;;
      esac
    done
  done
}

# Ayuda del algoritmo
# ----------------------------------
function imprimirAyuda() {
  local ayuda
  local funciona
  funciona=(
    "Algoritmo FCFS según necesidades" " memoria no reubicable memoria no continua"
    " "
    "Este algoritmo funciona introduciendo los procesos" " en CPU según el orden de llegada de los mismos."
    "Se ejecutarán los procesos siempre que entren en" " memoria, en caso contrario no serán planteados."
  )
  ayuda=(
    "Puedes introducir los datos de tres formas:"
    " "
    "- Forma manual: Inserta el valor de memoria y" " despues todos los procesos uno a uno"
    "- Forma automática desde archivo: Introduce los" " datos desde el archivo externo de datos"
    "- Forma automática: Asigna todos los valores de" " forma automática"
  )

  clear
  centrarEnPantalla "$(imprimirCuadro "50" "default" "AYUDA")" "n" | sacarHaciaArchivo "$archivoSalida" -a
  centrarEnPantalla "$(imprimirCuadro "50" "7" "${funciona[@]}")" "n" | sacarHaciaArchivo "$archivoSalida" -a
  centrarEnPantalla "$(imprimirCuadro "50" "advertencia" "${ayuda[@]}")" "n" | sacarHaciaArchivo "$archivoSalida" -a
  read -r -p "$(centrarEnPantalla "$(imprimirCuadro "35" "default" "Pulsa intro para volver al menú")" "n")"
  clear
  elegirTipoDeEntrada "$archivoEntrada"
}

######################## 3. ALGORITMO
# Calcula los cambios en memoria para no hacerlo en la misma funcion de impresion
# ----------------------------------
function calcularCambiosMemoria() {

  # Devuelve true si un proceso ha entrado en la memoria
  # ----------------------------------
  function entraEnMemoria() {
    local entra="false"
    local i="$1"

    # Fuera|En Espera -> En Memoria|Ejecutando
    if [[ "${arrayCopia[$PROC_EST, $i]}" == "${estados[0]}" || "${arrayCopia[$PROC_EST, $i]}" == "${estados[1]}" ]] && [[ "${array[$PROC_EST, $i]}" == "${estados[2]}" || "${array[$PROC_EST, $i]}" == "${estados[3]}" ]]; then
      entra="true"
    fi

    echo "$entra"
  }

  # Mete el proceso en memoria
  # ----------------------------------
  function meterEnMemoria() {
    # Vamos añadiendolo a los huecos que están vacios
    posicion="0"
    for ((tamProc = 0; tamProc < array[$PROC_TAM, $i]; tamProc++)); do
      while [[ "${procesosEnMemoria[$posicion]}" != "$stringVacio" ]]; do
        ((posicion++))
      done
      # Guardamos la ID para igualar colores
      procesosEnMemoria[$posicion]="$i"
    done
  }

  # Devuelve true si un proceso sale de memoria
  # ----------------------------------
  function saleDeMemoria() {
    local sale="false"
    local i="$1"

    # En Memoria|Ejecutando -> Terminado
    if [[ "${arrayCopia[$PROC_EST, $i]}" == "${estados[2]}" || "${arrayCopia[$PROC_EST, $i]}" == "${estados[3]}" ]] && [[ "${array[$PROC_EST, $i]}" == "${estados[4]}" ]]; then
      sale="true"
    fi

    echo "$sale"
  }

  # Saca de memoria el proceso
  # ----------------------------------
  function sacarDeMemoria() {
    # Quitar el proceso y ponerlo en hueco vacio
    for ((j = 0; j < MEM_TAM; j++)); do
      if [[ "${procesosEnMemoria[$j]}" == "$i" ]]; then
        procesosEnMemoria[$j]="$stringVacio"
      fi
    done
  }

  # Si hay algún cambio que altere la memoria, la  cambiamos, si no la imprimimos como estaba
  # para no mover los procesos, ya que no es reubicable
  # ----------------------------------
  function comprobarMovimientosDeMemoria() {
    local -i posicion

    for ((i = 1; i <= NUM_FIL; i++)); do
      if [[ "$(entraEnMemoria "$i")" == "true" ]]; then
        meterEnMemoria
      elif [[ "$(saleDeMemoria "$i")" == "true" ]]; then
        sacarDeMemoria
      fi
    done
  }

  # Main de cuadro de memoria
  # ----------------------------------
  comprobarMovimientosDeMemoria
}

# Calcula la linea de cpu hasta el momento
# ----------------------------------
function calcularCambiosCPU() {

  # Comprueba si ningun proceso está ejecutandose
  # ----------------------------------
  function algoEstaEjecutandose() {
    local algoEjecutandose="false"

    for ((p = 1; p <= NUM_FIL; p++)); do
      if [[ "${array[$PROC_EST, $p]}" == "${estados[3]}" ]]; then
        algoEjecutandose="$p"
      fi
    done

    echo "$algoEjecutandose"
  }

  # Comprueba si hay algun cambio en cpu
  # ----------------------------------
  function comprobarMovimientosDeCPU() {
    local eseAlgo
    eseAlgo="$(algoEstaEjecutandose)"

    if [[ "$eseAlgo" != "false" ]]; then
      procesosEnCPU[$instante]="$eseAlgo"
    fi
  }

  comprobarMovimientosDeCPU
}

# Imprime el uso de la memoria según los procesos en ella
# ----------------------------------
function imprimirMemoria() {
  # Imprime la primera fila
  # ----------------------------------
  function imprimirPrimeraFila() {
    for ((pos = posicion; pos < posicionFinal; pos++)); do
      if [[ "${procesosEnMemoria[$pos]}" == "$stringVacio" ]]; then
        printf "%s" "$espacios"
      else
        local nombreEstaPuesto="false"
        idProceso="${procesosEnMemoria[$pos]}"

        # Comprobamos si ya hemos puesto el nombre
        for ((i = 0; i < pos; i++)); do
          if [[ "${procesosEnMemoria[$i]}" == "$idProceso" ]]; then
            nombreEstaPuesto="true"
          fi
        done

        # Lo volvemos a poner si antes ahi un espacio u otro proceso
        if [[ "${procesosEnMemoria[$((pos - 1))]}" == "$stringVacio" || "${procesosEnMemoria[$((pos - 1))]}" != "$idProceso" ]]; then
          nombreEstaPuesto="false"
        fi

        # Si no hemos puesto el nombre lo ponemos
        if [[ "$nombreEstaPuesto" == "false" ]]; then
          printf "${serieColores_FG[$idProceso]}%s$(fc)" "${array[$PROC_NUM, $idProceso]}"
        else
          printf "%s" "$espacios"
        fi
      fi
    done
  }

  # Imprime la segunda fila
  # ----------------------------------
  function imprimirSegundaFila() {
    local color
    for ((pos = posicion; pos < posicionFinal; pos++)); do
      if [[ "${procesosEnMemoria[$pos]}" == "$stringVacio" ]]; then
        color="${colorVacio:0:6}"
        color+="7"
        color+="${colorVacio:7}"
        printf "$color%s$(fc)" "$vacio"
      else
        idProceso="${procesosEnMemoria[$pos]}"
        color="${serieColores_FG[$idProceso]:0:7}"
        color+="${serieColores[$idProceso]:7}"
        printf "$color%s$(fc)" "$relleno"
      fi
    done
  }

  # Imprime la tercera fila
  # ----------------------------------
  function imprimirTerceraFila() {
    for ((pos = posicion; pos < posicionFinal; pos++)); do
      if [[ "${procesosEnMemoria[$pos]}" != "${procesosEnMemoria[$((pos - 1))]}" || "$pos" == "0" ]]; then
        idProceso="${procesosEnMemoria[$pos]}"
        printf "${serieColores_FG[$idProceso]}%*s$(fc)" "$(calcularLongitud "$espacios")" "$pos" # Cambiar por pos + 1 si se quiere empezar por la posición 1
      else
        printf "%s" "$espacios"
      fi
    done
  }

  # Imprime cuadro de memoria o nulo si no hay nada que imprimir
  # ----------------------------------
  function imprimir() {
    local idProceso
    local posicion
    local posicionFinal

    for ((i = 0; i < MEM_TAM; i = $((i + anchoTruncado)))); do
      posicion="$i"
      posicionFinal="$((i + anchoTruncado))"

      if [[ "$posicionFinal" -gt "$MEM_TAM" ]]; then
        posicionFinal="$MEM_TAM"
      fi

      # PRIMERA FILA
      printf "\t%s%s\n" "$espacios" "$(imprimirPrimeraFila)"

      # SEGUNDA FILA
      # Solo ponemos el nombre de la banda en la primera fila de truncado
      if [[ "$i" -lt "$anchoTruncado" ]]; then
        printf "\t$(cc Neg blanco fg)%-*s$(fc)%s" "$(calcularLongitud "$espacios")" "BM|" "$(imprimirSegundaFila)"
      else
        printf "\t$(cc Neg blanco fg)%-*s$(fc)%s" "$(calcularLongitud "$espacios")" "$espacios" "$(imprimirSegundaFila)"
      fi
      # Y el valor final en la última
      if [[ "$posicionFinal" -ge "$MEM_TAM" ]]; then
        printf "$(cc Neg blanco fg) %s$(fc)\n" "$posicionFinal"
      else
        printf "\n"
      fi

      # TERCERA FILA
      printf "\t%s%s\n" "$espacios" "$(imprimirTerceraFila)"
    done
  }

  # Main de cuadro de memoria
  # ----------------------------------
  imprimir
}

# Imprime la linea de procesos de CPU
# @param Instante actual
# ----------------------------------
function imprimirLineaProcesos() {
  # Imprime la primera fila
  # ----------------------------------
  function imprimirPrimeraFila() {
    for ((pos = posicion; pos <= posicionFinal; pos++)); do
      if [[ "${procesosEnCPU[$pos]}" == "" ]]; then
        printf "%s" "$espacios"
      else
        local nombreEstaPuesto="false"
        idProceso="${procesosEnCPU[$pos]}"

        # Comprobamos si ya hemos puesto el nombre
        for ((i = posicion; i < pos; i++)); do
          if [[ "${procesosEnCPU[$i]}" == "$idProceso" ]]; then
            nombreEstaPuesto="true"
          fi
        done

        # Si no hemos puesto el nombre lo ponemos
        if [[ "$nombreEstaPuesto" == "false" ]]; then
          if [[ "$((pos % anchoTruncado))" != "0" || "$pos" == "$posicion" ]]; then
            printf "${serieColores_FG[$idProceso]}%s$(fc)" "${array[$PROC_NUM, $idProceso]}"
          fi
        else
          printf "%s" "$espacios"
        fi
      fi
    done
  }

  # Imprime la segunda fila
  # ----------------------------------
  function imprimirSegundaFila() {
    local color
    local siguienteEntra="▎"
    for ((pos = posicion; pos <= posicionFinal; pos++)); do
      if [[ "${procesosEnCPU[$pos]}" == "" && "$pos" != "$posicionFinal" && "$((pos % anchoTruncado))" != "0" ]]; then
        color="${colorVacio:0:6}"
        color+="7"
        color+="${colorVacio:7}"
        printf "$color%s$(fc)" "$vacio"
      else
        idProceso="${procesosEnCPU[$pos]}"
        # Comando de color para frente y fondo mismo color
        color="${serieColores_FG[$idProceso]:0:7}"
        color+="${serieColores[$idProceso]:7}"

        if [[ "$pos" != "$posicionFinal" ]]; then
          if [[ "$idProceso" == "" ]]; then
            color="${colorVacio:0:6}"
            color+="7"
            color+="${colorVacio:7}"
            printf "$color%s$(fc)" "$vacio"
          else
            printf "$color%s$(fc)" "$relleno"
          fi
        elif [[ "$pos" == "0" && "$idProceso" == "" ]] || [[ "$pos" == "$posicion" && "$idProceso" != "" ]] || [[ "$idProceso" != "" && "${procesosEnCPU[$pos]}" != "${procesosEnCPU[$((pos - 1))]}" && "$((pos % anchoTruncado))" != "0" ]]; then
          printf "${serieColores_FG[$idProceso]}%s$(fc)" "$siguienteEntra"
        fi
      fi
    done
  }

  # Imprime la tercera fila
  # ----------------------------------
  function imprimirTerceraFila() {
    for ((pos = posicion; pos <= posicionFinal; pos++)); do
      if [[ "$pos" == "$posicionFinal" ]] || [[ "$pos" == "0" && "$idProceso" == "" ]] || [[ "$pos" == "$posicion" && "$pos" != "$posicionFinal" ]] || [[ "$((pos % anchoTruncado))" != "0" && "${procesosEnCPU[$pos]}" != "${procesosEnCPU[$((pos - 1))]}" ]]; then
        idProceso="${procesosEnCPU[$pos]}"
        printf "${serieColores_FG[$idProceso]}%*s$(fc)" "$(calcularLongitud "$espacios")" "$pos"
      else
        printf "%s" "$espacios"
      fi
    done
  }

  # Imprime la linea de procesos en la CPU
  # @param Instante
  # ----------------------------------
  function imprimir() {
    local idProceso
    local posicion
    local posicionFinal

    for ((posicion = 0; posicion < instante || posicion == 0; posicion = $((posicion + anchoTruncado)))); do
      posicionFinal="$((posicion + anchoTruncado))"

      if [[ "$posicionFinal" -gt "$instante" ]]; then
        posicionFinal="$instante"
      fi

      #PRIMERA FILA
      printf "\t%s%s\n" "$espacios" "$(imprimirPrimeraFila "$1")"

      # SEGUNDA FILA
      # Solo ponemos el nombre de la banda en la primera fila de truncado
      if [[ "$posicion" -lt "anchoTruncado" ]]; then
        printf "\t$(cc Neg blanco fg)%-*s$(fc)%s\n" "$(calcularLongitud "$espacios")" "BT|" "$(imprimirSegundaFila "$1")"
      else
        printf "\t$(cc Neg blanco fg)%-*s$(fc)%s\n" "$(calcularLongitud "$espacios")" "$espacios" "$(imprimirSegundaFila "$1")"
      fi

      # TERCERA FILA
      printf "\t%s%s\n" "$espacios" "$(imprimirTerceraFila "$1")"
    done
  }

  # Main de cuadro de CPU
  # ----------------------------------
  imprimir "$1"
}

# Asigna los estados de los procesos
# ----------------------------------
function asignarDatosInicial() {
  for ((i = 1; i <= NUM_FIL; i++)); do
    array[$PROC_EST, $i]="${estados[0]}"
    array[$PROC_EJE_RES, $i]="$stringNoAsignado"
    array[$PROC_RES, $i]="$stringNoAsignado"
    array[$PROC_ESP, $i]="$stringNoAsignado"
    array[$PROC_TAM_INI, $i]="$stringNoAsignado"
    array[$PROC_TAM_FIN, $i]="$stringNoAsignado"
  done

  MEM_USE="0"
  for ((i = 0; i < MEM_TAM; i++)); do
    procesosEnMemoria[$i]="$stringVacio"
  done
}

# Función que calcula la memoria restante
# ----------------------------------
function calcularMemoriaRestante() {
  MEM_USE="0"

  for ((k = 0; k <= NUM_FIL; k++)); do
    if [[ "${array[$PROC_EST, $k]}" == "${estados[2]}" || "${array[$PROC_EST, $k]}" == "${estados[3]}" ]]; then
      MEM_USE+="${array[$PROC_TAM, $k]}"
    fi
  done
}

# Asigna los estados segun avanza el algoritmo
# ----------------------------------
function asignarEstadosSegunInstante() {
  local -i instante="$1"
  local procesoEjecutando="false"
  local ningunProcesoEnCola="true"
  local memRestante

  # Asignamos los estados segun varias cosas, que el proceso haya llegado (llegada <= instante), que quepa en memoria (en los huecos que queden) y que no haya finalizado
  for ((i = 1; i <= NUM_FIL; i++)); do

    memRestante=$((MEM_TAM - MEM_USE))

    # Fuera
    if [[ "${array[$PROC_EST, $i]}" == "${estados[0]}" ]]; then
      if [[ "${array[$PROC_LLE, $i]}" -le "$instante" ]]; then
        array[$PROC_EST, $i]="${estados[1]}"
      fi
    fi

    # En Espera
    if [[ "${array[$PROC_EST, $i]}" == "${estados[1]}" ]]; then
      array[$PROC_ESP, $i]="$((instante - array[$PROC_LLE, $i]))"
      array[$PROC_RES, $i]="0"

      # Si ningun proceso anterior esta en espera, ejecutamos
      for ((cola = 1; cola < i; cola++)); do
        if [[ "${array[$PROC_EST, $cola]}" == "${estados[1]}" ]]; then
          ningunProcesoEnCola="false"
        fi
      done

      if [[ "$ningunProcesoEnCola" == "true" ]]; then
        if [[ "${array[$PROC_TAM, $i]}" -gt "$MEM_TAM" ]]; then
          array[$PROC_EST, $i]="${estados[3]}"
        elif [[ "${array[$PROC_TAM, $i]}" -le "$memRestante" ]]; then
          array[$PROC_EST, $i]="${estados[2]}"
        fi
      fi
    fi

    # En Memoria
    if [[ "${array[$PROC_EST, $i]}" == "${estados[2]}" ]]; then
      array[$PROC_ESP, $i]="$((instante - array[$PROC_LLE, $i]))"
      array[$PROC_EJE_RES, $i]="${array[$PROC_EJE, $i]}"
      for ((j = 1; j <= NUM_FIL; j++)); do
        if [[ "${array[$PROC_EST, $j]}" == "${estados[3]}" ]]; then
          procesoEjecutando="true"
        fi
      done

      if [[ "$procesoEjecutando" != "true" ]]; then
        array[$PROC_EST, $i]="${estados[3]}"
      fi
    fi

    # Ejecutando
    if [[ "${array[$PROC_EST, $i]}" == "${estados[3]}" ]]; then
      array[$PROC_RES, $i]="$((instante - array[$PROC_LLE, $i]))" # Que coincide con el tiempo de ejcución por ser FCFS
      if [[ "${array[$PROC_EJE_RES, $i]}" == "0" ]]; then
        array[$PROC_EST, $i]="${estados[4]}"
      fi
    fi

    calcularMemoriaRestante
  done
}

# Comprueba si el programa ha acabado
# ----------------------------------
function procesosHanTerminado() {
  local procHanTerminado="true"

  for ((i = 1; i <= NUM_FIL; i++)); do
    if [[ "${array[$PROC_EST, $i]}" != "${estados[4]}" ]]; then
      procHanTerminado="false"
    fi
  done

  echo "$procHanTerminado"
}

# Comprueba los procesos que se estan ejecutando
# ----------------------------------
function comprobarProcesosEjecutando() {
  for ((i = 1; i <= NUM_FIL; i++)); do
    if [[ "${array[$PROC_EST, $i]}" == "${estados[3]}" ]]; then
      ((array[$PROC_EJE_RES, $i]--))
    fi
  done
}

######################## 4. OTRAS FUNCIONES UTILES USADAS EN TODO EL PROGRAMA

# Hace una copia del array antes de cambiarlo en la ejecucion
# ----------------------------------
function copiarArray() {
  for ((i = 1; i <= NUM_FIL; i++)); do
    for ((j = 1; j <= NUM_COL; j++)); do
      arrayCopia[$j, $i]="${array[$j, $i]}"
    done
  done
}

# Saca la información del comando que acompaña
# @param "-a" para append
# ----------------------------------
function sacarHaciaArchivo() {
  local archivo
  archivo+="$1"

  if [ "$2" == "-a" ]; then
    tee -a "$archivo"
  else
    tee "$archivo"
  fi
}

# Devuelve la expresión completa de color, pasándole los parámetros
# que queremos en orden
# @param tipoEspecial (Negrita=Neg, Subrayado=Sub, Normal=Nor, Parpadeo=Par)
# @param (valor random, default,  error, acierto, fg aleatorio sobre bg negro
# o lista de colores en orden)
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
  *)
    salida+="1;"
    ;;
  esac

  if [[ "$2" != "" && "$3" == "" ]]; then
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
    blanco)
      salida+="$(generarColor fg_negro);$(($(generarColor bg_negro) + 7))m"
      ;;
    *)
      salida+="$(generarColor fg_negro);$(($(generarColor bg_negro) + 1 + $(($2 % 6))))m"
      ;;
    esac
  elif [[ "$3" == "fg" ]]; then
    case "$2" in
    blanco)
      salida+="$(($(generarColor fg_negro) + 7))m"
      ;;
    *)
      salida+="$(($(generarColor fg_negro) + 1 + $(($2 % 6))))m"
      ;;
    esac

  fi

  echo "$salida"
}

# Finaliza el uso de colores
# ----------------------------------
function fc() {
  echo "\033[0m"
}

# Devuelve la longitud del string, contando los patrones de colores.
# @param String del que queremos calcular la longitud
# ----------------------------------
function calcularLongitud() {
  echo ${#1}
}

# Imprime la introduccion del programa
# @param Ancho del cuadro
# @param Color
# @param Array del contenido del cuadro
# @param Tipo de texto
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
    if [[ "$2" == "" ]]; then
      color=$(cc Neg "$1")
    else
      color=$(cc "$2" "$1")
    fi
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
      printf "$color%s" ""
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
  asignacolor "$2" "$4"
  asignarEstiloCuadro
  imprimir "$@"
}

# Imprime una tabla según el tamaño del array de datos
# @param numeroFilasImprimir
# @param numeroColumnasImprimir
# @param numeroDeColumnaDelQueEmpezamos
# ----------------------------------
function imprimirTabla() {
  local -a titulos
  local colorEncabezado
  local colorBordes
  local estiloTabla
  local -A anchoCelda
  local filasImprimir
  local columnasImprimir
  local encTabla
  local pieTabla
  local numColComienzo

  # Función que añade filas para todos los procesos indicando de que hueco de memoria a que hueco ocupan
  # ----------------------------------
  function modificarArrayConCachosDeMemoriaUsados() {

    # Movemos los datos de la copia del array todo una hacia arriba y
    # tambiñen movemos los colores una hacia arriba.
    # Los huecos se rellenan con los datos de inicio y final de memoria
    # y los colores con la fila anterior a la que movemos.
    # @param Fila desde la que movemos para arriba
    # @param Salto
    # ----------------------------------
    function hacerHuecos() {
      local proc="$1"
      local salto="$2"
      local nodo=$((proc + salto))
      # Otorgamos un nuevo hueco y movemos todo hacia arriba
      # La linea pasada se limpia para poder ser escrita con los nuevos datos.
      for ((numFila = filasImprimir; numFila > nodo; numFila--)); do
        serieColores_FG[$numFila]="${serieColores_FG[$((numFila - salto))]}"
        for ((numColum = 1; numColum <= NUM_COL; numColum++)); do
          arrayCopia[$numColum, $numFila]="${arrayCopia[$numColum, $((numFila - salto))]}"
        done
      done

      for ((numFila = nodo; numFila > proc; numFila--)); do
        serieColores_FG[$numFila]="${serieColores_FG[$proc]}"
        for ((numColum = 1; numColum <= NUM_COL; numColum++)); do
          arrayCopia[$numColum, $((proc + 1))]=""
        done
      done
    }

    # Añade tantas filas como huecos disntintos ocupe el proceso en memoria.
    # @param "Proceso a añadir las líneas"
    # ----------------------------------
    function colocarHuecosMemoria() {
      local proceso="$1"
      local -a ini
      ini[0]=0
      local -a fin
      local huecos
      huecos="-1"

      for ((itMem = 0; itMem < MEM_TAM; itMem++)); do
        # Inicio de memoria
        if [[ "${procesosEnMemoria[$itMem]}" == "$((proceso - huecosTotales))" && "${procesosEnMemoria[$((itMem - 1))]}" != "$((proceso - huecosTotales))" ]]; then
          ini[$((huecos + 1))]="$itMem"
        fi
        # Final de memoria
        if [[ "${procesosEnMemoria[$itMem]}" == "$((proceso - huecosTotales))" && "${procesosEnMemoria[$((itMem + 1))]}" != "$((proceso - huecosTotales))" ]]; then
          fin[$((huecos + 1))]="$itMem"
          ((huecos++))
        fi
      done

      if [[ "$huecos" -gt "0" ]]; then
        filasImprimir=$((filasImprimir + huecos))
        i=$((i + huecos))
        huecosTotales=$((huecosTotales + huecos))
        hacerHuecos "$proceso" "$huecos"
      fi
      for ((numHuecos = 0; numHuecos <= huecos; numHuecos++)); do
        arrayCopia[$PROC_TAM_INI, $((proceso + numHuecos))]="${ini[$numHuecos]}"
        arrayCopia[$PROC_TAM_FIN, $((proceso + numHuecos))]="${fin[$numHuecos]}"
      done
    }

    # Actualizamos la copia del array al actual, y modificaremos este para no tocar el otro
    # ----------------------------------
    function comprobarMemoria() {
      local huecosTotales="0"
      for ((i = 1; i <= filasImprimir; i++)); do
        if [[ "${arrayCopia[$PROC_EST, $i]}" == "${estados[2]}" || "${arrayCopia[$PROC_EST, $i]}" == "${estados[3]}" ]]; then
          colocarHuecosMemoria "$i"
        fi
      done
    }

    comprobarMemoria
  }

  # Asigna el titulo de la tabla
  # ----------------------------------
  function asignarTitulos() {
    titulos[$((PROC_NUM - 1))]="Ref"
    titulos[$((PROC_LLE - 1))]="Tll"
    titulos[$((PROC_EJE - 1))]="Tej"
    titulos[$((PROC_TAM - 1))]="Mem"
    titulos[$((PROC_TAM_INI - 1))]="MIni"
    titulos[$((PROC_TAM_FIN - 1))]="MFin"
    titulos[$((PROC_ESP - 1))]="Tesp"
    titulos[$((PROC_RES - 1))]="Tret"
    titulos[$((PROC_EJE_RES - 1))]="Trej"
    titulos[$((PROC_EST - 1))]="Estado"
  }

  # Guarda los colores de la tabla
  # ----------------------------------
  function guardarColoresDeTabla() {
    colorEncabezado=$(cc Sub blanco fg)
    colorBordes=$(cc Neg blanco fg)
  }

  # Imprime los titulos de las columnas de datos
  # ----------------------------------
  function imprimirTitulos() {
    local longitudArray # Para centrar en la tabla

    for ((i = numColComienzo; i <= columnasImprimir; i++)); do
      longitudArray=$(calcularLongitud "${titulos[$((i - 1))]}")
      printf "${estiloTabla[10]}%-*s$colorEncabezado%s$(fc)%*s" "$((anchoCelda[$i] / 2 - longitudArray / 2))" "" "${titulos[$((i - 1))]}" "$(((anchoCelda[$i] + 1) / 2 - (longitudArray + 1) / 2))" ""
    done

    printf "${estiloTabla[10]}%s" ""
  }

  # Comprueba que las entradas estén corectas
  # ----------------------------------
  function comprobarFilasYColumnas() {
    columnasImprimir="$1"
    numColComienzo="$2"
    filasImprimir="$NUM_FIL"

    if [ "$columnasImprimir" -gt "$NUM_COL" ]; then
      columnasImprimir="$NUM_COL"
    fi
    if [[ "$numColComienzo" == "" || "$numColComienzo" -gt "$columnasImprimir" ]]; then
      numColComienzo="1"
    fi
  }

  # Asigna un estilo a la tabla, de doble linea, linea basica,
  # esquinas redondeadas, etc...
  # ----------------------------------
  function asignarEstiloDeTabla() {
    local -a simboloHorizontal

    estiloTabla=("${estiloGeneral[@]}")

    for ((j = numColComienzo; j <= columnasImprimir; j++)); do
      for ((i = 0; i < anchoCelda[$j]; i++)); do
        simboloHorizontal[$j]+=${estiloTabla[0]}
      done
    done

    encTabla=${estiloTabla[1]}${simboloHorizontal[$numColComienzo]}
    pieTabla=${estiloTabla[3]}${simboloHorizontal[$numColComienzo]}

    for ((i = ((numColComienzo + 1)); i <= columnasImprimir; i++)); do
      encTabla+=${estiloTabla[4]}${simboloHorizontal[$i]}
      pieTabla+=${estiloTabla[6]}${simboloHorizontal[$i]}
    done

    encTabla+=${estiloTabla[7]}
    pieTabla+=${estiloTabla[9]}
  }

  # Asigna el ancho de la celda y el numero de filas a mostrar
  # desde el indice
  # ----------------------------------
  function asignarAnchos() {
    local longitudElemento

    # Asigna los anchos de forma dinamica según el ancho de la celda
    # ----------------------------------
    function asignarAnchosDinamicamente() {
      for ((i = numColComienzo; i <= columnasImprimir; i++)); do
        anchoCelda[$i]="1"
        for ((j = 0; j <= filasImprimir; j++)); do
          if [[ "$j" == "0" ]]; then
            longitudElemento=$(calcularLongitud "${titulos[$((i - 1))]}")
          else
            longitudElemento=$(calcularLongitud "${arrayCopia[$i, $j]}")
          fi

          if [[ "${anchoCelda[$i]}" -lt "$longitudElemento" ]]; then
            anchoCelda[$i]="$longitudElemento"
          fi
        done

        if [[ "$((anchoCelda[$i] % 2))" == "1" ]]; then
          anchoCelda[$i]=$((anchoCelda[$i] + 0))
        else
          anchoCelda[$i]=$((anchoCelda[$i] + 0))
        fi
      done
    }

    asignarAnchosDinamicamente
  }

  # Imprime la tabla final en orden
  # ----------------------------------
  function imprimir() {
    local longitudArray
    longitudArray="0"

    # Encabezado Y Titulos
    # ----------------------------------
    function encabezadoYTitulos() {
      printf "$colorBordes%s$(fc)\n" "$encTabla"

      imprimirTitulos
      printf "\n"
    }

    # Fila de datos
    # ----------------------------------
    function datos() {
      for ((k = 1; k <= filasImprimir; k++)); do
        for ((j = numColComienzo; j <= columnasImprimir; j++)); do
          # Filas numéricas a la derecha
          if [[ "$j" -gt "1" && "$j" -lt "8" ]] || [[ "$j" == "9" ]] || [[ "$j" == "10" ]]; then
            # Derecha
            printf "${estiloTabla[10]}${serieColores_FG[$k]}%*s$(fc)" "${anchoCelda[$j]}" "${arrayCopia[$j, $k]}"
          # Filas de strings a la izquierda
          else
            # Añadimos un hueco a "En ejecución" porque la tilde borra un espacio. Por cieto, WTF!
            if [[ "$j" == "$PROC_EST" && "${arrayCopia[$j, $k]}" == "${estados[3]}" ]]; then
              longitudArray="1"
            fi
            # Izquierda
            printf "${estiloTabla[10]}${serieColores_FG[$k]}%-*s$(fc)" "$((anchoCelda[$j] + longitudArray))" "${arrayCopia[$j, $k]}"
            longitudArray="0"
          fi
        done
        printf "${estiloTabla[10]}%s\n" ""
      done
    }

    # Fila de pie
    # ----------------------------------
    function pie() {
      printf "$colorBordes%s$(fc)\n" "$pieTabla"
    }

    encabezadoYTitulos
    datos
    pie
  }

  # Main de impresion
  # ----------------------------------
  copiarArray
  guardarColoresDeTabla
  asignarTitulos
  comprobarFilasYColumnas "$1" "$2"
  if [[ "$algoritmoComienza" == "true" ]]; then
    modificarArrayConCachosDeMemoriaUsados
  fi
  asignarAnchos
  asignarEstiloDeTabla
  imprimir
}

# Ordena el array según tiempo de llegada para mostrar la tabla.
# @param col Movemos también los colores.
# ----------------------------------
function ordenarArray() {
  local movemosColor="$1"

  # Funcion que mueve la fila completa por la siguiente
  # ----------------------------------
  function moverFilaCompleta() {
    local temp
    local fila="$1"

    for ((col = 1; col <= NUM_COL; col++)); do
      temp="${array[$col, $fila]}"
      array[$col, $fila]="${array[$col, $(($fila + 1))]}"
      array[$col, $(($fila + 1))]="$temp"
    done
  }

  # Movemos también el color
  # ----------------------------------
  function moverColor() {
    local temp
    local fila="$1"

    temp="${serieColores_FG[$fila]}"
    if [[ "$temp" != "" ]]; then
      serieColores_FG[$fila]="${serieColores_FG[$((fila + 1))]}"
      serieColores_FG[$(($fila + 1))]="$temp"
    fi

    temp="${serieColores[$fila]}"
    if [[ "$temp" != "" ]]; then
      serieColores[$fila]="${serieColores[$((fila + 1))]}"
      serieColores[$(($fila + 1))]="$temp"
    fi
  }

  # Ejecuta el algoritmo burbuja
  # ----------------------------------
  function burbuja() {
    local tempOrigen
    local tempDestino

    for ((i = 1; i <= NUM_FIL; i++)); do
      for ((j = 1; j < NUM_FIL; j++)); do
        tempOrigen="${array[$PROC_LLE, $j]}"
        tempDestino="${array[$PROC_LLE, $((j + 1))]}"

        if [ "$tempOrigen" -gt "$tempDestino" ]; then
          moverFilaCompleta "$j"
          if [[ "$movemosColor" == "-c" ]]; then
            moverColor "$j"
          fi
        fi
      done
    done
  }

  burbuja
}

# Centra en pantalla el valor pasado, si es un string, divide por saltos de
# linea y coloca cada linea en el centro
# @param String a centrar
# @param Si se quiere un espacio al final
# ----------------------------------
function centrarEnPantalla() {

  # Centra en el medio de la terminal
  # ----------------------------------
  function opcionCentrarEnTerminal() {
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
      printf "%*.*s %s %*.*s" 0 "$(((termwidth - 2 - longitudElemento) / 2))" "$padding" "${string[$i]}" 0 "$(((termwidth - 1 - longitudElemento) / 2))" "$padding"
      if [[ "i" -lt "$((${#string[@]} - 1))" ]]; then
        printf "\n"
      fi
    done

    if [[ "$2" == "n" ]]; then
      printf "\n"
    fi
  }

  # Añade un poco de espacio a la izquierda
  # ----------------------------------
  function opcionEspacioIzquierda() {
    local string
    IFS=$'\n' string=($1)

    for ((i = 0; i < ${#string[@]}; i++)); do
      printf "\t%s" "${string[$i]}"
      if [[ "i" -le "${#string[@]}" ]]; then
        printf "\n"
      fi
    done

    if [[ "$2" == "n" ]]; then
      printf "\n"
    fi
  }

  opcionEspacioIzquierda "$1" "$2"
}

# Funcion basica de avance de algoritmo
# ----------------------------------
function avanzarAlgoritmo() {
  read -r -p "$(centrarEnPantalla "$(imprimirCuadro "30" "default" "Pulsa intro para avanzar")" "n")"
  clear
}

######################## Main
# Main, eje central del algoritmo, única llamada en cuerpo
# ----------------------------------
function main() {
  # Variables globales de subfunciones
  # ----------------------------------
  declare -a estiloGeneral
  declare -A array
  declare -A arrayCopia
  declare -a serieColores
  declare -a serieColores_FG
  declare -i NUM_COL
  declare -i NUM_FIL
  declare -i MEM_TAM
  declare -i MEM_USE
  # Variables de columnas, para saber que hay en cada una - Usadas para aclarar el código
  # ----------------------------------
  declare -i PROC_NUM
  declare -i PROC_LLE
  declare -i PROC_EJE
  declare -i PROC_TAM
  declare -i PROC_TAM_INI
  declare -i PROC_TAM_FIN
  declare -i PROC_EST
  declare -i PROC_RES
  declare -i PROC_ESP
  declare -i PROC_EJE_RES
  # Variables locales
  # ----------------------------------
  local configFile
  local introduccion
  local error
  local acierto
  local advertencia
  local archivoSalida
  local archivoSalidaBN
  local archivoEntrada
  local salirDePractica
  local algoritmoComienza

  # Extraccion de variables del archivo de config
  # ------------------------------------------------
  function asignaciones() {
    # Asigna las variables extraidas del archivo de ocnfiguración
    # ----------------------------------
    function asignarConfigs() {
      configFile=$(dirname "$0")
      configFile+="/Config/config.toml"
      introduccion=$(extraerDeConfig "introduccion")
      error=$(extraerDeConfig "error")
      acierto=$(extraerDeConfig "acierto")
      advertencia=$(extraerDeConfig "advertencia")
      archivoSalida="$(dirname "$0")/$(extraerDeConfig "archivoSalida")"
      archivoSalidaBN="$(dirname "$0")/$(extraerDeConfig "archivoSalidaBN")"
      archivoEntrada="$(dirname "$0")/$(extraerDeConfig "archivoEntrada")"
      # Limpiamos las lineas vacias del archivo de entrada
      sed -i '/^$/d' "$archivoEntrada"
    }

    # Asigna el numero de cada columna para asignarlo en las diferentes funciones
    # ----------------------------------
    function asignarPosicionYNumColumnas() {
      PROC_NUM="1"
      PROC_LLE="2"
      PROC_EJE="3"
      PROC_TAM="4"
      PROC_ESP="5"
      PROC_RES="6"
      PROC_EJE_RES="7"
      PROC_EST="8"
      PROC_TAM_INI="9"
      PROC_TAM_FIN="10"

      NUM_COL="$PROC_TAM_FIN" # Ya que siempre esta columna va a ser la última
    }

    asignarConfigs
    asignarEstiloGeneral "4"
    asignarPosicionYNumColumnas
  }
  # ------------------------------------------------

  # Introduccion
  # ------------------------------------------------
  function introduccion() {
    # Imprime introducción
    centrarEnPantalla "$(imprimirCuadro "50" "default" "$introduccion")" "n" | sacarHaciaArchivo "$archivoSalida"
    # Imprime mensaje error
    centrarEnPantalla "$(imprimirCuadro "50" "error" "$error")" "n"
    # Imprime mensaje advertencia
    centrarEnPantalla "$(imprimirCuadro "50" "advertencia" "$advertencia")" "n"
    # Avanza de fase
    avanzarAlgoritmo
  }
  # ------------------------------------------------

  # Elección menú, entrada de datos y tipo de tiempo
  # ------------------------------------------------
  function menu() {
    elegirTipoDeEntrada "$archivoEntrada"
  }
  # ------------------------------------------------

  # Ejecuta Algoritmo
  # ------------------------------------------------
  function algoritmo() {
    local -a estados=("Fuera del Sistema" "En Espera" "En Memoria" "En Ejecución" "Finalizado")
    local -a procesosEnMemoria
    local -a procesosEnCPU
    local stringVacio
    local instante
    local acabarAlgoritmo
    local colorVacio
    procesosEnCPU=()
    acabarAlgoritmo="false"
    stringVacio="null"
    stringNoAsignado="--"

    # Imprime una cabecera muy simple
    # ----------------------------------
    function algCabecera() {
      if [[ "$1" == "-c" ]]; then
        centrarEnPantalla "$(imprimirCuadro "50" "acierto" "$acierto")"
      else
        centrarEnPantalla "$(printf "$(cc Neg acierto) %s $(fc)" "$acierto")"
      fi
    }

    # Calcula los siguientes datos a mostrar
    # ----------------------------------
    function algCalcularSigIns() {
      printf "\n"

      # Con Color
      # centrarEnPantalla "$(printf "$(cc Neg 3) %s $(fc)" "T=$instante - Memoria usada: $MEM_USE/$MEM_TAM")"
      # Sin Color
      centrarEnPantalla "$(printf "$(cc Neg blanco fg) %s $(fc)" "T=$instante - Memoria usada: $MEM_USE/$MEM_TAM")"
    }

    # Calcula los tiempos medios de respuesta y espera
    # ----------------------------------
    function algTiemposMedios() {
      local -i mediaRespuesta
      local -i mediaEspera
      mediaEspera="0"
      mediaRespuesta="0"

      for ((i = 1; i <= NUM_FIL; i++)); do
        if [[ "${array[$PROC_RES, $i]}" != "$stringNoAsignado" ]]; then
          mediaRespuesta+="${array[$PROC_RES, $i]}"
        fi
        if [[ "${array[$PROC_ESP, $i]}" != "$stringNoAsignado" ]]; then
          mediaEspera+="${array[$PROC_ESP, $i]}"
        fi
      done

      mediaRespuesta="$((mediaRespuesta * 100))"
      mediaEspera="$((mediaEspera * 100))"

      # Saca la media de respuesta en formato decimal
      # ----------------------------------
      function sacarMediaRespuesta() {
        printf "%.2f" "$((mediaRespuesta / NUM_FIL))e-2"
      }

      # Saca la media de espera en formato decimal
      # ----------------------------------
      function sacarMediaEspera() {
        printf "%.2f" "$((mediaEspera / NUM_FIL))e-2"
      }

      # Con Color
      # centrarEnPantalla "$(printf "$(cc Neg 3) %s $(fc)" "Tiempo Medio de Retorno: $(sacarMediaRespuesta) - Tiempo Medio de Espera: $(sacarMediaEspera)")" "n"
      # Sin Color
      centrarEnPantalla "$(printf "$(cc Neg blanco fg) %s $(fc)" "Tiempo Medio de Retorno: $(sacarMediaRespuesta) - Tiempo Medio de Espera: $(sacarMediaEspera)")" "n"
    }

    # Funcion que calcula el tiempo y estado de todos los proceos en cada instante,
    # sirve para saber como colcarlos en memoria y calcular el tiempo medio final
    # ----------------------------------
    function algCalcularDatos() {
      comprobarProcesosEjecutando
      asignarEstadosSegunInstante "$instante"
    }

    # Imprime el dibujo de la tabla
    # ----------------------------------
    function algImprimirTabla() {
      centrarEnPantalla "$(imprimirTabla "20")"
    }

    # Funcion para avanzar el algoritmo o terminarlo
    # ----------------------------------
    function algAvanzarAlgoritmo() {
      local temp
      temp=""

      printf "\n"
      read -r -p "$(centrarEnPantalla "$(imprimirCuadro "50" "default" "Pulsa intro para avanzar o [F] para finalizar")" "n")" temp

      # Doble clear para limpiar pantalla (ya que el conetenido es mayor que la pantalla y solo hace el salto)
      clear

      if [[ "$temp" =~ ^([fF])$ ]]; then
        local mensajeSalto=("Ejecutando y exportando algoritmo en"
          "segundo plano. Serán solo unos segundos")
        acabarAlgoritmo="true"
        centrarEnPantalla "$(imprimirCuadro "50" "3" "${mensajeSalto[@]}")" "n"
      fi
    }

    # Comprueba si en el instante de ejucion pasa algo importante para mostrar o no
    # Consideramos que algo importante pasa si cambia algún estado de los procesos
    # ----------------------------------
    function algoImportantePasa() {
      local algoImportantePasa="false"

      for ((i = 1; i <= NUM_FIL; i++)); do
        if [[ "${array[$PROC_EST, $i]}" != "${arrayCopia[$PROC_EST, $i]}" ]]; then
          algoImportantePasa="true"
        fi
      done

      echo "$algoImportantePasa"
    }

    # Main del cuerpo del algoritmo
    # ----------------------------------
    function algCuerpoAlgoritmo() {
      local espacios
      local relleno
      local vacio
      local anchoTruncado
      espacios="   "
      relleno="██▊"
      vacio="░░░"
      anchoTruncado="$(($(tput cols) / 4))"

      algCalcularSigIns
      algImprimirTabla
      algTiemposMedios
      imprimirMemoria
      imprimirLineaProcesos "$instante"
    }

    # Asigna los colores que llevaran los procesos y todas las lineas en las que esten presentados
    # ----------------------------------
    function algAsignarColorVacio() {
      colorVacio="$(cc Nor blanco)" # Cuando la memoria esta vacia debe ser blanco
    }

    # Main de las llamadas de la parte de calculo de algoritmo
    # ----------------------------------
    clear
    instante="0"
    algoritmoComienza="true"
    ordenarArray
    asignarDatosInicial
    algAsignarColorVacio
    algCabecera "-c" -a >>"$archivoSalida"

    while [[ $(procesosHanTerminado) != "true" ]]; do
      copiarArray
      algCalcularDatos
      calcularCambiosCPU

      # Si pasa algo importante lo mostramos en pantalla y/o sacamos por archivo
      if [[ "$(algoImportantePasa)" == "true" || "$instante" == "0" ]]; then
        calcularCambiosMemoria
        if [[ "$acabarAlgoritmo" == "true" ]]; then
          algCuerpoAlgoritmo >>"$archivoSalida"
        else
          algCabecera
          algCuerpoAlgoritmo | sacarHaciaArchivo "$archivoSalida" -a
          algAvanzarAlgoritmo
        fi
      fi
      ((instante++))
    done
  }
  # ------------------------------------------------

  # Pregunta al usuario si quiere salir del programa
  # ------------------------------------------------
  function preguntarSiQuiereInforme() {

    # Funcion que saca el menu de salida
    # ----------------------------------
    function menuInforme() {
      local tipo
      local opcionesEntrada
      local archivo
      opcionesEntrada=(
        "1.- Informe en color"
        "2.- Informe en blanco y negro"
        "0.- No sacar informe"
      )

      # Sacamos archivo byn
      sed -r 's/\x1B\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]//g' "$archivoSalida" | less >"$archivoSalidaBN"

      centrarEnPantalla "$(imprimirCuadro "50" "default" "MENU DE INFORME")" "n"
      centrarEnPantalla "$(imprimirCuadro "50" "default" "${opcionesEntrada[@]}")" "n"
      tipo=$(recibirEntrada)

      while [[ ! "$tipo" =~ ^[0-2]$ ]]; do
        printf "\n"
        centrarEnPantalla "$(imprimirCuadro "50" "error" "Inserta un valor numérico entre 0 y 2")" "n"
        tipo=$(recibirEntrada)
      done

      case "$tipo" in
      1)
        less -r "$archivoSalida"
        clear
        menuInforme
        ;;
      2)
        less -r "$archivoSalidaBN"
        clear
        menuInforme
        ;;
      0) ;;
      esac
    }

    clear
    menuInforme
  }
  # ------------------------------------------------

  # Pregunta al usuario si quiere sacar el informe
  # ------------------------------------------------
  function preguntarSiQuiereSalir() {
    local temp

    clear
    centrarEnPantalla "$(imprimirCuadro "50" "default" "¿Quieres volver a ejecutar el algoritmo? [S/N]")" "n"
    temp=$(recibirEntrada)

    while [[ ! "$temp" =~ ^([sS][iI]|[sS]|[nN][oO]|[nN])$ ]]; do
      printf "\n"
      centrarEnPantalla "$(imprimirCuadro "50" "error" "Entrada de datos errónea")" "n"
      temp=$(recibirEntrada)
    done

    if [[ $temp =~ [nN][oO]|[nN] ]]; then
      salirDePractica="true"
    elif [[ "$temp" =~ [sS][iI]|[sS] ]]; then
      array=()
      clear | sacarHaciaArchivo "$archivoSalida" -a
      centrarEnPantalla "$(imprimirCuadro "50" "blanco" "Ejecutando el algoritmo de nuevo")" "n" | sacarHaciaArchivo "$archivoSalida" -a
    fi
  }
  # ------------------------------------------------

  # Saca spam
  # ------------------------------------------------
  function imprimirSpam() {
    local spam
    local gitSpam=("¡Gracias por usar nuestro algoritmo!" "Visita nuestro repositorio aquí abajo")
    spam="
▄▄▄▄▄▄▄  ▄▄▄ ▄    ▄   ▄▄▄▄▄▄▄
█ ▄▄▄ █  ▄▄█▀▀▄▄▀▀▄ ▀ █ ▄▄▄ █
█ ███ █ █ █▀██  █▀ ▄█ █ ███ █
█▄▄▄▄▄█ ▄▀█ █ ▄ ▄ ▄ ▄ █▄▄▄▄▄█
▄▄   ▄▄▄ █▄  ▄ █   ▀█   ▄▄   
▀▀▄██▀▄█▀▄▀▀ ▀██▄ ▀▀▄▀ ▀█ ▀▀ 
█▀▀ █▄▄█▀▄█ █ ▀ █ ▀ ▄▀▄▄ ▀  ▄
█▀   █▄█▀ █▀ ▄▀█  ▀▀█▄▀▀█▄▄▀▀
  ▀▄█▀▄▀▀▀▄▀▄▄▄▄█▄ █ ▄ █▀▄█ ▀
█▄ ██▄▄▀▀▀ █▄ ▄█▀  █  ▀▀█▄▀▀█
█ █▀ ▀▄█   █▄▄█▀▀▄█▄█▄█▄▄ ▄▄▄
▄▄▄▄▄▄▄ █▄▀▀█▄ █▄█▀▄█ ▄ ██▄  
█ ▄▄▄ █ ▀▄▄▄   █   ██▄▄▄█▄ █▄
█ ███ █   █▀▄▀ ██▄▄███▄▄▄███▀
█▄▄▄▄▄█ █   ▀▄▄ ▀▄ ▄  ██▄▀█ ▀
 "
    clear
    centrarEnPantalla "$(imprimirCuadro "50" "acierto" "${gitSpam[0]}")" "n"
    # centrarEnPantalla "$(imprimirCuadro "33" "default" "$spam")" "n"
  }
  # ------------------------------------------------

  # Main de main xD
  # ----------------------------------
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
