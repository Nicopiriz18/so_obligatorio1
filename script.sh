#!/bin/bash

# Verificar si existe el archivo de admins, si no, crearlo y agregar usuario admin:admin:nombre
if [ ! -f admins.txt ]; then
    echo "admin:admin:Administrador" > admins.txt
fi

# Crear archivos necesarios si no existen
touch clientes.txt
touch mascotas.txt
touch adopciones.txt

# Función para mostrar el menú del administrador
menu_admin() {
    while true; do
        echo "----- Menú Administrador -----"
        echo "1. Registrar usuario"
        echo "2. Registro de mascotas"
        echo "3. Estadísticas de adopción"
        echo "4. Salir"
        read -p "Seleccione una opción: " opcion_admin
        case $opcion_admin in
            1) registrar_usuario ;;
            2) registrar_mascota ;;
            3) estadisticas_adopcion ;;
            4) break ;;
            *) echo "Opción inválida" ;;
        esac
    done
}

# Función para mostrar el menú del cliente
menu_cliente() {
    while true; do
        echo "----- Menú Cliente -----"
        echo "1. Listar mascotas disponibles para adopción"
        echo "2. Adoptar mascota"
        echo "3. Salir"
        read -p "Seleccione una opción: " opcion_cliente
        case $opcion_cliente in
            1) listar_mascotas ;;
            2) adoptar_mascota ;;
            3) break ;;
            *) echo "Opción inválida" ;;
        esac
    done
}

# Función para registrar un nuevo usuario
registrar_usuario() {
    echo "----- Registrar Usuario -----"
    read -p "Nombre: " nombre
    read -p "Cédula: " cedula
    read -p "Número de teléfono: " telefono
    read -p "Fecha de nacimiento (dd/mm/yyyy): " fecha_nacimiento
    read -p "Tipo de usuario (admin/cliente): " tipo_usuario
    read -p "Contraseña: " password

    # Verificar si el usuario ya existe
    if grep -q "^$cedula:" clientes.txt || grep -q "^$cedula:" admins.txt; then
        echo "El usuario ya existe."
    else
        if [ "$tipo_usuario" == "admin" ]; then
            echo "$cedula:$password:$nombre" >> admins.txt
        elif [ "$tipo_usuario" == "cliente" ]; then
            echo "$cedula:$password:$nombre" >> clientes.txt
        else
            echo "Tipo de usuario inválido."
            return
        fi
        echo "Usuario registrado exitosamente."
    fi
}

# Función para registrar una nueva mascota
registrar_mascota() {
    echo "----- Registrar Mascota -----"
    read -p "Número Identificador: " id_mascota
    # Verificar que sea un número entero
    if ! [[ "$id_mascota" =~ ^[0-9]+$ ]]; then
        echo "El número identificador debe ser un número entero."
        return
    fi
    # Verificar que no se repita
    if grep -q "^$id_mascota;" mascotas.txt; then
        echo "El número identificador ya existe."
        return
    fi
    read -p "Tipo de mascota: " tipo_mascota
    read -p "Nombre: " nombre_mascota
    read -p "Sexo: " sexo_mascota
    read -p "Edad: " edad_mascota
    # Verificar que la edad sea un número entero mayor a cero
    if ! [[ "$edad_mascota" =~ ^[1-9][0-9]*$ ]]; then
        echo "La edad debe ser un número entero mayor a cero."
        return
    fi
    read -p "Descripción: " descripcion_mascota
    read -p "Fecha de ingreso al sistema (dd/mm/yyyy): " fecha_ingreso

    echo "$id_mascota;$tipo_mascota;$nombre_mascota;$sexo_mascota;$edad_mascota;$descripcion_mascota;$fecha_ingreso" >> mascotas.txt
    echo "Mascota registrada exitosamente."
}

# Función para mostrar estadísticas de adopción
estadisticas_adopcion() {
    echo "----- Estadísticas de Adopción -----"
    if [ ! -s adopciones.txt ]; then
        echo "No hay adopciones registradas."
        return
    fi

    total_adoptadas=0
    suma_edades=0
    tipos_contador=()
    tipos_lista=()
    meses_contador=()
    meses_lista=()

    while IFS=';' read -r id tipo nombre sexo edad descripcion fecha_ingreso fecha_adopcion; do
        total_adoptadas=$((total_adoptadas + 1))
        suma_edades=$((suma_edades + edad))

        # Contar tipos
        encontrado_tipo=0
        for i in "${!tipos_lista[@]}"; do
            if [ "${tipos_lista[$i]}" == "$tipo" ]; then
                tipos_contador[$i]=$((tipos_contador[$i] + 1))
                encontrado_tipo=1
                break
            fi
        done
        if [ $encontrado_tipo -eq 0 ]; then
            tipos_lista+=("$tipo")
            tipos_contador+=(1)
        fi

        # Contar meses
        mes=$(echo "$fecha_adopcion" | cut -d'/' -f2)
        encontrado_mes=0
        for i in "${!meses_lista[@]}"; do
            if [ "${meses_lista[$i]}" == "$mes" ]; then
                meses_contador[$i]=$((meses_contador[$i] + 1))
                encontrado_mes=1
                break
            fi
        done
        if [ $encontrado_mes -eq 0 ]; then
            meses_lista+=("$mes")
            meses_contador+=(1)
        fi

    done < adopciones.txt

    # Porcentaje de adopción por tipo de mascota
    echo "Porcentaje de adopción por tipo de mascota:"
    for i in "${!tipos_lista[@]}"; do
        tipo="${tipos_lista[$i]}"
        count_tipo="${tipos_contador[$i]}"
        porcentaje=$(( (100 * count_tipo) / total_adoptadas ))
        echo "Tipo $tipo: $porcentaje% de adopciones"
    done

    # Mes con más adopciones
    max_adopciones=0
    mes_max=""
    for i in "${!meses_lista[@]}"; do
        mes="${meses_lista[$i]}"
        count_mes="${meses_contador[$i]}"
        if [ "$count_mes" -gt "$max_adopciones" ]; then
            max_adopciones=$count_mes
            mes_max=$mes
        fi
    done
    echo "El mes con más adopciones es: $mes_max con $max_adopciones adopciones"

    # Edad promedio de animales adoptados
    promedio_edad=$((suma_edades / total_adoptadas))
    echo "La edad promedio de los animales adoptados es: $promedio_edad años"
}

# Función para listar mascotas disponibles
listar_mascotas() {
    echo "----- Mascotas Disponibles para Adopción -----"
    if [ ! -s mascotas.txt ]; then
        echo "No hay mascotas disponibles."
    else
        while IFS=';' read -r id tipo nombre sexo edad descripcion fecha_ingreso; do
            echo "$id - $nombre - $tipo - $edad años - $descripcion"
        done < mascotas.txt
    fi
}

# Función para adoptar una mascota
adoptar_mascota() {
    echo "----- Adoptar Mascota -----"
    if [ ! -s mascotas.txt ]; then
        echo "No hay mascotas disponibles para adoptar."
        return
    fi
    listar_mascotas
    read -p "Ingrese el número de la mascota que desea adoptar: " id_adoptar
    # Eliminar espacios en blanco
    id_adoptar=$(echo "$id_adoptar" | xargs)
    # Buscar la mascota
    mascota_line=$(grep "^$id_adoptar;" mascotas.txt)
    if [ -z "$mascota_line" ]; then
        echo "Mascota no encontrada."
    else
        # Confirmar adopción
        read -p "¿Está seguro que desea adoptar esta mascota? (s/n): " confirmar
        if [ "$confirmar" == "s" ]; then
            # Agregar a adopciones.txt
            fecha_adopcion=$(date +"%d/%m/%Y")
            echo "$mascota_line;$fecha_adopcion" >> adopciones.txt
            # Eliminar de mascotas.txt
            grep -v "^$id_adoptar;" mascotas.txt > temp_mascotas.txt && mv temp_mascotas.txt mascotas.txt
            echo "Adopción realizada exitosamente."
        else
            echo "Adopción cancelada."
        fi
    fi
}

# Inicio del script
while true; do
    echo "----- Autenticación -----"
    read -p "Usuario (Cédula): " usuario
    if [ -z "$usuario" ]; then
        echo "El nombre de usuario no puede estar vacío."
        continue
    fi
    read -sp "Contraseña: " password
    echo ""
    # Verificar si el usuario está en admins.txt
    if grep -q "^$usuario:$password:" admins.txt; then
        # Obtener el nombre del administrador
        nombre_usuario=$(grep "^$usuario:$password:" admins.txt | cut -d':' -f3)
        echo "Bienvenido, administrador $nombre_usuario."
        menu_admin
    elif grep -q "^$usuario:$password:" clientes.txt; then
        # Obtener el nombre del cliente
        nombre_usuario=$(grep "^$usuario:$password:" clientes.txt | cut -d':' -f3)
        echo "Bienvenido, $nombre_usuario."
        menu_cliente
    else
        echo "Credenciales incorrectas."
    fi
done
