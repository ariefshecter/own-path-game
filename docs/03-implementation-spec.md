# Jalan Sendiri — Technical Specification (Narrative Adventure Engine)

## 1. Engine & Project Structure
- **Engine:** Godot Engine 4.3 LTS (GDScript).
- **Target:** Mobile Android (Portrait 1080x1920) / Desktop Preview.
- **Architecture:** Scene-driven finite state machine.

```text
res://
├── assets/
│   ├── backgrounds/         # bg_main_menu, bg_college_room, bg_campus, bg_coffee_stall
│   ├── sprites/             # protagonist, father, mother, dosen, cafe_girl, uncle, etc.
│   ├── audio/               # bgm_warm_loop, sfx_keyboard, sfx_paper, sfx_phone, sfx_tea
│   └── fonts/               # Nunito.ttf
├── scenes/
│   ├── MainMenu.tscn        # Menu awal profesional
│   ├── chapters/
│   │   ├── ch1/             # Scene mini chapter 1.1 s/d 1.5
│   │   │   ├── Ch1_1_Skripsi.tscn
│   │   │   ├── Ch1_2_FamilyWA.tscn
│   │   │   ├── Ch1_3_Sidang.tscn
│   │   │   ├── Ch1_4_Wisuda.tscn
│   │   │   └── Ch1_5_MejaMakan.tscn
│   │   ├── ch2/             # Mini chapter 2.1 s/d 2.5
│   │   ├── ch3/             # Mini chapter 3.1 s/d 3.5
│   │   └── ch4/             # Mini chapter 4.1 s/d 4.5
│   └── microgames/          # Prefab interaksi mikro reusable
│       ├── TypingCoding.tscn
│       ├── ScratchPaper.tscn
│       ├── PhoneMessage.tscn
│       └── BrewCoffee.tscn
├── scripts/
│   ├── autoload/
│   │   ├── GameState.gd     # Save/load progres chapter aktif
│   │   └── AudioManager.gd  # Controller audio global
│   └── dialogue/
│       └── DialogueBox.gd   # Controller typewriter dialog & pilihan
└── project.godot
```

## 2. Micro-Interaction Reusable Modules
1. **`TypingCoding.tscn`:** Menangkap sentuhan layar untuk memajukan kode program di editor teks, menghasilkan suara ketukan keyboard mekanik.
2. **`PhoneMessage.tscn`:** Simulasi antarmuka aplikasi pesan WA dengan gelembung chat yang muncul satu per satu dengan pilihan balasan cepat.
3. **`ScratchPaper.tscn`:** Interaksi menggeser jari di atas dokumen untuk mencoret catatan koreksi.

## 3. Save & Load System
- File: `user://savegame.json`.
- Menyimpan: `player_name`, `unlocked_chapter` (1..4), `unlocked_mini_chapter` (1..5), dan riwayat pilihan respon penting.
- Pemain dapat memilih scene mana saja yang sudah pernah diselesaikan melalui menu riwayat adegan.
