const express = require('express');
const router = express.Router();
const db = require('../db');

// GET semua tasks milik user
router.get('/:userId', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM tasks WHERE user_id = ? ORDER BY deadline ASC',
      [req.params.userId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// POST tambah task baru
router.post('/', async (req, res) => {
  try {
    const { user_id, name, deadline, submission_link } = req.body;
    const [result] = await db.query(
      'INSERT INTO tasks (user_id, name, deadline, submission_link) VALUES (?, ?, ?, ?)',
      [user_id, name, deadline || null, submission_link || null]
    );
    res.json({ message: 'Task ditambahkan', id: result.insertId });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// PUT update task (edit atau toggle selesai)
router.put('/:id', async (req, res) => {
  try {
    const { name, deadline, is_done, submission_link, completed_at } = req.body;
    await db.query(
      `UPDATE tasks SET 
        name = ?, deadline = ?, is_done = ?, 
        submission_link = ?, completed_at = ? 
       WHERE id = ?`,
      [name, deadline || null, is_done, submission_link || null, completed_at || null, req.params.id]
    );
    res.json({ message: 'Task diperbarui' });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// DELETE hapus task
router.delete('/:id', async (req, res) => {
  try {
    await db.query('DELETE FROM tasks WHERE id = ?', [req.params.id]);
    res.json({ message: 'Task dihapus' });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

module.exports = router;