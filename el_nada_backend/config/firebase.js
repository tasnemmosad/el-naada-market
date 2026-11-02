
const fs = require('node:fs');

const {
  initializeApp,
  cert,
} = require('firebase-admin/app');

const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');

// Read the service account key from a private local file.
const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!keyPath) {
  throw new Error(
    'GOOGLE_APPLICATION_CREDENTIALS is missing',
  );
}

const serviceAccount = JSON.parse(
  fs.readFileSync(keyPath, 'utf8'),
);

if (
  !serviceAccount.private_key ||
  !serviceAccount.client_email
) {
  throw new Error('Invalid Firebase service account key');
}

const app = initializeApp({
  credential: cert(serviceAccount),
  projectId: process.env.FIREBASE_PROJECT_ID,
});

const auth = getAuth(app);
const db = getFirestore(app);

module.exports = { auth, db };
