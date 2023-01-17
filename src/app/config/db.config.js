const  Pool  = require('pg').Pool;

const connectionString = "postgres://tung:uw1LNRHdRu6CaqJu2o2QHoV6G7rvlZWH@dpg-cf3ffien6mpkr68mddp0-a.singapore-postgres.render.com/hospital_i51l"

	const pool = new Pool( {
		connectionString: connectionString,
		ssl: { rejectUnauthorized: false }
	});

module.exports = pool;