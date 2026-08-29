# Agent Instructions

## 0a. New Project Bootstrap (kalau folder project belum ada)
Trigger: user minta mulai project baru, ATAU `Projects/<project_slug>/` tidak ditemukan di vault
saat identity check (section 0) dijalankan.

1. Sebelum bootstrap, cek dulu apakah project ini layak punya folder context permanen.
   Tanya ke user (atau simpulkan dari konteks task) apakah project ini:
   - punya repo git (ada `repo_path` yang jelas), ATAU
   - diniatkan dikerjakan lebih dari satu sesi (bukan eksperimen sekali coba lalu dibuang).

   Kalau kedua hal itu TIDAK terpenuhi (misal cuma "coba-coba script sekali jalan", tanya
   cepat, atau eksplorasi tanpa rencana lanjut), **jangan bootstrap folder project**.
   Kerjakan saja tugasnya tanpa membuat entry baru di vault. Kalau ternyata project ini
   berkembang jadi serius di sesi berikutnya, baru bootstrap saat itu.
2. Kalau layak dibootstrap: konfirmasi dulu ke user nama project, `project_slug` (huruf kecil,
   tanpa spasi, dipakai sebagai nama folder — misal `webwave1d`), dan `repo_path` kalau ada.
   Jangan menebak slug sendiri.
3. Setelah dikonfirmasi, buat struktur berikut di `Projects/<project_slug>/`:
   ```
   Projects/<project_slug>/
     00-project-context.md   (isi frontmatter di bawah + ringkasan tujuan project)
     tasks/
       active-task.md        (checklist kosong, status: not-started)
     handoff.md               (kosong, siap diisi session log pertama)
     decisions/               (folder kosong)
   ```
4. `00-project-context.md` minimal berisi frontmatter ini (wajib, dipakai untuk identity check):
   ```yaml
   ---
   project_slug: <slug>
   project_name: <Nama Project>
   repo_path: <path repo kalau ada>
   last_updated: <tanggal hari ini>
   ---
   ```
   Diikuti ringkasan singkat: tujuan project, tech stack, referensi penting (kalau user sudah sebutkan).
5. Jangan otomatis membuat project baru kalau user cuma bertanya atau brainstorming —
   hanya buat kalau user benar-benar mengonfirmasi mau mulai kerja di project itu.
6. Setelah struktur dibuat, lanjut ke identity check normal (section 0) sebelum mulai kerja.

## 0. Identity Check (WAJIB, sebelum baca apa pun)
Tujuan: memastikan agent tidak salah membaca project lain di vault yang sama.

1. Task yang diberikan user HARUS menyertakan `project_slug` (nama folder project di vault).
   Kalau tidak disertakan, **tanya dulu ke user**, jangan menebak dari task terakhir yang aktif.
2. Baca `Projects/<project_slug>/00-project-context.md`.
3. Cek frontmatter file tersebut, minimal harus ada:
   ```yaml
   project_slug: webwave1d
   project_name: WebWave1D
   repo_path: ~/dev/webwave1d
   last_updated: 2026-08-24
   ```
4. Cocokkan `project_slug` di frontmatter dengan `project_slug` yang diberikan user/task.
   - **Match** → lanjut ke langkah berikutnya.
   - **Tidak match / file tidak ada / frontmatter kosong** → STOP. Laporkan mismatch ke user, jangan lanjut kerja dengan asumsi.
5. Setelah identity confirmed, semua operasi baca/tulis MCP Obsidian **dibatasi ke path**:
   `Projects/<project_slug>/**`
   Jangan traverse ke folder project lain, meskipun nama filenya terlihat relevan (mis. `handoff.md` di project lain).

## 1. Before Working
- Gunakan MCP Obsidian untuk membaca, dalam urutan ini:
  1. `Projects/<project_slug>/00-project-context.md`
  2. `Projects/<project_slug>/tasks/active-task.md`
  3. `Projects/<project_slug>/handoff.md`
- Jangan membaca seluruh vault. Jangan membaca project lain.
- Baca hanya source code yang berkaitan dengan subtask aktif (lihat `active-task.md`).
- Kalau `handoff.md` menyebutkan ada task yang belum selesai (status `in-progress` atau `blocked`),
  lanjutkan dari titik itu — jangan mulai ulang dari awal task.

## 2. Task Structure (untuk continuity antar-agent/akun)
`tasks/active-task.md` harus berbentuk checklist granular, bukan satu blok besar:
```markdown
## Task: <nama task>
Status: in-progress

- [x] Subtask 1 - selesai
- [x] Subtask 2 - selesai
- [ ] Subtask 3 - IN PROGRESS (agent berhenti di sini)
- [ ] Subtask 4 - belum
- [ ] Subtask 5 - belum
```
Alasan: kalau session terputus (limit habis) di tengah subtask 3, agent berikutnya
harus tahu persis subtask mana yang terakhir dikerjakan, bukan hanya "task X belum selesai".

## 3. While Working
- Ikuti arsitektur dan keputusan yang sudah tercatat di `decisions/`.
- Jangan mengubah database schema tanpa migration.
- Jangan membaca atau mengubah `.env`.
- **Checkpoint, bukan cuma laporan akhir**: setiap satu subtask selesai (bukan satu task besar),
  update `handoff.md` sebelum lanjut ke subtask berikutnya. Ini mengantisipasi limit/context habis
  tanpa peringatan di tengah kerja — jadi progres yang sudah solid tidak hilang.

## 4. Handoff Protocol (kunci untuk ganti akun/agent)
Setiap update `handoff.md` WAJIB berisi:
```markdown
## Session Log

### Session: 2026-08-24-A
- Agent/akun: A
- Waktu: 2026-08-24 14:30
- Subtask dikerjakan: Subtask 3 (integrasi SVB solver ke registry)
- Status akhir: IN PROGRESS — 70% selesai
- File yang disentuh:
  - src/solvers/svb.ts (belum di-commit)
  - src/registry/index.ts (sudah di-commit)
- State penting yang perlu diketahui agent berikutnya:
  - Interface WaveSolver sudah diupdate, tapi svb.ts belum implement method `validate()`
  - Ada bug sementara: hasil solver NaN kalau dx < 0.01, belum ditelusuri
- Next step paling spesifik: lanjutkan implementasi `validate()` di svb.ts,
  bandingkan dengan tolerance di 00-project-context.md bagian "SVB Validation"
- Blocker: tidak ada / [sebutkan kalau ada]
```
- Session baru selalu **ditambahkan** (append), bukan menimpa log sebelumnya —
  supaya ada jejak siapa mengerjakan apa kalau perlu ditelusuri ulang.
- Jangan mencatat perubahan kecil seperti formatting atau typo di session log.

## 5. After Working (task benar-benar selesai)
- Update status di `tasks/active-task.md` jadi `done` untuk seluruh checklist.
- Update `handoff.md` dengan ringkasan akhir + tandai task sebagai closed.
- Catat keputusan arsitektur penting di `decisions/`.
- Jangan mencatat perubahan kecil seperti formatting atau typo.

## 6. Stop Conditions
Agent harus berhenti dan bertanya ke user (bukan menebak) kalau:
- `project_slug` tidak match antara task dan frontmatter project context.
- `handoff.md` terakhir berstatus `blocked` dan alasan blocker belum terselesaikan.
- Instruksi task baru bertentangan dengan keputusan yang sudah tercatat di `decisions/`.
