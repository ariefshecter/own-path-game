# Jalan Sendiri (Own Path) — Agent Build Handoff

## Mission
Bangun game mobile Android 2D bergenre roguelike deckbuilder menggunakan Godot Engine 4 (GDScript). Game ini mengusung tema perjuangan mandiri anak muda yang melepaskan ekspektasi orang tua, mengeksplorasi 3 Chapter (15 Mini Chapter, masing-masing 5 lantai bernode acak), mengelola sistem keuangan ganda (uang run vs setoran bank tabungan permanen), dan diakhiri dengan kematian damai sang tokoh utama pada akhir Chapter 3. Seluruh aset grafis dan audio memanfaatkan aset gratis/open-source berlisensi CC0.

## Product Vision
Sebuah game indie naratif-reflektif yang mengubah rasa frustrasi tuntutan sosial menjadi mekanisme roguelike yang adiktif, mendalam, dan emosional di genggaman ponsel.

## User Experience Goals
- Kontrol satu tangan (portrait) yang intuitif dengan sentuhan tap/drag kartu yang responsif.
- Sensasi ketegangan saat memilih jalur node lantai dan mengorbankan uang operasional ke tabungan bank.
- Atmosfer grafis minimalis elegan yang tidak melelahkan mata berkat tema *Dark Slate & Amber Gold*.

## Non-Negotiable Requirements
1. **Engine & Format:** Godot Engine 4.x, orientasi Portrait Android, offline-first tanpa koneksi internet.
2. **Struktur Level:** 3 Chapter, tiap chapter 5 Mini Chapter (Total 15). Tiap mini chapter terdiri dari 5 lantai dengan 2-3 pilihan node bercabang.
3. **Mekanik Fail Forward:** Kalah di mini chapter hanya mengulang dari awal mini chapter bersangkutan (checkpoint tersimpan per mini chapter).
4. **Sistem 3 Tipe Stage:**
   - Pertempuran Turn-based (Deckbuilder: Mental = HP, Energi Harian = Mana).
   - Dilema Hidup (Random event berbobot peluang).
   - Kios Realitas & Bank (Beli buff run sementara + Setor uang in-run ke tabungan abadi permanen).
5. **Ekonomi Dual-Layer:** Uang run hangus saat kalah, uang yang sudah disetor ke bank aman untuk meta-upgrades di hub kamar.
6. **Zero Paid Assets:** Menggunakan aset CC0/Public domain dari Kenney.nl, Game-icons.net, dan Google Fonts.
7. **Ending Naratif:** Lantai 5 Mini Chapter 3-5 mengakhiri kisah dengan kematian sang tokoh yang bahagia dan damai.

## Out of Scope
- Fitur multiplayer, leaderboard, cloud matchmaking.
- Sistem monetisasi iklan agresif atau pembelian dalam aplikasi (IAP) gacha.
- Animasi spine/skeletal kompleks.

## Technical Architecture
- **Language & Engine:** Godot 4.3 LTS (GDScript).
- **Core Autoloads:**
  - `GameManager.gd` (State transisi scene & run lifecycle).
  - `PlayerData.gd` (Data tabungan bank, meta upgrades, savegame encrypted).
  - `RunManager.gd` (Deck run aktif, inventory buff, status lantai).
- **Storage:** Local encrypted file `user://savegame.dat`.

## Data Model
- `cards.json`: Definisi kartu (`id`, `name`, `cost`, `type`, `effects`, `description`).
- `enemies.json`: Definisi masalah/musuh (`id`, `name`, `chapter`, `resolve_hp`, `intent_patterns`).
- `events.json`: Definisi dilema naratif (`id`, `title`, `story_text`, `options`).
- `meta_upgrades.json`: Pohon upgrade kamar (`id`, `name`, `cost_bank`, `bonus_stat`).

## Database / Storage Recommendation
File lokal terenkripsi bawaan Godot (`FileAccess.open_encrypted_with_pass`). Sangat ringan, tidak membutuhkan server database eksternal, dan aman dari modifikasi hex sederhana di perangkat Android.

## Hosting / Data Location / Deployment
- 100% On-device storage. Data pemain tetap berada di direktori lokal aplikasi Android (`user://`).
- Deployment berupa berkas build APK/AAB siap pasang di perangkat Android.

## Platform Targets
- **MVP Target:** Android Mobile (Portrait mode, sentuh satu tangan).
- **Secondary (Development/Testing):** Godot Desktop Runner (PC Windows/Linux) untuk memudahkan debugging cepat selama proses pembuatan.

## Technical Stack Recommendation
- **Frontend / Game UI:** Godot 4 Control Nodes (VBoxContainer, TextureRect, RichTextLabel).
- **Logic Script:** GDScript.
- **Style:** Godot Theme resource (`theme.tres`) terintegrasi.
- **Audio:** AudioStreamPlayer2D dengan resource format OGG Vorbis / WAV.

## Implementation Phases

### Phase 1: Foundation & Data Skeleton
Goal: Struktur project Godot 4 siap, sistem save/load data lokal berfungsi, data kartu/musuh terhubung dari file JSON.
Tasks:
- Inisialisasi folder project Godot 4 resolusi 1080x1920 portrait.
- Buat skrip singleton `PlayerData.gd` dan `GameManager.gd`.
- Susun skema `cards.json` dengan minimal 15 kartu starter.
Verification: Game berjalan di viewport Godot PC, data savegame terbuat otomatis di folder user.

### Phase 2: Deckbuilder Battle Module
Goal: Arena pertempuran kartu turn-based playable.
Tasks:
- Bangun scene `Battle.tscn` lengkap dengan visual bar Mental & Energi.
- Buat controller penarikan kartu (draw, hand, discard, reshuffle).
- Buat logic AI aksi musuh dengan visual intent di atas kepalanya.
- Kalkulasi damage, shield, dan kondisi menang/kalah battle.
Verification: Pemain bisa mengalahkan 1 musuh uji coba menggunakan kartu tangan dan menerima reward uang run.

### Phase 3: Map Exploration & Banking Shop
Goal: Siklus eksplorasi 5 lantai dengan cabang node dan transaksi perbankan.
Tasks:
- Algoritma pembagian 5 lantai node di `MapManager.gd`.
- Layar Kios Toko dengan fitur beli buff sementara dan slider "Setor ke Rekening Permanen".
- Layar Dilema Acak (Event) dengan pilihan aksi bercabang.
Verification: Pemain bisa melewati 5 lantai dari bawah ke atas, belanja di toko, menyetor tabungan, dan melihat saldo bank bertambah permanen.

### Phase 4: Progression, Chapter Loop & Ending
Goal: Menghubungkan seluruh 3 Chapter (15 Mini Chapter), meta upgrade kamar, dan scene ending.
Tasks:
- Buat scene Hub Kamar Kontrakan dengan upgrade tabungan bank.
- Implementasi checkpoint per mini chapter (gagal hanya mengulang mini chapter aktif).
- Implementasi ending scene khusus di akhir Lantai 5 Mini Chapter 3-5.
- Impor aset CC0 Kenney dan font Google Fonts.
Verification: Siklus permainan lengkap dari Chapter 1 sampai epilog Chapter 3 dapat dimainkan tanpa crash.

## Build Tasks for Agent
1. Setup folder Godot `project.godot` beserta konfigurasi display portrait Android.
2. Buat file mock data `cards.json`, `enemies.json`, dan `events.json`.
3. Tulis skrip `PlayerData.gd` dengan fungsi `save_data()`, `load_data()`, `deposit_to_bank()`.
4. Tulis skrip `BattleController.gd` dan scene `CardUI.tscn`.
5. Tulis skrip `MapGenerator.gd` untuk membuat struktur 5 lantai acak.
6. Buat scene dialog ending dan credit screen.

## Testing Requirements
- **Unit Test Skrip:** Perhitungan damage terhadap shield dan mental akurat tanpa angka negatif error.
- **State Check:** Saat kalah di Lantai 3, data uang run terhapus tetapi uang tabungan di bank tetap utuh.
- **Save Integrity Check:** Game dapat ditutup paksa di tengah pertempuran dan saat dibuka kembali melanjutkan progress yang benar.

## Verification Commands / Checks
```bash
# Jalankan proyek di engine Godot via CLI (Headless / Runner check)
godot --path . --check-only
godot --path . -d
```

## Acceptance Criteria
- [ ] Berjalan lancar di resolusi portrait Android tanpa elemen UI terpotong.
- [ ] 3 Chapter x 5 Mini Chapter x 5 Lantai dapat ditelusuri dengan sistem checkpoint mini chapter.
- [ ] Mekanisme pertarungan kartu turn-based berfungsi penuh (draw, play card, energy cost, end turn, enemy turn).
- [ ] Sistem Setor Tabungan di Toko berfungsi menambah saldo permanen yang bertahan antar-kematian run.
- [ ] Ending naratif kematian damai terpicu di akhir Chapter 3 Mini Chapter 5.

## Done Means
- Proyek Godot 4 dapat dibuka dan dijalankan tanpa error di terminal atau editor.
- Seluruh 15 mini chapter terkonfigurasi dengan data musuh dan event naratif.
- Mekanisme deckbuilder, toko bank, dan meta upgrade berfungsi utuh sesuai acceptance criteria.

## Known Risks
- Resiko kartu overpower / underpower -> Gunakan nilai parameter sederhana yang mudah disesuaikan di file JSON tanpa ubah kode engine.
- Resiko layar notch HP menutupi UI atas -> Pasang margin safe area sebesar 48-64 piksel di bagian atas dan bawah layar.

## Prompt for Build Agent
Gunakan handoff ini untuk membangun proyek game Godot 4 "Jalan Sendiri". Mulai dengan inspeksi struktur direktori, buat skrip arsitektur singleton inti, susun scene kartu dan pertempuran secara bertahap, lalu hubungkan sistem node map dan ekonomi bank. Uji fungsionalitas logika game secara mandiri sebelum menyelesaikan implementasi.
