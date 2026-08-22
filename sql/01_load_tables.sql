-- ============================================================================
-- STEP 1 — LOAD RAW DATA KE BIGQUERY
-- Credit Risk Data Intern Technical Test — SLIK Dataset
--
-- Ganti `slik-da-intern-technical-test.slik` dengan project & dataset Anda
-- (search-replace "slik-da-intern-technical-test.slik" di seluruh file SQL).
--
-- Semua kolom raw sengaja di-load sebagai STRING karena data mentah
-- mengandung nilai kotor (mis. '#VALUE!' pada kolom tanggal). Casting ke
-- tipe numerik/tanggal dilakukan secara aman (SAFE_CAST / SAFE.PARSE_DATE)
-- di query agregasi (02_slik_aggregated_table.sql).
--
-- Cara load (BigQuery Console):
--   1. Buat dataset: slik  (lokasi bebas, mis. asia-southeast2)
--   2. Jalankan DDL di bawah ini untuk membuat tabel kosong dengan skema STRING.
--   3. Upload tiap CSV: menu dataset > CREATE TABLE >
--        Source      : Upload  (pilih file CSV)
--        Table       : sesuai nama di bawah
--        Schema      : gunakan tabel yang sudah dibuat (write disposition: Append)
--        Header rows to skip: 1
--   Alternatif via bq CLI:
--     bq load --source_format=CSV --skip_leading_rows=1 \
--        slik-da-intern-technical-test:slik.slik_result "data/Technical Test Dataset - result.csv"
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Tabel fasilitas SLIK (result.csv) — 14.660 baris, 104 kolom
--    Berisi 1 baris per snapshot fasilitas pinjaman + riwayat 24 bulan
--    kolektibilitas (Kol) dan hari tunggakan / DPD (Ht).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE `slik-da-intern-technical-test.slik.slik_result` (
  `ktp` STRING,
  `kreditId` STRING,
  `posisiDataTerakhir` STRING,
  `ljk` STRING,
  `bakiDebet` STRING,
  `tanggalUpdate` STRING,
  `sifatKredit` STRING,
  `jenisKredit` STRING,
  `tanggalAkadAwal` STRING,
  `tanggalAwalKredit` STRING,
  `tanggalJatuhTempo` STRING,
  `jenisPenggunaan` STRING,
  `sektorEkonomi` STRING,
  `sukuBunga` STRING,
  `angsuran` STRING,
  `plafon` STRING,
  `realisasiBulanBerjalan` STRING,
  `tanggalMacet` STRING,
  `tunggakanPokok` STRING,
  `tunggakanBunga` STRING,
  `kolektibilitas` STRING,
  `frekuensiRestrukturisasi` STRING,
  `tanggalRestrukturisasiAkhir` STRING,
  `tanggalKondisi` STRING,
  `kondisi` STRING,
  `kondisiKet` STRING,
  `plafonAwal` STRING,
  `tahunBulan01` STRING,
  `tahunBulan01Kol` STRING,
  `tahunBulan01Ht` STRING,
  `tahunBulan02` STRING,
  `tahunBulan02Kol` STRING,
  `tahunBulan02Ht` STRING,
  `tahunBulan03` STRING,
  `tahunBulan03Kol` STRING,
  `tahunBulan03Ht` STRING,
  `tahunBulan04` STRING,
  `tahunBulan04Kol` STRING,
  `tahunBulan04Ht` STRING,
  `tahunBulan05` STRING,
  `tahunBulan05Kol` STRING,
  `tahunBulan05Ht` STRING,
  `tahunBulan06` STRING,
  `tahunBulan06Kol` STRING,
  `tahunBulan06Ht` STRING,
  `tahunBulan07` STRING,
  `tahunBulan07Kol` STRING,
  `tahunBulan07Ht` STRING,
  `tahunBulan08` STRING,
  `tahunBulan08Kol` STRING,
  `tahunBulan08Ht` STRING,
  `tahunBulan09` STRING,
  `tahunBulan09Kol` STRING,
  `tahunBulan09Ht` STRING,
  `tahunBulan10` STRING,
  `tahunBulan10Kol` STRING,
  `tahunBulan10Ht` STRING,
  `tahunBulan11` STRING,
  `tahunBulan11Kol` STRING,
  `tahunBulan11Ht` STRING,
  `tahunBulan12` STRING,
  `tahunBulan12Kol` STRING,
  `tahunBulan12Ht` STRING,
  `tahunBulan13` STRING,
  `tahunBulan13Kol` STRING,
  `tahunBulan13Ht` STRING,
  `tahunBulan14` STRING,
  `tahunBulan14Kol` STRING,
  `tahunBulan14Ht` STRING,
  `tahunBulan15` STRING,
  `tahunBulan15Kol` STRING,
  `tahunBulan15Ht` STRING,
  `tahunBulan16` STRING,
  `tahunBulan16Kol` STRING,
  `tahunBulan16Ht` STRING,
  `tahunBulan17` STRING,
  `tahunBulan17Kol` STRING,
  `tahunBulan17Ht` STRING,
  `tahunBulan18` STRING,
  `tahunBulan18Kol` STRING,
  `tahunBulan18Ht` STRING,
  `tahunBulan19` STRING,
  `tahunBulan19Kol` STRING,
  `tahunBulan19Ht` STRING,
  `tahunBulan20` STRING,
  `tahunBulan20Kol` STRING,
  `tahunBulan20Ht` STRING,
  `tahunBulan21` STRING,
  `tahunBulan21Kol` STRING,
  `tahunBulan21Ht` STRING,
  `tahunBulan22` STRING,
  `tahunBulan22Kol` STRING,
  `tahunBulan22Ht` STRING,
  `tahunBulan23` STRING,
  `tahunBulan23Kol` STRING,
  `tahunBulan23Ht` STRING,
  `tahunBulan24` STRING,
  `tahunBulan24Kol` STRING,
  `tahunBulan24Ht` STRING,
  `akadPembiayaan` STRING,
  `kategoriDebiturKode` STRING,
  `jenisPenggunaanKet` STRING,
  `jenisAgunan` STRING,
  `tenor` STRING
);

-- ----------------------------------------------------------------------------
-- 2. Demografi 1 (demographic1.csv) — 587 baris, key = id_number (NIK)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE `slik-da-intern-technical-test.slik.slik_demographic1` (
  `id_number` STRING,
  `age_group` STRING,
  `industry` STRING,
  `marital_status` STRING,
  `gender` STRING
);

-- ----------------------------------------------------------------------------
-- 3. Demografi 2 (demographic2.csv) — 573 baris, key = noIdentitas (NIK)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE `slik-da-intern-technical-test.slik.slik_demographic2` (
  `noIdentitas` STRING,
  `kabKotaKet` STRING,
  `pekerjaanKet` STRING,
  `bidangUsahaKet` STRING,
  `statusGelarDebitur` STRING
);

-- ----------------------------------------------------------------------------
-- 4. Mapping LJK (ljk mapping.csv) — 2.701 baris, kode LJK -> nama lembaga.
--    CATATAN: tabel ini TIDAK unik per kode (1 kode bisa punya beberapa nama,
--    mis. entitas konvensional & UUS-nya). Dedup dilakukan di query agregasi.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE `slik-da-intern-technical-test.slik.slik_ljk_mapping` (
  `ljk` STRING,
  `ljkKet` STRING
);
