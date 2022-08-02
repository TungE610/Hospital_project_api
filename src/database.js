const  Pool  = require('pg').Pool;
const fs = require('fs')

const connectionString = "postgres://wpvshidiavvlwq:05f0f977ff4864962a4faf3ff34d12141bbc9a0a5b5cc187582f80dcd6b770b8@ec2-34-193-44-192.compute-1.amazonaws.com:5432/ddbsdi68li6rdl"

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
