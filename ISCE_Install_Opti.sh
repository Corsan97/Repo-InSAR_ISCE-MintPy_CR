# Verificar si el usuario actual es root
if [ "$(id -u)" = "0" ]; then
    echo "Este script está siendo ejecutado por el usuario root."
else
    echo "Este script está siendo ejecutado por un usuario normal."
fi


#1 Actualización del sistema
apt update
apt upgrade

#2 Instalación de librerías y paquetes necesarios
apt-get install -y curl git build-essential gfortran libfftw3-3 libfftw3-dev xorg libx11-dev libxm4 libxt-dev python3-h5py facter libhdf5-dev scons python3-numpy gcc g++ make m4 python3-matplotlib python3-mpltoolkits.basemap python3-scipy python3-pulp python3-gdal libgdal-dev python3-pip libmotif-dev imagemagick grace cython3 libopencv-dev python3-opencv gdal-bin python3-astropy mlocate python3-pulp

#3 Definición de variables de entorno
ISCE_ROOT="/usr/local"
ISCE_HOME="$ISCE_ROOT"/isce
ISCE_TEMP=$HOME/isce_temp
ISCE_INSTALLER=$ISCE_TEMP/isce2
export SCONS_CONFIG_DIR=$ISCE_INSTALLER/SCONS_CONFIG_DIR

#4 Clonar repositorio de ISCE y cambiar a la versión 2.5.3
mkdir  $ISCE_TEMP
cd $ISCE_TEMP
git clone https://github.com/isce-framework/isce2.git
cd $ISCE_INSTALLER
git checkout tags/v2.5.3

#5 Modificar archivo de configuración si se está instalando en Ubuntu 22.04 LTS
sed -i_bkp "0,/GFORTRANFLAGS/s/'-ffixed-line-length-none'/'-fallow-argument-mismatch','-ffixed-line-length-none'/" $ISCE_TEMP/isce2/configuration/sconsConfigFile.py

#6 Crear archivo de configuración SConfigISCE
mkdir  $SCONS_CONFIG_DIR
file=$SCONS_CONFIG_DIR/SConfigISCE
hdf5Path=/usr/include/hdf5/serial
gdalPath=/usr/include/gdal
opencvPath=/usr/include/opencv4
gccV=`gcc -dumpversion`
pythonH=`find /usr/include/python3.9/Python.h`
pythonHDir=`dirname ${pythonH}`
sitePackages=sitePackages=`(python3 -c "import site; print(site.getsitepackages())" | tr -d [],"'")`

numpyPath="" 
for dir in $sitePackages 
do 
	part="/numpy/core/include" 
	DIR=$dir$part 
	if [ -d "$DIR" ]; then numpyPath=$DIR; fi 
done

#7 Escribir configuración en el archivo SConfigISCE
echo PRJ_SCONS_BUILD=$ISCE_HOME >> $file
echo PRJ_SCONS_INSTALL=$ISCE_HOME >> $file
echo LIBPATH=/usr/lib /usr/lib64 /usr/lib/gcc/x86_64-linux-gnu/$gccV/ /usr/lib/x86_64-linux-gnu/hdf5/serial >> $file
echo CPPPATH=$pythonHDir $numpyPath $hdf5Path $gdalPath $opencvPath >> $file
echo FORTRANPATH=/usr/include >> $file
echo FORTRAN=/usr/bin/gfortran>> $file
echo CC=/usr/bin/gcc >> $file
echo CXX=/usr/bin/g++ >> $file
echo MOTIFLIBPATH=/usr/lib/x86_64-linux-gnu >> $file
echo X11LIBPATH=/usr/lib/x86_64-linux-gnu >> $file
echo MOTIFINCPATH=/usr/include/Xm >> $file
echo X11INCPATH=/usr/include/X11 >> $file
echo ENABLE_CUDA=False >> $file

#8Entrar a la carpeta de instalación cd $ISCE_INSTALLER
cd $ISCE_INSTALLER

#9 Compilar e instalar ISCE
scons

#10 Generar stack de instalación
cp -r  $ISCE_INSTALLER/contrib/stack $ISCE_HOME/components/contrib/

#11 Limpiar directorio temporal
rm -rf $ISCE_TEMP

cd $HOME
#12 Instalación de Python3.9 para Ubuntu 22.04 LTS
apt-get install -y software-properties-common 
add-apt-repository ppa:deadsnakes/ppa 
apt-get install -y python3.9 python3.9-dev python3.9-venv python3.9-distutils python3.9-lib2to3 python3.9-gdbm python3.9-tk 
#13 configurar por defecto Python3.9 
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2 
update-alternatives --set python3 /usr/bin/python3.9

#14 Instalación de requerimientos
pip3 install --no-cache argon2-cffi==21.3.0 argon2-cffi-bindings==21.2.0 asttokens==2.0.5 attrs==21.4.0 backcall==0.2.0 beautifulsoup4==4.11.1 bleach==5.0.1 Cartopy==0.20.3 certifi==2022.6.15 cffi==1.15.1 charset-normalizer==2.1.0 click==8.1.3 click-plugins==1.1.1 cligj==0.7.2 cycler==0.11.0 debugpy==1.6.0 decorator==5.1.1 defusedxml==0.7.1 entrypoints==0.4 executing==0.8.3 fastjsonschema==2.15.3 Fiona==1.8.21 fonttools==4.33.3 geojson==2.5.0 geomet==0.3.0 geopandas==0.11.0 h5py==3.7.0 html2text==2020.1.16 idna==3.3 ipykernel==6.15.0 ipyleaflet==0.16.0 ipython==8.4.0 ipython-genutils==0.2.0 ipywidgets==7.7.1 jedi==0.18.1 Jinja2==3.1.2 jsonschema==4.6.1 jupyter==1.0.0 jupyter-client==7.3.4 jupyter-console==6.4.4 jupyter-core==4.10.0 jupyterlab-pygments==0.2.2 jupyterlab-widgets==1.1.1 kiwisolver==1.4.3 lab==7.1 lxml==4.9.0 MarkupSafe==2.1.1 matplotlib==3.5.2 matplotlib-inline==0.1.3 mistune==0.8.4 munch==2.5.0 nbclient==0.6.6 nbconvert==6.5.0 nbformat==5.4.0 nest-asyncio==1.5.5 notebook==6.4.12 numpy==1.23.0 opencv-python==4.6.0.66 packaging==21.3 pandas==1.4.3 pandocfilters==1.5.0 parso==0.8.3 pexpect==4.8.0 pickleshare==0.7.5 Pillow==9.1.1 prometheus-client==0.14.1 prompt-toolkit==3.0.30 psutil==5.9.1 ptyprocess==0.7.0 pure-eval==0.2.2 pycparser==2.21 Pygments==2.12.0 pyparsing==3.0.9 pyproj==3.3.1 pyrsistent==0.18.1 pyshp==2.3.0 python-dateutil==2.8.2 pytz==2022.1 pyzmq==23.2.0 qtconsole==5.3.1 QtPy==2.1.0 requests==2.28.1 scipy==1.8.1 Send2Trash==1.8.0 sentinelsat==1.1.1 Shapely==1.8.2 simplejson==3.17.6 six==1.16.0 soupsieve==2.3.2.post1 stack-data==0.3.0 terminado==0.15.0 tinycss2==1.1.1 tornado==6.2 tqdm==4.64.0 traitlets==5.3.0 traittypes==0.2.1 txt2tags==3.7 urllib3==1.26.9 wcwidth==0.2.5 webencodings==0.5.1 widgetsnbextension==3.6.1 xyzservices==2022.6.0 GDAL==3.4.3


#15 Perfil de usuario para login a la Earthdata para el acceso a la descarga de archivos online
echo machine urs.earthdata.nasa.gov > $HOME/.netrc
echo login nombre_usuario >> $HOME/.netrc 
echo password contraseña >> $HOME/.netrc

echo Instalación de script para la descarga de órbitas
pip3 install --no-cache click --upgrade
pip3 install --no-cache sentineleof

echo Configuración de variables de entorno
#16 Directorio principal de instalación 
export ISCE_ROOT="/usr/local"
#17 Nombre del directorio de instalación del software 
export ISCE_HOME="$ISCE_ROOT"/isce
export PATH="$ISCE_HOME"/bin:"$ISCE_HOME"/applications:$ISCE_HOME/components/contrib/stack/topsStack:"$PATH"
export PYTHONPATH="$ISCE_ROOT":"$ISCE_HOME"/applications:"$ISCE_HOME"/components:$ISCE_HOME/components/contrib/stack/topsStack

#18 Parámetros del script
stackSentinel.py --help

#19 Enviar a bash.bashrc
echo export PATH=$ISCE_HOME/bin:$ISCE_HOME/applications:$ISCE_HOME/components:$ISCE_HOME/components/contrib/stack/topsStack:$PATH >> /etc/bash.bashrc
echo export PYTHONPATH=$ISCE_ROOT:$ISCE_HOME/applications:$ISCE_HOME/components:$ISCE_HOME/components/contrib/stack/topsStack >> /etc/bash.bashrc

#20 Confirmar la configuración de variables de entorno
source /etc/bash.bashrc
echo "Instalación de ISCE y el script stackSentinel.py completada"
