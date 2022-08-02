const express = require('express')
const bodyParser = require('body-parser')
const app = express()
const cors = require('cors')
const pool = require('./app/config/db.config')
require('dotenv').config()
const bcrypt = require('bcrypt')
app.listen(process.env.PORT || 5000, () => {
	console.log("The server is running in 5000")
})
/// middleware
app.use(cors())
app.use(express.json())


const users = []
app.get('/users', (req,res) => {
	res.json(users)
})


app.post('/users', async (req,res) => {
	try {
		const hashedPassword = await bcrypt.hash(req.body.password, 10)
		const user = {email : req.body.email, password : hashedPassword}
		users.push(user)
		res.status(201).send()
	}catch(error){
		console.log(error.message)
	}
})

app.get('/users/login', async (req,res) => {
	try {
  const allUsers = await pool.query('SELECT * FROM accounts')
	const hashedUsers = await Promise.all(
		allUsers.rows.map(async (user) => {
		return {
			email : user.email,
			password : await bcrypt.hash(user.password, 10),
			role : user.role,
			doctor_id : user.doctor_id,
			room_id : user.room_id
		}
	}))
		users.push(...hashedUsers)	

		res.status(201).send()
	}catch{
// 		console.log(error.message)
	}
})

app.post('/users', async (req,res) => {
		try {
			const hashedPassword = await bcrypt.hash(req.body.password, 10)
			const user = {name : req.body.name, password : hashedPassword}
			users.push(user)

		}catch(error){
			console.log(error.message)
		}
	})


app.post('/users/login', async (req,res) => {
	const user = users.find(user => user.email === req.body.email)
	if(user == null ) {
		return res.status(400).send('Cant not find user')
	} 
	try {
		if(await bcrypt.compare(req.body.password, user.password)){
			res.send(
				{ email : user.email, 
					password : user.password,
					role : user.role,
					doctor_id : user.doctor_id,
					room_id : user.room_id,
				}
			)
		} else {
			return res.status(400).send('Cant not find user')
		}
	}catch {
		res.status(500).send()
	}
})

app.post('/patients', async (req, res) => {
	try {
		const { patient_name, sex, age, dob, address, phone_number, status_of_insurance, medical_history, citizen_id  } = req.body;
		const patient_id =`${citizen_id.slice(-4)}${dob.slice(-5).replace('-','')}`
		const newPatient = await pool.query('INSERT INTO patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)', [patient_id, patient_name, dob, age, sex, address,phone_number,status_of_insurance, medical_history,citizen_id ])
		res.json(newPatient)
	}catch(error) {
		console.log(error.message)
	}
})

//// get all doctor 

app.get('/doctors', async (req, res) => {
	try {
		const allDoctors = await pool.query('SELECT doctor_id, doctor_name, age, status,room_id, specialty.specialty FROM doctor, specialty WHERE doctor.specialty_id = specialty.specialty_id');
		res.json(allDoctors.rows)
	}catch(error) {
		console.log(error.message)
	}
})

/// get a specific doctor with doctorI or name
app.get('/doctors/:column/:value', async (req, res) => {
	const { column, value } = req.params;
	if(column === 'doctor_id'){
		try {
			const newValue = '%' + value + '%'
			const doctor = await pool.query('SELECT doctor_id, doctor_name, age, status,room_id, specialty.specialty FROM doctor, specialty WHERE doctor.specialty_id = specialty.specialty_id AND doctor_id LIKE $1', [newValue]);
			res.json(doctor.rows)
		}catch(error) {
			console.log(error.message)
		}
	} else {
		try {
				const newValue = '%' + value + '%'
				const doctor = await pool.query('SELECT doctor_id, doctor_name, age, status,room_id, specialty.specialty FROM doctor, specialty WHERE doctor.specialty_id = specialty.specialty_id AND doctor_name ILIKE $1',[newValue]);
				res.json(doctor.rows)
		}catch(error) {
			console.log(error.message)
		}
	}
})
/////delete a doctor 

app.post('/doctors/delete/:doctor_id', async (req, res) => {
	try {
		const { doctor_id } = req.params;
		const allDoctors = await pool.query('DELETE FROM doctor WHERE doctor_id = $1', [doctor_id]);
		res.json(allDoctors.rows)
	}catch(error) {
		console.log(error.message)
	}
})

///// update doctor infomation

/// get a specific doctor with doctorI or name

app.get('/rooms/:column/:value', async (req, res) => {
	const { column, value } = req.params;
	if(column === 'room_id'){
		try {
			const newValue = '%' + value + '%'
			const room = await pool.query('SELECT room.room_id,room.status, num_of_waiting, doctor.doctor_name AS manager ,specialty FROM room, specialty, doctor WHERE room.specialty_id = specialty.specialty_id AND room.manager_id = doctor.doctor_id AND room.room_id LIKE $1', [newValue]);
			res.json(room.rows)
		}catch(error) {
			console.log("1",error.message)
		}
	} else {
		try {
				const newValue = '%' + value + '%'
				const room = await pool.query('SELECT room.room_id,room.status, num_of_waiting, doctor.doctor_name AS manager ,specialty FROM room, specialty, doctor WHERE room.specialty_id = specialty.specialty_id AND room.manager_id = doctor.doctor_id AND specialty LIKE $1', [newValue]);
				res.json(room.rows)
		}catch(error) {
			console.log("2",error.message)
		}
	}
})
/// get all rooms
app.get('/rooms', async (req, res) => {
	try {
		const allRooms = await pool.query('SELECT room.room_id,room.status, num_of_waiting, doctor.doctor_name AS manager ,specialty FROM room, specialty, doctor WHERE room.specialty_id = specialty.specialty_id AND room.manager_id = doctor.doctor_id');
		res.json(allRooms.rows)
	}catch(error) {
		console.log("3",error.message)
	}
})
/// get a specify room with roomID

app.get('/rooms/:roomId', async (req, res) => {
	try {
		const { roomId } = req.params;
		const room = await pool.query('SELECT doctor.doctor_id,doctor.status, doctor.doctor_name, age FROM doctor, room WHERE doctor.room_id = room.room_id AND doctor.room_id = $1', [roomId]);
		res.json(room.rows)
	}catch(error) {
		console.log("4",error.message)
	}
})





//////add an registration

app.post('/registrations', async(req, res) => {
	try {
		const { specialty_id, patient_id, registration_time, expected_time ,room_id} = req.body;
		const newRegistration = await pool.query('INSERT INTO registration (specialty_id, patient_id, registration_time, expected_time, room_id) VALUES ($1, $2, $3, $4, $5)', [specialty_id, patient_id, registration_time, expected_time, room_id])
		res.json(newRegistration)
	}catch(error) {
		console.log(error.message)
	}
})

//// find first waiting in room 
app.get('/registrations/:room_id', async(req, res) => {
	try {
		const {room_id} =req.params
		console.log(room_id)
		const firstWaiting = await pool.query('SELECT patient_id,specialty_id FROM registration WHERE room_id = $1 AND status IS NULL AND registration_time = (SELECT MIN(registration_time) FROM registration WHERE room_id = $1 AND status IS NULL )', [room_id])
		res.json(firstWaiting.rows[0])
	}catch(error) {
		console.log(error.message)
	}
})

////get all appointment
app.get('/appointments', async (req, res) => {
	try {
		const allAppointments = await pool.query('SELECT appointment.appointment_id,appointment.start_time, appointment.expected_time, diagnosis ,specialty.specialty,room_id,appointment.patient_id,patient.status_of_insurance, doctor_id FROM appointment,patient,specialty WHERE appointment.patient_id = patient.patient_id AND appointment.specialty_id = specialty.specialty_id AND appointment.end_time IS NULL');
		res.json(allAppointments.rows)
	}catch(error) {
		console.log(error.message)
	}
})

////add an appointment 

app.post('/appointments', async(req, res) => {
	try {
		const { appointment_id, doctor_id, patient_id, specialty_id, room_id, start_time } = req.body;
		const newAppointment = await pool.query('INSERT INTO appointment (appointment_id, doctor_id, patient_id,specialty_id,room_id, start_time) VALUES ($1, $2, $3, $4, $5, $6)', [appointment_id, doctor_id, patient_id,specialty_id, room_id, start_time])
		res.json(newAppointment)
	}catch(error) {
		console.log(error.message)
	}
})

app.get('/appointments/:appointment_id', async (req, res) => {
	try {
		const { appointment_id } = req.params
		const appointments = await pool.query('SELECT appointment.appointment_id,appointment.start_time, appointment.expected_time, diagnosis ,specialty.specialty,room_id,patient_id, doctor_id FROM appointment,specialty WHERE appointment.specialty_id = specialty.specialty_id AND appointment.appointment_id = $1',[appointment_id])
		res.json(appointments.rows[0])
	}catch(error){
		console.log(error.message)
	}
})
app.post('/appointments/:appointment_id', async (req, res) => {
	try {
		const { appointment_id } = req.params
		const appointments = await pool.query('UPDATE appointment SET diagnosis = $1, expected_time = $2 WHERE appointment_id = $3',[req.body.diagnosis,req.body.expected_time, appointment_id])
		res.json(appointments)
	}catch(error){
		console.log("100",error.message)
	}
})


app.post('/appointments/end_up/:appointment_id', async (req,res) => {
	try {
		const { appointment_id } = req.params
		console.log(appointment_id, req.body.end_time)
		const appointments = await pool.query('UPDATE appointment SET end_time = $1 WHERE appointment_id = $2',[req.body.end_time, appointment_id])
		res.json(appointments)
	}catch(error){
		console.log("8",error.message)
	}
})


// app.post('/appointments/delete/:appointment_id', async (req, res) => {
// 	try {
// 		const { appointment_id } = req.params;
// 		const allAppointments = await pool.query('DELETE FROM appointment WHERE appointment_id = $1', [appointment_id]);
// 		res.json(allAppointments.rows)
// 	}catch(error) {
// 		console.log(error.message)
// 	}
// })
///// get specific appointment with id or doctor_id or specialty or appointment_id
app.get('/appointments/:column/:value', async (req, res) => {
	const { column, value } = req.params;
	console.log(column, value)
	if(column === 'appointment_id'){
		try {
			const newValue = '%' + value + '%'
			const appointments = await pool.query('SELECT appointment.appointment_id,appointment.start_time, appointment.expected_time, diagnosis ,specialty.specialty,room_id,patient_id, doctor_id FROM appointment,specialty WHERE appointment.specialty_id = specialty.specialty_id AND appointment_id LIKE $1', [newValue]);
			res.json(appointments.rows)
		}catch(error) {
			console.log(error.message)
		}
	} else if(column === 'specialty') {
		try {
				const newValue = '%' + value + '%'
				const appoinments = await pool.query('SELECT appointment.appointment_id,appointment.start_time, appointment.expected_time, diagnosis ,specialty.specialty,room_id,patient_id, doctor_id FROM appointment,specialty WHERE appointment.specialty_id = specialty.specialty_id AND specialty LIKE $1',[newValue]);
				res.json(appoinments.rows)
		}catch(error) {
			console.log(error.message)
		}
	} else {
		try {
			const newValue = '%' + value + '%'
			const appoinments = await pool.query('SELECT appointment.appointment_id,appointment.start_time, appointment.expected_time, diagnosis ,specialty.specialty,room_id,patient_id, doctor_id, end_time FROM appointment,specialty WHERE appointment.specialty_id = specialty.specialty_id AND appointment.doctor_id LIKE $1',[newValue]);
			res.json(appoinments.rows)
	}catch(error) {
		console.log(error.message)
	}
	}
})
////get available doctors
app.get('/room/:id', async(req, res) => {
	try {
		const { id } = req.params;
		const availableDoctor = await pool.query("SELECT doctor_id FROM doctor WHERE room_id = $1 AND status = true", [id])
		res.json(availableDoctor.rows[0])
	}catch(error) {
		console.log(error.message)
	}
})
//// get min waiting room of specialty
app.get('/room/min_wait/:specialty_id', async(req, res) => {
	try {
		const { specialty_id } = req.params;
		const minWait = await pool.query("SELECT room_id FROM room WHERE room.specialty_id = $1 ORDER BY num_of_waiting ASC LIMIT 1 ", [specialty_id])
		res.json(minWait.rows[0])
	}catch(error) {
		console.log(error.message)
	}
})

//// get a available room 
app.get('/specialties/:id', async(req, res) => {
	try {
		const { id } = req.params;
		const availableRooms = await pool.query("SELECT room.room_id FROM room, specialty WHERE room.specialty_id = specialty.specialty_id AND specialty.specialty_id = $1 AND room.status = 't'", [id])
		res.json(availableRooms.rows[0])
	}catch(error) {
		console.log(error.message)
	}
})


/// get all medicine name and cost 
app.get('/medicals', async(req, res) => {
	try {
		const medicals = await pool.query("SELECT medical_id,medical_name, cost  FROM medical")
		res.json(medicals.rows)
	}catch(error) {
		console.log(error.message)
	}
})

//// make a bill

app.post('/bills', async (req, res) => {
	try {
		console.log(req.body)
		const bill = await pool.query('INSERT INTO bill(bill_id, appointment_id, patient_id, examination_fee, medicine_fee, discounted_charges,total_charges) VALUES ($1, $2, $3, $4, $5, $6, $7)',[req.body.bill_id, req.body.appointment_id, req.body.patient_id, req.body.examination_fee, req.body.medicine_fee, req.body.discounted_charges, req.body.total_charges])
		res.json(bill)
	}catch(error){
		console.log(error.message)
	}
})

app.post('/medicines', async (req, res) => {
	try {
		console.log(req.body)
		const medicine = await pool.query('INSERT INTO medicine(medical_id, bill_id, quantity) VALUES ($1, $2, $3)',[req.body.medical_id, req.body.bill_id,req.body.quantity])
		res.json(medicine)
	}catch(error){
		console.log(error.message)
	}
})
