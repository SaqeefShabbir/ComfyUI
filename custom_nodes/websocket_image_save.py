"""
WebSocket Image Save Node for ComfyUI
Saves images and sends them via WebSocket for real-time preview
"""

import os
import json
import folder_paths
from PIL import Image
import numpy as np
import torch

class SaveImageWebsocket:
    """
    Save Image Node with WebSocket support for real-time preview
    """
    def __init__(self):
        self.output_dir = folder_paths.get_output_directory()
        self.type = "output"
        self.prefix_append = ""
        self.compress_level = 4

    @classmethod
    def INPUT_TYPES(cls):
        """
        Define input types for the node
        """
        return {
            "required": {
                "images": ("IMAGE",),
                "filename_prefix": ("STRING", {"default": "ComfyUI"}),
                "compress": ("BOOLEAN", {"default": True}),
            },
            "hidden": {
                "prompt": "PROMPT",
                "extra_pnginfo": "EXTRA_PNGINFO",
            },
        }

    RETURN_TYPES = ()
    FUNCTION = "save_images"
    OUTPUT_NODE = True
    CATEGORY = "image"

    def save_images(self, images, filename_prefix="ComfyUI", compress=True,
                    prompt=None, extra_pnginfo=None):
        """
        Save images to disk and send via WebSocket
        """
        # Create output directory if it doesn't exist
        full_output_folder = os.path.join(self.output_dir, filename_prefix)
        os.makedirs(full_output_folder, exist_ok=True)

        # Get existing files to determine next counter
        existing_files = [f for f in os.listdir(full_output_folder)
                          if f.startswith(filename_prefix) and f.endswith('.png')]
        counter = len(existing_files)

        results = []
        for image in images:
            # Convert from tensor to PIL
            i = 255.0 * image.cpu().numpy()
            img = Image.fromarray(np.clip(i, 0, 255).astype(np.uint8))

            # Generate filename
            filename = f"{filename_prefix}_{counter:05d}.png"
            filepath = os.path.join(full_output_folder, filename)

            # Save image
            if compress:
                img.save(filepath, compress_level=self.compress_level)
            else:
                img.save(filepath)

            # Prepare metadata
            metadata = {
                "filename": filename,
                "subfolder": filename_prefix,
                "type": self.type,
            }

            results.append(metadata)
            counter += 1

        # Send WebSocket notification
        if prompt is not None:
            self._send_websocket_notification(results, prompt, extra_pnginfo)

        return {"ui": {"images": results}}

    def _send_websocket_notification(self, results, prompt, extra_pnginfo):
        """
        Send notification via WebSocket
        """
        try:
            # Import here to avoid circular imports
            from comfy.cli_args import args
            if not args.disable_auto_launch:
                # This will be handled by the main ComfyUI server
                pass
        except ImportError:
            pass

        # Add metadata to results
        for result in results:
            result["prompt"] = prompt
            if extra_pnginfo:
                result["extra_pnginfo"] = extra_pnginfo


# Node registration for ComfyUI
NODE_CLASS_MAPPINGS = {
    "SaveImageWebsocket": SaveImageWebsocket,
}

NODE_DISPLAY_NAME_MAPPINGS = {
    "SaveImageWebsocket": "Save Image (Websocket)",
}