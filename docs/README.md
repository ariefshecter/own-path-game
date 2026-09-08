# Jalan Sendiri (Own Path) Package README

Status: Ready for Superpowers
Mode: Full
Current verdict: PASS
Last updated: 2026-09-08

## One-line summary
Game mobile Android 2D roguelike deckbuilder bertema perjuangan mandiri anak muda keluar dari ekspektasi orang tua, dengan struktur eksplorasi 5 lantai bercabang per mini chapter (ala Arknights IS), sistem ekonomi ganda (uang run vs setoran bank permanen), dan ending katarsis damai.

## Current next action
Spesifikasi selesai dengan status PASS. Siap dieksekusi oleh developer atau AI coding agent menggunakan `04-agent-build-handoff.md`.

## Artifact map
- `00-idea-capture.md` — Intisari ide awal, batasan platform, dan pilar konsep.
- `01-design-doc.md` — Dokumen desain game lengkap (narasi 3 chapter, pertempuran mental vs energi, checkpoint mini chapter, pipeline aset CC0).
- `02-ui-design-brief.md` — Panduan visual mobile portrait, wireframe layar battle & peta node, palet warna *Dark Slate & Amber Gold*, dan prompt konsep visual.
- `03-implementation-spec.md` — Spesifikasi teknis engine Godot 4.x, skema data JSON (`cards.json`, `enemies.json`, `events.json`), arsitektur singleton, dan algoritma perbankan.
- `04-agent-build-handoff.md` — Panduan eksekusi build agent tunggal siap pakai lengkap dengan sprint phase, kriteria verifikasi, dan acceptance criteria.
- `05-spec-review.md` — Evaluasi kesiapan spesifikasi dengan checklist dan vonis PASS.

## Handoff file
Gunakan berkas ini untuk memulai build:
`/home/riefzy/ideas/own-path-roguelike/04-agent-build-handoff.md`

## Open decisions
Semua keputusan kunci arsitektur telah disepakati:
- Genre: Turn-based Deckbuilder.
- Orientasi: Mobile Portrait (1080x1920) ramah satu tangan.
- Engine: Godot 4.x (GDScript).
- Aset: 100% Free / CC0 (Kenney, Game-icons, Google Fonts).
- Tabungan: Setor manual di Toko & Bank.

## Non-goals
- Multiplayer / Online ranking.
- IAP predatory / Gacha.
- Cutscene video berat / Animasi skeletal rumit.
