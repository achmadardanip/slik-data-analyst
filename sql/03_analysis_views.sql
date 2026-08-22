-- ============================================================================
-- TABEL & VIEW ANALISIS (sumber data Looker Studio & workbook Excel)
--
-- Seluruh angka pada deliverable bisa direproduksi dari objek di file ini.
-- Nama dan definisi kolom dijaga identik dengan implementasi pembanding di
-- pandas/DuckDB supaya dua jalur perhitungan (BigQuery vs Python) bisa
-- dibandingkan baris per baris.
--
--  0. vw_slik_facility            : 1 baris = 1 fasilitas (snapshot dedup).
--  1. vw_slik_facility_history    : 1 baris = fasilitas x bulan pelaporan.
--  2. slik_customer_analysis      : TABEL lebar 1 baris per customer -- 25 kolom
--                                   agregat + demografi + segmen + band + label
--                                   ramah-pembaca + outcome  ->  DS_CUST.
--  3. vw_matrix_whitelist_x_kol6m : matrix report whitelist_flag x Kol 6 bulan.
--  4. vw_segment_summary          : ringkasan metrik per segmen perilaku SLIK.
--  5. vw_scorecard_deciles        : rank-ordering desil eksposur & angsuran.
--  6. vw_scorecard_power          : IV + Gini + AUC per kandidat variabel.
--  7. vw_slik_monthly_trend       : tren 24 bulan level portofolio -> DS_TREND.
--  8. vw_slik_monthly_customer    : panel NIK x bulan             -> DS_PANEL.
--  9. vw_whitelist_scenarios      : simulasi 5 skenario kriteria whitelist.
-- 10. vw_demografi_ci             : bad rate per demografi + CI 95% (Wilson).
--
-- BULAN APLIKASI
-- Bulan aplikasi 2023-11 ditulis sebagai literal DATE '2023-11-01' di setiap
-- objek, bukan sebagai script variable: definisi VIEW di BigQuery tidak boleh
-- mereferensikan variabel DECLARE.
--
-- CATATAN BINNING
-- Desil dan bin IV memakai rumus yang sama dengan referensi Python
-- (`pd.qcut(rank(method="first"), 10)`): urutkan nilai (tie-break NIK, sama
-- dengan urutan baris tabel agregat), lalu
--     desil = GREATEST(1, CEIL((peringkat - 1) * 10 / (jumlah_baris - 1)))
-- Rumus ini dipakai, bukan NTILE(10), karena NTILE menaruh seluruh baris sisa
-- di bucket-bucket awal sehingga ukuran desil dan IV-nya berbeda tipis dari
-- angka yang tercetak di workbook Excel. Dengan rumus di atas kedua jalur
-- menghasilkan angka yang identik dan bisa dibandingkan langsung.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 0. Snapshot fasilitas (dedup 1 baris per kreditId).
--    Dipakai ulang oleh view lain supaya logika dedup & flag kondisi hanya
--    ditulis satu kali. Aturan kondisi mengikuti KODE REFERENSI OJK REF#24.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `slik-da-intern-technical-test.slik.vw_slik_facility` AS
SELECT
  d.ktp                                                  AS NIK,
  d.kreditId                                             AS kredit_id,
  COALESCE(SAFE_CAST(d.bakiDebet AS FLOAT64), 0)         AS balance,
  COALESCE(SAFE_CAST(d.plafon    AS FLOAT64), 0)         AS plafond,
  COALESCE(SAFE_CAST(d.angsuran  AS FLOAT64), 0)         AS installment,
  SAFE_CAST(d.kolektibilitas AS INT64)                   AS kol_now,
  (d.kondisi = '0')                                      AS is_active,
  (d.kondisi IN ('3', '4'))                              AS is_writeoff,
  (d.kondisi IN ('1','2','5','6','7','8','9','11','12')) AS is_closed,
  (d.jenisKredit = 'X-30')                               AS is_credit_card,
  (d.jenisAgunan IS NULL)                                AS is_unsecured
FROM (
  SELECT
    r.*,
    ROW_NUMBER() OVER (
      PARTITION BY r.kreditId
      ORDER BY
        SAFE.PARSE_DATE('%m/%d/%Y', r.tanggalUpdate) DESC NULLS LAST,
        SAFE_CAST(r.bakiDebet AS FLOAT64) DESC
    ) AS rn
  FROM `slik-da-intern-technical-test.slik.slik_result` r
) d
WHERE d.rn = 1;


-- ----------------------------------------------------------------------------
-- 1. Riwayat bulanan long-format: 1 baris = fasilitas x bulan pelaporan.
--    24 kolom `tahunBulanNN` di data mentah dijadikan array lalu di-UNNEST,
--    sehingga bulan bisa dipakai sebagai dimensi tanggal (tren & panel).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `slik-da-intern-technical-test.slik.vw_slik_facility_history` AS
WITH fac AS (
  SELECT
    d.ktp                                                  AS NIK,
    d.kreditId                                             AS kredit_id,
    (d.kondisi = '0')                                      AS is_active,
    (d.kondisi IN ('1','2','5','6','7','8','9','11','12')) AS is_closed,
    (d.jenisAgunan IS NULL)                                AS is_unsecured,
    [
      STRUCT(d.tahunBulan01 AS ym, d.tahunBulan01Kol AS kol, d.tahunBulan01Ht AS ht),
      STRUCT(d.tahunBulan02, d.tahunBulan02Kol, d.tahunBulan02Ht),
      STRUCT(d.tahunBulan03, d.tahunBulan03Kol, d.tahunBulan03Ht),
      STRUCT(d.tahunBulan04, d.tahunBulan04Kol, d.tahunBulan04Ht),
      STRUCT(d.tahunBulan05, d.tahunBulan05Kol, d.tahunBulan05Ht),
      STRUCT(d.tahunBulan06, d.tahunBulan06Kol, d.tahunBulan06Ht),
      STRUCT(d.tahunBulan07, d.tahunBulan07Kol, d.tahunBulan07Ht),
      STRUCT(d.tahunBulan08, d.tahunBulan08Kol, d.tahunBulan08Ht),
      STRUCT(d.tahunBulan09, d.tahunBulan09Kol, d.tahunBulan09Ht),
      STRUCT(d.tahunBulan10, d.tahunBulan10Kol, d.tahunBulan10Ht),
      STRUCT(d.tahunBulan11, d.tahunBulan11Kol, d.tahunBulan11Ht),
      STRUCT(d.tahunBulan12, d.tahunBulan12Kol, d.tahunBulan12Ht),
      STRUCT(d.tahunBulan13, d.tahunBulan13Kol, d.tahunBulan13Ht),
      STRUCT(d.tahunBulan14, d.tahunBulan14Kol, d.tahunBulan14Ht),
      STRUCT(d.tahunBulan15, d.tahunBulan15Kol, d.tahunBulan15Ht),
      STRUCT(d.tahunBulan16, d.tahunBulan16Kol, d.tahunBulan16Ht),
      STRUCT(d.tahunBulan17, d.tahunBulan17Kol, d.tahunBulan17Ht),
      STRUCT(d.tahunBulan18, d.tahunBulan18Kol, d.tahunBulan18Ht),
      STRUCT(d.tahunBulan19, d.tahunBulan19Kol, d.tahunBulan19Ht),
      STRUCT(d.tahunBulan20, d.tahunBulan20Kol, d.tahunBulan20Ht),
      STRUCT(d.tahunBulan21, d.tahunBulan21Kol, d.tahunBulan21Ht),
      STRUCT(d.tahunBulan22, d.tahunBulan22Kol, d.tahunBulan22Ht),
      STRUCT(d.tahunBulan23, d.tahunBulan23Kol, d.tahunBulan23Ht),
      STRUCT(d.tahunBulan24, d.tahunBulan24Kol, d.tahunBulan24Ht)
    ]                                                      AS history
  FROM (
    SELECT
      r.*,
      ROW_NUMBER() OVER (
        PARTITION BY r.kreditId
        ORDER BY
          SAFE.PARSE_DATE('%m/%d/%Y', r.tanggalUpdate) DESC NULLS LAST,
          SAFE_CAST(r.bakiDebet AS FLOAT64) DESC
      ) AS rn
    FROM `slik-da-intern-technical-test.slik.slik_result` r
  ) d
  WHERE d.rn = 1
)
SELECT
  f.NIK,
  f.kredit_id,
  f.is_active,
  f.is_closed,
  f.is_unsecured,
  SAFE_CAST(h.ym AS INT64)                       AS ym,
  SAFE.PARSE_DATE('%Y%m%d', CONCAT(h.ym, '01'))  AS report_month,
  SAFE_CAST(h.kol AS INT64)                      AS kol,
  SAFE_CAST(h.ht  AS FLOAT64)                    AS dpd
FROM fac f, UNNEST(f.history) h
WHERE h.ym IS NOT NULL;


-- ----------------------------------------------------------------------------
-- Label kolektibilitas resmi OJK (REF#21). `no_history_label` diparameterkan
-- supaya kolom 12 bulan tidak memakai teks "6 Bln".
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION `slik-da-intern-technical-test.slik.fn_kol_label`(
  kol INT64, no_history_label STRING
) RETURNS STRING AS (
  CASE kol
    WHEN 1 THEN 'Kol 1 - Lancar'
    WHEN 2 THEN 'Kol 2 - Dalam Perhatian Khusus'
    WHEN 3 THEN 'Kol 3 - Kurang Lancar'
    WHEN 4 THEN 'Kol 4 - Diragukan'
    WHEN 5 THEN 'Kol 5 - Macet'
    ELSE no_history_label
  END
);


-- ----------------------------------------------------------------------------
-- 2. Tabel analisis level customer -- data source utama (DS_CUST).
--    25 kolom spesifikasi + demografi + segmen perilaku + band scorecard
--    + label ramah-pembaca + dua definisi outcome.
--
--    DUA DEFINISI "BAD" DIPISAH DENGAN SENGAJA:
--    - ever_npl_12m   : Kol >= 3 pada riwayat 12 bulan. Kolom ini juga dipakai
--                       untuk MEMBENTUK segmen sehingga tautologis -> kontrol.
--    - npl_now_active : Kol >= 3 pada snapshot fasilitas yang masih AKTIF per
--                       2023-11. Independen dari definisi segmen -> dipakai
--                       untuk seluruh bad rate di dashboard & scorecard.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE `slik-da-intern-technical-test.slik.slik_customer_analysis` AS
WITH kol_snap AS (
  SELECT
    NIK,
    MAX(kol_now)                      AS kol_now_max,
    MAX(IF(is_active, kol_now, NULL)) AS kol_now_active_max
  FROM `slik-da-intern-technical-test.slik.vw_slik_facility`
  GROUP BY NIK
),
base AS (
  SELECT
    a.*,
    d1.age_group,
    d1.industry,
    d1.marital_status,
    d1.gender,
    d2.kabKotaKet          AS kab_kota,
    d2.pekerjaanKet        AS pekerjaan,
    d2.bidangUsahaKet      AS bidang_usaha,
    d2.statusGelarDebitur  AS pendidikan,
    k.kol_now_max,
    k.kol_now_active_max
  FROM `slik-da-intern-technical-test.slik.slik_aggregated_table` a
  LEFT JOIN `slik-da-intern-technical-test.slik.slik_demographic1` d1 ON a.NIK = d1.id_number
  LEFT JOIN `slik-da-intern-technical-test.slik.slik_demographic2` d2 ON a.NIK = d2.noIdentitas
  LEFT JOIN kol_snap k ON a.NIK = k.NIK
)
SELECT
  b.*,
  -- ------------------------------------------------------------------
  -- Segmen perilaku SLIK (rule-based, urutan = tingkat keparahan):
  --   E. Writeoff          : pernah dihapusbukukan / hapus tagih
  --   D. NPL / Delinquent  : Kol >= 3 atau DPD > 90 dalam 12 bulan terakhir
  --   C. Restructured      : punya fasilitas restrukturisasi
  --   B. Past Due Ringan   : Kol 2 atau DPD 1-90 dalam 12 bulan terakhir
  --   A. Clean & Current   : selain di atas (selalu lancar)
  -- ------------------------------------------------------------------
  CASE
    WHEN b.flags_chargewriteoff_count > 0                              THEN 'E. Writeoff'
    WHEN COALESCE(b.collection_status_allcondition_last_12months_max, 1) >= 3
         OR COALESCE(b.dpd_nonbank_allcondition_last_12months_max, 0) > 90
         OR COALESCE(b.dpd_allcondition_last_3months_max, 0) > 90     THEN 'D. NPL / Delinquent'
    WHEN b.whitelist_flag = '2.Customer has Restru'                    THEN 'C. Restructured'
    WHEN COALESCE(b.collection_status_allcondition_last_12months_max, 1) = 2
         OR COALESCE(b.dpd_allcondition_last_3months_max, 0)  > 0
         OR COALESCE(b.dpd_nonbank_allcondition_last_12months_max, 0) > 0
                                                                       THEN 'B. Past Due Ringan'
    ELSE                                                                    'A. Clean & Current'
  END AS slik_behavior_segment,
  -- Band eksposur & angsuran untuk analisis scorecard
  CASE
    WHEN COALESCE(b.slik_exposure, 0) = 0          THEN '0. Tanpa Eksposur'
    WHEN b.slik_exposure <  5000000                THEN '1. < 5 Juta'
    WHEN b.slik_exposure < 25000000                THEN '2. 5 - 25 Juta'
    WHEN b.slik_exposure < 100000000               THEN '3. 25 - 100 Juta'
    ELSE                                                '4. >= 100 Juta'
  END AS slik_exposure_band,
  CASE
    WHEN COALESCE(b.slik_installment, 0) = 0       THEN '0. Tanpa Angsuran'
    WHEN b.slik_installment <  1000000             THEN '1. < 1 Juta'
    WHEN b.slik_installment <  5000000             THEN '2. 1 - 5 Juta'
    WHEN b.slik_installment < 20000000             THEN '3. 5 - 20 Juta'
    ELSE                                                '4. >= 20 Juta'
  END AS slik_installment_band,
  -- Label ramah-pembaca (dipakai sebagai dimensi di Looker & Excel)
  `slik-da-intern-technical-test.slik.fn_kol_label`(
    b.collection_status_allcondition_last_6months_max,  'Tanpa Riwayat 6 Bln')  AS kol_6m_label,
  `slik-da-intern-technical-test.slik.fn_kol_label`(
    b.collection_status_allcondition_last_12months_max, 'Tanpa Riwayat 12 Bln') AS kol_12m_label,
  -- 5 kolektibilitas diringkas jadi 3 band + 1 kelompok tanpa riwayat
  CASE
    WHEN b.collection_status_allcondition_last_6months_max IS NULL THEN '3. Tanpa Riwayat'
    WHEN b.collection_status_allcondition_last_6months_max = 1     THEN '0. Lancar'
    WHEN b.collection_status_allcondition_last_6months_max = 2     THEN '1. Perhatian Khusus'
    ELSE                                                                '2. NPL (Kol 3-5)'
  END AS risk_band_6m,
  -- Indikator biner untuk rate di dashboard
  IF(COALESCE(b.collection_status_allcondition_last_12months_max, 1) >= 3, 1, 0) AS ever_npl_12m,
  IF(COALESCE(b.dpd_allcondition_last_3months_max, 0) > 0, 1, 0)                 AS ever_dpd_3m,
  IF(b.flags_allcondition_count > 0 AND b.mob_active_avg IS NOT NULL, 1, 0)      AS has_active_facility,
  IF(COALESCE(b.kol_now_max, 1) >= 3, 1, 0)                                      AS npl_now,
  IF(COALESCE(b.kol_now_active_max, 1) >= 3, 1, 0)                               AS npl_now_active,
  IF(COALESCE(b.slik_exposure, 0) = 0, 1, 0)                                     AS is_thin_file
FROM base b;


-- ----------------------------------------------------------------------------
-- 3. Matrix report: whitelist_flag x kolektibilitas maksimum 6 bulan terakhir.
--    Customer tanpa riwayat 6 bulan masuk kategori eksplisit "Tanpa Riwayat
--    6 Bln" supaya total matrix tetap 587 (NULL tidak boleh menghilangkan baris).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `slik-da-intern-technical-test.slik.vw_matrix_whitelist_x_kol6m` AS
SELECT
  whitelist_flag,
  kol_6m_label,
  COUNT(*) AS total_customer
FROM `slik-da-intern-technical-test.slik.slik_customer_analysis`
GROUP BY whitelist_flag, kol_6m_label
ORDER BY
  whitelist_flag,
  IF(STARTS_WITH(kol_6m_label, 'Kol '), SAFE_CAST(SUBSTR(kol_6m_label, 5, 1) AS INT64), 9);


-- ----------------------------------------------------------------------------
-- 4. Ringkasan per segmen perilaku SLIK.
--    `npl_active_pct` (outcome independen) adalah kolom yang dibaca di
--    dashboard; `customer_ever_npl_12m` hanya kontrol karena tautologis.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `slik-da-intern-technical-test.slik.vw_segment_summary` AS
SELECT
  slik_behavior_segment,
  COUNT(*)                                             AS total_customer,
  ROUND(AVG(flags_allcondition_count), 1)              AS avg_facility_count,
  ROUND(AVG(slik_exposure), 1)                         AS avg_slik_exposure,
  ROUND(AVG(slik_installment), 1)                      AS avg_slik_installment,
  ROUND(AVG(balance_sum), 1)                           AS avg_balance_sum,
  ROUND(AVG(mob_allcondition_max), 1)                  AS avg_mob_max,
  SUM(ever_npl_12m)                                    AS customer_ever_npl_12m,
  SUM(npl_now_active)                                  AS customer_npl_now_active,
  SUM(ever_dpd_3m)                                     AS customer_dpd_3m,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)     AS pct_customer,
  ROUND(100 * AVG(npl_now_active), 1)                  AS npl_active_pct,
  ROUND(100 * AVG(ever_dpd_3m), 1)                     AS dpd_3m_pct
FROM `slik-da-intern-technical-test.slik.slik_customer_analysis`
GROUP BY slik_behavior_segment
ORDER BY slik_behavior_segment;


-- ----------------------------------------------------------------------------
-- 5. Evaluasi scorecard, bagian 1: rank-ordering desil.
--    Bila sebuah metrik layak dipakai, bad rate seharusnya naik/turun monoton
--    dari desil 1 ke desil 10. Desil eksposur dan desil angsuran dihitung
--    terpisah lalu disandingkan pada nomor desil yang sama (sama seperti
--    output pandas `scorecard_deciles.csv`).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `slik-da-intern-technical-test.slik.vw_scorecard_deciles` AS
WITH r AS (
  SELECT
    NIK,
    slik_exposure,
    slik_installment,
    npl_now_active,
    ever_npl_12m,
    GREATEST(1, CAST(CEIL(
      (ROW_NUMBER() OVER (ORDER BY slik_exposure, NIK) - 1) * 10
      / (COUNT(*) OVER () - 1)) AS INT64))            AS decile_exposure,
    GREATEST(1, CAST(CEIL(
      (ROW_NUMBER() OVER (ORDER BY slik_installment, NIK) - 1) * 10
      / (COUNT(*) OVER () - 1)) AS INT64))            AS decile_installment
  FROM `slik-da-intern-technical-test.slik.slik_customer_analysis`
),
d_exp AS (
  SELECT
    decile_exposure                     AS decile,
    COUNT(*)                            AS total_customer,
    ROUND(MIN(slik_exposure), 2)        AS exposure_min,
    ROUND(MAX(slik_exposure), 2)        AS exposure_max,
    ROUND(100 * AVG(npl_now_active), 1) AS npl_active_pct_exposure,
    ROUND(100 * AVG(ever_npl_12m),   1) AS ever_npl_12m_pct_exposure
  FROM r
  GROUP BY decile_exposure
),
d_ins AS (
  SELECT
    decile_installment                  AS decile,
    ROUND(100 * AVG(npl_now_active), 1) AS npl_active_pct_installment,
    ROUND(100 * AVG(ever_npl_12m),   1) AS ever_npl_12m_pct_installment
  FROM r
  GROUP BY decile_installment
)
SELECT
  e.decile,
  e.total_customer,
  e.exposure_min,
  e.exposure_max,
  e.npl_active_pct_exposure,
  i.npl_active_pct_installment,
  e.ever_npl_12m_pct_exposure,
  i.ever_npl_12m_pct_installment
FROM d_exp e
JOIN d_ins i ON e.decile = i.decile
ORDER BY e.decile;


-- ----------------------------------------------------------------------------
-- 6. Evaluasi scorecard, bagian 2: daya pisah tiap kandidat variabel.
--    IV   = SUM((p_bad - p_good) * LN(p_bad / p_good)) atas 10 bin sama-jumlah;
--           bin kosong diberi 0,5 kejadian supaya LN tidak divergen.
--    AUC  = Mann-Whitney U / (n_bad * n_good) memakai rank rata-rata untuk nilai
--           kembar (rank_min + (jumlah_kembar - 1) / 2).
--    Gini = |2 * AUC - 1|. AUC < 0,5 berarti arah hubungan terbalik.
--    Target = npl_now_active (outcome independen).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `slik-da-intern-technical-test.slik.vw_scorecard_power` AS
WITH m AS (
  SELECT
    c.NIK,
    c.npl_now_active AS bad,
    x.metric,
    x.label,
    x.value
  FROM `slik-da-intern-technical-test.slik.slik_customer_analysis` c,
  UNNEST([
    STRUCT('slik_exposure' AS metric,
           'Total eksposur SLIK (limit CC + outstanding KTA)' AS label,
           c.slik_exposure AS value),
    STRUCT('slik_installment',
           'Total angsuran SLIK per bulan',
           c.slik_installment),
    STRUCT('flags_allcondition_count',
           'Jumlah fasilitas kredit (semua kondisi)',
           CAST(c.flags_allcondition_count AS FLOAT64)),
    STRUCT('flags_active_dpd10plus_count',
           'Jumlah fasilitas aktif pernah telat >10 hari',
           CAST(c.flags_active_dpd10plus_count AS FLOAT64)),
    STRUCT('flags_restructured_allcondition_unsecured_count',
           'Jumlah fasilitas tanpa agunan direstrukturisasi',
           CAST(c.flags_restructured_allcondition_unsecured_count AS FLOAT64)),
    STRUCT('mob_allcondition_max',
           'Umur kredit terlama (bulan)',
           CAST(c.mob_allcondition_max AS FLOAT64)),
    STRUCT('balance_unsecured_sum',
           'Total outstanding tanpa agunan',
           c.balance_unsecured_sum)
  ]) x
  WHERE x.value IS NOT NULL
),
ranked AS (
  SELECT
    metric,
    label,
    bad,
    GREATEST(1, CAST(CEIL(
      (ROW_NUMBER() OVER (PARTITION BY metric ORDER BY value, NIK) - 1) * 10
      / (COUNT(*) OVER (PARTITION BY metric) - 1)) AS INT64))  AS bin,
    RANK()    OVER (PARTITION BY metric ORDER BY value)
      + (COUNT(*) OVER (PARTITION BY metric, value) - 1) / 2   AS rank_avg
  FROM m
),
binned AS (
  SELECT metric, bin, COUNTIF(bad = 1) AS bad_n, COUNTIF(bad = 0) AS good_n
  FROM ranked
  GROUP BY metric, bin
),
tot AS (
  SELECT metric, SUM(bad_n) AS bad_tot, SUM(good_n) AS good_tot
  FROM binned
  GROUP BY metric
),
iv AS (
  SELECT metric, SUM((p_bad - p_good) * LN(p_bad / p_good)) AS iv
  FROM (
    SELECT
      b.metric,
      IF(b.bad_n  = 0, 0.5 / t.bad_tot,  b.bad_n  / t.bad_tot)  AS p_bad,
      IF(b.good_n = 0, 0.5 / t.good_tot, b.good_n / t.good_tot) AS p_good
    FROM binned b
    JOIN tot t ON b.metric = t.metric
  )
  GROUP BY metric
),
auc AS (
  SELECT
    metric,
    SAFE_DIVIDE(
      SUM(IF(bad = 1, rank_avg, 0)) - COUNTIF(bad = 1) * (COUNTIF(bad = 1) + 1) / 2,
      COUNTIF(bad = 1) * COUNTIF(bad = 0)
    ) AS auc
  FROM ranked
  GROUP BY metric
)
SELECT
  l.metric,
  l.label,
  ROUND(i.iv, 3)                AS iv,
  ROUND(ABS(2 * a.auc - 1), 3)  AS gini,
  ROUND(a.auc, 3)               AS auc,
  IF(a.auc >= 0.5, 'Searah (naik = lebih berisiko)',
                   'Terbalik (naik = lebih aman)') AS arah,
  CASE
    WHEN ABS(2 * a.auc - 1) >= 0.4 THEN 'Kuat'
    WHEN ABS(2 * a.auc - 1) >= 0.2 THEN 'Sedang'
    WHEN ABS(2 * a.auc - 1) >= 0.1 THEN 'Lemah'
    ELSE                                'Tidak dapat dipakai'
  END AS kekuatan
FROM (SELECT DISTINCT metric, label FROM m) l
JOIN iv  i ON l.metric = i.metric
JOIN auc a ON l.metric = a.metric
ORDER BY gini DESC;


-- ----------------------------------------------------------------------------
-- 7. Tren kualitas portofolio 24 bulan sebelum aplikasi (Nov 2021 - Okt 2023).
--    Jendela sengaja berhenti di Okt 2023: bulan aplikasi (Nov 2023) tidak ikut
--    supaya tidak ada kebocoran informasi setelah keputusan kredit.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `slik-da-intern-technical-test.slik.vw_slik_monthly_trend` AS
WITH h AS (
  SELECT *
  FROM `slik-da-intern-technical-test.slik.vw_slik_facility_history`
  WHERE ym BETWEEN 202111 AND 202310 AND kol IS NOT NULL
),
fac_lvl AS (
  SELECT
    ym,
    MIN(report_month)          AS report_month,
    COUNT(DISTINCT NIK)        AS customer_reported,
    COUNT(DISTINCT kredit_id)  AS facility_reported,
    COUNTIF(kol >= 3)          AS facility_npl,
    COUNTIF(kol =  2)          AS facility_dpk,
    AVG(dpd)                   AS avg_dpd_days
  FROM h
  GROUP BY ym
),
cust_lvl AS (
  SELECT ym, COUNTIF(kol_max >= 3) AS customer_npl
  FROM (SELECT ym, NIK, MAX(kol) AS kol_max FROM h GROUP BY ym, NIK)
  GROUP BY ym
)
SELECT
  f.report_month,
  f.ym,
  FORMAT_DATE('%b-%y', f.report_month)                        AS month_label,
  f.customer_reported,
  f.facility_reported,
  c.customer_npl,
  ROUND(100 * c.customer_npl  / f.customer_reported, 2)       AS customer_npl_pct,
  f.facility_npl,
  ROUND(100 * f.facility_npl  / f.facility_reported, 2)       AS facility_npl_pct,
  f.facility_dpk,
  ROUND(100 * f.facility_dpk  / f.facility_reported, 2)       AS facility_dpk_pct,
  ROUND(f.avg_dpd_days, 1)                                    AS avg_dpd_days
FROM fac_lvl f
JOIN cust_lvl c ON f.ym = c.ym
ORDER BY f.ym;


-- ----------------------------------------------------------------------------
-- 8. Panel bulanan per pemohon (NIK x bulan) -- satu-satunya sumber yang punya
--    dimensi tanggal SEKALIGUS atribut kategori, sehingga date range control
--    dan filter kategori di Looker Studio bisa bekerja pada chart yang sama.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `slik-da-intern-technical-test.slik.vw_slik_monthly_customer` AS
WITH h AS (
  SELECT *
  FROM `slik-da-intern-technical-test.slik.vw_slik_facility_history`
  WHERE ym BETWEEN 202111 AND 202310 AND kol IS NOT NULL
),
p AS (
  SELECT
    ym,
    NIK,
    MIN(report_month)         AS report_month,
    MAX(kol)                  AS kol,
    MAX(dpd)                  AS hari_telat_max,
    COUNT(DISTINCT kredit_id) AS fasilitas_dilaporkan
  FROM h
  GROUP BY ym, NIK
)
SELECT
  p.report_month,
  p.ym,
  FORMAT_DATE('%b-%y', p.report_month) AS month_label,
  p.NIK,
  p.kol,
  -- baris ber-kol NULL sudah difilter, jadi label "tanpa riwayat" tak terpakai
  `slik-da-intern-technical-test.slik.fn_kol_label`(p.kol, 'Tanpa Riwayat') AS kol_label,
  IF(p.kol >= 3, 1, 0) AS is_npl,
  IF(p.kol =  2, 1, 0) AS is_dpk,
  p.hari_telat_max,
  p.fasilitas_dilaporkan,
  c.whitelist_flag,
  c.slik_behavior_segment,
  c.age_group,
  c.gender,
  c.pendidikan,
  c.npl_now_active,
  c.ever_npl_12m,
  c.slik_exposure_band
FROM p
LEFT JOIN `slik-da-intern-technical-test.slik.slik_customer_analysis` c ON p.NIK = c.NIK
ORDER BY p.ym, p.NIK;


-- ----------------------------------------------------------------------------
-- 9. Simulasi kriteria whitelist: berapa pemohon yang lolos dan berapa bad rate
--    kelompok yang lolos, untuk lima tingkat ketegasan kriteria.
--    Basis persentase selalu seluruh pemohon (587), bukan jumlah yang lolos.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `slik-da-intern-technical-test.slik.vw_whitelist_scenarios` AS
WITH spec AS (
  SELECT * FROM UNNEST([
    STRUCT('S0 - Semua aplikasi (tanpa filter)'            AS skenario,
           FALSE AS require_others, 99 AS max_kol_12m, 9999.0 AS max_dpd_3m),
    STRUCT('S1 - Flag Others saja (kriteria saat ini)',     TRUE,  99, 9999.0),
    STRUCT('S2 - Others + Kol 12 bln <= 2',                 TRUE,   2, 9999.0),
    STRUCT('S3 - Others + Kol 12 bln <= 2 + DPD 3 bln = 0', TRUE,   2,    0.0),
    STRUCT('S4 - Others + Kol 12 bln = 1 + DPD 3 bln = 0',  TRUE,   1,    0.0)
  ])
),
eval AS (
  SELECT
    s.skenario,
    (NOT s.require_others OR c.whitelist_flag = '3.Customer Others')
      AND COALESCE(c.collection_status_allcondition_last_12months_max, 1) <= s.max_kol_12m
      AND COALESCE(c.dpd_allcondition_last_3months_max, 0)  <= s.max_dpd_3m AS is_lolos,
    c.npl_now_active,
    c.npl_now,
    c.ever_npl_12m
  FROM `slik-da-intern-technical-test.slik.slik_customer_analysis` c
  CROSS JOIN spec s
)
SELECT
  skenario,
  COUNTIF(is_lolos)                                        AS lolos,
  ROUND(100 * COUNTIF(is_lolos) / COUNT(*), 1)             AS pct_basis,
  ROUND(100 * AVG(IF(is_lolos, npl_now_active, NULL)), 2)   AS npl_active_pct,
  ROUND(100 * AVG(IF(is_lolos, npl_now,        NULL)), 2)   AS npl_now_pct,
  ROUND(100 * AVG(IF(is_lolos, ever_npl_12m,   NULL)), 2)   AS npl_12m_pct
FROM eval
GROUP BY skenario
ORDER BY skenario;


-- ----------------------------------------------------------------------------
-- 10. Bad rate per kelompok demografi + selang kepercayaan 95%.
--     Dipakai di halaman demografi (Excel & Looker) supaya kelompok dengan
--     sampel kecil tidak dibaca berlebihan: bila lo-hi dua kelompok saling
--     tumpang tindih, perbedaan rate-nya belum bisa disebut nyata.
--     Bentuk long (dimensi, kategori) agar satu chart bisa dipakai untuk
--     semua dimensi lewat satu filter kontrol.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `slik-da-intern-technical-test.slik.vw_demografi_ci` AS
WITH long AS (
  SELECT d.dimensi, d.kategori, c.ever_npl_12m, c.npl_now_active
  FROM `slik-da-intern-technical-test.slik.slik_customer_analysis` c,
  UNNEST([
    STRUCT('Kelompok usia'     AS dimensi, c.age_group AS kategori),
    STRUCT('Jenis kelamin',              c.gender),
    STRUCT('Pendidikan',                 c.pendidikan),
    STRUCT('Status pernikahan',          c.marital_status)
  ]) d
  WHERE d.kategori IS NOT NULL
),
agg AS (
  SELECT
    dimensi,
    kategori,
    COUNT(*)            AS n,
    SUM(ever_npl_12m)   AS k,
    SUM(npl_now_active) AS k_npl_aktif
  FROM long
  GROUP BY dimensi, kategori
),
wilson AS (
  -- Wilson score interval (z = 1,96). Dipilih daripada normal-approximation
  -- karena tetap berada di rentang 0-1 walau n kecil atau rate 0%.
  SELECT
    a.*,
    1 + POW(1.96, 2) / n                                                AS denom,
    k / n + POW(1.96, 2) / (2 * n)                                      AS center,
    1.96 * SQRT(k / n * (1 - k / n) / n + POW(1.96, 2) / (4 * n * n))   AS spread
  FROM agg a
)
SELECT
  dimensi,
  kategori,
  n,
  k,
  ROUND(k / n, 4)                   AS rate,
  ROUND((center - spread) / denom, 4) AS lo,
  ROUND((center + spread) / denom, 4) AS hi,
  k_npl_aktif,
  ROUND(k_npl_aktif / n, 4)         AS npl_active_rate
FROM wilson
ORDER BY dimensi, kategori;
