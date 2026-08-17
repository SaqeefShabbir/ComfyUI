Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Optimizing ComfyUI for Speed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location E:\Projects\ComfyUI

# Create optimized startup script
Write-Host "[1/3] Creating optimized startup script..." -ForegroundColor Yellow
@"
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
"@ | Out-File -FilePath "start_optimized.bat" -Encoding ascii
Write-Host "Created start_optimized.bat" -ForegroundColor Green

# Create optimized workflow template
Write-Host "[2/3] Creating workflow template..." -ForegroundColor Yellow
@"
# ============================================
# OPTIMIZED WORKFLOW FOR CPU
# ============================================

## Model Choices (Choose one):
# 1. SDXL Turbo - Steps: 4, CFG: 2.0 (FASTEST)
# 2. SDXL Lightning - Steps: 8, CFG: 3.0 (FAST)
# 3. SDXL Base - Steps: 20, CFG: 7.5 (SLOW)

## Recommended Settings:
- Resolution: 768x768 or 896x896
- Batch Size: 1
- Preview Method: none

## KSampler Settings:
- Seed: Randomize
- Steps: 4 (Turbo) or 8 (Lightning)
- CFG: 2.0 (Turbo) or 3.0 (Lightning)
- Sampler: dpmpp_2m
- Scheduler: karras
- Denoise: 1.0

## Negative Prompt:
"worst quality, blurry, ugly, deformed, lowres, low quality"
"@ | Out-File -FilePath "OPTIMIZATION_GUIDE.txt" -Encoding ascii
Write-Host "Created OPTIMIZATION_GUIDE.txt" -ForegroundColor Green

# Create batch processing script
Write-Host "[3/3] Creating batch processing script..." -ForegroundColor Yellow
@"
# batch_generate.py
# Run: python batch_generate.py "your prompt here"

import json
import requests
import sys
import time

def generate_image(prompt, steps=4, cfg=2.0):
    workflow = {
        "1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "sd_xl_turbo_1.0.safetensors"}},
        "2": {"class_type": "CLIPTextEncode", "inputs": {"text": prompt, "clip": ["1", 1]}},
        "3": {"class_type": "CLIPTextEncode", "inputs": {"text": "worst quality, blurry, ugly, deformed", "clip": ["1", 1]}},
        "4": {"class_type": "EmptyLatentImage", "inputs": {"width": 768, "height": 768, "batch_size": 1}},
        "5": {"class_type": "KSampler", "inputs": {
            "model": ["1", 0], "positive": ["2", 0], "negative": ["3", 0], "latent_image": ["4", 0],
            "seed": int(time.time()), "steps": steps, "cfg": cfg, 
            "sampler_name": "dpmpp_2m", "scheduler": "karras", "denoise": 1.0
        }},
        "6": {"class_type": "VAEDecode", "inputs": {"samples": ["5", 0], "vae": ["1", 2]}},
        "7": {"class_type": "SaveImage", "inputs": {"filename_prefix": "ComfyUI", "images": ["6", 0]}}
    }
    
    print(f"Generating: {prompt}")
    print(f"Steps: {steps}, CFG: {cfg}")
    
    response = requests.post("http://127.0.0.1:8188/prompt", json={"prompt": workflow})
    return response.json()

if __name__ == "__main__":
    prompt = sys.argv[1] if len(sys.argv) > 1 else ""a cute orange cat with big eyes, sitting on a cozy window sill, sunlight coming through, digital art, 4k, highly detailed""
    generate_image(prompt)
"@ | Out-File -FilePath "batch_generate.py" -Encoding ascii
Write-Host "Created batch_generate.py" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Optimization complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start optimized ComfyUI:" -ForegroundColor Yellow
Write-Host "   start_optimized.bat" -ForegroundColor Cyan
Write-Host ""
Write-Host "Quick Settings:" -ForegroundColor Yellow
Write-Host "   Model: SDXL Turbo" -ForegroundColor Cyan
Write-Host "   Steps: 4" -ForegroundColor Cyan
Write-Host "   CFG: 2.0" -ForegroundColor Cyan
Write-Host "   Resolution: 768x768" -ForegroundColor Cyan
Write-Host ""