
const express = require('express');
const db = require('../config/database');
const authenticateToken = require('../middleware/auth_middleware');

const router = express.Router();

router.use(authenticateToken);


async function getCustomer(connection, userId) {
  const [users] = await connection.execute(
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
    const error = new Error('إنشاء الطلبات متاح للعملاء فقط.');
    error.statusCode = 403;
    throw error;
  }

  let phoneCandidates = [];

  if (typeof user.phone === 'string') {
    if (/^\+201[0125][0-9]{8}$/.test(user.phone)) {
      phoneCandidates = [user.phone, user.phone.substring(3)];
    } else if (/^01[0125][0-9]{8}$/.test(user.phone)) {
      phoneCandidates = ['+2' + user.phone, user.phone];
    }
  }

  if (phoneCandidates.length === 0) {
    const error = new Error('رقم الهاتف المسجل غير صحيح.');
    error.statusCode = 400;
    throw error;
  }

  const [customers] = await connection.execute(
    `SELECT id, address
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

  return customers[0];
}

// POST /orders
router.post('/', async (req, res) => {
  let connection;
  let transactionStarted = false;

  try {
    const userId = req.user.userId;

    const deliveryType = req.body?.delivery_type;
    const paymentMethod = req.body?.payment_method;

    // التحقق من طريقة الاستلام
    if (!['pickup', 'delivery'].includes(deliveryType)) {
      return res.status(400).json({
        success: false,
        message: 'طريقة الاستلام غير صحيحة.',
      });
    }

    // التحقق من طريقة الدفع
    if (!['cash', 'card', 'wallet'].includes(paymentMethod)) {
      return res.status(400).json({
        success: false,
        message: 'طريقة الدفع غير صحيحة.',
      });
    }

    connection = await db.getConnection();

    await connection.beginTransaction();
    transactionStarted = true;

    const customer = await getCustomer(connection, userId);

    // التحقق من عنوان التوصيل
    let deliveryAddress = null;

    if (deliveryType === 'delivery') {
      deliveryAddress = customer.address;

      if (
        typeof deliveryAddress !== 'string' ||
        deliveryAddress.trim() === ''
      ) {
        const error = new Error(
          'يرجى إضافة عنوان التوصيل في الملف الشخصي.'
        );
        error.statusCode = 400;
        throw error;
      }
    }

    // قراءة عناصر السلة مع قفل الصفوف أثناء إنشاء الطلب
    const [basketItems] = await connection.execute(
      `SELECT product_id, quantity
       FROM basket_items
       WHERE customer_id = ?
       FOR UPDATE`,
      [customer.id]
    );

    if (basketItems.length === 0) {
      const error = new Error('السلة فارغة.');
      error.statusCode = 400;
      throw error;
    }

    const orderProducts = [];
    let totalInCents = 0;

    // قراءة السعر الحالي لكل منتج من قاعدة البيانات
    for (const basketItem of basketItems) {
      const [products] = await connection.execute(
        `SELECT id, name_ar, in_stock
         FROM products
         WHERE id = ?
         LIMIT 1
         FOR UPDATE`,
        [basketItem.product_id]
      );

      if (products.length === 0 || products[0].in_stock !== 1) {
        const error = new Error(
          'أحد المنتجات الموجودة في السلة غير متاح حالياً.'
        );
        error.statusCode = 409;
        throw error;
      }

      const product = products[0];

      const [prices] = await connection.execute(
        `SELECT id, unit_price
         FROM product_prices
         WHERE product_id = ?
         ORDER BY valid_from DESC, id DESC
         LIMIT 1`,
        [product.id]
      );

      if (prices.length === 0) {
        const error = new Error(
          `لا يوجد سعر مسجل للمنتج ${product.name_ar}.`
        );
        error.statusCode = 409;
        throw error;
      }

      const price = prices[0];
      const quantity = Number(basketItem.quantity);
      const unitPrice = Number(price.unit_price);

      if (
        !Number.isFinite(quantity) ||
        quantity <= 0 ||
        !Number.isFinite(unitPrice) ||
        unitPrice < 0
      ) {
        const error = new Error(
          'بيانات الكمية أو السعر غير صحيحة.'
        );
        error.statusCode = 409;
        throw error;
      }

      const subtotalInCents = Math.round(
        quantity * unitPrice * 100
      );

      totalInCents += subtotalInCents;

      orderProducts.push({
        productId: product.id,
        priceId: price.id,
        productName: product.name_ar,
        unitPrice: unitPrice.toFixed(2),
        quantity: quantity.toFixed(2),
        subtotal: (subtotalInCents / 100).toFixed(2),
      });
    }

    const total = (totalInCents / 100).toFixed(2);

    // إنشاء الطلب الرئيسي
    const [orderResult] = await connection.execute(
      `INSERT INTO orders (
        customer_id,
        delivery_type,
        payment_method,
        delivery_address,
        total,
        created_by,
        updated_by
      )
      VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        customer.id,
        deliveryType,
        paymentMethod,
        deliveryAddress,
        total,
        userId,
        userId,
      ]
    );

    const orderId = orderResult.insertId;

    // إضافة تفاصيل المنتجات إلى الطلب
    for (const item of orderProducts) {
      await connection.execute(
        `INSERT INTO order_items (
          order_id,
          product_id,
          price_id,
          product_name,
          unit_price,
          quantity,
          subtotal
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          orderId,
          item.productId,
          item.priceId,
          item.productName,
          item.unitPrice,
          item.quantity,
          item.subtotal,
        ]
      );
    }

    // تفريغ السلة بعد نجاح إنشاء الطلب وتفاصيله
    await connection.execute(
      `DELETE FROM basket_items
       WHERE customer_id = ?`,
      [customer.id]
    );

    await connection.commit();
    transactionStarted = false;

    return res.status(201).json({
      success: true,
      message: 'تم إنشاء طلبك بنجاح.',
      order: {
        id: orderId,
        customer_id: customer.id,
        delivery_type: deliveryType,
        payment_method: paymentMethod,
        delivery_address: deliveryAddress,
        total: Number(total),
        items_count: orderProducts.length,
        items: orderProducts,
      },
    });
  } catch (error) {
    if (connection && transactionStarted) {
      await connection.rollback();
    }

    console.error('Create order error:', error);

    return res.status(error.statusCode || 500).json({
      success: false,
      code: error.code,
      message: error.message || 'تعذر إنشاء الطلب.',
    });
  } finally {
    if (connection) {
      connection.release();
    }
  }
});

/*
 * GET /orders
 * عرض طلبات العميل الحالي
 */
router.get('/', async (req, res) => {
  let connection;

  try {
    connection = await db.getConnection();

    const customer = await getCustomer(
      connection,
      req.user.userId,
    );

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'الملف الشخصي للعميل غير موجود',
      });
    }

    const [orders] = await connection.query(
      `
      SELECT
        id,
        delivery_type,
        payment_method,
        delivery_address,
        total,
        status,
        created_at
      FROM orders
      WHERE customer_id = ?
      ORDER BY created_at DESC, id DESC
      `,
      [customer.id],
    );

    return res.json({
      success: true,
      count: orders.length,
      orders,
    });
  } catch (error) {
    console.error('Get orders error:', error);

    return res.status(500).json({
      success: false,
      message: 'حدث خطأ أثناء تحميل الطلبات',
    });
  } finally {
    if (connection) connection.release();
  }
});

/*
 * GET /orders/:id
 * تفاصيل طلب واحد للعميل الحالي
 */
router.get('/:id', async (req, res) => {
  let connection;

  try {
    const orderId = Number(req.params.id);

    if (!Number.isSafeInteger(orderId) || orderId <= 0) {
      return res.status(400).json({
        success: false,
        message: 'رقم الطلب غير صحيح',
      });
    }

    connection = await db.getConnection();

    const customer = await getCustomer(
      connection,
      req.user.userId,
    );

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: 'الملف الشخصي للعميل غير موجود',
      });
    }

    const [orders] = await connection.query(
      `
      SELECT
        id,
        customer_id,
        delivery_type,
        payment_method,
        delivery_address,
        total,
        status,
        created_at
      FROM orders
      WHERE id = ?
        AND customer_id = ?
      LIMIT 1
      `,
      [orderId, customer.id],
    );

    if (orders.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'الطلب غير موجود',
      });
    }

    const [items] = await connection.query(
      `
      SELECT
        id,
        product_id,
        product_name,
        unit_price,
        quantity,
        subtotal
      FROM order_items
      WHERE order_id = ?
      ORDER BY id ASC
      `,
      [orderId],
    );

    return res.json({
      success: true,
      order: {
        ...orders[0],
        items,
      },
    });
  } catch (error) {
    console.error('Get order details error:', error);

    return res.status(500).json({
      success: false,
      message: 'حدث خطأ أثناء تحميل تفاصيل الطلب',
    });
  } finally {
    if (connection) connection.release();
  }
});

module.exports = router;
