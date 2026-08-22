# Looker Studio — perbaikan layout & panduan bangun ulang

Dokumen ini memperbaiki dua hal: (1) **layout yang berantakan dan terpotong saat mode
presentasi**, dan (2) menaikkan kualitas dashboard ke standar presentasi konsultan
(single page view, pola baca F/Z, storyline, hierarki visual, warna bermakna, kontrol
interaktif, branding Jago).

Semua ukuran di dokumen ini memakai satu kanvas tetap: **1600 × 900 px (16:9)**.

---

## 0. Akar masalah: kenapa visual terpotong di mode presentasi

Periksa berurutan — penyebabnya hampir selalu salah satu dari empat ini.

| # | Penyebab | Cara memastikan | Perbaikan |
|---|---|---|---|
| 1 | **Ukuran kanvas per halaman menimpa ukuran laporan.** Halaman yang punya ukuran sendiri tidak ikut berubah saat ukuran laporan diubah — ini yang membuat sebagian halaman rapi dan sebagian berantakan. | `Page` → `Current page settings` → tab **STYLE** → Canvas size bukan `Auto` | Set **Auto** di *setiap* halaman, lalu atur ukuran sekali saja di level laporan (bagian 1) |
| 2 | **Komponen melewati tepi kanvas.** Mode edit punya area kerja yang bisa digeser, jadi kelebihannya tidak terlihat; mode View memotong tepat di batas kanvas. | Di mode edit, `Ctrl/Cmd + A` lalu lihat apakah ada kotak seleksi yang keluar dari bidang putih | Semua komponen wajib berada di dalam **safe area** x: 40–1560, y: 40–860 (bagian 2) |
| 3 | **Display mode `Actual size`** pada kanvas yang lebih lebar dari jendela browser | `Theme and layout` → **LAYOUT** → Display mode | Set **Fit to width**, dan matikan **Has margin** |
| 4 | **Header laporan `Always show`** memakan ± 50 px di atas sehingga baris judul tergeser turun dan baris terakhir terdorong keluar | Header masih terlihat saat mode View | Set header visibility **Initially hidden** |

Catatan Safari: Looker Studio paling stabil di Chrome. Untuk presentasi, buka mode
**View** lalu full screen browser (Chrome: `F11`; Safari: `⌃⌘F`). Kalau tetap ada
selisih render di Safari, presentasikan dari Chrome dan simpan PDF sebagai cadangan
(`Share` → `Download report` → PDF, centang *Ignore custom background color*).

---

## 1. Setelan kanvas — dilakukan sekali di level laporan

`Theme and layout` → tab **LAYOUT**:

| Setelan | Nilai | Alasan |
|---|---|---|
| Canvas size | **Custom — 1600 × 900** (sama dengan preset *Screen 16:9*) | 16:9 = rasio proyektor dan layar laptop, jadi satu halaman = satu layar penuh tanpa scroll |
| Display mode | **Fit to width** | kanvas ikut menyesuaikan lebar jendela, tidak terpotong di layar kecil |
| Has margin | **off** | menghilangkan bingkai abu-abu di tepi saat presentasi |
| Header visibility | **Initially hidden** | halaman penuh untuk konten, toolbar muncul saat kursor didekatkan |
| Navigation type | **Left** (atau `Tabs` di atas) | navigasi 7 halaman tetap terlihat saat presentasi |
| Snap to | **Grid** | ukuran/posisi konsisten antar halaman |
| Grid settings | Size **5**, Padding **0** | kelipatan 5 px cukup untuk semua angka di dokumen ini |

Lalu, untuk **setiap** halaman: `Page` → `Current page settings` → **STYLE** →
Canvas size = **Auto**. Ini langkah yang paling sering terlewat dan penyebab utama
layout tidak seragam antar halaman.

---

## 2. Kerangka halaman (berlaku sama untuk 7 halaman)

Kanvas 1600 × 900, **safe area** x: 40–1560 (lebar konten 1520), y: 40–860.
Tidak ada komponen yang boleh melewati batas ini.

| Zona | x | y | w | h | Isi |
|---|---|---|---|---|---|
| Judul halaman | 40 | 40 | 1000 | 44 | 22 px bold, warna ink `#111111` |
| Sub-judul | 40 | 84 | 1000 | 24 | 11 px, ink-2 `#6E7781` — cakupan data & sumber |
| Logo Jago | 1420 | 42 | 140 | 40 | image, rata kanan |
| Garis amber | 40 | 118 | 1520 | 3 | rectangle isi `#FDAF27`, tanpa border |
| Label topik | 40 | 128 | 700 | 18 | 9 px bold amber, HURUF BESAR |
| Baris kontrol | 40 | 152 | 1520 | 32 | filter + date range (bagian 4) |
| **Headline temuan** | 40 | 196 | 1520 | 48 | 16 px bold — kalimat temuan, bukan judul grafik |
| Zona konten | 40 | 254 | 1520 | 558 | blok grafik/tabel (per halaman di bagian 5) |
| Catatan kaki | 40 | 826 | 1520 | 30 | 9 px ink-2 — definisi metrik + nama file sumber |

**Pola baca F/Z.** Informasi paling penting selalu di kiri atas: judul → headline
temuan → KPI → grafik utama (kiri, besar) → grafik pendukung (kanan, kecil) →
catatan (bawah). Mata pembaca tidak perlu melompat.

**Pembagian lebar yang dipakai** (selalu berjumlah 1520 supaya tepi kanan rata):

| Pola | Lebar blok | Dipakai untuk |
|---|---|---|
| 4-up | 365 + 365 + 365 + 365, gutter 20 | baris KPI dan baris kontrol |
| 60/40 | 920 + 580, gutter 20 | grafik utama + grafik pendukung |
| 50/50 | 750 + 750, gutter 20 | dua grafik setara |
| Penuh | 1520 | tabel lebar / pivot |

**Cara mendapat ukuran identik tanpa kolom angka.** Looker Studio tidak punya kotak
input X/Y/W/H. Yang berfungsi: buat satu komponen, atur ukurannya, lalu
`Ctrl/Cmd + C` → `Ctrl/Cmd + V` untuk duplikat (duplikat mewarisi ukuran persis),
geser dengan snap-to-grid, lalu rapikan dengan `Arrange` → `Align` (top/left) dan
`Arrange` → `Distribute` (horizontally/vertically). Nudge 1 px dengan tombol arah.

---

## 3. Tema Jago (design system)

`Theme and layout` → tab **THEME** → `Customize`. Warna diambil dari media assets
Bank Jago dan sama persis dengan yang dipakai pada dashboard Excel, sehingga kedua
deliverable terlihat satu keluarga.

| Peran | Hex | Dipakai untuk |
|---|---|---|
| Amber (primer merek) | `#FDAF27` | **satu** seri/kategori yang sedang disorot, garis aksen, baris rekomendasi |
| Amber muda | `#FFF1D0` | latar sel/kartu yang disorot |
| Purple (sekunder) | `#722B79` | metrik risiko (NPL, bad rate) — sengaja beda kelas dari amber |
| Purple muda | `#EFE3F0` | latar sel metrik risiko |
| Slate (netral data) | `#8B9299` | semua kategori yang **tidak** disorot |
| Slate muda | `#C7CCD1` | batang pembanding / seri sekunder |
| Ink | `#111111` | judul dan angka |
| Ink-2 | `#6E7781` | label, sub-judul, catatan |
| Canvas | `#F5F6F7` | latar halaman |
| Card | `#FFFFFF` | latar grafik dan tabel |
| Hairline | `#E4E7EA` | garis tabel dan gridline |

Aturan pemakaian warna — maksimal 3 warna bermakna:

1. **Slate = default.** Semua kategori memakai slate.
2. **Amber = satu hal yang ingin ditunjukkan** pada grafik itu (skenario yang
   direkomendasikan, kelompok dengan risiko tertinggi, bulan terburuk). Satu grafik
   = satu batang amber. Kalau semuanya amber, tidak ada yang tersorot.
3. **Purple = metrik risiko** (garis % NPL, kolom bad rate). Konsisten di 7 halaman
   supaya pembaca hafal: ungu berarti "ini angka risikonya".

Font: **Arial** untuk semua teks (tersedia di daftar font Looker Studio). Ukuran:
judul 22, headline temuan 16, judul blok 11 bold, label 9–10, angka KPI 28.

Chart style yang diseragamkan untuk semua grafik: Background **Card** `#FFFFFF`,
Border radius **4**, border **off**, Grid color **Hairline** `#E4E7EA`, legend
**Bottom** (atau off kalau hanya satu seri), Chart header **Do not show** kecuali
memang ingin memberi pembaca akses sort/export.

Logo: unggah `assets/jago_logo.png` lewat `Insert` → `Image`. Jangan pakai fitur
"Report header logo" saja — logo di kanvas ikut terekspor ke PDF.

---

## 4. Data source dan kontrol interaktif

### 4.1 Data source

Semua file ada di `output/`. Unggah ke Google Sheets (satu file = satu spreadsheet)
lalu sambungkan dengan konektor **Google Sheets**; atau pakai konektor **BigQuery**
ke view yang dibuat `sql/03_analysis_views.sql`.

| Alias | File | Objek BigQuery | Grain | Baris | Dipakai halaman |
|---|---|---|---|---|---|
| `DS_CUST` | `slik_customer_analysis.csv` | `slik_customer_analysis` | 1 baris = 1 NIK | 587 | 1, 2, 3, 4, 6, 7 |
| `DS_PANEL` | `slik_monthly_customer.csv` | `vw_slik_monthly_customer` | 1 baris = NIK × bulan | 12.369 | 1 (tren), 5 |
| `DS_TREND` | `slik_monthly_trend.csv` | `vw_slik_monthly_trend` | 1 baris = bulan | 24 | 5 (KPI ringkas) |
| `DS_DECILE` | `scorecard_deciles.csv` | `vw_scorecard_deciles` | 1 baris = desil | 10 | 4 |
| `DS_POWER` | `scorecard_power.csv` | `vw_scorecard_power` | 1 baris = kandidat variabel | 7 | 4 |
| `DS_SCEN` | `whitelist_scenarios.csv` | `vw_whitelist_scenarios` | 1 baris = skenario | 5 | 1, 7 |
| `DS_SEG` | `segment_summary.csv` | `vw_segment_summary` | 1 baris = segmen | 5 | 3 |

Wajib dicek setelah menyambungkan `DS_PANEL` dan `DS_TREND`: kolom `report_month`
harus bertipe **Date (YYYYMMDD)**, bukan Text. Kalau masih Text, date range control
tidak akan muncul sebagai pilihan. Ubah di halaman data source: kolom
`report_month` → Type → `Date & Time` → `Date (YYYYMMDD)`.

Lewat konektor **BigQuery** langkah itu tidak perlu: `report_month` sudah bertipe
`DATE` di `vw_slik_monthly_customer` dan `vw_slik_monthly_trend`, jadi Looker Studio
mengenalinya sebagai Date sejak awal. Konversi manual hanya diperlukan pada jalur
Google Sheets, karena spreadsheet mengirim kolom itu sebagai teks. Jumlah baris di
tabel di atas sudah dicocokkan dengan view BigQuery **dan** CSV di `output/` — keduanya
identik, jadi kedua jalur konektor menghasilkan angka yang sama.

Field yang perlu dibuat di data source (Add a field):

| Data source | Nama field | Rumus | Kegunaan |
|---|---|---|---|
| `DS_CUST` | `NPL aktif (%)` | `AVG(npl_now_active)` (agregasi Average, format Percent) | outcome independen — dipakai di semua bad rate |
| `DS_CUST` | `Lolos kriteria usulan` | `CASE WHEN whitelist_flag = "3.Customer Others" AND COALESCE(collection_status_allcondition_last_12months_max, 1) <= 2 THEN "Lolos" ELSE "Ditolak" END` | scorecard "pemohon lolos" & grafik halaman 7 |
| `DS_PANEL` | `Kol 3-5 (%)` | `AVG(is_npl)` (Average, Percent) | garis tren risiko |
| `DS_PANEL` | `Rata-rata hari telat` | `AVG(hari_telat_max)` | batang tren |

Dua hal yang mudah terlewat dan langsung membuat angka Looker berbeda dari Excel/notebook:

- **`COALESCE(..., 1)` pada rumus "Lolos kriteria usulan" itu wajib, bukan hiasan.**
  Sembilan pemohon ber-flag `3.Customer Others` tidak punya satu pun baris riwayat pada
  jendela 12 bulan, jadi `collection_status_allcondition_last_12months_max`-nya NULL.
  Pipeline SQL memperlakukan NULL sebagai Kol 1 (tidak ada tunggakan yang dilaporkan) —
  lihat `COALESCE(..., 1)` di `vw_whitelist_scenarios`. Tanpa `COALESCE`, Looker menilai
  `NULL <= 2` sebagai salah, sembilan pemohon itu masuk "Ditolak", dan scorecard halaman 7
  menampilkan **481 (82,3%)** — bukan **490 (83,5%)** seperti di README, workbook, dan
  notebook.
- **Kolom persen di view sudah teragregasi; ganti agregasinya ke `Average`.** Field seperti
  `pct_basis`, `npl_active_pct`, `gini`, `iv`, `rate`, `avg_facility_count`,
  `customer_npl_pct`, dan `avg_dpd_days` sudah berupa hasil hitung satu baris per kategori.
  Looker Studio memberi agregasi default **Sum**, yang benar hanya selama satu baris per
  titik; begitu ada filter atau rentang tanggal yang menggabungkan beberapa baris, hasilnya
  menjadi persentase di atas 100. Di halaman data source, set `Default aggregation` =
  **Average** untuk kolom-kolom ini.

### 4.2 Kontrol interaktif

Letakkan di **baris kontrol** (y = 152, tinggi 32) pada setiap halaman, urut kiri→kanan:

| # | Jenis kontrol | Field | Lebar | x | Berlaku untuk |
|---|---|---|---|---|---|
| 1 | Drop-down list | `whitelist_flag` | 365 | 40 | semua chart `DS_CUST` |
| 2 | Drop-down list | `slik_behavior_segment` | 365 | 425 | semua chart `DS_CUST` |
| 3 | Drop-down list | `age_group` | 365 | 810 | semua chart `DS_CUST` |
| 4 | **Date range control** | `report_month` | 365 | 1195 | chart `DS_PANEL` (halaman 1 & 5) |

Detail penting:

- Setiap drop-down: `Style` → Label bahasa awam (mis. "Kelompok whitelist",
  "Segmen perilaku", "Kelompok usia"), bukan nama kolom teknis.
- Date range control **default**: `Advanced` → `Start = Nov 1 2021`,
  `End = Oct 31 2023` (jendela 24 bulan sebelum aplikasi). Jangan pakai preset
  "Last 30 days" — data berhenti Oktober 2023, hasilnya akan kosong.
- Kontrol hanya memengaruhi chart yang **berbagi data source yang sama**. Karena itu
  chart tren memakai `DS_PANEL` (punya tanggal *dan* atribut kategori), bukan
  `DS_TREND` — dengan begitu date range dan filter kategori bekerja bersama.
- Supaya kontrol berlaku di 7 halaman tanpa diduplikasi: seleksi keempat kontrol →
  klik kanan → **Make report-level**. Lalu `Theme and layout` → LAYOUT →
  Report-level component position = **Top**.
- Aktifkan **cross-filtering** pada chart utama (`Chart` → `Interactions` →
  `Apply filter`) agar klik pada satu batang menyaring seluruh halaman. Ini yang
  membuat dashboard terasa hidup saat demo.

---

## 5. Storyline 7 halaman

Alur argumen sengaja dibuat seperti deck konsultan: **temuan → bukti → uji →
rekomendasi**. Judul setiap halaman adalah *kesimpulan*, bukan label ("Kriteria
whitelist masih meloloskan pemohon macet", bukan "Ringkasan").

| Hal | Peran dalam cerita | Pertanyaan yang dijawab |
|---|---|---|
| 1 | **Jawaban** | Apa masalahnya dan apa usulannya? |
| 2 | Bukti 1 — matrix report | Di kantong mana risiko yang masih lolos? |
| 3 | Bukti 2 — segmentasi | Perilaku apa yang membedakan pemohon buruk? |
| 4 | Uji — kelayakan variabel | Apakah eksposur/angsuran layak jadi skor risiko? |
| 5 | Konteks waktu | Apakah kondisi memburuk atau membaik? |
| 6 | Kontrol — demografi | Apakah demografi bisa dipakai untuk menolak? |
| 7 | **Rekomendasi + simulasi** | Berapa dampak kriteria baru ke basis dan NPL? |

### Halaman 1 — Ringkasan eksekutif

Judul: *Kriteria whitelist masih meloloskan pemohon yang sudah macet*
Headline: *Tambahkan syarat Kol maksimal 2 selama 12 bulan: NPL yang lolos turun dari
13 pemohon menjadi 0, basis pemohon hanya menyusut 3,4 poin persen*

| Komponen | Tipe | x | y | w | h | Data |
|---|---|---|---|---|---|---|
| KPI 1 | Scorecard | 40 | 254 | 365 | 96 | `DS_CUST` · Record Count → "587 pemohon dianalisis" |
| KPI 2 | Scorecard | 425 | 254 | 365 | 96 | `DS_CUST` filter `whitelist_flag = 3.Customer Others` → 510 |
| KPI 3 | Scorecard | 810 | 254 | 365 | 96 | `DS_CUST` filter `Lolos kriteria usulan = Ditolak` & `npl_now_active = 1` → 13 (angka purple) |
| KPI 4 | Scorecard | 1195 | 254 | 365 | 96 | `DS_CUST` `NPL aktif (%)` dengan filter `Lolos kriteria usulan = Lolos` → 0,0% |
| Label blok kiri | Text | 40 | 366 | 920 | 20 | "Simulasi kriteria whitelist: mana yang paling seimbang?" |
| Label blok kanan | Text | 980 | 366 | 580 | 20 | "Kualitas portofolio 24 bulan sebelum aplikasi" |
| **Grafik utama** | Combo: bar + line | 40 | 392 | 920 | 420 | `DS_SCEN` · dimensi `skenario`; bar = `pct_basis` (slate, batang S2 amber lewat *Series #3*), line = `npl_active_pct` (purple) |
| Grafik pendukung | Time series line | 980 | 392 | 580 | 420 | `DS_PANEL` · dimensi `report_month`, metrik `Kol 3-5 (%)` (purple) + trendline linear amber |
| Catatan kaki | Text | 40 | 826 | 1520 | 30 | definisi "NPL aktif" & "pernah bermasalah 12 bln" |

Hierarki visual: grafik simulasi 920 px (bukti utama keputusan) jauh lebih besar dari
grafik tren 580 px (konteks). Scorecard KPI 3 dan 4 memakai angka purple karena itu
dua angka yang menentukan keputusan.

### Halaman 2 — Matrix report

Judul: *Flag whitelist bekerja, satu kantong risiko masih lolos*
Headline: *60 dari 61 pemohon ber-flag Writeoff berada di Kol 5, tetapi 13 pemohon
ber-flag "Others" tercatat Kol 3-5 dalam 6 bulan terakhir*

| Komponen | Tipe | x | y | w | h | Data |
|---|---|---|---|---|---|---|
| Label kiri | Text | 40 | 254 | 920 | 20 | "Jumlah pemohon per kombinasi flag × kolektibilitas 6 bulan" |
| Label kanan | Text | 980 | 254 | 580 | 20 | "Komposisi risiko di dalam tiap flag (dinormalkan 100%)" |
| **Pivot heatmap** | Pivot table with heatmap | 40 | 280 | 920 | 400 | `DS_CUST` · baris `whitelist_flag`, kolom `kol_6m_label`, metrik Record Count; Style → Cell colors = heatmap amber |
| 100% stacked bar | Stacked bar (100%) | 980 | 280 | 580 | 400 | `DS_CUST` · dimensi `whitelist_flag`, breakdown `risk_band_6m`, metrik Record Count |
| Kotak insight | Text on rectangle | 40 | 700 | 920 | 112 | 3 baris bullet: konsentrasi, celah "Others", 10 pemohon tanpa riwayat |
| Tabel celah | Table | 980 | 700 | 580 | 112 | `DS_CUST` filter `whitelist_flag = 3.Customer Others` AND `kol_6m_label` ∈ Kol 3/4/5 · kolom NIK, `kol_6m_label`, `npl_now_active` |
| Catatan kaki | Text | 40 | 826 | 1520 | 30 | "total seluruh sel = 587; Kol 3-5 = NPL menurut OJK" |

Kenapa dua grafik ini: pivot heatmap menjawab **konsentrasi absolut** (di mana
massanya), 100% stacked bar menjawab **komposisi relatif** tanpa bias ukuran grup —
dua pertanyaan berbeda dari satu tabel yang sama.

### Halaman 3 — Segmentasi perilaku

Judul: *Jumlah fasilitas kredit membedakan segmen paling tegas*
Headline: *Segmen "Macet / NPL" memegang rata-rata 64 fasilitas kredit — 3,6 kali
segmen bersih (18 fasilitas)*

| Komponen | Tipe | x | y | w | h | Data |
|---|---|---|---|---|---|---|
| Label tabel | Text | 40 | 254 | 1520 | 20 | "Profil lima segmen perilaku SLIK" |
| **Tabel segmen** | Table | 40 | 280 | 1520 | 210 | `DS_SEG` · kolom segmen, pemohon, % basis, rata-rata fasilitas, eksposur, angsuran, NPL aktif; Style → Show row numbers off, Wrap text on |
| Label kiri | Text | 40 | 506 | 920 | 20 | "Rata-rata jumlah fasilitas vs NPL aktif per segmen" |
| Label kanan | Text | 980 | 506 | 580 | 20 | "Ukuran tiap segmen" |
| **Combo chart** | Bar + line | 40 | 532 | 920 | 280 | `DS_SEG` · bar `avg_facility_count` (slate, segmen D amber), line `npl_active_pct` (purple) |
| Bar horizontal | Bar (horizontal) | 980 | 532 | 580 | 280 | `DS_SEG` · dimensi segmen, metrik `total_customer`; segmen D & E purple |
| Catatan kaki | Text | 40 | 826 | 1520 | 30 | catatan kejujuran: segmen D/E sebagian dibentuk dari riwayat kolektibilitas |

### Halaman 4 — Uji kelayakan variabel scorecard

Judul: *Eksposur dan angsuran SLIK bukan pemeringkat risiko*
Headline: *Desil eksposur terkecil punya tingkat pernah-bermasalah 20,3% dan desil terbesar
8,5% — arahnya terbalik, tetapi tangganya tidak rapi*

| Komponen | Tipe | x | y | w | h | Data |
|---|---|---|---|---|---|---|
| Label kiri | Text | 40 | 254 | 920 | 20 | "Rank ordering: tingkat bermasalah per desil eksposur" |
| Label kanan | Text | 980 | 254 | 580 | 20 | "Daya pisah tiap kandidat variabel" |
| **Line chart desil** | Line (2 seri) | 40 | 280 | 920 | 300 | `DS_DECILE` · dimensi `decile`; seri 1 `ever_npl_12m_pct_exposure` purple, seri 2 `npl_active_pct_exposure` slate putus-putus |
| Tabel daya pisah | Table with bars | 980 | 280 | 580 | 300 | `DS_POWER` · kolom label, `gini`, `iv`, `arah`; Style → Gini sebagai *bar* |
| Label kiri bawah | Text | 40 | 596 | 750 | 20 | "Sebaran eksposur SLIK antar pemohon" |
| Label kanan bawah | Text | 810 | 596 | 750 | 20 | "Sebaran angsuran SLIK per bulan" |
| Histogram eksposur | Bar (kolom) | 40 | 622 | 750 | 190 | `DS_CUST` · dimensi `slik_exposure_band`, metrik Record Count; band "Rp 0" amber |
| Histogram angsuran | Bar (kolom) | 810 | 622 | 750 | 190 | `DS_CUST` · dimensi `slik_installment_band`, metrik Record Count; band "Rp 0" amber |
| Catatan kaki | Text | 40 | 826 | 1520 | 30 | "Gini = \|2 × AUC − 1\|; IV < 0,1 lemah · 0,1–0,3 sedang · > 0,3 kuat" + penyebab banyak Rp 0 |

Catatan analisis yang harus ikut ditulis di kotak tabel: variabel teratas
(`flags_active_dpd10plus_count`, Gini 0,91) nyaris satu definisi dengan target
sehingga daya pisahnya semu. Kandidat yang benar-benar berguna adalah
`flags_allcondition_count` (Gini 0,28 · IV 0,73).

### Halaman 5 — Tren kualitas portofolio (halaman date range)

Judul: *Kualitas kredit memburuk selama 24 bulan sebelum aplikasi*
Headline: *Rata-rata hari keterlambatan naik dari 27 hari menjadi 52 hari, dan porsi
pemohon Kol 3-5 naik 1,9 poin persen*

| Komponen | Tipe | x | y | w | h | Data |
|---|---|---|---|---|---|---|
| Label kiri | Text | 40 | 254 | 1020 | 20 | "Rata-rata hari telat dan porsi pemohon Kol 3-5 per bulan laporan" |
| Label kanan | Text | 1080 | 254 | 480 | 20 | "Ringkasan rentang yang dipilih" |
| **Combo time series** | Time series (bar + line, 2 axis) | 40 | 280 | 1020 | 420 | `DS_PANEL` · dimensi `report_month`; bar `Rata-rata hari telat` (slate, axis kiri), line `Kol 3-5 (%)` (purple, axis kanan) |
| Scorecard bulan awal | Scorecard | 1080 | 280 | 480 | 100 | `DS_PANEL` `Kol 3-5 (%)` + comparison *previous period* |
| Scorecard hari telat | Scorecard | 1080 | 390 | 480 | 100 | `DS_PANEL` `Rata-rata hari telat` |
| Tabel bulan terburuk | Table | 1080 | 500 | 480 | 200 | `DS_PANEL` · dimensi `month_label`, metrik `Kol 3-5 (%)`, sort desc, limit 5 |
| Kotak "mengapa penting" | Text on rectangle | 40 | 716 | 750 | 96 | kolom `collection_status_allcondition_last_12months_max` menangkap pemulihan semu |
| Kotak cakupan data | Text on rectangle | 810 | 716 | 750 | 96 | tiap bulan hanya memuat pemohon yang dilaporkan (rata-rata 515 dari 587) |
| Catatan kaki | Text | 40 | 826 | 1520 | 30 | sumber `slik_monthly_customer.csv` (panel NIK × bulan) |

Halaman ini yang membuat **date range control** bermakna: seluruh komponen di atas
memakai `DS_PANEL`, jadi mengubah rentang bulan langsung mengubah grafik, kedua
scorecard, dan tabel bulan terburuk sekaligus.

### Halaman 6 — Demografi vs risiko

Judul: *Demografi memberi sinyal lemah, kecuali kelompok usia 50-54*
Headline: *Usia 50-54 mencatat 30,8% pernah bermasalah versus 10,3% pada usia 25-29 —
satu-satunya selisih yang tidak beririsan dengan selang kepercayaan kelompok lain*

| Komponen | Tipe | x | y | w | h | Data |
|---|---|---|---|---|---|---|
| Label kiri | Text | 40 | 254 | 750 | 20 | "Tingkat pernah bermasalah per kelompok usia" |
| Label kanan | Text | 810 | 254 | 750 | 20 | "Per tingkat pendidikan (hanya kelompok dengan sampel ≥ 15)" |
| Bar kolom usia | Bar (kolom) | 40 | 280 | 750 | 300 | `DS_CUST` · dimensi `age_group`, metrik `ever_npl_12m` (Average, %); 50-54 amber |
| Bar horizontal pendidikan | Bar (horizontal) | 810 | 280 | 750 | 300 | `DS_CUST` · dimensi `pendidikan`, metrik `ever_npl_12m` (Average, %), sort asc, filter Record Count ≥ 15 |
| Label tabel | Text | 40 | 596 | 1520 | 20 | "Gender dan status pernikahan: apakah selisihnya nyata?" |
| Tabel + CI | Table | 40 | 622 | 1520 | 190 | `DS_CUST` · baris gender & `marital_status`; kolom jumlah pemohon, pernah bermasalah, tingkat, batas bawah/atas 95% |
| Catatan kaki | Text | 40 | 826 | 1520 | 30 | keterbatasan: tidak ada data penghasilan → DBR tidak dapat dihitung; 14 pemohon tanpa baris demografi |

Selang kepercayaan 95% (metode Wilson) tidak tersedia sebagai fitur Looker Studio.
Dua pilihan: (a) tampilkan kolom `n` dan tulis batas CI di data source sebagai field
terhitung, atau (b) sambungkan view `vw_demografi_ci` dari `sql/03_analysis_views.sql`
— view ini sudah berbentuk long (`dimensi`, `kategori`, `n`, `k`, `rate`, `lo`, `hi`),
jadi satu tabel bisa melayani keempat dimensi demografi lewat satu filter kontrol.
Yang penting: **jangan** menampilkan bad rate kelompok kecil tanpa `n` di sebelahnya.

### Halaman 7 — Rekomendasi dan simulasi kebijakan

Judul: *Atur kriteria dan lihat dampaknya ke basis pemohon dan NPL*
Headline: *Kriteria usulan: flag "3.Customer Others" DAN kolektibilitas maksimal 2
sepanjang 12 bulan terakhir — 490 pemohon lolos (83,5% basis) dengan nol NPL aktif*

| Komponen | Tipe | x | y | w | h | Data |
|---|---|---|---|---|---|---|
| KPI 1 | Scorecard | 40 | 254 | 365 | 96 | `DS_CUST` filter `Lolos kriteria usulan = Lolos` → 490 pemohon |
| KPI 2 | Scorecard | 425 | 254 | 365 | 96 | % basis dipertahankan → 83,5% |
| KPI 3 | Scorecard | 810 | 254 | 365 | 96 | `NPL aktif (%)` yang lolos → 0 (purple) |
| KPI 4 | Scorecard | 1195 | 254 | 365 | 96 | `ever_npl_12m` yang lolos → 0,0% |
| Label kiri | Text | 40 | 366 | 750 | 20 | "Lima skenario baku sebagai pembanding" |
| Label kanan | Text | 810 | 366 | 750 | 20 | "Sebaran segmen pemohon yang lolos kriteria terpilih" |
| **Tabel skenario** | Table | 40 | 392 | 750 | 260 | `DS_SCEN` · kolom skenario, lolos, % basis, NPL aktif; baris S2 diberi latar amber |
| Bar segmen lolos | Bar (horizontal) | 810 | 392 | 750 | 260 | `DS_CUST` filter `Lolos kriteria usulan = Lolos` · dimensi `slik_behavior_segment`, Record Count |
| **Kotak rekomendasi** | Text on rectangle amber muda | 40 | 668 | 1520 | 144 | 3 rekomendasi bernomor: tambah syarat Kol ≤ 2; jalur verifikasi terpisah untuk 154 pemohon tanpa jejak SLIK; uji champion-challenger sebelum berlaku penuh |
| Catatan kaki | Text | 40 | 826 | 1520 | 30 | "simulasi dihitung dari 587 pemohon historis, bukan uji coba berjalan" |

---

## 6. Checklist verifikasi sebelum submit

Jalankan berurutan. Item 1–5 adalah yang memperbaiki masalah "terpotong".

- [ ] `Theme and layout` → LAYOUT: canvas **1600 × 900**, Display mode **Fit to
      width**, Has margin **off**, header **Initially hidden**
- [ ] Ketujuh halaman: `Page` → `Current page settings` → STYLE → Canvas size
      **Auto** (bukan ukuran sendiri)
- [ ] Di setiap halaman tekan `Ctrl/Cmd + A`: tidak ada kotak seleksi yang keluar
      dari bidang kanvas (batas aman x 40–1560, y 40–860)
- [ ] Tombol **View**: cek ketujuh halaman satu per satu, lalu ulangi dengan jendela
      browser diperkecil sampai ± 1000 px — tidak boleh ada bagian yang terpotong
- [ ] Full screen (Chrome `F11`) dan telusuri halaman 1→7 seperti presentasi asli
- [ ] Tidak ada scrollbar vertikal di dalam chart mana pun (tanda chart terlalu
      kecil untuk jumlah barisnya — perbesar atau kurangi baris)
- [ ] Setiap halaman punya **judul berupa kesimpulan** dan **satu headline temuan**
- [ ] Setiap grafik punya maksimal satu elemen amber; metrik risiko selalu purple
- [ ] Semua label memakai bahasa awam; nama kolom teknis hanya muncul di catatan
      kaki atau tooltip
- [ ] Date range control default `Nov 1 2021 – Oct 31 2023` dan benar-benar
      mengubah halaman 5
- [ ] Ketiga drop-down filter sudah **report-level** dan berfungsi di semua halaman
- [ ] **Uji angka kunci**: scorecard halaman 7 menunjukkan **490 pemohon / 83,5%**
      (kalau muncul 481 / 82,3%, rumus `Lolos kriteria usulan` belum memakai
      `COALESCE(..., 1)` — lihat §4.1), dan KPI 3 halaman 1 menunjukkan **13**
- [ ] Kolom persen bawaan view (`pct_basis`, `npl_active_pct`, `gini`, `iv`, `rate`,
      `avg_facility_count`, `customer_npl_pct`, `avg_dpd_days`) memakai agregasi
      **Average**, bukan Sum — tidak ada persentase di atas 100 setelah difilter
- [ ] `File` → `Download report` → PDF: hasil PDF tidak ada halaman kosong dan tidak
      ada visual terpotong (bukti tambahan untuk lampiran submit)
- [ ] `Share` → *Anyone with the link – Viewer*, lalu tambahkan alamat email
      pewawancara sebagai Viewer

## 7. Hubungan dengan deliverable lain

| Deliverable | File | Isi |
|---|---|---|
| Excel / Google Sheets | `output/SLIK_Analysis_Dashboard.xlsx` | 7 halaman dashboard + Kamus Metrik + Catatan & Asumsi + 3 tab data; storyline, warna, dan angka identik dengan dokumen ini |
| Looker Studio | dokumen ini | 7 halaman yang sama, plus date range control dan cross-filtering |
| Notebook insight | `notebooks/slik_insight_analysis.ipynb` | cara angka dihitung dan pengujian statistiknya |
| SQL | `sql/01..03_*.sql` | pipeline BigQuery yang menghasilkan seluruh angka |

Angka pada dokumen ini berasal dari CSV di folder `output/` (posisi data November 2023,
587 pemohon). Kalau data berubah, jalankan ulang pipeline SQL lalu segarkan data source
di Looker Studio — tata letak tidak perlu disentuh.







