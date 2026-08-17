@echo off
echo ========================================
echo   ComfyUI - Optimized for Speed
echo ========================================
echo.

cd /d "E:\Projects\ComfyUI"
call comfyui_env\Scripts\activate

:: Optimized settings
set PYTORCH_ENABLE_MPS_FALLBACK=1
set PYTHONWARNINGS=ignore

echo Starting with optimized settings...
echo Resolution: 768x768
echo Steps: 4 (Turbo) or 8 (Lightning)
echo Memory: Low VRAM mode
echo.

python main.py --listen --cpu --preview-method none --reserve-vram 1024

pause
