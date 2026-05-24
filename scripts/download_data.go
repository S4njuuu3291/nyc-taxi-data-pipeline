package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const (
	DatasetID = "4b4i-vvec"
	BaseURL   = "https://data.cityofnewyork.us/resource/" + DatasetID + ".json"
	OutputDir = "data/source"
	ChunkSize = 50000 // Ukuran tarikan stabil tanpa token
)

func main() {
	startTime := time.Now()

	// 1. Buat folder data/source jika belum ada
	if err := os.MkdirAll(OutputDir, os.ModePerm); err != nil {
		fmt.Printf("Gagal membuat folder: %v\n", err)
		return
	}

	// Map untuk menampung pointer file yang sedang terbuka secara dinamis
	openFiles := make(map[string]*os.File)
	headerWritten := make(map[string]bool)

	// Tutup semua file yang sempat dibuka di akhir program
	defer func() {
		for _, f := range openFiles {
			f.Close()
		}
	}()

	client := &http.Client{Timeout: 60 * time.Second}
	offset := 0
	totalDownloaded := 0

	fmt.Printf("=== MEMULAI UNDUH DATA MENTAH 100%% PLEK KETIPLEK (Output: %s) ===\n", OutputDir)

	for {
		chunkStart := time.Now()

		// Bangun query URL Socrata API - TANPA FILTER TANGGAL (Ambil seadanya dari baris database)
		v := url.Values{}
		v.Set("$limit", fmt.Sprintf("%d", ChunkSize))
		v.Set("$offset", fmt.Sprintf("%d", offset))

		reqURL := BaseURL + "?" + v.Encode()

		resp, err := client.Get(reqURL)
		if err != nil {
			fmt.Printf("\n[ERROR] Koneksi terputus di offset %d: %v. Mencoba ulang dalam 5 detik...\n", offset, err)
			time.Sleep(5 * time.Second)
			continue
		}

		body, err := io.ReadAll(resp.Body)
		resp.Body.Close()
		if err != nil {
			continue
		}

		if resp.StatusCode != http.StatusOK {
			fmt.Printf("\n[ERROR] Server return status %d di offset %d. Berhenti.\n", resp.StatusCode, offset)
			break
		}

		var records []map[string]interface{}
		if err := json.Unmarshal(body, &records); err != nil {
			fmt.Printf("\n[ERROR] Gagal parse JSON: %v\n", err)
			break
		}

		// Jika server sudah mengembalikan array kosong, artinya seluruh 38,3 juta data SUDAH HABIS ditarik
		if len(records) == 0 {
			break
		}

		// Ambil list semua nama kolom (headers) secara konsisten dari data pertama
		var headers []string
		if len(records) > 0 {
			for k := range records[0] {
				headers = append(headers, k)
			}
		}

		// Proses setiap baris data kotor
		for _, rec := range records {
			// Tentukan nama file berdasarkan teks tpep_pickup_datetime asli (Contoh: "2023-01-01T00:32:10" -> "2023_01")
			var fileKey string
			pickupTime, ok := rec["tpep_pickup_datetime"].(string)
			
			if ok && len(pickupTime) >= 7 {
				// Ambil YYYY_MM dari string aslinya langsung (tanpa validasi apakah tahunnya masuk akal atau tidak)
				year := pickupTime[0:4]
				month := pickupTime[5:7]
				fileKey = fmt.Sprintf("taxi_%s_%s", year, month)
			} else {
				fileKey = "taxi_unknown_date"
			}

			// Dapatkan atau buat file handler untuk file bulanan tersebut
			file, exists := openFiles[fileKey]
			if !exists {
				fileName := filepath.Join(OutputDir, fileKey+".csv")
				// Gunakan O_APPEND agar jika skrip jalan ulang, data tidak terhapus tapi menumpuk di bawahnya
				f, err := os.OpenFile(fileName, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
				if err != nil {
					fmt.Printf("Gagal membuka file %s: %v\n", fileName, err)
					continue
				}
				openFiles[fileKey] = f
				file = f
			}

			// Tulis header jika file tersebut baru pertama kali dibuat dalam sesi ini
			if !headerWritten[fileKey] {
				// Cek jika file baru kosong, tulis header
				fi, _ := file.Stat()
				if fi.Size() == 0 {
					file.WriteString(strings.Join(headers, ",") + "\n")
				}
				headerWritten[fileKey] = true
			}

			// Susun string CSV baris ini sesuai urutan header kolom
			var rowValues []string
			for _, h := range headers {
				val := rec[h]
				if val == nil {
					rowValues = append(rowValues, "")
				} else {
					// Bersihkan tanda koma atau newline di dalam string data agar struktur CSV tidak rusak
					strVal := fmt.Sprintf("%v", val)
					strVal = strings.ReplaceAll(strVal, ",", " ")
					strVal = strings.ReplaceAll(strVal, "\n", " ")
					rowValues = append(rowValues, strVal)
				}
			}
			file.WriteString(strings.Join(rowValues, ",") + "\n")
		}

		totalDownloaded += len(records)
		offset += ChunkSize
		chunkDuration := time.Since(chunkStart).Seconds()

		// Cetak progress baris tunggal secara real-time
		fmt.Printf("   Tersimpan total: %s baris | Speed: %.0f rps  ", 
			formatRibuan(totalDownloaded), float64(len(records))/chunkDuration)
		fmt.Print("\r")
	}

	fmt.Printf("\n\n=== PROSES UNDUH SELESAI SELURUHNYA ===\n")
	fmt.Printf("Total data plek ketiplek: %s baris\n", formatRibuan(totalDownloaded))
	fmt.Printf("Total file CSV terbentuk: %d file\n", len(openFiles))
	fmt.Printf("Total waktu pengerjaan : %.2f menit.\n", time.Since(startTime).Minutes())
}

func formatRibuan(n int) string {
	s := fmt.Sprintf("%d", n)
	if len(s) <= 3 {
		return s
	}
	var res string
	for i, c := range s {
		if i > 0 && (len(s)-i)%3 == 0 {
			res += ","
		}
		res += string(c)
	}
	return res
}
