
// const fs = require('node:fs');

// const {
//   initializeApp,
//   cert,
// } = require('firebase-admin/app');

// const { getAuth } = require('firebase-admin/auth');
// const { getFirestore } = require('firebase-admin/firestore');

// // Read the service account key from a private local file.
// const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

// if (!keyPath) {
//   throw new Error(
//     'GOOGLE_APPLICATION_CREDENTIALS is missing',
//   );
// }

// const serviceAccount = JSON.parse(
//   fs.readFileSync(keyPath, 'utf8'),
// );

// if (
//   !serviceAccount.private_key ||
//   !serviceAccount.client_email
// ) {
//   throw new Error('Invalid Firebase service account key');
// }

// const app = initializeApp({
//   credential: cert(serviceAccount),
//   projectId: process.env.FIREBASE_PROJECT_ID,
// });

// const auth = getAuth(app);
// const db = getFirestore(app);

// module.exports = { auth, db };

const fs = require('node:fs');

const { initializeApp, cert } =
  require('firebase-admin/app');

const { getAuth } =
  require('firebase-admin/auth');

const { getFirestore } =
  require('firebase-admin/firestore');

let serviceAccount;

// Production: credentials from Render
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  try {
    serviceAccount = JSON.parse(
      process.env.FIREBASE_SERVICE_ACCOUNT
    );
  } catch (error) {
    throw new Error(
      'Invalid FIREBASE_SERVICE_ACCOUNT JSON'
    );
  }
}

// Local: credentials from service account file
else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  const keyPath =
    process.env.GOOGLE_APPLICATION_CREDENTIALS;

  serviceAccount = JSON.parse(
    fs.readFileSync(keyPath, 'utf8')
  );
} else {
  throw new Error(
    'Firebase credentials are missing'
  );
}

if (
  !serviceAccount.project_id ||
  !serviceAccount.private_key ||
  !serviceAccount.client_email
) {
  throw new Error('Invalid Firebase credentials');
}

const firebaseApp = initializeApp({
  credential: cert(serviceAccount),
  projectId:
    process.env.FIREBASE_PROJECT_ID ||
    serviceAccount.project_id,
});

const auth = getAuth(firebaseApp);
const db = getFirestore(firebaseApp);

module.exports = { auth, db };
