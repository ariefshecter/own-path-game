# Idea Capture: Jalan Sendiri (Revised Architecture)

Date: 2026-09-09
Mode: Full Mode

## 1. Summary & Core Narrative Revision
Game mobile 2D roguelike deckbuilder psikologis-emosional dengan nuansa visual ala *A Space for the Unbound*. Game ini mengangkat kisah seorang pemuda yang terjebak dalam ekspektasi orang tua. Alur dimulai dari masa kuliah semester akhir jurusan pendidikan (terpaksa masuk demi orang tua, meski ia mencintai teknik informatika/coding). Setelah lulus tepat waktu sebagai lulusan terbaik peringkat ke-2, ia tetap dihakimi karena bukan peringkat pertama. Merasa seluruh usahanya sia-sia dan hanya diukur oleh angka serta gengsi, keputusasaan mendalam membawanya pada tindakan bunuh diri di kamar kosnya.

- **The Reality Plot Twist & Akar Keputusasaan:**
  Alasan Rian mengakhiri hidupnya bukan sekadar kegagalan meraih peringkat pertama, melainkan kesadaran dingin bahwa **ia tidak akan pernah diizinkan memiliki hidupnya sendiri**. Sepanjang hidupnya, orang tuanya memegang kendali absolut atas setiap pilihan. Ketika berkas lamaran pekerjaan pun telah ditandatangani sepihak oleh orang tuanya tanpa izin, sang Ayah menegaskan bahwa selama ia masih membawa nama keluarga, ia tidak punya hak menentukan arah hidupnya sendiri. Di kamar kosnya, rasa sesak yang tak berujung membuatnya mengambil botol racun di samping ijazahnya. Sebelum alter-ego Rian melangkah pergi di Chapter 1, game menyematkan *scene foreshadowing* sunyi yang menyorot botol racun tanpa label tersebut di atas meja. Seluruh 4 chapter yang dimainkan adalah imajinasi/halusinasi sadar terakhirnya: sebuah impian tentang keberanian yang tak pernah sanggup ia ambil di dunia nyata.

## 2. Updated Chapter Scope (4 Chapters, 20 Mini Chapters)
Setiap Chapter memiliki 5 Mini Chapter (Total 20 Mini Chapter).
- **Chapter 1: "Tuntutan & Retakan Awal (Masa Kuliah & Skripsi)"** (1.1 s/d 1.5)
- **Chapter 2: "Langkah Semu & Hangatnya Asmara"** (2.1 s/d 2.5)
- **Chapter 3: "Realitas Dingin & Kehilangan Arah"** (3.1 s/d 3.5)
- **Chapter 4: "Penerimaan Akhir & Senyuman di Detik Terakhir"** (4.1 s/d 4.5)

## 3. Floor & Stage Progression Mechanic
Klarifikasi struktur run:
Dalam **1 Mini Chapter**, terdapat **3 Lantai Ekspedisi Penuh (Full Expedition Floors)** seperti peta visual di screenshot:
- **Lantai 1 (Early Journey):** Peta bercabang dengan 4 variasi stage Tier 1. Pemain melangkah sebanyak 3–4 langkah/stage dari awal lantai menuju gerbang lantai 2. Tidak ada pengulangan stage yang sama pada satu jalur.
- **Lantai 2 (Mid Escalation):** Peta bercabang dengan 6 variasi stage Tier 2. Pemain melangkah 5–6 langkah/stage menuju gerbang lantai 3.
- **Lantai 3 (Climax & Boss):** Peta bercabang dengan 8 variasi stage Tier 3 + 1 Stage Bos Mini Chapter di puncak lantai 3. Pemain melangkah 7 langkah sebelum menantang Bos.
- Jika pemain gagal di salah satu lantai sebelum bos lantai 3 kalah: mengulang dari Lantai 1 mini chapter tersebut (dengan intervensi telepon desakan orang tua).

## 4. UI Architecture & Quality Bar
Bukan prototipe kasar, melainkan produk komersial profesional:
- **Main Menu UI:** Layar pembuka profesional dengan tombol "Permainan Baru", "Lanjutkan Game", "Pengaturan (Volume BGM/SFX, Resolusi, Safe Area Mobile)", dan "Kredit".
- **Design System Aset Lengkap:** Rencana aset komprehensif mencakup latar belakang ilustrasi, visual kartu berstempel, pin/node stage dengan konektor garis dinamis, layar popup stage, dan HUD responsif.
