# Laporan MSBD Kelompok 3 - Latihan 3

### Pertanyaan Reflektif A

**1. Pada Q4, apa tepatnya yang membuat NOT IN berbahaya, dan bagaimana memeriksa apakah sebuah kolom rawan terhadap masalah itu?**
> NOT IN bisa berbahaya jika hasil dari dari subquery mengandung nilai NULL. Karena NULL tidak dianggap sama dengan nilai apa pun, kondisi perbandingan ini dapat menjadi tidak pasti sehingga hasil query bisa salah atau tidak menampilkan data yang seharusnya. Untuk memeriksanya, kita dapat mengecek apakah kolom yang digunakan pada subquery memiliki nilai NULL, misalnya dengan COUNT(*) dan COUNT(nama_kolom). Jadi jika jumlahnya berbeda, yang berarti terdapat nilai NULL.

**2. Pada Q5, berapa kali subquery dievaluasi secara konseptual, dan mengapa "sekali per baris luar" belum tentu sama dengan yang benar-benar dikerjakan mesin?**
> Secara konseptual, subquery berkorelasi pada Q5 dianggap dievaluasi untuk setiap baris dari query luar karena menggunakan s.store_id dari baris luar. Namun, PosgreSQL tidak harus menjalankannya secara terpisah untuk setiap baris luar. Namun, PostgreSQL tidak harus menjalankannya secara terpisah untuk setiap baris. Query planner dapat mengoptimalkan atau mengubah cara eksekusinya sehingga jumlah evaluasi sebenarnya bisa berbeda dari konsep tersebut.

---