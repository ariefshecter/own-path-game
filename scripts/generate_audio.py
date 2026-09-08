#!/usr/bin/env python3
"""
Generator efek suara sintetis retro & akustik WAV (16-bit PCM 44.1kHz)
Berlisensi bebas penuh / CC0 untuk game 'Jalan Sendiri'.
Menghasilkan:
- card_play.wav (gesekan kartu kertas taktil)
- coin.wav (gemerincing koin logam ganda)
- hit.wav (hentakan tumpul beban mental)
- shield.wav (nada resonansi perlindungan diri)
- bgm_acoustic_loop.wav (petikan melodi gitar akustik/lo-fi hangat berulang)
"""

import wave
import struct
import math
import random
from pathlib import Path

SAMPLE_RATE = 44100
OUT_DIR = Path("/home/riefzy/Project/own-path-game/assets/audio")
OUT_DIR.mkdir(parents=True, exist_ok=True)

def write_wav(filename, samples):
    with wave.open(str(OUT_DIR / filename), "w") as w:
        w.setnchannels(1) # mono
        w.setsampwidth(2) # 16-bit
        w.setframerate(SAMPLE_RATE)
        # Clamping
        int_samples = [max(-32767, min(32767, int(s * 32767))) for s in samples]
        raw_data = struct.pack(f"<{len(int_samples)}h", *int_samples)
        w.writeframes(raw_data)
    print(f"Generated: {filename} ({len(samples)} frames)")

# 1. Card Play (Swish kertas lembut)
def gen_card_play():
    duration = 0.18
    n_frames = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n_frames):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (i / n_frames))
        # Filtered noise + low tone
        noise = (random.random() * 2 - 1) * 0.4
        tone = math.sin(2 * math.pi * 320 * t) * 0.3
        samples.append((noise + tone) * env * 0.7)
    write_wav("card_play.wav", samples)

# 2. Coin (Chime logam cerah)
def gen_coin():
    duration = 0.35
    n_frames = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n_frames):
        t = i / SAMPLE_RATE
        env = math.exp(-12 * t)
        tone1 = math.sin(2 * math.pi * 987.77 * t) # B5
        tone2 = math.sin(2 * math.pi * 1318.51 * t) # E6
        samples.append((tone1 * 0.5 + tone2 * 0.5) * env * 0.8)
    write_wav("coin.wav", samples)

# 3. Hit / Impact (Hentakan beban tumpul)
def gen_hit():
    duration = 0.25
    n_frames = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n_frames):
        t = i / SAMPLE_RATE
        env = math.exp(-14 * t)
        freq = 160 * math.exp(-10 * t) + 40
        tone = math.sin(2 * math.pi * freq * t)
        noise = (random.random() * 2 - 1) * 0.25 * env
        samples.append((tone * 0.7 + noise) * env * 0.9)
    write_wav("hit.wav", samples)

# 4. Shield / Protect (Nada penenang damai)
def gen_shield():
    duration = 0.32
    n_frames = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n_frames):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (i / n_frames)) * math.exp(-3 * t)
        tone1 = math.sin(2 * math.pi * 440 * t) # A4
        tone2 = math.sin(2 * math.pi * 659.25 * t) # E5
        samples.append((tone1 * 0.5 + tone2 * 0.5) * env * 0.7)
    write_wav("shield.wav", samples)

# 5. BGM Akustik Hangat (Loop 8 baris birama berdurasi ~12 detik ala A Space for the Unbound)
def gen_bgm_warm_loop():
    # Chord progression santai di kunci D Mayor: D - G - Bm - A (hangat & nostaljik)
    bpm = 84
    beat_dur = 60.0 / bpm
    total_beats = 16
    total_dur = beat_dur * total_beats
    n_frames = int(SAMPLE_RATE * total_dur)
    samples = [0.0] * n_frames
    
    # Frekuensi akord (D, F#, A / G, B, D / B, D, F# / A, C#, E)
    chords = [
        # Bar 1 & 2: D Maj (146.83, 220.0, 293.66, 369.99)
        [146.83, 220.00, 293.66, 369.99],
        # Bar 3 & 4: G Maj (196.00, 246.94, 293.66, 392.00)
        [196.00, 246.94, 293.66, 392.00],
        # Bar 5 & 6: B min (123.47, 220.00, 293.66, 369.99)
        [123.47, 220.00, 293.66, 369.99],
        # Bar 7 & 8: A Sus / Maj (110.00, 220.00, 277.18, 329.63)
        [110.00, 220.00, 277.18, 329.63]
    ]
    
    for bar_idx, chord in enumerate(chords):
        bar_start_beat = bar_idx * 4
        # Petikan 4 nada per bar
        for note_idx in range(4):
            beat = bar_start_beat + note_idx
            note_time = beat * beat_dur
            freq = chord[note_idx % len(chord)]
            
            note_frames = int(SAMPLE_RATE * (beat_dur * 1.8))
            start_idx = int(note_time * SAMPLE_RATE)
            
            for j in range(note_frames):
                target_idx = start_idx + j
                if target_idx >= n_frames:
                    break
                t_note = j / SAMPLE_RATE
                # Pluck decay envelope
                env = math.exp(-3.2 * t_note)
                harm1 = math.sin(2 * math.pi * freq * t_note)
                harm2 = math.sin(2 * math.pi * (freq * 2) * t_note) * 0.35
                harm3 = math.sin(2 * math.pi * (freq * 3) * t_note) * 0.15
                wave_val = (harm1 + harm2 + harm3) * env * 0.22
                samples[target_idx] += wave_val

    write_wav("bgm_warm_loop.wav", samples)

if __name__ == "__main__":
    gen_card_play()
    gen_coin()
    gen_hit()
    gen_shield()
    gen_bgm_warm_loop()
