- [SDOSTraduora](#sdostraduora)
  - [Introducción](#introducción)
  - [Instalación](#instalación)
    - [Añadir al proyecto](#añadir-al-proyecto)
    - [Como dependencia en Package.swift](#como-dependencia-en-packageswift)
  - [Cómo se usa](#cómo-se-usa)
    - [Ejecutar el script](#ejecutar-el-script)
    - [Textos en traduora](#textos-en-traduora)
    - [Parámetros del script](#parámetros-del-script)

# SDOSTraduora
- Changelog: https://github.com/SDOSLabs/SDOSTraduora/blob/master/CHANGELOG.md

## Introducción
SDOSTraduora es un script que genera los ficheros `.strings` a partir de un proyecto creado en un portal derivado de https://github.com/ever-co/ever-traduora. Esta plataforma permite definir los strings de un proyecto en varios idiomas y permite su acceso a través de API, por lo que puede ser usada para aplicaicones iOS y Android.

## Instalación

### Añadir al proyecto

Abrir Xcode y e ir al apartado `File > Add Packages...`. En el cuadro de búsqueda introducir la url del respositorio y seleccionar la versión:
```
https://github.com/SDOSLabs/SDOSTraduora.git
```
No se debe añadir a ningún target

### Como dependencia en Package.swift

``` swift
dependencies: [
    .package(url: "https://github.com/SDOSLabs/SDOSTraduora.git", .upToNextMajor(from: "2.0.0"))
]
```

No se debe añadir a ningún target

## Cómo se usa

### Ejecutar el script

Hay que lanzar un script durante antes de la compilación que generará los ficheros `.strings` configurados en el proyecto de traduora indicado. Estos ficheros deberán añadirse en el proyecto. Para la ejecución del script hay que seguir los siguientes pasos:

1. En Xcode: Pulsar sobre `File > New > Target...`, elegir la opción `Cross-platform`, seleccionar `Aggregate` e indicar el nombre `Traduora`
2. Seleccionar el proyecto, elegir el TARGET que acabamos de crear, seleccionar la pestaña de `Build Phases` y pulsar en añadir `New Run Script Phase` en el icono de **`+`** arriba a la izquierda
3. Renombrar el script a `Traduora`
4. Copiar el siguiente script:
    ```sh
    "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/SDOSTraduora/src/Scripts/SDOSTraduora" --server "${TRADUORA_SERVER}" --client-id "${TRADUORA_CLIENT_ID}" --client-secret "${TRADUORA_SECRET}" --project-id "${TRADUORA_PROJECT_ID}" --output-path "${SRCROOT}/${TRADUORA_OUTPUT_FOLDER}" --output-file-name "Localizable.generated.strings"
    ```
    > Los valores del script `${TRADUORA_SERVER}`, `${TRADUORA_CLIENT_ID}`, `${TRADUORA_SECRET}`, `${TRADUORA_PROJECT_ID}` y `${TRADUORA_OUTPUT_FOLDER}` deben ser sustituidos por los valores correspondientes a cada proyecto (ver el apartado [Parámetros del script](#parámetros-del-script))
5. Compilar el target `Traduora` para genere los ficheros `Localizable.generated.strings`
6. Al compilar se generararán los ficheros en la ruta `${SRCROOT}/${TRADUORA_OUTPUT_FOLDER}` y deberán ser incluidos en el proyecto. **Hay que añadir los fichero `.strings`, no las carpetas**

### Textos en traduora

Los textos que pongamos en la plataforma traduora permiten las siguientes adaptaciones a la hora de indicar parámetros para su compatibilidad con Android:

- Para añadir un parámetro de tipo `string` debemos mantener el siguiente formato:
  ```
  {%{{posición}}string}
  ```
    > Ejemplo: `"Hola, {%1string} y {%2string}"` da como salida `"Hola, %@ y %@"`

- Para añadir un parámetro de tipo `int` debemos mantener el siguiente formato:
  ```
  {%{{posición}}int}
  ```
    > Ejemplo: `"Hola, tengo {%1int} años."` da como salida `"Hola, tengo %ld años."`

- Si se trata de un texto que contenga un parámetro de tipo `int` pero con una longitud fija se define de la siguiente forma:
  ```
  {%{{posición}}{{longitud}}int}
  ```
  La variable `{{longitud}}` indicará los caracterés numéricos que siempre deberá tener el texto.
    > Ejemplo: `"Hola, mi número de teléfono es {%109int}"` da como salida `"Hola, mi número de teléfono es %09ld"`
---
En todos los casos la variable `{{posición}}` es la posición que ocupa el parámetro en la cadena de texto, empezando desde 1. Cada nuevo parámetro aumentará este valor en 1.

  > Ejemplo: `"Hola, {%1string} y {%2string}. Mi número de teléfono es {%109int}"` da como salida `"Hola, %@ y %@. Mi número de teléfono es %09ld"`

### Parámetros del script

Al llamar al script SDOSTraduora podemos usar los siguientes parámetros

|Parámetro|Obligatorio|Descripción|Ejemplo|
|---------|-----------|-----------|-----------|
|`--lang [valor]`||Locales a descargar separados por `;`. Si no se indica se descargan todos los locales disponibles en el proyecto|`es_ES;eu_ES`|
|`--client-id [valor]`|[x]| `client id` del proyecto creado en traduora | `6d7bdab2-9bf4-4207-8f9b-8b4fc092715c`|
|`--client-secret [valor]`|[x]|`client secret` del proyecto creado en traduora|`bXTaRO6ilBLtNykwXsuvaAbXtllbAwla`|
|`--project-id [valor]`|[x]|Identificador del proyecto de traduora|`f2413d5a-71b6-48ce-b27d-64a82dd71899`|
|`--server [valor]`|[x]|Dominio del servidor de traduora donde se deberá conectar para realizar la descarga de los ficheros|`traduora.myinstance.com`|
|`--output-path [valor]`|[x]|Carpeta de destino donde se descargaran las traduciones de traduora|`${SRCROOT}/main/resources/generated`|
|`--output-file-name [valor]`|[x]|Nombre de los ficheros descargados desde traduora|`Localizable.generated.strings`|
