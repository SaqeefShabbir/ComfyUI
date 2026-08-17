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
