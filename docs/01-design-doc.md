# Jalan Sendiri (Own Path) — Game Design Document

## 1. One-line Summary
Game mobile 2D roguelike deckbuilder untuk Android bernuansa visual hangat dan ekspresif ala *A Space for the Unbound*, mengisahkan anak muda yang menempuh jalan hidupnya sendiri, melewati manis-pahitnya cinta yang kandas, menolak godaan menyerah pulang ke ekspektasi orang tua, dan menerima takdir akhir dengan damai.

## 2. Product Philosophy & Tonality
- **Kontras Visual & Tema (Bitter-Sweet Warmth):** Tampilan visual, tombol, dan warna sengaja dibuat ramah, cerah, dan hangat (*pixel art / clean indie illustration* bernuansa pedesaan atau pinggiran kota 90-an/2000-an ala *A Space for the Unbound*). Hal ini membuat benturan masalah emosional dan tekanan batin terasa jauh lebih intim dan menusuk.
- **Unsur Komedi Satir & Tragikomedi Sehari-hari:** Tidak monoton muram. Penuh lelucon getir yang relate: mie instan kuah campur nasi, broadcast hoax grup WA keluarga, kucing oren tetangga yang galak, obrolan canggung tukang galon, dan sarkasme ringan karakter untuk menertawakan penderitaannya sendiri. Humor berfungsi sebagai perisai mental sebelum dihantam kenyataan.
- **Tekanan Manipulatif Emosional:** Kegagalan dalam game bukan sekadar layar "Game Over" hitam, melainkan intervensi psikologis orang tua yang memanfaatkan momen terlemah sang anak untuk memaksanya menyerah.

## 3. Narrative Arcs & The Romance Sub-plot

### Chapter 1: "Langkah Pertama & Hangatnya Seseorang" (Mini Chapter 1-1 s/d 1-5)
- **Kondisi:** Karakter keluar dari rumah dengan tekad membara. Menemukan seseorang yang memahami mimpinya.
- **Mekanik Tambahan:** Beberapa kartu aksi bertema afeksi (*"Dukungan Manis"*, *"Janji Berdua"*).
- **Musuh:** Rasa Bersalah, Telepon Ibu, Pandangan Sinis Tetangga.

### Chapter 2: "Gesekan Realitas & Jarak yang Menjauh" (Mini Chapter 2-1 s/d 2-5)
- **Kondisi:** Tekanan finansial dan kelelahan mental mulai merusak hubungan asmara. Pertengkaran kecil karena uang, komunikasi yang menipis, hingga keputusan berpisah demi tidak saling membebani.
- **Musuh:** Tagihan Kos, Lembur Tak Berujung, Pesan Singkat Dingin (*"Kita Selesai"*), Keraguan Diri.

### Chapter 3: "Melangkah Sendiri Menuju Akhir" (Mini Chapter 3-1 s/d 3-5)
- **Kondisi:** Sendiri sepenuhnya. Tubuh mulai rapuh dimakan usia dan beban hidup, namun batinnya menemukan keikhlasan penuh. Kenangan cinta masa lalu menjadi memori indah, bukan lagi beban.
- **Puncak & Ending Sejati (True Ending):** Di akhir Lantai 5 Mini Chapter 3-5, karakter meninggal dunia dengan senyum tenang dan damai, mengetahui ia telah menjalani hidup yang ia pilih sendiri seutuhnya.

## 4. Protagonis & Kustomisasi Nama
- **Karakter:** Laki-laki muda tetap (Fixed Male) yang sedang berjuang mandiri di perantauan/kota.
- **Kustomisasi Nama:** Di awal permainan sebelum Chapter 1 dimulai, pemain disambut layar formulir KTP/Buku Catatan Usang untuk menginput nama karakter (misal: "Budi", "Rian", "Ferry", default: "Rian").
- **Dampak Penamaan:** Nama karakter langsung tersisip dinamis ke dalam balon pesan kemarahan orang tua (*"Rian, kamu jangan durhaka!"*), panggilan sayang mantan (*"Semangat ya Rian..."*), serta surat tagihan kos.

## 5. Mekanik Kegagalan & Pilihan "Tunduk Pulang" (The Bad Ending Trap)
Setiap kali pemain kehabisan Mental (Sanity = 0) di lantai mana pun dalam sebuah mini chapter:
- Layar beralih ke panggilan telepon dari rumah dengan narasi menusuk:
  *"Dengar kata Papa dan Mama dari dulu kan enak. Kamu tinggal pulang, ikuti jurusan/pekerjaan yang kami pilihkan, hidupmu terjamin. Buat apa tersiksa di luar sana?"*
- Pemain diberikan dua opsi tombol besar:
  1. **"TETAP MELANGKAH" (Bangkit Lagi):** Menolak bujukan. Mengulang mini chapter tersebut dari Lantai 1 dengan tabungan bank tetap aman.
  2. **"PULANG KE RUMAH" (Menyerah):** Memicu **BAD ENDING**.
     - Ditampilkan adegan: Orang tua tersenyum bangga di hadapan keluarga besar/tetangga sambil memamerkan sang anak yang kini rapi berseragam sesuai impian mereka. Di belakang mereka, sang tokoh utama berdiri dengan mata sayu, kosong, tanpa senyum, kehilangan jiwanya.
     - **Penalti Total:** Seluruh progres game, checkpoint chapter, level akun, dan tabungan bank dihapus total (Hard Reset). Pemain harus memulai dari Prolog Chapter 1-1.

## 5. Layout & UI Atmosphere
- Palet Warna UI: Biru langit cerah, krem kertas buku gambar, oranye matahari terbenam, dan kuning kenari hangat.
- Font: Bergaya retro-modern rounded yang bersahabat dan mudah dibaca.
- Ikon: Berbentuk ilustrasi stempel / stiker lucu dengan garis tepi cokelat hangat.

## 6. Technical State Machine
- `GameState.gd` diperluas dengan flag:
  - `hard_reset_save()`: Menghapus total file simpanan jika memilih Bad Ending.
  - `romance_stage`: Indikator babak hubungan (Mekar -> Retak -> Kandas).
