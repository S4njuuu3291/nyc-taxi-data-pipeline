#!/usr/bin/env python3
"""
Airflow init script — koneksi default pasca migrasi.
Migrasi DB & user admin ditangani otomatis oleh Airflow entrypoint
via environment variable _AIRFLOW_DB_MIGRATE dan _AIRFLOW_WWW_USER_CREATE.
"""

import subprocess
import logging

logging.basicConfig(level=logging.INFO, format="%(message)s")
log = logging.getLogger("airflow-init")


def run(cmd: list[str], desc: str):
    log.info(f"▶ {desc}...")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        log.info(f"  ✓ {desc} selesai")
    else:
        log.warning(f"  ⚠ {desc} gagal (kode {result.returncode})")


def main():
    run(["airflow", "connections", "create-default-connections"], "Koneksi default")
    log.info("✓ Init selesai")


if __name__ == "__main__":
    main()
