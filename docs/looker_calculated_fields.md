# Looker Studio — rumus field siap tempel

Salin ke **Resource → Manage added data sources → Edit → Add a field**.

> **Baca dulu.** Sejak `vw_looker_customer` dan `vw_looker_kpi` dibuat di BigQuery
> (`sql/03_analysis_views.sql` objek 11 & 12), **seluruh field `DS_CUST` di bawah
> tidak perlu dibuat lagi** — kolomnya sudah datang siap pakai dari view. Yang masih
> harus dibuat manual hanya dua field `DS_PANEL`.
>
> Alasannya bukan sekadar hemat langkah: rumus `Lolos kriteria usulan` wajib memakai
> `COALESCE(..., 1)` karena 9 pemohon ber-flag Others tidak punya baris riwayat pada
> jendela 12 bulan. Ditulis ulang dengan tangan tanpa `COALESCE`, laporan menampilkan
> 481 (82,3%) alih-alih 490 (83,5%) dan bertentangan dengan README, workbook, serta
> notebook. Dengan kolomnya dihitung di SQL, kesalahan itu tidak mungkin terjadi.
>
> Bagian `DS_CUST` disimpan di sini sebagai rujukan definisi metrik dan sebagai jalur
> cadangan kalau laporan disambungkan lewat CSV/Google Sheets, bukan BigQuery.

---

## DS_CUST — sudah tersedia dari `vw_looker_customer`, tidak perlu dibuat

| Kolom di view | Padanan rumus manual (jalur CSV) |
|---|---|
| `lolos_kriteria_usulan` | lihat "Lolos kriteria usulan" di bawah |
| `celah_npl_others_6bln` | lihat "Celah Others" di bawah |
| `kelompok_whitelist` | pemetaan label `whitelist_flag` |
| `segmen_awam` | pemetaan label `slik_behavior_segment` |
| `status_jejak_slik` | pemetaan label `is_thin_file` |

Untuk bad rate, tidak perlu field baru sama sekali: pakai kolom `npl_now_active` atau
`ever_npl_12m` langsung, lalu set agregasi **Average** dan format **Percent** di panel
chart, dan ganti nama tampilannya lewat ikon pensil pada nama metrik.

### NPL aktif (%)
```
AVG(npl_now_active)
```
- Type: **Percent**
- Default aggregation: **Average**
- Label tampilan: `NPL aktif (%)`

### Pernah bermasalah 12 bln (%)
```
AVG(ever_npl_12m)
```
- Type: **Percent**, Aggregation: **Average**
- Label: `Pernah bermasalah 12 bln (%)`

### Lolos kriteria usulan
```
CASE
  WHEN whitelist_flag = "3.Customer Others"
   AND COALESCE(collection_status_allcondition_last_12months_max, 1) <= 2
  THEN "Lolos"
  ELSE "Ditolak"
END
```
- Type: **Text**
- Label: `Lolos kriteria usulan`
- **Jangan hapus `COALESCE`** — tanpa itu hasilnya 481, bukan 490.

### Celah Others (kol 6 bln ≥ 3)
```
CASE
  WHEN whitelist_flag = "3.Customer Others"
   AND collection_status_allcondition_last_6months_max >= 3
  THEN 1
  ELSE 0
END
```
- Type: **Number**, Aggregation: **Sum**
- Label: `Celah Others (kol 6 bln ≥ 3)`

---

## DS_KPI (`vw_looker_kpi`) — tanpa rumus, tanpa filter

Satu baris berisi seluruh angka KPI. Untuk tiap scorecard: pilih kolomnya, agregasi
**MAX**, dan **jangan pasang chart-level filter apa pun**.

| Kolom | Nilai | Dipakai |
|---|---|---|
| `total_pemohon` | 587 | hal 1 |
| `pemohon_tanpa_catatan_buruk` | 510 | hal 1 |
| `celah_npl_others_6bln` | 13 | hal 1 |
| `pemohon_lolos_usulan` | 490 | hal 7 |
| `pct_basis_lolos_usulan` | 83,5 | hal 7 |
| `npl_aktif_lolos_pct` | 0,0 | hal 1 & 7 |
| `pernah_npl_12bln_lolos_pct` | 0,0 | hal 7 |
| `npl_aktif_basis_pct` | 3,41 | catatan kaki |
| `npl_aktif_kriteria_sekarang_pct` | 1,57 | hal 1 narasi |
| `biaya_basis_pp` | 3,4 | hal 7 narasi |

---

## DS_PANEL (`vw_slik_monthly_customer`) — dua field ini masih perlu dibuat

### Kol 3-5 (%)
```
AVG(is_npl)
```
- Percent, Average — label: `Kol 3-5 (%)`

### Rata-rata hari telat
```
AVG(hari_telat_max)
```
- Number, Average — label: `Rata-rata hari telat`

---

## Agregasi default yang harus diubah ke Average (bukan Sum)

Pada data source, set **Default aggregation = Average** untuk kolom:

| Data source | Kolom |
|---|---|
| DS_KPI | *tidak perlu* — 1 baris, pakai agregasi **MAX** |
| DS_SCEN | `pct_basis`, `npl_active_pct`, `npl_now_pct`, `npl_12m_pct` |
| DS_SEG | `pct_customer`, `avg_facility_count`, `avg_slik_exposure`, `avg_slik_installment`, `avg_balance_sum`, `avg_mob_max`, `npl_active_pct`, `dpd_3m_pct` |
| DS_DECILE | `exposure_min`, `exposure_max`, `npl_active_pct_exposure`, `npl_active_pct_installment`, `ever_npl_12m_pct_exposure`, `ever_npl_12m_pct_installment` |
| DS_POWER | `gini`, `iv`, `auc` |
| DS_TREND | `customer_npl_pct`, `facility_npl_pct`, `facility_dpk_pct`, `avg_dpd_days` |
| DS_DEMO (`vw_demografi_ci`, opsional hal 6) | `rate`, `lo`, `hi`, `npl_active_rate` |

Kalau tetap Sum, filter atau rentang tanggal bisa menghasilkan persentase > 100%.
Kolom hitungan orang (`total_customer`, `lolos`, `n`, `k`, `customer_reported`) justru
harus tetap **Sum** — kolom itu memang jumlah, bukan rata-rata.

---

## Uji angka (harus cocok)

| Uji | Nilai |
|---|---|
| Total pemohon | 587 |
| Flag Others | 510 |
| Celah Others kol 3–5 (6 bln) | 13 |
| S2 lolos | 490 (83,5%) |
| S2 NPL aktif yang lolos | 0,00% |
| NPL aktif portofolio (S0) | 3,41% |
