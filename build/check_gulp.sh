#!/usr/bin/sh
exit;
# Comprobamos si existe gulp
if ! type gulp >/dev/null 2>&1; then
    echo -ne 'No existe gulp, quiere instalarlo? [s/n]: ';
    read quiere;
    quiere=$(echo $quiere | tr '[:lower:]' '[:upper:]');

    if [ "$quiere" = "S" ];then
        echo -ne "Instalando gulp...";
        sudo npm rm --global gulp
        sudo npm install --global gulp-cli

        # Instalamos dependencias
        sudo npm install

    else
        echo 'Deberá instalar gulp manualmente';
        exit;
    fi
else
    echo 'Gulp está instalado correctamente';
fi

if ! type gulp >/dev/null 2>&1; then
    echo 'Algo ha ido mal en la instalacion, pruebe manualmente';
    exit;
fi
