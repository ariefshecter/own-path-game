# Jalan Sendiri — UI Design Brief (Full Expedition & Professional Mobile Standard)

## 1. Purpose & Visual Philosophy
Membangun standar visual profesional bergaya anime retro-nostalgia ala *A Space for the Unbound*. UI dirancang ramah, cerah, hangat, dan ekspresif (*warm watercolor paper & sticker aesthetic*) untuk mengontraskan realitas gelap cerita.

## 2. Struktur Peta Ekspedisi 3 Lantai (Integrated Strategies Model)
Setiap Mini Chapter (dimulai dari 1.1) terdiri dari 3 Lantai Ekspedisi:
- **Lantai 1 (Masa Awal):** 4 langkah vertikal menuju tangga lantai 2. Variasi 4 stage Tier 1.
- **Lantai 2 (Eskalasi):** 5-6 langkah vertikal menuju tangga lantai 3. Variasi 6 stage Tier 2.
- **Lantai 3 (Puncak & Bos):** 7 langkah vertikal dengan 8 variasi stage Tier 3 dan 1 Stage Bos Puncak di puncak langkah ke-7.

### Aturan Non-Repeating Stage
Pada satu jalur lurus/bercabang yang diambil pemain dari langkah pertama hingga langkah terakhir lantai, tidak boleh ada tipe stage yang sama muncul dua kali berturut-turut.

## 3. Komponen Node Stage (Visual Pop-Up Sticker)
Node di peta digambar sebagai tombol stiker timbul berukuran 180x90 px:
1. **[⚔ Masalah]:** Warna oranye kemerahan `#E76F51` dengan ikon pedang sketsa.
2. **[☕ Warung]:** Warna cokelat kopi hangat `#DDA15E` dengan ikon cangkir kopi.
3. **[🏪 Kios]:** Warna hijau mint `#2A9D8F` dengan ikon toko buku/fotokopi.
4. **[✉ Dilema]:** Warna kuning mustard `#E9C46A` dengan ikon amplop surat.
5. **[👑 Bos]:** Warna merah bata tebal `#D62828` dengan stempel mahkota.

Garis konektor antar-node digambar menggunakan sistem `_draw()` Godot berupa garis putus-putus pensil cokelat (`#4A3E3D`).

## 4. Rincian 4 Stage Khusus Mini Chapter 1.1
- **Stage 1A: [⚔ Beban] Debugging Skripsi Bab 4**
  - Arena pertempuran vs Bug Skripsi & Coretan Tinta Dosen.
- **Stage 1B: [☕ Warung] Seduh Kopi Warung Kampus**
  - Layar interaksi santai warung kopi pinggir jalan: memulihkan mental (+15) dan mendapatkan dorongan moral.
- **Stage 1C: [🏪 Kios] Fotokopi & ATK Barokah**
  - Tempat menyetor tabungan bank permanen dan membeli kartu perlengkapan skripsi (misal: *Stabilo Warna-warni*, *Flashdisk Cadangan*).
- **Stage 1D: [✉ Dilema] Ajakan Nongkrong vs Selesaikan Kode**
  - Kotak dialog dilema berbobot peluang resiko: ikut nongkrong (+Mental tapi -Koin) atau lanjut koding (+Fokus tapi lelah fisik).

## 5. Screen Transitions & State Machine
Setiap selesai menyelesaikan 1 stage:
1. Status player (Mental & Koin) tersimpan di `GameState`.
2. Posisi langkah (`current_step`) bertambah 1.
3. Layar kembali ke peta lantai aktif dengan node yang sudah diselesaikan berubah warna hijau pudar dan node berikutnya terbuka.
4. Di langkah terakhir lantai: muncul pintu transisi ke lantai berikutnya. Di lantai 3 langkah ke-7: pintu menuju arena Bos Mini Chapter 1.1 (*Draf Skripsi Tercoret Tinta Merah*).
