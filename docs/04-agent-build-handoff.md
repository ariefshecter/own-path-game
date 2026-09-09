# Jalan Sendiri — Agent Build Handoff (Mini Chapter 1.1 Focus)

## Mission
Bangun sistem Peta Ekspedisi 3 Lantai ala Arknights Integrated Strategies secara profesional dan hubungkan 4 variasi stage Tier 1 untuk Mini Chapter 1.1 pada game mobile Android 2D "Jalan Sendiri" di Godot 4.3 LTS.

## Core Non-Negotiables
1. **Peta 3 Lantai:** Satu Mini Chapter memiliki 3 Lantai Ekspedisi penuh:
   - Lantai 1: 4 langkah/kolom node.
   - Lantai 2: 6 langkah/kolom node.
   - Lantai 3: 7 langkah/kolom node + 1 Bos Mini Chapter.
2. **Aturan Non-Repeating:** Pada satu jalur yang terhubung langsung, tidak ada dua tipe stage identik yang berurutan.
3. **4 Variasi Stage Tier 1 (Khusus Mini Chapter 1.1):**
   - Stage 1A: [⚔ Beban] Debugging Skripsi Bab 4 (Battle).
   - Stage 1B: [☕ Warung] Kopi Belakang Kampus (Rest/Heal).
   - Stage 1C: [🏪 Kios] Fotokopi & ATK Barokah (Shop & Bank).
   - Stage 1D: [✉ Dilema] Ajakan Nongkrong vs Koding (Event).
4. **Visual Konektor Dinamis:** Garis antar-node digambar via `_draw()` canvas item (garis putus-putus pensil retro).

## Technical Implementation Plan
- `scripts/map/ExpeditionGenerator.gd`: Algoritma graf terarah (DAG) 3 lantai dengan validasi non-repeating.
- `scenes/ExpeditionMap.tscn` & `scripts/ExpeditionMap.gd`: Controller visual peta ekspedisi dengan HUD status, tombol kembali ke Hub, dan gambar garis konektor.
- `scenes/stages/StageBattle.tscn`, `StageCoffee.tscn`, `StageShop.tscn`, `StageDilemma.tscn`: Scene penanganan masing-masing stage.

## Acceptance Criteria
- [ ] Peta Lantai 1 Mini Chapter 1.1 ter-generate dengan 4 langkah vertikal/horizontal yang valid tanpa stage berulang berurutan pada satu jalur.
- [ ] Garis koneksi antar node terhubung dan digambar rapi di atas kertas background.
- [ ] Pemain dapat menyelesaikan stage demi stage, menerima reward, dan status berpindah ke lantai berikutnya.
- [ ] Engine Godot 4 headless lulus verifikasi 0 error.
