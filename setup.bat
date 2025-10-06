@echo off
echo ========================================
echo    COMPULSA - INSTALACION COMPLETA
echo ========================================
echo.

REM Verificar si Python está instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Python no está instalado.
    echo Por favor instala Python desde https://python.org
    pause
    exit /b 1
)

REM Verificar si Flutter está instalado
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Flutter no está instalado.
    echo Por favor instala Flutter desde https://flutter.dev
    pause
    exit /b 1
)

echo ✅ Python y Flutter detectados correctamente
echo.

REM Configurar Backend
echo 📦 Configurando Backend...
cd backend

REM Crear entorno virtual
if not exist "venv\" (
    echo Creando entorno virtual...
    python -m venv venv
)

REM Activar entorno virtual e instalar dependencias
echo Instalando dependencias del backend...
call venv\Scripts\activate.bat
pip install -r requirements.txt

REM Inicializar base de datos
echo Inicializando base de datos...
python init_db.py

echo ✅ Backend configurado correctamente
echo.

REM Volver al directorio raíz
cd ..

REM Configurar Frontend Flutter
echo 📱 Configurando Frontend Flutter...
echo Obteniendo dependencias de Flutter...
flutter pub get

echo ✅ Frontend configurado correctamente
echo.

echo ========================================
echo        INSTALACION COMPLETADA
echo ========================================
echo.
echo Para iniciar la aplicación:
echo.
echo 1. Backend: cd backend ^&^& start.bat
echo 2. Frontend: flutter run
echo.
echo La API estará disponible en: http://localhost:8000
echo Documentación: http://localhost:8000/docs
echo.
pause