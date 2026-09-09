#!/usr/bin/env python3
"""
Generate mechanical keyboard keypress sound (sfx_keyboard.wav)
for coding micro-interaction.
"""

import wave
import struct
import math
import random
from pathlib import Path

SAMPLE_RATE = 44100
OUT_FILE = Path("/home/riefzy/Project/own-path-game/assets/audio/sfx_keyboard.wav")

def gen_keyboard_click():
    duration = 0.08
    n_frames = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n_frames):
        t = i / SAMPLE_RATE
        env = math.exp(-60 * t)
        # Click transient + slight resonant thud
        noise = (random.random() * 2 - 1) * 0.4
        thud = math.sin(2 * math.pi * 180 * t) * 0.6
        click = math.sin(2 * math.pi * 1200 * t) * 0.4
        samples.append((noise + thud + click) * env * 0.8)
        
    with wave.open(str(OUT_FILE), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        int_samples = [max(-32767, min(32767, int(s * 32767))) for s in samples]
        w.writeframes(struct.pack(f"<{len(int_samples)}h", *int_samples))
    print("Generated sfx_keyboard.wav")

if __name__ == "__main__":
    gen_keyboard_click()
