# Jalan Sendiri (Own Path) — Technical Implementation Spec

## 1. Summary
Dokumen spesifikasi teknis untuk membangun game mobile 2D roguelike deckbuilder "Jalan Sendiri" pada platform Android menggunakan Godot Engine 4 (GDScript). Dokumen ini merinci arsitektur sistem, skema data kartu dan node, state machine pertempuran, logika perbankan/ekonomi ganda, serta fase build bertahap.

## 2. Market & Similar Products Check
- **Slay the Spire / Night of the Full Moon:** Fondasi battle turn-based kartu, kalkulasi energi, dan intent musuh.
- **Arknights: Integrated Strategies (IS):** Pola eksplorasi lantai 1-5 bercabang, pemilihan risiko jalur, toko, serta pembagian relik sementara.
- **Diferensiasi "Jalan Sendiri":**
  - Tema bukan fantasi magis, melainkan perjuangan eksistensial, batas finansial, dan mental kemandirian anak muda.
  - Mekanik *Banking Dilemma*: mentransfer uang operasional saat ini menjadi tabungan abadi masa depan yang mengubah kalkulasi resiko bertahan vs berkembang.
  - Struktur checkpoint per mini chapter yang bersahabat untuk sesi bermain mobile santai (5-10 menit per mini chapter).

## 3. Recommended Technical Stack
- **Game Engine:** Godot Engine 4.3 LTS (2D Mode, Renderer: Mobile / Forward+ kompatibel GL Compatibility untuk Android luas).
- **Bahasa Skrip:** GDScript (native, zero compile overhead, performa tinggi untuk game 2D).
- **Penyimpanan Lokal:** `user://savegame.json` dengan enkripsi string XOR sederhana atau AES bawaan Godot `FileAccess.open_encrypted_with_pass`.
- **Target OS:** Android 8.0+ (API Level 26 s/d 34). Target orientasi: Portrait (1080x1920 viewport dasar).
- **Aset Pipeline:** Kenney Assets (UI Pack, 1-bit / monochrome icons, UI audio FX) diimpor langsung ke folder `res://assets/`.

## 4. System Architecture & Core Modules

```text
res://
├── assets/                  # Texture, Audio, Fonts (CC0)
├── data/                    # JSON / Custom Resource data (Cards, Enemies, Events, Upgrades)
│   ├── cards.json
│   ├── enemies.json
│   ├── events.json
│   └── meta_upgrades.json
├── scenes/
│   ├── hub/                 # Layar kamar, upgrade tabungan, pilih chapter
│   ├── map/                 # Layar node lantai 1-5 bercabang
│   ├── battle/              # Layar pertempuran kartu
│   ├── shop/                # Layar toko & konter bank
│   └── event/               # Layar dilema/narasi acak
├── scripts/
│   ├── autoload/            # Singletons
│   │   ├── GameManager.gd   # Navigasi scene global & lifecycle run
│   │   ├── PlayerData.gd    # Data permanen (tabungan, level akun, unlock)
│   │   └── AudioManager.gd  # Controller SFX dan musik latar
│   ├── controllers/         # Logika flow game
│   │   ├── MapGenerator.gd  # Algoritma pembagian cabang node 5 lantai
│   │   └── BattleManager.gd # Turn manager, deck cycling, damage calculator
│   └── entities/            # Objek kartu, musuh, buff
│       ├── CardData.gd
│       ├── EnemyData.gd
│       └── BuffData.gd
└── project.godot
```

## 5. Data Model & Schema

### A. Player Profile (`PlayerData.gd`)
```json
{
  "profile_name": "Jalan Mandiri",
  "permanent_level": 1,
  "bank_savings": 0,
  "unlocked_chapters": {
    "chapter_1": 1,
    "chapter_2": 0,
    "chapter_3": 0
  },
  "purchased_meta_buffs": [
    "base_sanity_boost_1",
    "starting_energy_efficiency"
  ]
}
```

### B. In-Run State (`RunManager.gd`)
```json
{
  "current_chapter": 1,
  "current_mini_chapter": 1,
  "current_floor": 1,
  "max_floors": 5,
  "run_sanity_max": 80,
  "run_sanity_current": 80,
  "run_coins": 100,
  "run_exp": 0,
  "run_level": 1,
  "active_run_buffs": [],
  "deck_cards": ["card_refuse", "card_rest", "card_work", "card_work", "card_focus"],
  "floor_map_nodes": []
}
```

### C. Card Data Structure (`cards.json`)
```json
[
  {
    "id": "card_refuse",
    "name": "Menolak Tuntutan",
    "energy_cost": 1,
    "type": "ACTION",
    "effects": [
      { "target": "ENEMY", "type": "DAMAGE", "value": 8 },
      { "target": "SELF", "type": "SHIELD", "value": 3 }
    ],
    "description": "Hadapi masalah dengan ketegasan: Berikan 8 Tekanan dan dapatkan 3 Pertahanan Mental."
  },
  {
    "id": "card_rest",
    "name": "Menarik Napas",
    "energy_cost": 1,
    "type": "DEFENSE",
    "effects": [
      { "target": "SELF", "type": "SHIELD", "value": 8 }
    ],
    "description": "Ambil jeda sejenak. Dapatkan 8 Pertahanan Mental."
  },
  {
    "id": "card_overtime",
    "name": "Kerja Lembur",
    "energy_cost": 2,
    "type": "ACTION",
    "effects": [
      { "target": "ENEMY", "type": "DAMAGE", "value": 14 },
      { "target": "SELF", "type": "GAIN_COINS", "value": 15 }
    ],
    "description": "Korbankan stamina: Berikan 14 Tekanan dan dapatkan 15 Uang Run tambahan."
  }
]
```

## 6. Procedural Map Generator Logic (`MapGenerator.gd`)
1. Setiap mini chapter memiliki 5 lantai linear (Lantai 1 sampai 5).
2. Setiap lantai memiliki 2 sampai 3 opsi node:
   - Lantai 1: 2 Node (Gameplay Utama / Battle ringan).
   - Lantai 2: 2-3 Node (Campuran Battle & Dilema/Event).
   - Lantai 3: 3 Node (Battle, Dilema, atau Kios Toko).
   - Lantai 4: 2 Node (Kios Toko & Bank atau Event krusial).
   - Lantai 5: 1 Node Final (Bos/Puncak Mini Chapter).
3. Pemain memilih satu node di lantai saat ini, yang membuka akses ke node-node yang terhubung di lantai berikutnya.

## 7. Dual-Economy & Banking Algorithm
- **Uang Run (Dompet):**
  - Didapat dari memenangkan Stage Battle (+20-40 koin) atau opsi Event tertentu.
  - Digunakan untuk: beli kartu baru di Toko (biaya: 40-75 koin), beli buff run sementara (50-100 koin), atau pulihkan Mental (30 koin).
- **Tabungan Abadi (Rekening Bank):**
  - Hanya dapat diisi di Node Kios Toko & Bank melalui fitur "Setor ke Rekening".
  - Uang run dikurangi `X`, tabungan bank permanen bertambah `X`.
  - Jika pemain kalah/kewarasan habis di run, uang tabungan di bank **tidak hilang**, sedangkan uang run di dompet **hangus**.
  - Tabungan diakses di Layar Hub/Kamar untuk membeli upgrade permanen (misal: +10 Base Max Sanity, +1 Kartu Awal Pilihan).

## 8. Implementation Phases

### Fase 1: Core Engine & Data Backbone (Sprint 1)
- Setup project Godot 4.3 dengan resolusi portrait mobile 1080x1920 (aspect expand/shrink-fit).
- Implementasi `GameManager`, `PlayerData`, dan sistem simpan-muat data lokal `savegame.json`.
- Impor data kartu, musuh, dan event dari JSON.

### Fase 2: Turn-Based Battle Module (Sprint 2)
- Scene `BattleController.tscn` lengkap: Player Area, Enemy Area, Hand Container.
- Logika draw card (default 4 kartu/turn), discard pile reshuffle jika draw pile kosong.
- Penghitungan damage, shield (bertahan sampai giliran pemain berikutnya), dan aksi musuh berdasarkan AI pattern sederhana.

### Fase 3: Map Exploration & Event/Shop Modules (Sprint 3)
- Pembuatan visual node map 5 lantai dan interaksi navigasi.
- Implementasi scene `ShopScene.tscn` dengan slider transaksi Bank Setoran.
- Implementasi dialog event naratif acak dengan 2 pilihan respon berbobot peluang.

### Fase 4: Progression Loop, Narrative Chapters & Polish (Sprint 4)
- Menghubungkan Chapter 1, 2, dan 3 (total 15 mini chapter) dengan kurva kesulitan.
- Scene penutup (Epilog Chapter 3-5: kematian protagonis yang damai dan reflektif).
- Integrasi audio (SFX klik kartu, ketukan, koin, musik ambient syahdu).
- Android build export (.apk) dan pengujian sentuh pada resolusi smartphone.

## 9. Verification & Testing Plan
- **Unit Logic Checks:**
  - Fungsi draw kartu merombak discard pile tanpa duplikasi atau kartu hilang.
  - Perhitungan shield menyerap damage dengan benar sebelum mengurangi Mental.
  - Uang bank bertambah persis sebesar nominal setoran dan tetap tersimpan saat game ditutup paksa.
- **Integration Flow Checks:**
  - Gagal di Lantai 4 Mini Chapter 2-2 mengulang dari Lantai 1 Mini Chapter 2-2 (bukan mengulang dari Mini Chapter 1-1).
  - Selesai Lantai 5 berhasil meng-unlock mini chapter berikutnya.
  - Chapter 3 Mini Chapter 5 Lantai 5 memicu trigger scene ending khusus.
- **Android Device Check:**
  - Uji tap dan drag responsif di resolusi layar 16:9 dan 20:9 tanpa UI terpotong notch kamera.

## 10. Risks & Mitigations
- **Resiko:** Gameplay deckbuilder terlalu rumit diimplementasikan solo.
  - *Mitigasi:* Sederhanakan keyword kartu di awal hanya 4 tipe dasar (Serang, Tangkis, Fokus Energi, Pulih Mental).
- **Resiko:** Ketiadaan aset grafis membuat game terasa hambar.
  - *Mitigasi:* Gunakan tipografi yang kuat, kutipan dialog reflektif yang puitis, dan palet warna monokrom gelap elegan beraksen emas/biru.
