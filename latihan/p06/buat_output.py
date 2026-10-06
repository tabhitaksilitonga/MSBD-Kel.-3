#!/usr/bin/env python3
"""
buat_output.py - membuat file output EXPLAIN per soal (Q12-Q20) dengan format
seperti explain/q07_baseline.txt, dari hasil psql ASLI di database kamu.

Letak file : latihan/p06/buat_output.py
Dijalankan : dari root repo (folder yang berisi docker-compose.yml)

  python latihan/p06/buat_output.py              -> semua soal q12 sampai q20
  python latihan/p06/buat_output.py q13 q15      -> hanya soal tertentu
  python latihan/p06/buat_output.py q13 --mentah hasil_psql.txt
                                     -> tidak menjalankan psql; memakai teks
                                        output psql yang sudah kamu simpan

Angka (Execution Time, Buffers, dst.) semuanya diambil dari output psql,
skrip ini hanya merapikan format, menghitung Fastest/Median, dan menulis
ringkasan Plan/Sort.
"""
import re
import statistics
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent          # latihan/p06
ROOT = HERE.parents[1]                          # root repo
EXPLAIN_DIR = HERE / "explain"
MENTAH_DIR = EXPLAIN_DIR / "_mentah"
PSQL = ["docker", "compose", "exec", "-T", "postgres",
        "psql", "-U", "msbd", "-d", "latihan"]
DEFAULT_Q = [f"q{n}" for n in range(12, 21)]

MARK = re.compile(r"^--- (.+) ---$")
RUN = re.compile(r"^(.*) \| RUN (\d+)$")
SEP = re.compile(r"^-{3,}(\+-{3,})*$")
ROWS = re.compile(r"^\(\d+ rows?\)$")
EXEC = re.compile(r"Execution Time: ([\d.]+) ms")


# ---------------------------------------------------------------- parsing .sql
def judul_dan_query(sql_text):
    """Ambil judul 'Qxx - ...' dan peta label -> teks query dari file .sql."""
    lines = sql_text.splitlines()
    judul = ""
    for ln in lines:
        m = re.match(r"^-- (Q\d+): (.+)$", ln)
        if m:
            judul = f"{m.group(1)} - {m.group(2)}"
            break
    queries = {}
    i = 0
    while i < len(lines):
        m = re.match(r"^\\echo --- (.+) \| RUN 1 ---$", lines[i])
        if m:
            label = m.group(1)
            j = i + 1
            blok = []
            while j < len(lines):
                blok.append(lines[j])
                if lines[j].rstrip().endswith(";"):
                    break
                j += 1
            queries[label] = "\n".join(blok)
            i = j
        i += 1
    return judul, queries


# ------------------------------------------------------------- parsing psql
def pecah_blok(raw):
    """Pecah output psql menjadi blok per penanda '--- ... ---'."""
    blok, cur = [], None
    for ln in raw.splitlines():
        m = MARK.match(ln.strip())
        if m:
            if cur:
                blok.append(cur)
            cur = {"inner": m.group(1), "lines": []}
        elif cur is not None:
            cur["lines"].append(ln)
    if cur:
        blok.append(cur)
    return blok


def ambil_tabel(lines):
    """Kembalikan (header, separator, baris-baris, jumlah_baris) dari tabel psql."""
    for idx, ln in enumerate(lines):
        if SEP.match(ln.strip()) and idx > 0:
            header = lines[idx - 1]
            isi = []
            k = idx + 1
            while k < len(lines) and not ROWS.match(lines[k].strip()):
                isi.append(lines[k])
                k += 1
            jumlah = lines[k].strip() if k < len(lines) else ""
            return header, ln, isi, jumlah
    return None


def nama_node(teks):
    teks = teks.strip()
    if teks.startswith("->"):
        teks = teks[2:].strip()
    teks = teks.split(" (cost=")[0].strip()
    m = re.match(r"^(.*?) using (\S+) on ", teks)
    if m:
        return f"{m.group(1)} ({m.group(2)})"
    m = re.match(r"^(Bitmap Index Scan) on (\S+)$", teks)
    if m:
        return f"{m.group(1)} ({m.group(2)})"
    return re.sub(r" on [\w.]+$", "", teks)


def ringkas_plan(baris):
    node = []
    for n, ln in enumerate(baris):
        s = ln.strip()
        if "(cost=" in s and (n == 0 or s.startswith("->")):
            node.append(nama_node(s))
    return node


def olah_run(lines):
    tabel = ambil_tabel(lines)
    if not tabel:
        return None
    _, _, isi, jumlah = tabel
    datar = re.sub(r"\s+", " ", " ".join(x.strip() for x in isi)).strip()
    teks = f"{datar} {jumlah}".strip()
    m = EXEC.search(datar)
    waktu = float(m.group(1)) if m else None
    return {"teks": teks, "waktu": waktu, "node": ringkas_plan(isi)}


# ------------------------------------------------------------------- tulis
GARIS = "=" * 60
GARIS2 = "#" * 60
GARIS3 = "-" * 60


def tulis_skenario(out, label, query, runs):
    out += ["", GARIS2, f"SKENARIO: {label}", GARIS2, "", "Query:"]
    out += (query or "(lihat file .sql)").splitlines()
    out += [""]
    for nomor, r in runs:
        out += ["", GARIS, f"RUN {nomor}", GARIS, ""]
        out += [r["teks"] if r else "(output EXPLAIN tidak terbaca, periksa file mentah)"]
    waktu = [r["waktu"] for _, r in runs if r and r["waktu"] is not None]
    out += ["", "", GARIS, "RINGKASAN", GARIS, ""]
    if waktu:
        cepat = min(waktu)
        median = statistics.median(waktu)
        node = next((r["node"] for _, r in reversed(runs) if r and r["node"]), [])
        plan = " -> ".join(reversed(node)) if node else "-"
        ada_sort = "Ya" if any("Sort" in n for n in node) else "Tidak"
        catatan = "" if len(waktu) > 1 else "  (hanya 1 run)"
        out += [f"Fastest : {cepat:.3f} ms{catatan}",
                f"Median   : {median:.3f} ms{catatan}",
                f"Plan     : {plan}",
                f"Sort     : {ada_sort}"]
    else:
        out += ["Fastest : -", "Median   : -", "Plan     : -", "Sort     : -"]


def tulis_info(out, label, lines):
    out += ["", GARIS3, label, GARIS3]
    tabel = ambil_tabel(lines)
    if tabel:
        header, sep, isi, jumlah = tabel
        out += [header.rstrip(), sep.rstrip()] + [x.rstrip() for x in isi] + [jumlah]
    else:
        out += ["(tidak ada tabel hasil)"]


def buat_file(sql_path, raw):
    judul, queries = judul_dan_query(sql_path.read_text(encoding="utf-8"))
    out = [judul or sql_path.stem.upper()]
    skenario = []          # urutan: ("run", label, [(n, hasil)]) atau ("info", label, lines)
    for b in pecah_blok(raw):
        m = RUN.match(b["inner"])
        if m:
            label, nomor = m.group(1), int(m.group(2))
            if skenario and skenario[-1][0] == "run" and skenario[-1][1] == label:
                skenario[-1][2].append((nomor, olah_run(b["lines"])))
            else:
                skenario.append(("run", label, [(nomor, olah_run(b["lines"]))]))
        else:
            skenario.append(("info", b["inner"], b["lines"]))
    for jenis, label, isi in skenario:
        if jenis == "run":
            tulis_skenario(out, label, queries.get(label), isi)
        else:
            tulis_info(out, label, isi)
    return "\n".join(out) + "\n"


# -------------------------------------------------------------------- main
def jalankan_psql(sql_path):
    hasil = subprocess.run(PSQL, input=sql_path.read_text(encoding="utf-8"),
                           capture_output=True, text=True, encoding="utf-8",
                           errors="replace", cwd=ROOT)
    for ln in hasil.stderr.splitlines():
        if "ERROR" in ln or "FATAL" in ln:
            print("  !", ln)
    if hasil.returncode != 0 and not hasil.stdout.strip():
        sys.exit("psql gagal dijalankan. Pastikan docker compose up dan "
                 "skrip dijalankan dari root repo.\n" + hasil.stderr)
    return hasil.stdout


def main():
    args = sys.argv[1:]
    mentah_file = None
    if "--mentah" in args:
        i = args.index("--mentah")
        mentah_file = Path(args[i + 1])
        args = args[:i] + args[i + 2:]
    soal = [a.lower() for a in args] or DEFAULT_Q
    EXPLAIN_DIR.mkdir(exist_ok=True)
    MENTAH_DIR.mkdir(exist_ok=True)
    for q in soal:
        cocok = sorted(HERE.glob(f"{q}_*.sql"))
        if not cocok:
            print(f"{q}: file {q}_*.sql tidak ditemukan di {HERE}")
            continue
        sql_path = cocok[0]
        print(f"{q}: {sql_path.name}")
        if mentah_file:
            raw = mentah_file.read_text(encoding="utf-8", errors="replace")
        else:
            print("  menjalankan psql (bisa memakan waktu beberapa menit)...")
            raw = jalankan_psql(sql_path)
        (MENTAH_DIR / f"{q}_mentah.txt").write_text(raw, encoding="utf-8")
        hasil = buat_file(sql_path, raw)
        tujuan = EXPLAIN_DIR / f"{sql_path.stem}.txt"
        tujuan.write_text(hasil, encoding="utf-8")
        print(f"  -> {tujuan.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
