
const express = require('express');
const db = require('../config/database');

const router = express.Router();

// GET /products
// Get all available products with their latest price
router.get('/', async (req, res) => {
  try {
    const [products] = await db.execute(`
      SELECT
        p.id,
        p.name_en,
        p.name_ar,
        p.category,
        p.unit_of_msr_po,
        p.unit_of_msr_so,
        p.photo_url,
        p.in_stock,
        (
          SELECT pp.unit_price
          FROM product_prices pp
          WHERE pp.product_id = p.id
          ORDER BY pp.valid_from DESC, pp.id DESC
          LIMIT 1
        ) AS unit_price
      FROM products p
      WHERE p.in_stock = 1
      ORDER BY p.id DESC
    `);

    return res.status(200).json({
      success: true,
      count: products.length,
      products,
    });

  } catch (error) {
    console.error('Get products error:', error);

    return res.status(500).json({
      success: false,
      message: 'تعذر جلب المنتجات.',
    });
  }
});

// GET /products/:id
router.get('/:id', async (req, res) => {
  try {
    const productId = Number(req.params.id);

    if (!Number.isInteger(productId) || productId <= 0) {
      return res.status(400).json({
        success: false,
        message: 'رقم المنتج غير صحيح.',
      });
    }

    const [products] = await db.execute(`
      SELECT
        p.id,
        p.name_en,
        p.name_ar,
        p.category,
        p.unit_of_msr_po,
        p.unit_of_msr_so,
        p.photo_url,
        p.in_stock,
        (
          SELECT pp.unit_price
          FROM product_prices pp
          WHERE pp.product_id = p.id
          ORDER BY pp.valid_from DESC, pp.id DESC
          LIMIT 1
        ) AS unit_price
      FROM products p
      WHERE p.id = ?
      LIMIT 1
    `, [productId]);

    if (products.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'المنتج غير موجود.',
      });
    }

    return res.status(200).json({
      success: true,
      product: products[0],
    });

  } catch (error) {
    console.error('Get product error:', error);

    return res.status(500).json({
      success: false,
      message: 'تعذر جلب المنتج.',
    });
  }
});

module.exports = router;
