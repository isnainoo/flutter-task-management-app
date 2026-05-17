const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const db = require('../db');

// Register
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    const [existing] = await db.query(
      'SELECT id FROM users WHERE email = ?', [email]
    );
    if (existing.length > 0) {
      return res.status(400).json({ message: 'Email sudah terdaftar' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await db.query(
      'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
      [name, email, hashedPassword]
    );

    res.json({
      message: 'Registrasi berhasil',
      user: { id: result.insertId, name, email }
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const [rows] = await db.query(
      'SELECT * FROM users WHERE email = ?', [email]
    );
    if (rows.length === 0) {
      return res.status(401).json({ message: 'Email tidak ditemukan' });
    }

    const user = rows[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Password salah' });
    }

    res.json({
      message: 'Login berhasil',
      user: { id: user.id, name: user.name, email: user.email }
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// PUT update profile
router.put('/update-profile/:id', async (req, res) => {
  try {
    const { name } = req.body;
    await db.query('UPDATE users SET name = ? WHERE id = ?', [name, req.params.id]);
    res.json({ message: 'Profil berhasil diperbarui', name });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// PUT update password
router.put('/update-password/:id', async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    const [rows] = await db.query('SELECT password FROM users WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: 'User tidak ditemukan' });

    const isMatch = await bcrypt.compare(oldPassword, rows[0].password);
    if (!isMatch) return res.status(401).json({ message: 'Password lama salah' });

    const hashedNewPassword = await bcrypt.hash(newPassword, 10);
    await db.query('UPDATE users SET password = ? WHERE id = ?', [hashedNewPassword, req.params.id]);

    res.json({ message: 'Password berhasil diubah' });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

module.exports = router;