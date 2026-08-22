-- ============================================================================
-- STEP 2 — SLIK AGGREGATED TABLE (output utama technical test)
-- Loan application month : 2023-11
-- Output                 : `slik-da-intern-technical-test.slik.slik_aggregated_table`
--                          1 baris per NIK (587 customer), 25 kolom sesuai spec.
--
-- >>> DEFINISI & ASUMSI BISNIS (berdasarkan KODE REFERENSI + profil data) <<<
--  1. Sumber fasilitas  : slik_result. Duplikat kreditId (27 fasilitas punya
--     >1 snapshot, sebagian dengan tanggalUpdate '#VALUE!') di-dedup dengan
--     ROW_NUMBER: ambil snapshot ter-update (tanggalUpdate terbaru; tie-break
--     bakiDebet terbesar = konservatif terhadap eksposur).
--  2. Aktif             : kondisi = '0'  (REF#24: 00 = Fasilitas Aktif).
--  3. Write-off         : kondisi IN ('3','4')  (03 = Dihapusbukukan,
--                         04 = Hapus Tagih).
--  4. Closed            : kondisi IN ('1','2','5','6','7','8','9','11','12')
--                         = kategori "debitur tidak memiliki kewajiban"
--                         (lunas/dibatalkan/dialihkan). Write-off TIDAK
--                         dihitung closed karena kewajiban masih ada.
--  5. Restrukturisasi   : sifatKredit='1' (REF#14) ATAU
--                         frekuensiRestrukturisasi>0 ATAU
--                         tanggalRestrukturisasiAkhir tidak null.
--  6. Kartu kredit      : jenisKredit = 'X-30' (REF#15 sandi 30 = Kartu Kredit).
--  7. Unsecured         : jenisAgunan IS NULL (tidak ada agunan terdaftar).
--  8. Personal loan     : penggunaan Konsumsi (jenisPenggunaan='3')
--                         DAN unsecured DAN bukan kartu kredit
--                         (definisi KTA/cash-loan).
--  9. Nonbank           : LJK Perusahaan Pembiayaan (kode 6 digit prefix '25')
--                         ATAU nama LJK tanpa kata BANK/BPR/BPD (menangkap
--                         modal ventura & lembaga finansial lain). Bank umum,
--                         BPR (prefix 60) & BPRS (prefix 62) = bank.
-- 10. MOB (months on book): selisih bulan tanggalAwalKredit -> bulan aplikasi
--                         (2023-11).
-- 11. Window "N bulan sebelum aplikasi": bulan riwayat tahunBulanXX di
--     rentang [2023-11 minus N bulan .. 2023-10] (bulan aplikasi tidak ikut).
--     Riwayat maksimal tersedia s.d. 202310.
-- 12. dpd10plus         : fasilitas aktif yang PERNAH menunggak >10 hari
--                         (max hari tunggakan pada seluruh riwayat 24 bulan
--                         yang tersedia > 10).
-- 13. slik_installment  = 5% x outstanding kartu kredit aktif
--                         + total angsuran bulanan pinjaman aktif non-CC.
-- 14. slik_exposure     = total limit kartu kredit aktif
--                         + total outstanding personal loan aktif.
-- 15. Kolom count/sum default 0; kolom max/avg dibiarkan NULL bila customer
--     tidak punya fasilitas/riwayat yang memenuhi kriteria (NULL bermakna
--     "tidak ada data", beda dengan 0).
-- ============================================================================

DECLARE app_month DATE DEFAULT DATE '2023-11-01';

CREATE OR REPLACE TABLE `slik-da-intern-technical-test.slik.slik_aggregated_table` AS
WITH
-- ----------------------------------------------------------------------
-- Mapping LJK: dedup (1 kode bisa >1 nama, mis. entitas konvensional+UUS)
-- lalu klasifikasi bank vs nonbank.
-- ----------------------------------------------------------------------
ljk_map AS (
  SELECT
    ljk,
    ARRAY_AGG(ljkKet ORDER BY LENGTH(ljkKet) LIMIT 1)[OFFSET(0)] AS ljk_name
  FROM `slik-da-intern-technical-test.slik.slik_ljk_mapping`
  GROUP BY ljk
),
ljk_class AS (
  SELECT
    ljk,
    ljk_name,
    (
      STARTS_WITH(LPAD(ljk, 6, '0'), '25')                      -- Perusahaan Pembiayaan
      OR NOT REGEXP_CONTAINS(UPPER(ljk_name), r'BANK|BPR|BPD')  -- ventura / finansial lain
    ) AS is_nonbank
  FROM ljk_map
),

-- ----------------------------------------------------------------------
-- Dedup snapshot fasilitas: 1 baris per kreditId.
-- ----------------------------------------------------------------------
dedup AS (
  SELECT *
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
  )
  WHERE rn = 1
),

-- ----------------------------------------------------------------------
-- Level fasilitas: casting aman + seluruh flag bisnis + MOB + max DPD riwayat.
-- ----------------------------------------------------------------------
fac AS (
  SELECT
    d.ktp                                                    AS nik,
    d.kreditId                                               AS kredit_id,
    COALESCE(SAFE_CAST(d.bakiDebet  AS FLOAT64), 0)          AS balance,
    COALESCE(SAFE_CAST(d.plafon     AS FLOAT64), 0)          AS plafond,
    COALESCE(SAFE_CAST(d.angsuran   AS FLOAT64), 0)          AS installment,
    (d.kondisi = '0')                                        AS is_active,
    (d.kondisi IN ('3', '4'))                                AS is_writeoff,
    (d.kondisi IN ('1','2','5','6','7','8','9','11','12'))   AS is_closed,
    (
      d.sifatKredit = '1'
      OR COALESCE(SAFE_CAST(d.frekuensiRestrukturisasi AS INT64), 0) > 0
      OR d.tanggalRestrukturisasiAkhir IS NOT NULL
    )                                                        AS is_restructured,
    (d.jenisKredit = 'X-30')                                 AS is_credit_card,
    (d.jenisAgunan IS NULL)                                  AS is_unsecured,
    (
      d.jenisPenggunaan = '3'          -- Konsumsi
      AND d.jenisAgunan IS NULL        -- tanpa agunan
      AND d.jenisKredit <> 'X-30'      -- bukan kartu kredit
    )                                                        AS is_personal_loan,
    COALESCE(lc.is_nonbank, FALSE)                           AS is_nonbank,
    DATE_DIFF(
      app_month,
      SAFE.PARSE_DATE('%m/%d/%Y', d.tanggalAwalKredit),
      MONTH
    )                                                        AS mob,
    -- Riwayat 24 bulan sebagai array (bulan01 = bulan pelaporan terbaru)
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
    ]                                                        AS history
  FROM dedup d
  LEFT JOIN ljk_class lc USING (ljk)
),

-- Max DPD sepanjang riwayat tersedia, per fasilitas (untuk flag dpd10plus).
fac_dpd AS (
  SELECT
    f.*,
    (SELECT MAX(SAFE_CAST(h.ht AS FLOAT64)) FROM UNNEST(f.history) h) AS dpd_max_ever
  FROM fac f
),

-- ----------------------------------------------------------------------
-- Riwayat bulanan (long format): 1 baris per fasilitas x bulan pelaporan.
-- ----------------------------------------------------------------------
hist AS (
  SELECT
    f.nik,
    f.is_nonbank,
    f.is_closed,
    f.is_unsecured,
    SAFE.PARSE_DATE('%Y%m%d', CONCAT(h.ym, '01'))  AS report_month,
    SAFE_CAST(h.kol AS INT64)                      AS kol,
    SAFE_CAST(h.ht  AS FLOAT64)                    AS dpd
  FROM fac f, UNNEST(f.history) h
  WHERE h.ym IS NOT NULL
),

-- Agregasi riwayat per NIK dengan window relatif terhadap bulan aplikasi.
hist_agg AS (
  SELECT
    nik,
    MAX(IF(
      is_nonbank
      AND report_month BETWEEN DATE_SUB(app_month, INTERVAL 12 MONTH)
                           AND DATE_SUB(app_month, INTERVAL 1 MONTH),
      dpd, NULL))  AS dpd_nonbank_allcondition_last_12months_max,
    MAX(IF(
      is_closed AND is_unsecured
      AND report_month BETWEEN DATE_SUB(app_month, INTERVAL 24 MONTH)
                           AND DATE_SUB(app_month, INTERVAL 1 MONTH),
      kol, NULL))  AS collection_status_closed_unsecured_last_24months_max,
    MAX(IF(
      report_month BETWEEN DATE_SUB(app_month, INTERVAL 3 MONTH)
                       AND DATE_SUB(app_month, INTERVAL 1 MONTH),
      dpd, NULL))  AS dpd_allcondition_last_3months_max,
    MAX(IF(
      report_month BETWEEN DATE_SUB(app_month, INTERVAL 6 MONTH)
                       AND DATE_SUB(app_month, INTERVAL 1 MONTH),
      kol, NULL))  AS collection_status_allcondition_last_6months_max,
    MAX(IF(
      report_month BETWEEN DATE_SUB(app_month, INTERVAL 12 MONTH)
                       AND DATE_SUB(app_month, INTERVAL 1 MONTH),
      kol, NULL))  AS collection_status_allcondition_last_12months_max
  FROM hist
  GROUP BY nik
),

-- ----------------------------------------------------------------------
-- Agregasi level customer dari flag fasilitas.
-- ----------------------------------------------------------------------
fac_agg AS (
  SELECT
    nik,
    COUNT(*)                                                  AS flags_allcondition_count,
    COUNTIF(is_restructured AND is_active)                    AS flags_restructured_active_count,
    COUNTIF(is_writeoff)                                      AS flags_chargewriteoff_count,
    MAX(IF(is_credit_card AND is_active, plafond, NULL))      AS plafond_credit_card_active_max,
    MAX(IF(is_active, installment, NULL))                     AS installment_active_max,
    SUM(IF(is_personal_loan AND is_active, balance, 0))       AS balance_personal_loan_active_sum,
    SUM(IF(is_credit_card AND is_active, plafond, 0))         AS plafond_credit_card_active_sum,
    SUM(IF(is_personal_loan AND is_active, installment, 0))   AS installment_personal_loan_active_sum,
    SUM(IF(is_credit_card AND is_active, balance, 0))         AS balance_credit_card_active_sum,
    AVG(IF(is_active, mob, NULL))                             AS mob_active_avg,
    SUM(IF(is_unsecured, balance, 0))                         AS balance_unsecured_sum,
    SUM(plafond)                                              AS plafon_sum,
    MAX(mob)                                                  AS mob_allcondition_max,
    SUM(balance)                                              AS balance_sum,
    COUNTIF(is_active AND COALESCE(dpd_max_ever, 0) > 10)     AS flags_active_dpd10plus_count,
    COUNTIF(is_restructured AND is_unsecured)                 AS flags_restructured_allcondition_unsecured_count,
    -- komponen internal (tidak masuk output): angsuran aktif non-CC & flag restru
    SUM(IF(is_active AND NOT is_credit_card, installment, 0)) AS installment_loan_active_sum,
    COUNTIF(is_restructured)                                  AS flags_restructured_any_count
  FROM fac_dpd
  GROUP BY nik
)

-- ----------------------------------------------------------------------
-- Output final: 25 kolom sesuai spesifikasi.
-- ----------------------------------------------------------------------
SELECT
  fa.nik                                                      AS NIK,
  fa.flags_allcondition_count,
  fa.flags_restructured_active_count,
  fa.flags_chargewriteoff_count,
  fa.plafond_credit_card_active_max,
  fa.installment_active_max,
  fa.balance_personal_loan_active_sum,
  fa.plafond_credit_card_active_sum,
  fa.installment_personal_loan_active_sum,
  fa.balance_credit_card_active_sum,
  ROUND(fa.mob_active_avg, 2)                                 AS mob_active_avg,
  ha.dpd_nonbank_allcondition_last_12months_max,
  ha.collection_status_closed_unsecured_last_24months_max,
  ha.dpd_allcondition_last_3months_max,
  ha.collection_status_allcondition_last_6months_max,
  ha.collection_status_allcondition_last_12months_max,
  fa.balance_unsecured_sum,
  fa.plafon_sum,
  fa.mob_allcondition_max,
  fa.balance_sum,
  fa.flags_active_dpd10plus_count,
  fa.flags_restructured_allcondition_unsecured_count,
  -- 5% dari outstanding CC aktif + angsuran bulanan pinjaman aktif non-CC
  ROUND(0.05 * fa.balance_credit_card_active_sum
        + fa.installment_loan_active_sum, 2)                  AS slik_installment,
  -- limit CC aktif + outstanding personal loan aktif
  ROUND(fa.plafond_credit_card_active_sum
        + fa.balance_personal_loan_active_sum, 2)             AS slik_exposure,
  -- Flag prioritas: writeoff > restrukturisasi > lainnya
  CASE
    WHEN fa.flags_chargewriteoff_count  > 0 THEN '1.Customer has Writeoff'
    WHEN fa.flags_restructured_any_count > 0 THEN '2.Customer has Restru'
    ELSE                                         '3.Customer Others'
  END                                                         AS whitelist_flag
FROM fac_agg fa
LEFT JOIN hist_agg ha USING (nik)
ORDER BY fa.nik;
