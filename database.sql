
---- autp update doctor status trigger

CREATE OR REPLACE FUNCTION update_doctor_status() RETURNS TRIGGER AS 
$$
BEGIN
	IF TG_OP = 'INSERT' THEN UPDATE doctor SET status = false WHERE doctor_id = new.doctor_id;
	UPDATE registration SET status = true WHERE patient_id = new.patient_id;
	ELSE UPDATE doctor SET status = true WHERE doctor_id = old.doctor_id;
	END IF;
	RETURN new;
END 
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER af_insert_app 
AFTER INSERT OR UPDATE OF end_time ON appointment 
FOR EACH ROW 
EXECUTE PROCEDURE update_doctor_status();

-----auto update room status

CREATE OR REPLACE FUNCTION update_room_status() RETURNS TRIGGER AS 
$$
DECLARE roomID text;
BEGIN
  SELECT into roomID new.room_id FROM room WHERE 
				(SELECT COUNT(doctor_id) FROM doctor WHERE status = false  AND room_id = new.room_id) = (SELECT COUNT(doctor_id) FROM doctor WHERE room_id = new.room_id);
	IF roomID IS NOT NULL THEN UPDATE room SET status = 'f' WHERE room_id = roomID ;
	ELSE UPDATE room SET status = 't' WHERE room_id = new.room_id;
	END IF;
	RETURN  new;
END 
$$
LANGUAGE plpgsql;

---CREATE OR REPLACE TRIGGER up_rst_af_insert_app 
CREATE OR REPLACE TRIGGER up_rst_af_insert_app 
AFTER UPDATE ON doctor
FOR EACH ROW
EXECUTE PROCEDURE update_room_status();


----auto find min num_of_waiting and increase num of waiting when all available room are full  ---

CREATE OR REPLACE FUNCTION inc_num_of_waiting() RETURNS TRIGGER AS 
$$
DECLARE specialtyId text;
DECLARE oldNumWaiting int4;
BEGIN 
SELECT INTO specialtyId new.specialty_id FROM specialty WHERE (SELECT COUNT(room_id) FROM room WHERE status = 'f'  AND specialty_id = new.specialty_id) = (SELECT COUNT(room_id) FROM room WHERE specialty_id = new.specialty_id);
SELECT INTO oldNumWaiting num_of_waiting FROM room WHERE room_id = (SELECT room_id FROM room WHERE num_of_waiting = (SELECT MIN(num_of_waiting) FROM room WHERE specialty_id = specialtyId) AND specialty_id = specialtyId LIMIT 1) ;
	IF specialtyId IS NOT NULL THEN UPDATE room SET num_of_waiting = oldNumWaiting + 1  
	WHERE room_id = (SELECT room_id FROM room WHERE num_of_waiting = (SELECT MIN(num_of_waiting) FROM room WHERE specialty_id = specialtyId) AND specialty_id = specialtyId LIMIT 1) ;
  END IF;
RETURN new;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER inc_num_of_wt 
BEFORE INSERT ON registration 
FOR EACH ROW
EXECUTE PROCEDURE inc_num_of_waiting();

-----auto decrese num of waiting when delete appointment -------
CREATE OR REPLACE FUNCTION des_num_of_waiting() RETURNS TRIGGER AS 
$$
DECLARE oldNumWaiting int4;
BEGIN 
SELECT INTO oldNumWaiting num_of_waiting FROM room WHERE room_id = new.room_id;
IF oldNumWaiting > 0 THEN UPDATE room SET num_of_waiting = oldNumWaiting - 1 WHERE room_id = new.room_id;
END IF;
RETURN new;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER des_num_of_wt 
AFTER INSERT ON appointment 
FOR EACH ROW
EXECUTE PROCEDURE des_num_of_waiting();

------UPDATE -------
DROP CONSTRAINT res_fk_room;
ALTER TABLE registration DROP COLUMN room_id;
ALTER TABLE registration ADD specialty_id character(4);
ALTER TABLE registration ADD status boolean;
ALTER TABLE appointment DROP COLUMN status;

DROP TABLE users;
CREATE TABLE users (
	user_id SERIAL NOT NULL,
	email VARCHAR(255) NOT NULL UNIQUE,
	password CHARACTER(8) NOT NULL,
	CONSTRAINT ad_pk PRIMARY KEY (user_id)
);

INSERT INTO users (email, password) VALUES('tung2082002@gmail.com', '20082002');

UPDATE appointment SET end_time = '15:50:46' WHERE appointment_id = '05070716';


SELECT room.room_id 
FROM room
LEFT JOIN specialty ON room.specialty_id = 	specialty.specialty_id
LEFT JOIN doctor 		ON room.manager_id 	 = 	doctor.doctor_id 
WHERE num_of_waiting = ( SELECT MIN(num_of_waiting) 
FROM room LEFT JOIN specialty ON room.specialty_id = specialty.specialty_id
WHERE specialty.specialty  = 'Tai Mũi Họng') AND specialty.specialty = 'Tai Mũi Họng' ;


SELECT room.room_id, room.status, num_of_waiting, doctor.doctor_name AS manager, specialty 
FROM room
LEFT JOIN specialty ON room.specialty_id = 	specialty.specialty_id
LEFT JOIN doctor 		ON room.manager_id 	 = 	doctor.doctor_id 
WHERE num_of_waiting = ( SELECT MIN(num_of_waiting) 
FROM room LEFT JOIN specialty ON room.specialty_id = specialty.specialty_id
WHERE specialty.specialty  = 'Tai Mũi Họng') AND specialty.specialty = 'Tai Mũi Họng' ;



SELECT room.room_id, room.status, num_of_waiting, doctor.doctor_name AS manager, specialty 
FROM room
LEFT JOIN specialty ON room.specialty_id = 	specialty.specialty_id
LEFT JOIN doctor 		ON room.manager_id 	 = 	doctor.doctor_id 
WHERE num_of_waiting <= ALL( SELECT (num_of_waiting) 
FROM room LEFT JOIN specialty ON room.specialty_id = specialty.specialty_id
WHERE specialty.specialty  = 'Tai Mũi Họng') AND specialty.specialty = 'Tai Mũi Họng' ;



WITH st AS 
(SELECT specialty.specialty_id , specialty, COUNT(registration.patient_id) as num_patient
 FROM specialty LEFT JOIN registration ON specialty.specialty_id = registration.specialty_id 
GROUP BY specialty.specialty_id, specialty)
SELECT specialty FROM st 
WHERE num_patient = (SELECT MAX(ct.num) FROM (SELECT COUNT(patient_id) num FROM registration GROUP BY specialty_id) ct);

WITH st AS 
(SELECT specialty.specialty_id , specialty, COUNT(registration.patient_id) as num_patient
 FROM specialty LEFT JOIN registration ON specialty.specialty_id = registration.specialty_id 
GROUP BY specialty.specialty_id, specialty)
SELECT specialty FROM st 
WHERE num_patient >= ALL(SELECT (ct.num) FROM (SELECT COUNT(patient_id) num FROM registration GROUP BY specialty_id) ct);

WITH st AS (SELECT COUNT(patient_id) as num_pa,specialty_id FROM registration GROUP BY specialty_id )
SELECT specialty 
FROM st 
LEFT JOIN specialty ON st.specialty_id = specialty.specialty_id
WHERE num_pa = (SELECT MAX(ct.num) FROM (SELECT COUNT(patient_id) num FROM registration GROUP BY specialty_id) ct);


SELECT medical_id, medical_name FROM medical, medicine, bill 
WHERE medical.medical_id = medicine.medical_id AND medicine.bill_id = bill.medical_id

AND SUM(medicine.quantity) 


SELECT doctor_id, doctor_name, age, status,room_id, specialty.specialty 
FROM doctor, specialty 
WHERE doctor.specialty_id = specialty.specialty_id;
--------
SELECT room.room_id,room.status, num_of_waiting, doctor.doctor_name AS manager ,specialty 
FROM room, specialty, doctor 
WHERE room.specialty_id = specialty.specialty_id 
AND room.manager_id = doctor.doctor_id;

SELECT doctor_id, doctor_name, age, status,room_id, specialty.specialty 
FROM doctor, specialty 
WHERE doctor.specialty_id = specialty.specialty_id 
AND doctor_id LIKE $1;

SELECT doctor_id, doctor_name, age, status,room_id, specialty.specialty 
FROM doctor, specialty 
WHERE doctor.specialty_id = specialty.specialty_id 
AND doctor_name ILIKE $1;

INSERT INTO registration(patient_id, specialty_id)
VALUES 
('10000001', '2020'),
('10000002', '2020'),
('10000003', '2020'),
('10000004', '2020'),
('10000005', '2020'),
('10000006', '2020'),
('10000007', '2020'),
('10000008', '2020'),
('10000009', '2020'),
('10000010', '2020'),
('10000011', '2020'),
('10000012', '2020'),
('10000013', '2020'),
('10000014', '2020'),
('10000015', '2020'),
('10000016', '2020'),
('10000017', '2020'),
('10000018', '2020'),
('10000019', '2020'),
('10000020', '2020'),
('10000021', '2020'),
('10000022', '2020'),
('10000023', '2020'),
('10000024', '2020'),
('10000025', '2020'),
('10000026', '2020'),
('10000027', '2020'),
('10000028', '2020'),
('10000029', '2020'),
('10000030', '2020');





 SELECT doctor_id, doctor_name, age, status,room_id, specialty.specialty 
 FROM doctor, specialty 
 WHERE doctor.specialty_id = specialty.specialty_id 
 AND LOWER(doctor_name) LIKE '%ng%' AND status = false;

SELECT doctor_id, doctor_name, age, status,room_id, specialty.specialty 
 FROM doctor, specialty 
 WHERE doctor.specialty_id = specialty.specialty_id 
 AND doctor_name ILIKE '%Ng%' AND status = false;



SELECT doctor_id, doctor_name, age, status,room_id, specialty.specialty FROM doctor, specialty 
WHERE doctor.specialty_id = specialty.specialty_id AND doctor_name ILIKE '%Ng%'
INTERSECT
SELECT doctor_id, doctor_name, age, status,room_id, specialty.specialty FROM doctor, specialty 
WHERE doctor.specialty_id = specialty.specialty_id AND status = false;

