const  Pool  = require('pg').Pool;

  const pool = new Pool({
    user: process.env.DB_USERNAME,
    database: process.env.DB_DATABASE,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
		dialect: "postgres",
    port: process.env.DB_PORT,
  });
module.exports = pool;