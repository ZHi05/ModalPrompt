import os
from collections import OrderedDict
from concurrent.futures import ThreadPoolExecutor

from PIL import Image


class ImagePrefetcher:
    def __init__(self, image_folder, image_processor, cache_size=128, num_workers=8):
        self.image_folder = image_folder
        self.image_processor = image_processor
        self.executor = ThreadPoolExecutor(max_workers=num_workers)
        self._cache_size = cache_size
        self._cache = OrderedDict()
        self._futures = {}

    def _load_and_process(self, image_path):
        full_path = os.path.join(self.image_folder, image_path)
        with Image.open(full_path) as image:
            image = image.convert("RGB")
            processed = self.image_processor.preprocess(image, return_tensors="pt")
        return processed["pixel_values"][0]

    def _put_cache(self, image_path, image_tensor):
        if image_path in self._cache:
            self._cache.move_to_end(image_path)
        self._cache[image_path] = image_tensor
        if len(self._cache) > self._cache_size:
            self._cache.popitem(last=False)

    def _submit(self, image_path):
        if image_path in self._cache or image_path in self._futures:
            return
        self._futures[image_path] = self.executor.submit(self._load_and_process, image_path)

    def prefetch(self, image_paths):
        for path in image_paths:
            self._submit(path)

    def get(self, image_path):
        if image_path in self._cache:
            self._cache.move_to_end(image_path)
            return self._cache[image_path]

        future = self._futures.pop(image_path, None)
        if future is None:
            future = self.executor.submit(self._load_and_process, image_path)

        image_tensor = future.result()
        self._put_cache(image_path, image_tensor)
        return image_tensor

    def close(self):
        self.executor.shutdown(wait=True)
