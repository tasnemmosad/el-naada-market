
const express = require('express');
const db = require('../config/database');
const authenticateToken = require('../middleware/auth_middleware');

const router = express.Router();
console.log('BASKET ROUTES LOADED');
router.use(authenticateToken);


async function getCustomerId(userId) {
  const [users] = await db.execute(
    `SELECT id, phone, type
     FROM users
     WHERE id = ?
     LIMIT 1`,
    [userId]
  );

  if (users.length === 0) {
    const error = new Error('المستخدم غير موجود.');
    error.statusCode = 401;
    throw error;
  }

  const user = users[0];

  if (user.type !== 'customer') {
    const error = new Error('السلة متاحة لحسابات العملاء فقط.');
    error.statusCode = 403;
    throw error;
  }


  const phone = user.phone;
  let phoneCandidates = [];

  if (typeof phone === 'string') {
    if (/^\+201[0125][0-9]{8}$/.test(phone)) {
      phoneCandidates = [phone, phone.substring(3)];
    } else if (/^01[0125][0-9]{8}$/.test(phone)) {
      phoneCandidates = ['+2' + phone, phone];
    }
  }

  if (phoneCandidates.length === 0) {
    const error = new Error('رقم الهاتف المسجل غير صحيح.');
    error.statusCode = 400;
    throw error;
  }

  const [customers] = await db.execute(
    `SELECT id
     FROM customers
     WHERE phone1 IN (?, ?)
     LIMIT 1`,
    phoneCandidates
  );

  if (customers.length === 0) {
    const error = new Error(
      'يرجى استكمال بيانات الملف الشخصي أولاً.'
    );
    error.statusCode = 409;
    error.code = 'PROFILE_REQUIRED';
    throw error;
  }

  return customers[0].id;
}

// GET /basket

router.get('/', async (req, res) => {
  try {
    const customerId = await getCustomerId(req.user.userId);

    const [items] = await db.execute(
      `SELECT
        bi.product_id,
        bi.quantity,
        p.name_ar,
        p.name_en,
        p.category,
        p.unit_of_msr_so,
        p.photo_url,
        p.in_stock,
        (
          SELECT pp.unit_price
          FROM product_prices pp
          WHERE pp.product_id = p.id
          ORDER BY pp.valid_from DESC, pp.id DESC
          LIMIT 1
        ) AS unit_price,
        (
          SELECT pp.id
          FROM product_prices pp
          WHERE pp.product_id = p.id
          ORDER BY pp.valid_from DESC, pp.id DESC
          LIMIT 1
        ) AS price_id
      FROM basket_items bi
      INNER JOIN products p
        ON p.id = bi.product_id
      WHERE bi.customer_id = ?
      ORDER BY p.id DESC`,
      [customerId]
    );

    return res.status(200).json({
      success: true,
      count: items.length,
      items,
    });

  } catch (error) {
    console.error('Get basket error:', error);

    return res.status(error.statusCode || 500).json({
      success: false,
      code: error.code,
      message: error.message || 'تعذر تحميل السلة.',
    });
  }
});

// POST /basket

router.post('/', async (req, res) => {
  try {
    const customerId = await getCustomerId(req.user.userId);

    const productId = Number(req.body?.product_id);
    const quantityInput = req.body?.quantity;
    const quantity = Number(quantityInput);

    if (
      !Number.isInteger(productId) ||
      productId <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: 'رقم المنتج غير صحيح.',
      });
    }

    if (
      (typeof quantityInput !== 'number' &&
        typeof quantityInput !== 'string') ||
      (typeof quantityInput === 'string' &&
        quantityInput.trim() === '') ||
      !Number.isFinite(quantity) ||
      quantity <= 0 ||
      quantity > 9999.99 ||
      Math.round(quantity * 100) !== quantity * 100
    ) {
      return res.status(400).json({
        success: false,
        message: 'الكمية يجب أن تكون أكبر من صفر وبحد أقصى منزلتين عشريتين.',
      });
    }

    const [products] = await db.execute(
      `SELECT id
       FROM products
       WHERE id = ?
         AND in_stock = 1
       LIMIT 1`,
      [productId]
    );

    if (products.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'المنتج غير موجود أو غير متاح حالياً.',
      });
    }

    await db.execute(
      `INSERT INTO basket_items (
        customer_id,
        product_id,
        quantity
      )
      VALUES (?, ?, ?)
      ON DUPLICATE KEY UPDATE
        quantity = VALUES(quantity)`,
      [customerId, productId, quantity.toFixed(2)]
    );

    return res.status(200).json({
      success: true,
      message: 'تم تحديث السلة بنجاح.',
      product_id: productId,
      quantity: Number(quantity.toFixed(2)),
    });

  } catch (error) {
    console.error('Update basket error:', error);

    return res.status(error.statusCode || 500).json({
      success: false,
      code: error.code,
      message: error.message || 'تعذر تحديث السلة.',
    });
  }
});

// DELETE /basket/:productId

router.delete('/:productId', async (req, res) => {
  try {
    const customerId = await getCustomerId(req.user.userId);
    const productId = Number(req.params.productId);

    if (
      !Number.isInteger(productId) ||
      productId <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: 'رقم المنتج غير صحيح.',
      });
    }

    const [result] = await db.execute(
      `DELETE FROM basket_items
       WHERE customer_id = ?
         AND product_id = ?`,
      [customerId, productId]
    );

    return res.status(200).json({
      success: true,
      message: result.affectedRows > 0
        ? 'تم حذف المنتج من السلة.'
        : 'المنتج غير موجود في السلة.',
    });

  } catch (error) {
    console.error('Delete basket item error:', error);

    return res.status(error.statusCode || 500).json({
      success: false,
      code: error.code,
      message: error.message || 'تعذر حذف المنتج.',
    });
  }
});

// DELETE /basket

router.delete('/', async (req, res) => {
  try {
    const customerId = await getCustomerId(req.user.userId);

    await db.execute(
      `DELETE FROM basket_items
       WHERE customer_id = ?`,
      [customerId]
    );

    return res.status(200).json({
      success: true,
      message: 'تم تفريغ السلة بنجاح.',
    });

  } catch (error) {
    console.error('Clear basket error:', error);

    return res.status(error.statusCode || 500).json({
      success: false,
      code: error.code,
      message: error.message || 'تعذر تفريغ السلة.',
    });
  }
});

module.exports = router;
