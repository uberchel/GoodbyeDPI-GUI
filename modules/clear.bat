@echo off
cls

echo.
echo 🧹 Очистка проекта Delphi от временных и ненужных файлов...
echo =========================================================

echo.
echo 📂 Текущая папка: %cd%
echo.

:: Список расширений для удаления
set "files=*.ddp *.cfg *.dof *.dcu *.tds *.local *.obj *.identcache *.tvsconfig *.dsk *.dproj.local *.exe *.map *.log *.backup *_tmp.*"

:: Удаляем файлы
echo 🗑 Удаляю временные и ненужные файлы...
echo.

for %%f in (%files%) do (
    if exist "%%f" (
        del /q "%%f"
        echo   Удалён: %%f
    )
)

:: Удаляем папки (если есть)