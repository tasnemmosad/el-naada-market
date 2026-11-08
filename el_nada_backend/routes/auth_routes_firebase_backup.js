
const express = require('express');
const bcrypt = require('bcryptjs');
const crypto = require('node:crypto');
const rateLimit = require('express-rate-limit');

const { auth, db } = require('../config/firebase');
const { FieldValue } =
  require('firebase-admin/firestore');

const router = express.Router();

const registerLimiter = rateLimit({
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

// Stable Firebase UID for each phone number.
function uidForPhone(phone) {
  const hash = crypto
    .createHash('sha256')
    .update(phone)
    .digest('hex');

  return 'customer_' + hash;
}

router.post('/register', registerLimiter, async (req, res) => {
  const phone = normalizePhone(req.body?.phone);
  const password = req.body?.password;

  if (!phone) {
    return res.status(400).json({
      message: 'يرجى إدخال رقم موبايل صحيح.',
    });
  }

  if (
    typeof password !== 'string' ||
    password.length < 8 ||
    Buffer.byteLength(password, 'utf8') > 72
  ) {
    return res.status(400).json({
      message: 'يرجى إدخال كلمة مرور من 8 أحرف على الأقل.',
    });
  }

  const uid = uidForPhone(phone);
  let userCreated = false;

  try {
    // Never store the original password.
    const passwordHash = await bcrypt.hash(password, 12);

    // Firebase Auth enforces uniqueness of the UID.
    console.log('STEP 1: Creating Firebase user');
    await auth.createUser({
      uid,
      disabled: false,
    });
    console.log('STEP 2: Firebase user created');

    userCreated = true;

    const batch = db.batch();

    batch.create(db.collection('users').doc(uid), {
      phoneNumber: phone,
      phoneVerified: false,
      role: 'customer',
      createdAt: FieldValue.serverTimestamp(),
    });

    batch.create(
      db.collection('password_accounts').doc(uid),
      {
        passwordHash,
        createdAt: FieldValue.serverTimestamp(),
      },
    );

console.log('STEP 3: Creating custom token');

    const customToken = await auth.createCustomToken(uid);
console.log('STEP 4: Custom token created');
    await batch.commit();

    return res.status(201).json({
      message: 'تم إنشاء الحساب بنجاح.',
      customToken,
    });
  } catch (error) {
    if (error.code === 'auth/uid-already-exists') {
      return res.status(409).json({
        message: 'هذا الرقم مسجل بالفعل.',
      });
    }

    console.error('Register error:', error.code || error.message);

    // Roll back incomplete registration.
    if (userCreated) {
      try {
        await auth.deleteUser(uid);
      } catch (rollbackError) {
        console.error('Rollback failed:', rollbackError.code);
      }
    }

    return res.status(500).json({
      message: 'تعذر إنشاء الحساب. يرجى المحاولة لاحقًا.',
    });
  }
});

router.post('/login', registerLimiter, async (req, res) => {
  const phone = normalizePhone(req.body?.phone);
  const password = req.body?.password;

  const invalidCredentials = {
    message: 'رقم الموبايل أو كلمة المرور غير صحيحة.',
  };

  if (!phone || typeof password !== 'string') {
    return res.status(401).json(invalidCredentials);
  }

  if (Buffer.byteLength(password, 'utf8') > 72) {
    return res.status(401).json(invalidCredentials);
  }

  try {
    const uid = uidForPhone(phone);

    // Check Firebase account
    let user;

    try {
      user = await auth.getUser(uid);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        return res.status(401).json(invalidCredentials);
      }
      throw error;
    }

    if (user.disabled) {
      return res.status(403).json({
        message: 'هذا الحساب غير متاح حاليًا.',
      });
    }

    // Get saved password hash
    const doc = await db
      .collection('password_accounts')
      .doc(uid)
      .get();

    if (!doc.exists) {
      return res.status(401).json(invalidCredentials);
    }

    // Verify password
    const passwordHash = doc.data().passwordHash;

    const isCorrect = await bcrypt.compare(
      password,
      passwordHash,
    );

    if (!isCorrect) {
      return res.status(401).json(invalidCredentials);
    }

    // Create Firebase Custom Token
    const customToken = await auth.createCustomToken(uid);

    return res.status(200).json({
      message: 'تم تسجيل الدخول بنجاح.',
      customToken,
    });

  } catch (error) {
    console.error('Login error:', error.code || error.message);

    return res.status(500).json({
      message: 'تعذر تسجيل الدخول. يرجى المحاولة لاحقًا.',
    });
  }
});

module.exports = router;
