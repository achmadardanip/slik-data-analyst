# Credit Risk Data Intern Technical Test — SLIK Analysis

Pengerjaan lengkap technical test **Risk Data Analyst Intern** (posisi aplikasi pinjaman
**November 2023**):

| Deliverable | Isi | Lokasi |
|---|---|---|
| **A. SQL + Table ID** | *SLIK aggregated table* 587 customer × 25 kolom di BigQuery | `sql/` |
| **B. Visualisasi + analisis** | Dashboard Excel/Google Sheets 13 tab **dan** Looker Studio 7 halaman | `output/`, `docs/` |
| **C. Insight** | Jupyter Notebook tereksekusi (grafik + angka + narasi) | `notebooks/` |

## Struktur Proyek

```
├── sql/
│   ├── 01_load_tables.sql                 # DDL + panduan load CSV ke BigQuery
│   ├── 02_slik_aggregated_table.sql       # ⭐ query utama: SLIK aggregated table (25 kolom)
│   └── 03_analysis_views.sql              # 1 tabel + 10 view + 1 UDF: sumber data Looker Studio
├── output/
│   ├── SLIK_Analysis_Dashboard.xlsx       # ⭐ deliverable B: dashboard 13 tab, siap import GSheet
│   ├── slik_aggregated_table.csv          # hasil query utama (587 × 25)
│   ├── slik_customer_analysis.csv         # agregat + demografi + segmen + outcome risiko
│   ├── matrix_whitelist_x_kol6m.csv       # matrix report
│   ├── segment_summary.csv                # ringkasan 5 segmen perilaku
│   ├── scorecard_deciles.csv              # rank-ordering bad rate per desil
│   ├── scorecard_power.csv                # IV / Gini / AUC tiap kandidat variabel
│   ├── slik_monthly_trend.csv             # tren kualitas portofolio 24 bulan (Nov-21 … Oct-23)
│   ├── slik_monthly_customer.csv          # panel bulanan per customer (sumber kontrol date range)
│   └── whitelist_scenarios.csv            # simulasi 5 skenario kriteria whitelist
├── docs/
│   └── looker_studio_build.md             # ⭐ spesifikasi layout + tema Jago + storyline 7 halaman
├── notebooks/
│   └── slik_insight_analysis.ipynb        # ⭐ deliverable C: insight (sudah tereksekusi)
├── assets/
│   └── jago_logo.png                      # logo untuk header dashboard
└── requirements.txt
```

> **Dataset tidak disertakan.** Folder `data/` (4 CSV technical test + kamus KODE REFERENSI OJK)
> dan berkas soal tidak dipublikasikan di repositori ini: keduanya milik Bank Jago dan memuat
> identifier level debitur. Notebook di `notebooks/` sudah tereksekusi lengkap, jadi seluruh
> grafik, angka, dan narasi tetap dapat dibaca tanpa dataset. Untuk menjalankannya ulang,
> letakkan kembali dua berkas berikut di `data/`:
> `Technical Test Dataset - result.csv` dan `Technical Test Dataset - ljk mapping.csv`.

## Cara Menjalankan Notebook

```bash
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
.venv/bin/jupyter lab notebooks/slik_insight_analysis.ipynb
```

---

## Langkah Submission

### 1. BigQuery (deliverable A: SQL + Table ID)

Ketiga file `sql/` sudah memakai project & dataset final
`slik-da-intern-technical-test.slik`. Kalau di-deploy ke project lain, cukup search-replace
string tersebut.

1. Buka [BigQuery Console](https://console.cloud.google.com/bigquery) → buat project
   `slik-da-intern-technical-test` → buat dataset `slik` (lokasi bebas, mis. `asia-southeast2`).
2. Jalankan `sql/01_load_tables.sql` (membuat 4 tabel kosong ber-skema STRING), lalu upload
   tiap CSV dari folder `data/` ke tabel terkait: dataset → **Create table** → Upload → pilih file →
   *Write preference: Append to table* → *Header rows to skip: 1*.
   | File CSV | Tabel tujuan |
   |---|---|
   | `Technical Test Dataset - result.csv` | `slik_result` |
   | `Technical Test Dataset - demographic1.csv` | `slik_demographic1` |
   | `Technical Test Dataset - demographic2.csv` | `slik_demographic2` |
   | `Technical Test Dataset - ljk mapping.csv` | `slik_ljk_mapping` |
3. Jalankan `sql/02_slik_aggregated_table.sql` → menghasilkan
   **`slik-da-intern-technical-test.slik.slik_aggregated_table`** (587 baris × 25 kolom).
   Ini **Table ID** yang dilampirkan saat submit.
4. Jalankan `sql/03_analysis_views.sql` → 12 objek pendukung dashboard: tabel
   `slik_customer_analysis`, UDF `fn_kol_label`, dan 10 view (`vw_slik_facility`,
   `vw_slik_facility_history`, `vw_matrix_whitelist_x_kol6m`, `vw_segment_summary`,
   `vw_scorecard_deciles`, `vw_scorecard_power`, `vw_slik_monthly_trend`,
   `vw_slik_monthly_customer`, `vw_whitelist_scenarios`, `vw_demografi_ci`).
5. **Share akses**: halaman dataset `slik` → **Sharing → Permissions → Add principal** →
   `muhammad.subhan@jago.com` → role **BigQuery Data Viewer**.
6. **Google Docs**: salin isi ketiga file `sql/` ke satu dokumen Google Docs (beri heading per file),
   set akses *Anyone with the link – Viewer*, lampirkan link saat submit.

> **Kesetaraan angka SQL ↔ Excel ↔ Notebook.** Logika query utama dijalankan ulang lokal lewat dua
> implementasi independen (DuckDB dan pandas murni) dan seluruh 587×25 sel identik. Tabel BigQuery
> yang sudah jadi kemudian dibandingkan sel per sel terhadap hasil lokal: **14.670 dari 14.675 sel
> identik**; 5 sel sisanya (`mob_active_avg` 1 sel, `slik_installment` 4 sel) berbeda tepat 0,01
> karena urutan akumulasi *floating-point* antar engine berbeda dan nilainya jatuh persis di batas
> pembulatan `ROUND(…, 2)` — selisih relatif 1e-9 s.d. 3e-3, tidak mengubah satu pun angka agregat,
> segmen, atau rekomendasi.
>
> View analisis memakai rumus desil yang sama dengan `pd.qcut` — bukan `NTILE(10)`, yang menaruh
> baris sisa di bucket awal sehingga IV dan bad rate per desil berbeda tipis dari angka yang
> tercetak di workbook. Enam view (`vw_scorecard_power`, `vw_scorecard_deciles`,
> `vw_whitelist_scenarios`, `vw_segment_summary`, `vw_matrix_whitelist_x_kol6m`,
> `vw_slik_monthly_trend`) diuji langsung terhadap CSV di `output/` dan **seluruhnya identik**.
> Dua sel *cross-check* di dalam notebook (bagian 5 dan 8) mengulang uji yang sama dan mencetak
> `0 sel berbeda -> IDENTIK`. Jadi angka BigQuery, Excel, Looker, dan notebook bisa dibandingkan
> langsung tanpa catatan kaki.

### 2. Visualisasi + Analisis (deliverable B)

#### 2a. Google Sheets / Excel — dashboard sudah jadi

1. Buka [sheets.google.com](https://sheets.google.com) → **Blank spreadsheet**.
2. **File → Import → Upload** → pilih `output/SLIK_Analysis_Dashboard.xlsx` →
   *Import location: Replace spreadsheet*.
3. Rename file, lalu **Share**: *Anyone with the link – Viewer* dan tambahkan
   `muhammad.subhan@jago.com`. Lampirkan link saat submit.

Isi workbook — 13 tab, tiap tab dirancang **single page view** (muat satu layar tanpa scroll) dan
mengikuti pola baca F/Z (angka paling krusial di kiri atas):

| Tab | Isi |
|---|---|
| `1. Ringkasan` | KPI utama + rekomendasi kebijakan; halaman pembuka |
| `2. Matrix Report` | Matrix `whitelist_flag` × kolektibilitas maks 6 bulan + heatmap + komposisi 100% |
| `3. Segmentasi` | 5 segmen perilaku SLIK: ukuran, bad rate, rata-rata jumlah fasilitas |
| `4. Scorecard` | Rank-ordering per desil + tabel IV/Gini/AUC tiap kandidat variabel |
| `5. Tren Portofolio` | Tren 24 bulan NPL customer, NPL fasilitas, dan rata-rata DPD |
| `6. Demografi` | Bad rate per usia/pendidikan/gender/status, dengan `n` dan 95% CI |
| `7. Simulasi Kebijakan` | 5 skenario kriteria whitelist: basis lolos vs NPL yang tertahan |
| `Kamus Metrik` | Definisi setiap metrik dengan label bahasa awam |
| `Catatan & Asumsi` | Keputusan interpretasi, penanganan data quality, batasan |
| `data_agregat`, `data_customer`, `data_tren` | data mentah hasil query, siap dipakai sebagai data source |

Setiap tab dashboard memakai `print_area` eksplisit + *fit to 1 page* (A4 landscape), jadi satu
tab = satu halaman utuh baik di layar maupun saat dicetak/di-PDF-kan — tidak ada chart yang
terpotong di batas halaman. Geometri tiap halaman diverifikasi dengan me-render workbook ke PDF
dan mengukur tinggi konten per tab sebelum file dianggap final.

#### 2b. Looker Studio — 7 halaman

Panduan lengkap ada di **[`docs/looker_studio_build.md`](docs/looker_studio_build.md)**: setelan
kanvas (1600×900, *Fit to width*, `Canvas size = Auto` per halaman) yang memperbaiki visual
terpotong di mode presentasi, koordinat tiap elemen, tema Jago, dan checklist verifikasi.

| Halaman | Pertanyaan yang dijawab | Data source |
|---|---|---|
| 1. Ringkasan eksekutif | Seberapa besar dan seberapa berisiko basis pemohon ini? | `slik_customer_analysis` |
| 2. Matrix report | Apakah flag whitelist benar-benar memisahkan risiko? | `vw_matrix_whitelist_x_kol6m` |
| 3. Segmentasi perilaku | Perilaku kredit seperti apa yang paling berbahaya? | `vw_segment_summary` |
| 4. Uji kelayakan scorecard | Variabel SLIK mana yang layak masuk scorecard? | `vw_scorecard_deciles`, `vw_scorecard_power` |
| 5. Tren kualitas portofolio | Apakah kualitas kredit membaik atau memburuk? | `vw_slik_monthly_trend`, `vw_slik_monthly_customer` |
| 6. Demografi vs risiko | Apakah demografi menambah informasi di luar data SLIK? | `vw_demografi_ci` |
| 7. Rekomendasi & simulasi | Kriteria whitelist mana yang sebaiknya dipakai? | `vw_whitelist_scenarios` |

Elemen interaktif: **date range control** pada field `report_month` (panel bulanan `DS_PANEL`,
dipakai halaman 1 & 5) plus drop-down `whitelist_flag`, `slik_behavior_segment`, dan `age_group`.
Keempatnya dijadikan **report-level** agar berlaku di seluruh halaman, dan chart utama
mengaktifkan **cross-filtering** sehingga klik pada satu batang menyaring seluruh halaman.

Pemilihan chart didasarkan pada tipe variabel dan pertanyaan analisis, bukan tuntutan technical
test untuk memakai bar chart. Bar dipakai saat tujuannya membandingkan kategori; tren ordinal,
distribusi numerik, relationship, dan part-to-whole memakai visual yang berbeda.

### 3. Jupyter Notebook / Google Colab (deliverable C: insight)

`notebooks/slik_insight_analysis.ipynb` sudah tereksekusi lengkap (grafik + angka + narasi), jadi
bisa langsung dibaca di GitHub tanpa menjalankan apa pun. Untuk menjalankan ulang di Colab: upload
notebook beserta folder `data/` & `output/`, atau ganti sel *load data* dengan magic `%%bigquery`
langsung ke tabel BigQuery Anda.

---

## Definisi & Asumsi Kunci (dari KODE REFERENSI OJK + profil data)

| Konsep | Definisi yang dipakai |
|---|---|
| NIK | kolom `ktp` pada `slik_result` |
| Fasilitas **aktif** | `kondisi = '0'` (REF#24: Fasilitas Aktif) |
| **Write-off** | `kondisi IN ('3','4')` — Dihapusbukukan / Hapus Tagih |
| **Closed** | kondisi kategori "debitur tidak memiliki kewajiban" (lunas/dibatalkan/dialihkan: `1,2,5,6,7,8,9,11,12`) |
| **Restrukturisasi** | `sifatKredit='1'` ATAU `frekuensiRestrukturisasi>0` ATAU `tanggalRestrukturisasiAkhir` terisi |
| **Kartu kredit** | `jenisKredit = 'X-30'` (sandi 30) — *catatan: tidak ada CC berstatus aktif di dataset* |
| **Unsecured** | `jenisAgunan IS NULL` |
| **Personal loan** | penggunaan Konsumsi + unsecured + bukan kartu kredit (definisi KTA) |
| **Nonbank** | LJK Perusahaan Pembiayaan (kode prefix `25`) atau nama LJK tanpa BANK/BPR/BPD (modal ventura dll.) |
| **MOB** | selisih bulan `tanggalAwalKredit` → 2023-11 |
| Window "N bulan terakhir" | bulan riwayat `tahunBulanXX` pada rentang [2023-11 − N .. 2023-10], bulan aplikasi tidak diikutkan |
| **dpd10plus** | fasilitas aktif yang pernah DPD > 10 hari pada riwayat 24 bulan tersedia |
| `slik_installment` | 5% × outstanding CC aktif + Σ angsuran pinjaman aktif non-CC |
| `slik_exposure` | Σ limit CC aktif + Σ outstanding personal loan aktif |
| `whitelist_flag` | prioritas: 1. punya write-off → 2. punya restrukturisasi → 3. lainnya |

Definisi turunan yang dipakai untuk analisis risiko (lengkap di tab `Kamus Metrik`):

| Kolom | Arti | Kegunaan |
|---|---|---|
| `ever_npl_12m` | pernah kol ≥ 3 dalam 12 bulan terakhir (82 customer, 14,0%) | **kontrol saja** — kolom ini juga membentuk segmen, jadi tidak boleh dipakai sebagai target uji |
| `npl_now_active` | kol ≥ 3 **pada fasilitas yang masih aktif** per posisi 2023-11 (20 customer, 3,41%) | **target independen** yang dipakai untuk menilai skenario whitelist |
| `is_thin_file` | `slik_exposure = 0` (154 customer) | menandai pemohon tanpa jejak eksposur aktif |
| `slik_behavior_segment` | segmen rule-based dari sinyal terberat ke teringan: Writeoff → NPL/DPD>90 → Restructured → Past Due Ringan → Clean & Current | narasi segmentasi |
| IV / Gini / AUC | Information Value, Gini = \|2·AUC−1\|, AUC via Mann-Whitney terhadap `npl_now_active` | uji kelayakan variabel scorecard |

**Penanganan data quality** (didokumentasikan juga di komentar SQL dan tab `Catatan & Asumsi`):
- 27 `kreditId` duplikat (snapshot ganda) → dedup `ROW_NUMBER()` ambil `tanggalUpdate` terbaru, tie-break baki debet terbesar.
- 2.331 sel tanggal berisi `#VALUE!` → semua parsing memakai `SAFE.PARSE_DATE` / `SAFE_CAST` (raw di-load sebagai STRING).
- Mapping LJK tidak unik per kode (entitas konvensional + UUS) → dedup sebelum join.
- Spec meminta kolom kartu kredit, tetapi dataset **tidak punya satu pun CC berstatus aktif** → kolom tetap dibuat (nilainya 0) dan fakta ini dicatat, bukan disembunyikan.

## Ringkasan Hasil

**Profil basis.** 587 customer: 510 `3.Customer Others` · 61 `1.Customer has Writeoff` ·
16 `2.Customer has Restru`. Segmen perilaku: 72,6% Clean & Current · 10,9% Past Due Ringan ·
10,4% Writeoff · 3,7% NPL/Delinquent · 2,4% Restructured.

**Temuan 1 — flag whitelist valid tapi belum kedap.** Uji chi-square menolak independensi
(p ≪ 0,05): grup write-off memang menumpuk di kol 5. Tetapi **13 customer bergrup "Others"
sudah kol 3–5** dalam 6 bulan terakhir, sehingga kriteria yang berjalan sekarang masih
meloloskan pemohon macet.

**Temuan 2 — "credit shopper" adalah sinyal bahaya.** Segmen NPL/Delinquent memegang
rata-rata **64,2 fasilitas** kredit, dibanding 17,7 di segmen Clean & Current. Banyaknya
fasilitas, bukan besarnya pinjaman, yang membedakan pemohon buruk.

**Temuan 3 — eksposur besar justru lebih aman, tapi jangan dipakai sebagai skor.** Pada definisi
kontrol `ever_npl_12m`, bad rate turun dari **20,3% di desil eksposur terendah menjadi 8,5% di
desil tertinggi** — pemohon *thin file* (154 orang tanpa eksposur aktif) yang lebih berisiko.
Penurunannya **tidak monoton**, dan pada target `npl_now_active` rank-ordering-nya nyaris hilang
(20 kejadian tersebar di 10 desil). Uji kekuatan mengonfirmasi: `slik_exposure` hanya Gini
**0,115** (lemah, arah terbalik), sedangkan `flags_active_dpd10plus_count` mencapai Gini
**0,906**. Kesimpulannya: pakai sinyal kualitas (DPD, kolektibilitas) sebagai inti skor, dan
eksposur hanya sebagai pendamping — bukan cut-off.

**Temuan 4 — kualitas portofolio memburuk selama jendela pengamatan.** NPL level customer naik
dari **9,7% (Nov-21) ke 11,7% (Okt-23)** dan rata-rata DPD hampir dua kali lipat, dari
**26,9 menjadi 51,8 hari** — konteks yang membuat pengetatan kriteria lebih relevan.

**Rekomendasi — pakai skenario S2.** Menambahkan satu syarat saja pada kriteria yang berjalan,
yaitu kolektibilitas maksimum 12 bulan terakhir ≤ 2:

| Skenario | Lolos | % basis | NPL aktif yang lolos |
|---|---:|---:|---:|
| S0 — tanpa filter | 587 | 100,0% | 3,41% |
| S1 — flag Others saja (**kriteria saat ini**) | 510 | 86,9% | 1,57% |
| **S2 — Others + kol 12 bln ≤ 2** | **490** | **83,5%** | **0,00%** |
| S3 — S2 + DPD 3 bln = 0 | 459 | 78,2% | 0,00% |
| S4 — Others + kol 12 bln = 1 + DPD 3 bln = 0 | 428 | 72,9% | 0,00% |

S2 sudah menutup seluruh kebocoran NPL aktif dengan biaya 3,4pp basis pemohon. S3 dan S4 tidak
menambah proteksi apa pun tetapi memotong 5–11pp basis lagi, jadi syarat tambahannya tidak
sepadan. Detail perhitungan ada di `notebooks/slik_insight_analysis.ipynb` dan tab
`7. Simulasi Kebijakan`.




