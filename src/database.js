const  Pool  = require('pg').Pool;
const fs = require('fs')

const connectionString = "postgres://tung:uw1LNRHdRu6CaqJu2o2QHoV6G7rvlZWH@dpg-cf3ffien6mpkr68mddp0-a.singapore-postgres.render.com/hospital_i51l"

	const pool = new Pool( {
		connectionString: connectionString,
		ssl: { rejectUnauthorized: false }
	});

	const seedQuery = fs.readFileSync('src/db/hospital_new_bk.sql', { encoding: 'utf8' })
	pool.query(seedQuery, (err, res) => {
		console.log(err, res)
		console.log('Seeding Completed!')
		pool.end()
})
