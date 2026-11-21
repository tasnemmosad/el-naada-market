
const authenticateToken = require('../middleware/auth_middleware');
const express = require('express');

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');


const db = require('../config/database');

const router = express.Router();

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 10,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  message: {
    message: 'تم تجاوز عدد المحاولات المسموح بها.',
  },
});

function normalizePhone(input) {
  if (typeof input !== 'string') return null;

  const phone = input.trim();

  if (/^01[0125][0-9]{8}$/.test(phone)) {
    return '+2' + phone;
  }

  if (/^\+201[0125][0-9]{8}$/.test(phone)) {
    return phone;
  }

  return null;
}

function generateToken(user) {
  return jwt.sign(
    {
      userId: user.id,
      phone: user.phone,
      type: user.type,
    },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRES_IN || '1d',
    }
  );
}

function getCustomerPhoneCandidates(phone) {
  if (typeof phone !== 'string') return [];

  const normalized = normalizePhone(phone);

  if (!normalized) return [];

  const localPhone = normalized.substring(3);

  return [normalized, localPhone];
}

// REGISTER
router.post('/register', authLimiter, async (req, res) => {
  const phone = normalizePhone(req.body?.phone);
  const password = req.body?.password;

  const nickname =
    typeof req.body?.nickname === 'string'
      ? req.body.nickname.trim()
      : '';

  // Validate phone
  if (!phone) {
    return res.status(400).json({
      message: 'يرجى إدخال رقم موبايل صحيح.',
    });
  }

  // Validate nickname
  if (
    !nickname ||
    Array.from(nickname).length > 100
  ) {
    return res.status(400).json({
      message: 'يرجى إدخال اسم صحيح لا يزيد عن 100 حرف.',
    });
  }

  // Validate password
  if (
    typeof password !== 'string' ||
    password.length < 8 ||
    Buffer.byteLength(password, 'utf8') > 72
  ) {
    return res.status(400).json({
      message: 'يرجى إدخال كلمة مرور من 8 أحرف على الأقل.',
    });
  }

  try {
    const passwordHash = await bcrypt.hash(password, 12);

    const [result] = await db.execute(
      `INSERT INTO users (phone, nickname, password_hash)
       VALUES (?, ?, ?)`,
      [phone, nickname, passwordHash]
    );

    const user = {
      id: result.insertId,
      phone,
      nickname,
      type: 'customer',
    };

    const token = generateToken(user);

    return res.status(201).json({
      success: true,
      message: 'تم إنشاء الحساب بنجاح.',
      token,
      user: {
        id: user.id,
        phone: user.phone,
        nickname: user.nickname,
        type: user.type,
      },
    });

  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        message: 'هذا الرقم مسجل بالفعل.',
      });
    }

    console.error('Register error:', error.message);

    return res.status(500).json({
      message: 'تعذر إنشاء الحساب. يرجى المحاولة لاحقًا.',
    });
  }
});

// LOGIN
router.post('/login', authLimiter, async (req, res) => {
  const phone = normalizePhone(req.body?.phone);
  const password = req.body?.password;

  const invalidCredentials = {
    message: 'رقم الموبايل أو كلمة المرور غير صحيحة.',
  };

  if (
    !phone ||
    typeof password !== 'string' ||
    Buffer.byteLength(password, 'utf8') > 72
  ) {
    return res.status(401).json(invalidCredentials);
  }

  try {
  const [rows] = await db.execute(
  `SELECT id, phone, nickname, type, password_hash
   FROM users
   WHERE phone = ?
   LIMIT 1`,
  [phone]
);
    if (rows.length === 0) {
      return res.status(401).json(invalidCredentials);
    }

    const user = rows[0];

    const isCorrect = await bcrypt.compare(
      password,
      user.password_hash
    );

    if (!isCorrect) {
      return res.status(401).json(invalidCredentials);
    }

   const token = generateToken(user);

return res.status(200).json({
  success: true,
  message: 'تم تسجيل الدخول بنجاح.',
  token,
  user: {
    id: user.id,
    phone: user.phone,
    nickname: user.nickname,
    type: user.type,
  },
});

  } catch (error) {
    // console.error('Login error:', error.message);
console.error('LOGIN ERROR DETAILS:');
console.error(error);
console.error('Error code:', error.code);
console.error('Error message:', error.message);
console.error('Error stack:', error.stack);
    return res.status(500).json({
      message: 'تعذر تسجيل الدخول. يرجى المحاولة لاحقًا.',
    });
  }
  
});

router.get('/me', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
      `SELECT id, phone, nickname, type
       FROM users
       WHERE id = ?
       LIMIT 1`,
      [req.user.userId]
    );

    if (rows.length === 0) {
      return res.status(401).json({
        message: 'المستخدم غير موجود.',
      });
    }

    return res.status(200).json({
      success: true,
      user: rows[0],
    });

  } catch (error) {
    console.error('Auth verification error:', error.message);

    return res.status(500).json({
      message: 'تعذر التحقق من الحساب.',
    });
  }
});

// GET CUSTOMER PROFILE
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const [users] = await db.execute(
      `SELECT id, phone, nickname, type
       FROM users
       WHERE id = ?
       LIMIT 1`,
      [req.user.userId]
    );

    if (users.length === 0) {
      return res.status(401).json({
        message: 'المستخدم غير موجود.',
      });
    }

    const user = users[0];

    const phoneCandidates = getCustomerPhoneCandidates(user.phone);

    const [customers] = await db.execute(
      `SELECT id, name, address, phone1, phone2, payment_method
       FROM customers
       WHERE phone1 IN (?, ?)
       LIMIT 1`,
      phoneCandidates
    );

    return res.status(200).json({
      success: true,
      profile: {
        id: user.id,
        phone: user.phone,
        nickname: user.nickname,
        type: user.type,
        customer: customers.length > 0
          ? customers[0]
          : null,
      },
    });

  } catch (error) {
    console.error('Get profile error:', error.message);

    return res.status(500).json({
      message: 'تعذر تحميل بيانات الملف الشخصي.',
    });
  }
});

// UPDATE CUSTOMER PROFILE
router.put('/profile', authenticateToken, async (req, res) => {
  const name = typeof req.body?.name === 'string'
    ? req.body.name.trim()
    : '';

  const address = typeof req.body?.address === 'string'
    ? req.body.address.trim()
    : '';

  const phone2 = typeof req.body?.phone2 === 'string'
    ? req.body.phone2.trim()
    : null;

  const paymentMethod = req.body?.payment_method;

  const allowedPaymentMethods = [
    'cash',
    'card',
    'wallet',
  ];

  if (!name || name.length > 100) {
    return res.status(400).json({
      message: 'يرجى إدخال اسم عميل صحيح.',
    });
  }

  if (!address) {
    return res.status(400).json({
      message: 'يرجى إدخال العنوان.',
    });
  }

  if (
    phone2 !== null &&
    phone2 !== '' &&
    phone2.length > 20
  ) {
    return res.status(400).json({
      message: 'رقم الموبايل الإضافي غير صحيح.',
    });
  }

  if (!allowedPaymentMethods.includes(paymentMethod)) {
    return res.status(400).json({
      message: 'طريقة الدفع غير صحيحة.',
    });
  }

  try {
    const [users] = await db.execute(
      `SELECT id, phone
       FROM users
       WHERE id = ?
       LIMIT 1`,
      [req.user.userId]
    );

    if (users.length === 0) {
      return res.status(401).json({
        message: 'المستخدم غير موجود.',
      });
    }

    const user = users[0];

    const phoneCandidates = getCustomerPhoneCandidates(
      user.phone
    );

    const [customers] = await db.execute(
      `SELECT id
       FROM customers
       WHERE phone1 IN (?, ?)
       LIMIT 1`,
      phoneCandidates
    );

    if (customers.length > 0) {
      await db.execute(
        `UPDATE customers
         SET name = ?,
             address = ?,
             phone2 = ?,
             payment_method = ?,
             updated_at = CURRENT_TIMESTAMP,
             updated_by = ?
         WHERE id = ?`,
        [
          name,
          address,
          phone2 || null,
          paymentMethod,
          user.id,
          customers[0].id,
        ]
      );

    } else {
      await db.execute(
        `INSERT INTO customers (
          name,
          address,
          phone1,
          phone2,
          payment_method,
          created_by,
          updated_by
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          name,
          address,
          user.phone,
          phone2 || null,
          paymentMethod,
          user.id,
          user.id,
        ]
      );
    }

    return res.status(200).json({
      success: true,
      message: 'تم حفظ بيانات العميل بنجاح.',
    });

  } catch (error) {
    console.error('Update profile error:', error.message);

    return res.status(500).json({
      message: 'تعذر حفظ بيانات العميل.',
    });
  }
});

console.log('AUTH ROUTES LOADED');
console.log(
  'Registered auth routes:',
  router.stack.map(layer => ({
    path: layer.route?.path,
    methods: layer.route?.methods,
  }))
);
module.exports = router;
