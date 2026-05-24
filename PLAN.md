Timestamp: 24-06-2024 07.30
1. dalam tahap pertama ini, saya akan fokus dalam setup struktur projek, terraform, cluster lokal dan layer bronze, serta mengisi data source ke lokal dengan menggunakan data asli dari sumber. 

Hasil: 
- ✅ Struktur projek: infrastructure/, src/, scripts/, notebook/, data/
- ✅ Terraform: backend.tf, main.tf, variables.tf, outputs.tf (dev environment + reusable modules)
- ✅ Cluster lokal: notebook/cluster.ipynb (setup cluster notebook)
- ✅ Layer bronze: src/ingest_local.py (data ingestion local)
- ✅ Data source script: scripts/download_data.go (real data download automation)
- ✅ .gitignore: ignore files & CSV, preserve folder structure