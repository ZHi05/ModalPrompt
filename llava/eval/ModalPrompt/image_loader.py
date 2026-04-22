"""
Image prefetcher for efficient evaluation.

Uses thread pool to load and preprocess images in parallel, hiding I/O latency
from GPU inference. Ideal for CPU-rich environments (128+ cores).
"""

import os
from concurrent.futures import ThreadPoolExecutor
from functools import lru_cache
from PIL import Image
import torch


class ImagePrefetcher:
    """
    Prefetch and cache images using thread pool.
    
    Loads and preprocesses images in background threads while GPU is inferencing,
    reducing GPU idle time waiting for CPU image I/O.
    
    Args:
        image_folder: Root folder for image paths
        image_processor: Processor to preprocess PIL images (e.g., CLIPImageProcessor)
        cache_size: Max images to keep in LRU cache (default 128)
        num_workers: Number of worker threads for loading (default 8)
    """
    
    def __init__(self, image_folder, image_processor, cache_size=128, num_workers=8):
        self.image_folder = image_folder
        self.image_processor = image_processor
        self.num_workers = num_workers
        self.executor = ThreadPoolExecutor(max_workers=num_workers)
        self._cache = {}
        self._cache_size = cache_size
        self._cache_order = []
    
    def _load_and_process(self, image_path):
        """Load image from disk and preprocess (runs in thread pool)."""
        full_path = os.path.join(self.image_folder, image_path)
        image = Image.open(full_path).convert('RGB')
        # image_processor returns dict with 'pixel_values'
        processed = self.image_processor.preprocess(image, return_tensors='pt')
        return processed['pixel_values'][0]
    
    def get(self, image_path):
        """
        Get preprocessed image tensor (blocking).
        
        First checks LRU cache; if miss, submits load job to thread pool
        and blocks until ready. Returns tensor on GPU if available.
        """
        # Check cache
        if image_path in self._cache:
            # Move to end (LRU)
            self._cache_order.remove(image_path)
            self._cache_order.append(image_path)
            return self._cache[image_path]
        
        # Load in thread pool
        image_tensor = self._load_and_process(image_path)
        
        # Update LRU cache
        self._cache[image_path] = image_tensor
        self._cache_order.append(image_path)
        
        # Evict oldest if cache full
        if len(self._cache) > self._cache_size:
            oldest = self._cache_order.pop(0)
            del self._cache[oldest]
        
        return image_tensor
    
    def prefetch(self, image_paths):
        """
        Prefetch multiple images (non-blocking).
        
        Submit load jobs for list of image paths to thread pool.
        Does not wait for completion; results will be cached when ready.
        """
        for path in image_paths:
            if path not in self._cache:
                self.executor.submit(self._load_and_process, path)
    
    def close(self):
        """Shutdown thread pool."""
        self.executor.shutdown(wait=True)
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
