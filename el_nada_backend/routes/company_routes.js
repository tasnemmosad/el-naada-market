
const express = require('express');
const db = require('../config/database');

const router = express.Router();

// GET /company
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.execute(
      `SELECT id, name, address, phone
       FROM company
       ORDER BY id ASC
       LIMIT 1`
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'بيانات المحل غير متاحة حالياً',
      });
    }

    return res.status(200).json({
      success: true,
      company: rows[0],
    });
  } catch (error) {
    console.error('Get company error:', error);

    return res.status(500).json({
      success: false,
      message: 'حدث خطأ أثناء تحميل بيانات المحل',
    });
  }
});

module.exports = router;
