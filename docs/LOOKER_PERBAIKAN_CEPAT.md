# Perbaikan Cepat Looker Studio — Safari (mode presentasi tidak terpotong)

**Laporan Anda:**  
https://datastudio.google.com/reporting/4bd2171c-d77c-4ac7-a353-3d6a53de1698

**BigQuery:** `slik-da-intern-technical-test.slik`

Panduan ini fokus memperbaiki **layout berantakan / visual terpotong saat presentasi**, lalu
menaikkan kualitas visual ke standar deck konsultan (F/Z pattern, hierarki, warna Jago,
filter interaktif). Spesifikasi lengkap tiap halaman ada di
[`looker_studio_build.md`](looker_studio_build.md).

> **Catatan Safari:** Looker Studio paling stabil di **Chrome**. Untuk presentasi final,
> buka laporan yang sama di Chrome (`View` → full screen `F11`). Safari sering menambah
> selisih render ±5–10 px di tepi kanvas.

---

## Bagian A — Perbaiki terpotong dalam 10 menit (lakukan dulu)

Lakukan **berurutan**. Jangan loncat ke desain sebelum empat langkah ini selesai.

### A1. Setelan kanvas laporan (sekali saja)

1. Buka laporan → menu **Theme and layout** (ikon kuas).
2. Tab **LAYOUT**:

| Setelan | Nilai |
|---|---|
| Canvas size | **Custom → 1600 × 900** |
| Display mode | **Fit to width** |
| Has margin | **OFF** |
| Header visibility | **Initially hidden** |
| Navigation type | **Left** (sidebar) atau **Tabs** |

3. Tab **THEME** → **Customize** → isi warna (copy-paste hex):

| Peran | Hex |
|---|---|
| Primary / accent | `#FDAF27` |
| Secondary | `#722B79` |
| Background | `#F5F6F7` |
| Text | `#111111` |
| Grid / border | `#E4E7EA` |

4. Font: **Arial** (semua teks).

### A2. Setiap halaman = Auto (penyebab #1 visual terpotong)

Untuk **setiap halaman** (1–7):

1. Klik halaman di sidebar kiri.
2. Menu **Page** → **Current page settings** → tab **STYLE**.
3. Canvas size = **Auto** (bukan Custom, bukan Fixed height sendiri).

Kalau satu halaman punya ukuran sendiri, halaman itu akan berbeda saat presentasi.

### A3. Rapikan komponen ke dalam safe area

1. Di mode edit, tekan **⌘A** (Select all).
2. Pastikan **tidak ada** kotak seleksi yang keluar dari area putih kanvas.
3. Safe area wajib: **x 40–1560**, **y 40–860** (lebar konten 1520 px).
4. Geser komponen yang melewati batas; perkecil chart yang terlalu tinggi.
5. Menu **Arrange** → **Align** (top / left) dan **Distribute** (horizontal) supaya rapi.

### A4. Uji presentasi

1. Klik **View** (kanan atas).
2. Telusuri halaman 1→7 — **tidak boleh ada scroll vertikal** di halaman.
3. Perkecil lebar jendela browser (~1000 px) — chart tidak boleh terpotong.
4. Full screen Safari: **⌃⌘F** — ulangi cek.

### A5. Kalau tujuh halaman kerangkanya masih beda-beda: duplikat halaman

Ini penyebab tersisa yang paling sering, dan A1–A4 tidak menyembuhkannya. Delapan
komponen kerangka (judul, sub-judul, logo, garis amber, label topik, baris kontrol,
headline, catatan kaki) harus berada di koordinat **sama** di ketujuh halaman. Kalau
ditempel ulang dengan tangan per halaman, tiap halaman bergeser beberapa piksel ke
arah berbeda — judul naik-turun antar halaman, garis amber tidak sejajar, dan hanya
sebagian halaman yang komponen bawahnya melewati y=860. Di mode presentasi, itu
terlihat seperti layout berantakan.

Jangan betulkan enam halaman satu per satu. Lakukan ini:

1. Pilih **satu** halaman yang kerangkanya paling rapi. Perbaiki hanya halaman itu
   sampai lolos A3 dan A4.
2. Klik kanan halaman itu di panel halaman kiri → **Duplicate page**. Duplikat
   mewarisi seluruh komponen pada posisi identik — nol drift.
3. Duplikat sampai jumlah halaman cukup.
4. Pindahkan isi dari halaman lama ke duplikat lewat copy-paste antar halaman
   (**⌘C** di halaman lama → buka duplikat → **⌘V**); ukuran komponen ikut terbawa.
   Hanya ganti teks judul, headline, label topik, dan catatan kaki.
5. Hapus halaman lama setelah isinya dipindahkan.
6. Kontrol filter dijadikan **report-level** (Bagian D), jadi cukup dibuat sekali.

Penempatan manual turun dari 56 menjadi 8.

**Checklist cepat:**

- [ ] Canvas laporan = 1600×900, Fit to width, margin off
- [ ] 7 halaman semua Canvas size = **Auto**
- [ ] Semua komponen di dalam y ≤ 860
- [ ] Ketujuh halaman berasal dari Duplicate page, bukan ditempel ulang manual
- [ ] Mode View: tidak ada visual terpotong di semua halaman

---

## Bagian B — Struktur halaman (F/Z, single page view)

Setiap halaman memakai **kerangka yang sama** (1600×900). Informasi paling penting selalu
**kiri atas** (pola baca F/Z):

```
┌─────────────────────────────────────────────────────────────┐
│ JUDUL (kesimpulan, bukan label)              [logo Jago]    │ y=40
│ Sub-judul: sumber data & cakupan                            │ y=84
│ ─────────── garis amber #FDAF27 ─────────────────────────── │ y=118
│ LABEL TOPIK (HURUF BESAR, amber)                            │ y=128
│ [Filter whitelist] [Filter segmen] [Filter usia] [Date range]│ y=152
│ HEADLINE TEMUAN (1 kalimat, 16px bold)                      │ y=196
│ ┌──────────────────────┐  ┌─────────────┐                   │
│ │ GRAFIK UTAMA (60%)   │  │ PENDUKUNG   │                   │ y=254
│ │ 920 px lebar         │  │ 580 px      │                   │
│ └──────────────────────┘  └─────────────┘                   │
│ Catatan kaki: definisi metrik (9px abu)                     │ y=826
└─────────────────────────────────────────────────────────────┘
```

**Logo:** `Insert` → `Image` → unggah `assets/jago_logo.svg` (atau PNG resmi dari
[media assets Jago](https://www.jago.com/id/media-center/media-assets)) → posisi x=1420, y=42,
w=140, h=40.

---

## Bagian C — Data source (BigQuery)

Pastikan 8 data source terhubung ke project `slik-da-intern-technical-test`:

| Alias | Tabel / view BigQuery | Isi |
|---|---|---|
| `DS_CUST` | `slik.vw_looker_customer` | 587 pemohon + kolom label siap-pakai |
| `DS_KPI` | `slik.vw_looker_kpi` | 1 baris, semua angka KPI hal 1 & 7 |
| `DS_PANEL` | `slik.vw_slik_monthly_customer` | panel NIK × bulan (12.369) |
| `DS_TREND` | `slik.vw_slik_monthly_trend` | 24 bulan |
| `DS_DECILE` | `slik.vw_scorecard_deciles` | 10 desil |
| `DS_POWER` | `slik.vw_scorecard_power` | 7 kandidat variabel |
| `DS_SCEN` | `slik.vw_whitelist_scenarios` | 5 skenario |
| `DS_SEG` | `slik.vw_segment_summary` | 5 segmen |

**Refresh data:** Resource → Manage added data sources → Refresh each.

> **Kalau `DS_CUST` masih menunjuk ke `slik.slik_customer_analysis`, ganti sekarang.**
> Buka Resource → Manage added data sources → baris `DS_CUST` → **EDIT** → ikon
> pensil di nama tabel → pilih `vw_looker_customer` → **RECONNECT** → **APPLY**.
> Semua chart tetap hidup karena view meneruskan seluruh kolom lama apa adanya, dan
> chart mendapat kolom baru di bawah ini.

### Kolom yang sudah dihitung di BigQuery (tidak perlu calculated field)

`vw_looker_customer` menambah lima kolom supaya tidak ada rumus yang harus ditulis
ulang dengan tangan di Looker — inilah sumber kesalahan angka yang paling sering:

| Kolom | Isi | Dipakai di |
|---|---|---|
| `lolos_kriteria_usulan` | `Lolos` (490) / `Ditolak` (97) | hal 7 |
| `celah_npl_others_6bln` | 1 untuk 13 pemohon celah risiko | hal 1 KPI 3, hal 2 |
| `kelompok_whitelist` | `Tanpa catatan buruk` / `Pernah restrukturisasi` / `Pernah hapus buku` | filter, hal 2 |
| `segmen_awam` | `A. Lancar semua` … `E. Sudah dihapus buku` | filter, hal 3, hal 7 |
| `status_jejak_slik` | `Tanpa jejak SLIK aktif` / `Ada eksposur aktif` | hal 4, hal 7 |

`vw_looker_kpi` berisi satu baris dengan seluruh angka KPI. Untuk setiap scorecard:
pilih `DS_KPI`, pilih kolomnya, agregasi **MAX**, dan **jangan pasang filter apa pun**.

| Scorecard | Kolom `DS_KPI` | Nilai benar |
|---|---|---|
| Pemohon dianalisis (hal 1) | `total_pemohon` | **587** |
| Flag "Others" (hal 1) | `pemohon_tanpa_catatan_buruk` | **510** |
| Celah NPL (hal 1) | `celah_npl_others_6bln` | **13** |
| NPL aktif yang lolos (hal 1 & 7) | `npl_aktif_lolos_pct` | **0,0** |
| Pemohon lolos S2 (hal 7) | `pemohon_lolos_usulan` | **490** |
| % basis dipertahankan (hal 7) | `pct_basis_lolos_usulan` | **83,5** |
| Biaya basis (poin persen) | `biaya_basis_pp` | **3,4** |

Kalau scorecard hal 7 menampilkan **481 / 82,3%**, berarti masih memakai calculated
field lama tanpa `COALESCE(..., 1)`. Ganti sumbernya ke `DS_KPI` atau ke kolom
`lolos_kriteria_usulan`; jangan tulis ulang rumusnya.

### Field di `DS_PANEL` (dua ini masih perlu dibuat manual)

**Kol 3-5 (%)**
```
AVG(is_npl)
```
→ Percent, Average

**Rata-rata hari telat**
```
AVG(hari_telat_max)
```
→ Number, Average

Pastikan `report_month` bertipe **Date** (BigQuery sudah benar).

**Agregasi Average untuk kolom persen bawaan view** — `pct_basis`, `npl_active_pct`,
`gini`, `iv`, `rate`, `avg_facility_count`, `customer_npl_pct`, `avg_dpd_days`. Default
Looker adalah Sum, dan begitu difilter hasilnya bisa lewat 100%.

---

## Bagian D — Kontrol interaktif (report-level)

Buat 4 kontrol di baris y=152 (tinggi 32), lebar masing-masing 365 px:

| Kontrol | Field | Label bahasa awam |
|---|---|---|
| Drop-down | `kelompok_whitelist` | Kelompok whitelist |
| Drop-down | `segmen_awam` | Segmen perilaku |
| Drop-down | `age_group` | Kelompok usia |
| Date range | `report_month` (DS_PANEL) | Periode laporan |

Dua kontrol pertama memakai kolom label awam dari `vw_looker_customer`, jadi isi
drop-down terbaca "Tanpa catatan buruk", bukan "3.Customer Others".

**Date range default:** Advanced → Start **1 Nov 2021**, End **31 Okt 2023**
(Jangan pakai "Last 30 days" — data berhenti Okt 2023.)

Seleksi keempat kontrol → klik kanan → **Make report-level** → Theme and layout →
Report-level component position = **Top**.

Pada chart utama: **Chart interactions** → centang **Apply filter** (cross-filtering).

Scorecard `DS_KPI` sengaja tidak ikut tersaring (beda data source), karena angka itu
harus tetap sama dengan README dan workbook. Tulis di catatan kaki hal 1: "KPI baris
atas = populasi penuh; grafik di bawah mengikuti filter."

---

## Bagian E — 7 halaman: judul + isi (storyline McKinsey-style)

Judul halaman = **kesimpulan**, bukan label menu.

### Hal 1 — Ringkasan eksekutif
**Judul:** *Kriteria whitelist masih meloloskan pemohon yang sudah macet*  
**Headline:** *Tambahkan syarat Kol maksimal 2 selama 12 bulan: NPL aktif yang lolos turun
menjadi 0, basis hanya menyusut 3,4 poin persen*

| KPI (4 scorecard, y=254) | Metrik |
|---|---|
| 587 pemohon dianalisis | Record Count |
| 510 flag "Others" | filter whitelist |
| **13 celah NPL** (purple) | Others + kol 6 bln ≥ 3 |
| **0% NPL aktif** yang lolos S2 | filter Lolos + NPL aktif |

Grafik utama (920×420): Combo `DS_SCEN` — bar `% basis` (slate, bar S2 amber) + line
`npl_active_pct` (purple).  
Grafik kanan (580×420): Time series `DS_PANEL` — `Kol 3-5 (%)` per bulan.

### Hal 2 — Matrix report
**Judul:** *Flag whitelist bekerja, satu kantong risiko masih lolos*  
Pivot heatmap (920×400): baris `kelompok_whitelist`, kolom `kol_6m_label`, metrik Count.  
Stacked bar 100% (580×400): `kelompok_whitelist` × `risk_band_6m`.  
Tabel celah (580×112): filter `celah_npl_others_6bln = 1` → 13 baris.

### Hal 3 — Segmentasi
**Judul:** *Jumlah fasilitas kredit membedakan segmen paling tegas*  
Tabel `DS_SEG` (1520×210) + Combo bar fasilitas + line NPL (920×280) + bar ukuran segmen (580×280).

### Hal 4 — Uji scorecard
**Judul:** *Eksposur SLIK bukan pemeringkat risiko*  
Line desil (920×300) + tabel IV/Gini `DS_POWER` (580×300) + 2 histogram band (750×190).

### Hal 5 — Tren (halaman date range)
**Judul:** *Kualitas kredit memburuk selama 24 bulan sebelum aplikasi*  
Combo time series `DS_PANEL` (1020×420): bar hari telat + line Kol 3-5%.

### Hal 6 — Demografi
**Judul:** *Demografi memberi sinyal lemah*  
Bar usia + bar pendidikan (750×300 masing-masing) + tabel gender/nikah dengan kolom `n`.

### Hal 7 — Rekomendasi
**Judul:** *Atur kriteria dan lihat dampaknya*  
4 KPI dari `DS_KPI` (`pemohon_lolos_usulan` 490 / `pct_basis_lolos_usulan` 83,5% /
`npl_aktif_lolos_pct` 0,0% / `pernah_npl_12bln_lolos_pct` 0,0%) + tabel skenario S0–S4 +
bar segmen lolos (`lolos_kriteria_usulan = Lolos`, dimensi `segmen_awam`) +
kotak rekomendasi amber (3 poin).

Detail koordinat piksel tiap komponen: [`looker_studio_build.md` §5](looker_studio_build.md).

---

## Bagian F — Aturan visual (3 warna bermakna)

1. **Slate `#8B9299`** — semua kategori default.
2. **Amber `#FDAF27`** — **satu** elemen disorot per grafik (skenario S2, segmen D, usia 50–54).
3. **Purple `#722B79`** — semua metrik risiko (NPL %, bad rate, garis tren risiko).

Latar kartu grafik: **putih `#FFFFFF`**. Latar halaman: **`#F5F6F7`**.  
Jangan pakai lebih dari 3 warna data + netral — kalau semua bar amber, tidak ada yang tersorot.

---

## Bagian G — Verifikasi sebelum submit

- [ ] View mode: 7 halaman, zero scroll, zero clip
- [ ] Ketujuh halaman berasal dari **Duplicate page** (A5), kerangka identik
- [ ] PDF export (`Share` → Download report): tidak ada halaman kosong
- [ ] `DS_CUST` menunjuk ke `vw_looker_customer`, `DS_KPI` ke `vw_looker_kpi`
- [ ] Scorecard hal 7 = **490 / 83,5%** (kalau 481 / 82,3% → masih pakai rumus lama)
- [ ] KPI celah = **13**
- [ ] Semua scorecard `DS_KPI` tanpa chart-level filter, agregasi MAX
- [ ] Kolom persen bawaan view memakai agregasi **Average**, bukan Sum
- [ ] Date range mengubah hal 5
- [ ] Filter report-level bekerja di semua halaman
- [ ] Share: Anyone with link + `muhammad.subhan@jago.com` Viewer
- [ ] Data credentials = **Owner's credentials** (supaya reviewer bisa lihat tanpa akses BQ)
- [ ] Akun `muhammad.subhan@jago.com` juga diberi peran **BigQuery Data Viewer** pada
      dataset `slik` (syarat di soal tes — terpisah dari share Looker)

---

## Jika masih terpotong setelah A1–A5

1. Hapus komponen paling bawah yang melewati y=860.
2. Perkecil tinggi chart (maks 420 px untuk grafik utama).
3. Matikan legend yang tidak perlu (Style → Legend → None).
4. Kurangi jumlah baris tabel (filter top 5 / show row numbers off).
5. Presentasi dari **Chrome**, bukan Safari.

Spesifikasi teknis penuh + checklist 20 poin: [`looker_studio_build.md`](looker_studio_build.md).
