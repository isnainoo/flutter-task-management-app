# Flutter Task Management App

A Flutter-based task management application for organizing and tracking daily activities.

team project:
- L200230001, Maulana Irfan Ardiansyah
- L200230014, Alfito Mahendra Pradika
- L200230037, Isna Choiron Nasikhin

## Design
🎨 [View UI Design on Figma](https://www.figma.com/design/zCGJP3aZ3q23aqiRJSGMyq/PPM?node-id=0-1&t=jXUcs5KemAqWSCqS-1)

## Features
- Task creation and management
- Edit and delete tasks
- Task completion tracking
- Clean and intuitive interface

## Widgets
A. Struktur & Fondasi Layar

Scaffold: Tempat untuk AppBar, body

SafeArea: Menjaga agar tampilan aplikasi Bapak tidak tertabrak "poni" (notch) kamera HP atau tombol navigasi di bawah layar

DefaultTabController, TabBar, TabBarView: Membuat halaman utama bisa digeser kanan-kiri

B. Pengatur Tata Letak (Layouting)

Column & Row: Untuk menyusun elemen berderet ke bawah (Column) atau ke samping (Row)

ListView: Agar daftar tugas bisa di-scroll dengan mulus dan tidak terbatas

Expanded: Widget yang bertugas memenuhi sisa ruang kosong. Sangat berguna agar teks nama tugas atau link tidak error terpotong

Container & BoxDecoration: Untuk membuat kotak-kotak card tugas, background lengkung, dan efek membulat (border radius)

C. Interaksi & Input (User Experience)

StatefulWidget & setState: Agar layar bisa me-refresh diri sendiri secara real-time

TextField & TextEditingController: Kolom inputan untuk mengisi nama tugas, link, atau mengedit profil

GestureDetector: Agar link teks atau ikon kalender bisa diklik

Switch: Tombol sakelar (on/off) yang elegan di halaman pengaturan notifikasi

showDatePicker: Widget bawaan Android untuk memunculkan kalender cantik saat memilih tanggal deadline

PopScope: Ini widget penjaga pintu, dia membawa pulang nama/email baru ke halaman utama.

D. Feedback & Alert (Notifikasi Dalam Aplikasi)

AlertDialog: Kotak peringatan pop-up di tengah layar (seperti saat konfirmasi "Hapus Tugas" atau "Ubah Password")

ScaffoldMessenger (SnackBar): Pesan kilat yang muncul dari bawah layar (misal: "Tugas berhasil ditambahkan" atau "Notifikasi dihidupkan")

CircularProgressIndicator: Animasi loading berputar (spinner) agar pengguna tahu aplikasi sedang berpikir atau mengirim data ke server
