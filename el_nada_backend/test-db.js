
// require('dotenv').config();

// const db = require('./config/database');

// async function testConnection() {
//   try {
//     const [rows] = await db.query('SELECT DATABASE() AS dbName');

//     console.log('MySQL connected successfully!');
//     console.log('Database:', rows[0].dbName);
//   } catch (error) {
//     console.error('MySQL connection failed:', error.message);
//   } finally {
//     await db.end();
//   }
// }

// testConnection();
 require ('dotenv').config();
 const db = require ('./config/database');
 async function testConnection(){
  try {
    const [tables] = await db.query('SHOW TABLES');
    console.log('Database tables:' , tables);
    const [columns] = await db.query('DESCRIBE users');
    console.table(columns);
  }
  catch (error) {
    console.error(error.message);
  } finally {
    await db.end();
  }
 }
 testConnection();