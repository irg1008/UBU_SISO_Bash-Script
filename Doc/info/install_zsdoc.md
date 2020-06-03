## Información de instalación de "zsdoc"

#### Requisitos:

- Git para la instalación
    $ sudo apt install git
    $ sudo pacman -S git (ArchLinux)

- ZSH (otra shell como bash o sh, a veces viene integrada)
    $ sudo apt install zsh
    $ sudo pacman -S zsh (ArchLinux)

- Tree (generar documentación)
    $ sudo apt install tree
    $ sudo pacman -S tree (ArchLinux)

- Gem (Necesario para las siguientes instalaciones)
    $ sudo apt install gem
    $ pacman -S gem (ArchLinux)

- Asciidoctor (convertir la documentación)
    $ sudo apt install asciidoctor
    $ sudo gem install asciidoctor (ArchLinux)

- Asciidoctor-pdf (generar PDFs)
    $ sudo gem install asciidoctor-pdf --pre

- Pandoc (Generador Docx)
    $ sudo apt install pandoc
    $ pacman -S pandoc (ArchLinux)

### Pasos:

1. Clonamos el repositorio de "ZSHELLDOC"
    $ git clone https://github.com/zdharma/zshelldoc
2. Entramos en el
    $ cd zshelldoc
3. Hacemos make del repositorio (acceso general)
    $ make
4. (Opcional). Podemos eliminar el repositorio descargado
    $ rm -r zshelldoc

Ya podemos documentar cualquier script con las anteriores herramientas.

### Documentar un Script

1. Generar ADOC: 
    $ zsd --scomm --bash "$path_script"
    - Generará la carpeta ./zsdoc
    - --scomm: Elimina "#" de los comentarios
    - --bash: tipo de shell utilizada en el script a documentar

2. Generar HTML:
    $ asciidoctor "$path_adoc"

3. Generar PDF:
    $ asciidoctor -b pdf -r asciidoctor-pdf "$adoc_path"

4. Generar DOC:
    $ asciidoctor --backend docbook --out-file - "$adoc_path" | pandoc --from docbook --to docx --output "./zsdoc/$doc_name.docx"

# Más Información

    - Cómo modificar un .adoc
    https://asciidoctor.org/docs/user-manual/
        - Añadir índice (table of contents)
            Añadir :toc: