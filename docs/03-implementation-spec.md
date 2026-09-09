# Jalan Sendiri — Technical Specification & Asset Pipeline

## 1. System Architecture Update

### State Machine Multi-Lantai (Per 1 Mini Chapter)
```text
GameState
├── current_chapter (1..4)
├── current_mini_chapter (1..5)
├── current_expedition_floor (1..3)
│   ├── Floor 1: 3-4 steps (Tier 1 stages)
│   ├── Floor 2: 5-6 steps (Tier 2 stages)
│   └── Floor 3: 7 steps + Final Boss Stage (Tier 3 stages)
├── current_step (0..max_steps)
└── active_floor_graph
```

### Algoritma Peta Ekspedisi Multi-Kolom
Peta per lantai dibuat dengan sistem graf terarah (*Directed Acyclic Graph* / DAG) dari kiri ke kanan atau bawah ke atas:
- Jumlah Kolom / Langkah: Sesuai konfigurasi lantai (Lt 1: 4 kolom; Lt 2: 6 kolom; Lt 3: 8 kolom).
- Setiap kolom memiliki 2–3 node pilihan bercabang.
- **Aturan Non-Repeating:** Generator memeriksa node pendahulu langsung (`parent_nodes`); tipe stage yang sama tidak akan ditempatkan berturut-turut pada cabang yang terhubung langsung.

## 2. Asset Generation & Implementation Pipeline

### Phase 1: High-Fidelity Backgrounds
- Dibuat menggunakan model generator gambar berbasis prompt *A Space for the Unbound style*.
- Format: PNG 1080x1920 (Portrait Mobile) dan 1920x1080 (Landscape Adaptive).
- Lokasi: `res://assets/backgrounds/`.

### Phase 2: Main Menu UI & Settings Modal
- Scene: `res://scenes/MainMenu.tscn`.
- Skrip: `res://scripts/MainMenu.gd`.
- Fitur:
  - Tombol Permainan Baru (memunculkan modal konfirmasi jika sudah ada savegame).
  - Tombol Lanjutkan Game (disabled jika belum ada savegame).
  - Modal Pengaturan: Slider BGM (Linear to Decibels), Slider SFX, Toggle Fullscreen.
  - Modal Kredit: Catatan apresiasi naratif.

### Phase 3: Stage Nodes & Map Redesign (Integrated Strategies)
- Scene: `res://scenes/ExpeditionMap.tscn`.
- Skrip: `res://scripts/ExpeditionMap.gd` & `res://scripts/map/ExpeditionNode.gd`.
- Visual: Menggambar garis konektor antar node menggunakan fungsi `_draw()` bawaan Godot (`draw_dashed_line`) dengan warna pensil cokelat lembut.

### Phase 4: Stage Handlers Mini Chapter 1.1
- 4 Scene Stage Khusus:
  1. `res://scenes/stages/StageBattle.tscn` (Battle vs Bug Skripsi / Dosen).
  2. `res://scenes/stages/StageCoffee.tscn` (Minigame / Dialog warung kopi kampus).
  3. `res://scenes/stages/StageShop.tscn` (Fotokopi & Bank).
  4. `res://scenes/stages/StageDilemma.tscn` (Dilema tugas vs koding).
