const express = require('express');
const router = express.Router();
const db = require('../config/db');
// Get all users
router.get('/', (req, res) => {
    db.query('SELECT * FROM users', (err, results) => {
        if (err) throw err;
        res.json(results);
    });
});

// Get user by ID
router.get('/:id', (req, res) => {
    const { id } = req.params;
    db.query('SELECT * FROM users WHERE id = ?', [id], (err, results) => {
        if (err) throw err;
        res.json(results[0]);
    });
});

// Create new user
router.post('/', (req, res) => {
    const { username, password, truck_num, role } = req.body;
    db.query('INSERT INTO users (username, password, truck_num, role) VALUES (?, ?, ?, ?, ?)', [username, password, truck_num, role], (err, result) => {
        if (err) throw err;
        res.json({ id: result.insertId });
    });
});

// Update user
router.put('/:id', (req, res) => {
    const { id } = req.params;
    const { username, password, truck_num, role } = req.body;
    db.query('UPDATE users SET username = ?, password = ?, truck_num = ?, role = ? WHERE id = ?', [username, password, truck_num, role, id], (err) => {
        if (err) throw err;
        res.json({ message: 'User updated' });
    });
});

// Delete user
router.delete('/:id', (req, res) => {
    const { id } = req.params;
    db.query('DELETE FROM users WHERE id = ?', [id], (err) => {
        if (err) throw err;
        res.json({ message: 'User deleted' });
    });
});

module.exports = router;
