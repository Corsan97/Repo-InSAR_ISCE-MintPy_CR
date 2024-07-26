# Verificar si el usuario actual es root
if [ "$(id -u)" = "0" ]; then
    echo "Este script está siendo ejecutado por el usuario root."
else
    echo "Este script está siendo ejecutado por un usuario normal."
fi
echo "Iniciando instalación de MintPy"
cd $HOME
#Se crea carpeta tools
#mkdir tools

#Se clona  el repositorio de MintPy 
git clone https://github.com/insarlab/MintPy.git

#Instalación de MintPy
sudo python3 -m pip install MintPy

#Requerimientos de MintPy
sudo pip3 install --no-cache cartopy cvxopt dask>=1.0 dask-jobqueue>=0.3 defusedxml h5py joblib lxml matplotlib numpy pyaps3>=0.3 pykml>=0.2 pyproj pyresample pysolid scikit-image utm

#Nombre del directorio de instalación del software
export MINTPY_HOME=$HOME/MintPy
export PATH=${PATH}:${MINTPY_HOME}/mintpy
export PYTHONPATH=${PYTHONPATH}:${MINTPY_HOME}

smallbaselineApp.py --help

echo "Instalación de MintPy y smallbaselineApp.py completada"
echo "Iniciando instalación de PyAPS (modelo de corrección atmosférica ERA5) completada"

#Clonar el repositorio de PyAPS para la corrección atmosférica
git clone https://github.com/insarlab/PyAPS.git --depth 1

#cdsapi
pip3 install cdsapi

sudo echo url: https://cds.climate.copernicus.eu/api/v2 > $HOME/.cdsapirc 
sudo echo key: 12345:abcdefghij-134-abcdefgadf-82391b9d3f >> $HOME/.cdsapirc

#Verificar la correcta instalación de ISCE
python3 PyAPS/tests/test_dload.py
export DISPLAY=:0
python3 PyAPS/tests/test_calc.py

#Variable de entorno para descarga de modelo ERA5
echo export WEATHER_DIR=/era5 | sudo tee -a /etc/bash.bashrc > /dev/null

#Nombre del directorio de instalación del software hacia el bash.bashrc
echo export PATH=${PATH}:${MINTPY_HOME}/mintpy | sudo tee -a /etc/bash.bashrc > /dev/null
echo export PYTHONPATH=${PYTHONPATH}:${MINTPY_HOME} | sudo tee -a /etc/bash.bashrc > /dev/null

echo "Instalación de PyAPS (modelo de corrección atmosférica ERA5) completada"
