--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2
-- Dumped by pg_dump version 14.4

-- SET statement_timeout = 0;
-- SET lock_timeout = 0;
-- SET idle_in_transaction_session_timeout = 0;
-- SET client_encoding = 'UTF8';
-- SET standard_conforming_strings = on;
-- SELECT pg_catalog.set_config('search_path', '', false);
-- SET check_function_bodies = false;
-- SET xmloption = content;
-- SET client_min_messages = warning;
-- SET row_security = off;

-- --
-- -- Name: des_num_of_waiting(); Type: FUNCTION; Schema: public; Owner: -
-- --

-- CREATE OR REPLACE FUNCTION public.des_num_of_waiting() RETURNS trigger
--     LANGUAGE plpgsql
--     AS $$
-- DECLARE oldNumWaiting int4;
-- BEGIN 
-- SELECT INTO oldNumWaiting num_of_waiting FROM room WHERE room_id = new.room_id;
-- IF oldNumWaiting > 0 THEN UPDATE room SET num_of_waiting = oldNumWaiting - 1 WHERE room_id = new.room_id;
-- END IF;
-- RETURN new;
-- END
-- $$;


-- --
-- -- Name: inc_num_of_waiting(); Type: FUNCTION; Schema: public; Owner: -
-- --

-- CREATE OR REPLACE FUNCTION public.inc_num_of_waiting() RETURNS trigger
--     LANGUAGE plpgsql
--     AS $$
-- DECLARE specialtyId text;
-- DECLARE oldNumWaiting int4;
-- BEGIN 
-- SELECT INTO specialtyId new.specialty_id FROM specialty WHERE (SELECT COUNT(room_id) FROM room WHERE status = 'f'  AND specialty_id = new.specialty_id) = (SELECT COUNT(room_id) FROM room WHERE specialty_id = new.specialty_id);
-- SELECT INTO oldNumWaiting num_of_waiting FROM room WHERE room_id = (SELECT room_id FROM room WHERE num_of_waiting = (SELECT MIN(num_of_waiting) FROM room WHERE specialty_id = specialtyId) AND specialty_id = specialtyId LIMIT 1) ;
-- IF specialtyId IS NOT NULL THEN UPDATE room SET num_of_waiting = oldNumWaiting + 1  
-- WHERE room_id = (SELECT room_id FROM room WHERE num_of_waiting = (SELECT MIN(num_of_waiting) FROM room WHERE specialty_id = specialtyId) AND specialty_id = specialtyId LIMIT 1) ;
--   END IF;
-- RETURN new;
-- END
-- $$;


-- --
-- -- Name: update_doctor_status(); Type: FUNCTION; Schema: public; Owner: -
-- --

-- CREATE OR REPLACE FUNCTION public.update_doctor_status() RETURNS trigger
--     LANGUAGE plpgsql
--     AS $$
-- BEGIN
-- IF TG_OP = 'INSERT' THEN UPDATE doctor SET status = false WHERE doctor_id = new.doctor_id;
-- UPDATE registration SET status = true WHERE patient_id = new.patient_id;
-- ELSE UPDATE doctor SET status = true WHERE doctor_id = old.doctor_id;
-- END IF;
-- RETURN new;
-- END 
-- $$;


-- --
-- -- Name: update_num_of_waiting(); Type: FUNCTION; Schema: public; Owner: -
-- --

-- CREATE OR REPLACE FUNCTION public.update_num_of_waiting() RETURNS trigger
--     LANGUAGE plpgsql
--     AS $$
-- DECLARE specialtyId text;
-- DECLARE oldNumWaiting int4;
-- BEGIN 
-- SELECT INTO specialtyId new.specialty_id FROM specialty WHERE (SELECT COUNT(room_id) FROM room WHERE status = 'f'  AND specialty_id = new.specialty_id) = (SELECT COUNT(room_id) FROM room WHERE specialty_id = new.specialty_id);
-- SELECT INTO oldNumWaiting num_of_waiting FROM room WHERE room_id = (SELECT room_id FROM room WHERE num_of_waiting = (SELECT MIN(num_of_waiting) FROM room WHERE specialty_id = specialtyId) AND specialty_id = specialtyId LIMIT 1) ;
-- IF specialtyId IS NOT NULL THEN UPDATE room SET num_of_waiting = oldNumWaiting + 1  
-- WHERE room_id = (SELECT room_id FROM room WHERE num_of_waiting = (SELECT MIN(num_of_waiting) FROM room WHERE specialty_id = specialtyId) AND specialty_id = specialtyId LIMIT 1) ;
--   END IF;
-- RETURN new;
-- END
-- $$;


-- --
-- -- Name: update_room_status(); Type: FUNCTION; Schema: public; Owner: -
-- --

-- CREATE OR REPLACE FUNCTION public.update_room_status() RETURNS trigger
--     LANGUAGE plpgsql
--     AS $$
-- DECLARE roomID text;
-- BEGIN
--   SELECT into roomID new.room_id FROM room WHERE (SELECT COUNT(doctor_id) FROM doctor WHERE status = false  AND room_id = new.room_id) = (SELECT COUNT(doctor_id) FROM doctor WHERE room_id = new.room_id);
-- IF roomID IS NOT NULL THEN UPDATE room SET status = 'f' WHERE room_id = roomID ;
-- ELSE UPDATE room SET status = 't' WHERE room_id = new.room_id;
-- END IF;
-- RETURN  new;
-- END 
-- $$;


-- SET default_tablespace = '';

-- SET default_table_access_method = heap;

-- --
-- -- Name: accounts; Type: TABLE; Schema: public; Owner: -
-- --

-- CREATE TABLE public.accounts (
--     email character varying(255) NOT NULL,
--     password character(8) NOT NULL,
--     role character varying,
--     doctor_id character(5),
--     room_id character(8)
-- );


-- --
-- -- Name: appointment; Type: TABLE; Schema: public; Owner: -
-- --

-- CREATE TABLE public.appointment (
--     appointment_id character(8) NOT NULL,
--     start_time time without time zone,
--     diagnosis text,
--     specialty_id character(4) NOT NULL,
--     room_id character(8),
--     doctor_id character(5) NOT NULL,
--     patient_id character(8) NOT NULL,
--     expected_time time without time zone,
--     end_time time without time zone
-- );


-- --
-- -- Name: bill; Type: TABLE; Schema: public; Owner: -
-- --

-- CREATE TABLE public.bill (
--     bill_id character(10) NOT NULL,
--     appointment_id character(8) NOT NULL,
--     patient_id character(8) NOT NULL,
--     examination_fee money,
--     medicine_fee money,
--     total_charges money,
--     discounted_charges integer,
--     date_time date
-- );


-- --
-- -- Name: doctor; Type: TABLE; Schema: public; Owner: -
-- --

-- CREATE TABLE public.doctor (
--     doctor_id character(5) NOT NULL,
--     doctor_name character varying(40) NOT NULL,
--     age integer NOT NULL,
--     status boolean,
--     specialty_id character(4) NOT NULL,
--     room_id character(8) NOT NULL
-- );


-- --
-- -- Name: medical; Type: TABLE; Schema: public; Owner: -
-- --

-- CREATE TABLE public.medical (
--     medical_id character(8) NOT NULL,
--     cost money,
--     manufacturer character varying(60),
--     medical_name character varying
-- );


-- --
-- -- Name: medicine; Type: TABLE; Schema: public; Owner: -
-- --

-- CREATE TABLE public.medicine (
--     medical_id character(8) NOT NULL,
--     bill_id character(8) NOT NULL,
--     quantity integer
-- );


-- --
-- -- Name: patient; Type: TABLE; Schema: public; Owner: -
-- --

-- CREATE TABLE public.patient (
--     patient_id character(8) NOT NULL,
--     name character varying(40) NOT NULL,
--     dob date NOT NULL,
--     age integer,
--     sex character(1),
--     address character varying(120),
--     phone_number character(10),
--     status_of_insurance boolean,
--     medical_history text,
--     citizen_id character(12),
--     CONSTRAINT patient_chk_sex CHECK (((sex = 'F'::bpchar) OR (sex = 'M'::bpchar)))
-- );


-- --
-- -- Name: registration; Type: TABLE; Schema: public; Owner: -
-- --

-- CREATE TABLE public.registration (
--     patient_id character(8) NOT NULL,
--     registration_time time without time zone,
--     expected_time time without time zone,
--     instead_of character(8) DEFAULT NULL::bpchar,
--     specialty_id character(4),
--     status boolean,
--     room_id character(8)
-- );


-- --
-- -- Name: room; Type: TABLE; Schema: public; Owner: -
-- --

-- CREATE TABLE public.room (
--     room_id character(8) NOT NULL,
--     status character varying(20),
--     num_of_waiting integer,
--     manager_id character(8),
--     specialty_id character(4) NOT NULL
-- );


-- --
-- -- Name: specialty; Type: TABLE; Schema: public; Owner: -
-- --

-- CREATE TABLE public.specialty (
--     specialty_id character(4) NOT NULL,
--     specialty character varying(40)
-- );


-- --
-- -- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
-- --

-- INSERT INTO public.accounts (email, password, role, doctor_id, room_id) VALUES ('tung2082002@gmail.com', '20082002', 'super_admin', NULL, NULL);
-- INSERT INTO public.accounts (email, password, role, doctor_id, room_id) VALUES ('doctor@gmail.com', '11111111', 'doctor', '20205', '00000003');


-- --
-- -- Data for Name: appointment; Type: TABLE DATA; Schema: public; Owner: -
-- --

-- INSERT INTO public.appointment (appointment_id, start_time, diagnosis, specialty_id, room_id, doctor_id, patient_id, expected_time, end_time) VALUES ('04030728', '08:19:30', NULL, '2020', '00000002', '20204', '46320203', NULL, NULL);
-- INSERT INTO public.appointment (appointment_id, start_time, diagnosis, specialty_id, room_id, doctor_id, patient_id, expected_time, end_time) VALUES ('01010728', '08:22:08', NULL, '2020', '00000001', '20201', '24150901', NULL, NULL);
-- INSERT INTO public.appointment (appointment_id, start_time, diagnosis, specialty_id, room_id, doctor_id, patient_id, expected_time, end_time) VALUES ('06070728', '08:23:31', NULL, '2020', '00000003', '20206', '90900707', NULL, NULL);
-- INSERT INTO public.appointment (appointment_id, start_time, diagnosis, specialty_id, room_id, doctor_id, patient_id, expected_time, end_time) VALUES ('03010728', '08:23:57', NULL, '2020', '00000002', '20203', '14120401', NULL, NULL);
-- INSERT INTO public.appointment (appointment_id, start_time, diagnosis, specialty_id, room_id, doctor_id, patient_id, expected_time, end_time) VALUES ('02090728', '08:26:01', NULL, '2020', '00000001', '20202', '41150109', NULL, NULL);
-- INSERT INTO public.appointment (appointment_id, start_time, diagnosis, specialty_id, room_id, doctor_id, patient_id, expected_time, end_time) VALUES ('05040728', '08:26:27', 'Viem hong hat', '2020', '00000003', '20205', '25721004', '09:35:16', '09:36:07');
-- INSERT INTO public.appointment (appointment_id, start_time, diagnosis, specialty_id, room_id, doctor_id, patient_id, expected_time, end_time) VALUES ('05090728', '09:36:40', 'Viem hong', '2020', '00000003', '20205', '19420909', '13:03:41', '13:04:09');
-- INSERT INTO public.appointment (appointment_id, start_time, diagnosis, specialty_id, room_id, doctor_id, patient_id, expected_time, end_time) VALUES ('05030728', '13:04:26', NULL, '2020', '00000003', '20205', '45210303', NULL, NULL);


-- --
-- -- Data for Name: bill; Type: TABLE DATA; Schema: public; Owner: -
-- --

-- INSERT INTO public.bill (bill_id, appointment_id, patient_id, examination_fee, medicine_fee, total_charges, discounted_charges, date_time) VALUES ('05040728  ', '05040728', '25721004', '$100,000.00', '$400,000.00', '$500,000.00', 500000, NULL);
-- INSERT INTO public.bill (bill_id, appointment_id, patient_id, examination_fee, medicine_fee, total_charges, discounted_charges, date_time) VALUES ('05090728  ', '05090728', '19420909', '$100,000.00', '$240,000.00', '$340,000.00', 340000, NULL);


-- --
-- -- Data for Name: doctor; Type: TABLE DATA; Schema: public; Owner: -
-- --

-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20227', 'Nguyễn Tùng Lâm', 30, true, '2022', '00000008');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20213', 'NguyễnLương Duy', 41, true, '2021', '00000005');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20223', 'Lê Vũ Hoàng', 32, true, '2022', '00000008');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20221', 'NguyễnHoàng Hiếu', 35, true, '2022', '00000007');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20222', 'Trần Văn Hiếu', 36, true, '2022', '00000007');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20211', 'NguyễnKimCường', 32, true, '2021', '00000004');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20212', 'NguyễnNgọc Dũng', 36, true, '2021', '00000004');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20224', 'NguyễnHuyHoàng', 42, true, '2022', '00000008');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20215', 'Dương TiếnĐạt', 38, true, '2021', '00000006');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20216', 'Phạm Bá Đồng', 35, true, '2021', '00000006');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20214', 'Đào Kim Dương', 39, true, '2021', '00000005');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20204', 'Bùi Danh Tùng', 30, false, '2020', '00000002');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20201', 'NguyễnĐình ThànhAn', 27, false, '2020', '00000001');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20206', 'NguyễnKhắc Thái Bình', 31, false, '2020', '00000003');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20203', 'Nguyễn Văn Thiên Anh', 29, false, '2020', '00000002');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20202', 'Ngọ Việt Anh', 35, false, '2020', '00000001');
-- INSERT INTO public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) VALUES ('20205', 'VũQuang Anh', 33, false, '2020', '00000003');


-- --
-- -- Data for Name: medical; Type: TABLE DATA; Schema: public; Owner: -
-- --

-- INSERT INTO public.medical (medical_id, cost, manufacturer, medical_name) VALUES ('30000001', '$50,000.00', NULL, 'heroin');
-- INSERT INTO public.medical (medical_id, cost, manufacturer, medical_name) VALUES ('30000002', '$30,000.00', NULL, 'panysilin');
-- INSERT INTO public.medical (medical_id, cost, manufacturer, medical_name) VALUES ('30000003', '$60,000.00', NULL, 'cocain');
-- INSERT INTO public.medical (medical_id, cost, manufacturer, medical_name) VALUES ('30000004', '$70,000.00', NULL, 'glixerin');


-- --
-- -- Data for Name: medicine; Type: TABLE DATA; Schema: public; Owner: -
-- --

-- INSERT INTO public.medicine (medical_id, bill_id, quantity) VALUES ('30000001', '05040728', 2);
-- INSERT INTO public.medicine (medical_id, bill_id, quantity) VALUES ('30000002', '05040728', 2);
-- INSERT INTO public.medicine (medical_id, bill_id, quantity) VALUES ('30000003', '05040728', 4);
-- INSERT INTO public.medicine (medical_id, bill_id, quantity) VALUES ('30000002', '05090728', 2);
-- INSERT INTO public.medicine (medical_id, bill_id, quantity) VALUES ('30000003', '05090728', 3);


-- --
-- -- Data for Name: patient; Type: TABLE DATA; Schema: public; Owner: -
-- --

-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('23120202', 'Bui Danh Tung', '2002-02-02', 20, 'M', 'no company', '0393859464', true, NULL, '999911112312');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('41420303', 'Bui Danh Tung', '2002-03-03', 20, 'M', 'no company', '0393859464', true, NULL, '200213144142');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('46320404', 'Nguyen tung Lam', '2002-04-04', 20, 'M', 'no company', '0393859464', true, NULL, '210341424632');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('24560909', 'Bui Danh Tung', '2002-09-09', 20, 'M', 'no company', '0393859464', true, NULL, '202141242456');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('46320203', 'Bui Danh Tung', '2002-02-03', 20, 'M', 'no company', '0393859464', true, NULL, '201413414632');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('24150901', 'Nguyen Tung Lam', '2002-09-01', 20, 'M', 'no company', '0393859464', true, NULL, '381713412415');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('90900707', 'Nguyen Huu Tuan', '2002-07-07', 20, 'M', 'no company', '0393859464', true, NULL, '219387629090');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('14120401', 'Bui Danh Tung', '2002-04-01', 20, 'M', 'no company', '0393859464', true, NULL, '123145321412');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('41150109', 'Bui Danh Tung', '2002-01-09', 20, 'M', 'no company', '0393859464', true, NULL, '219148134115');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('25721004', 'Bui Danh Tung', '2002-10-04', 20, 'M', 'no company', '0393859464', true, NULL, '348241452572');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('12930305', 'Nguyen Thanh Long', '2002-03-05', 20, 'M', 'no company', '0393859464', true, NULL, '293819381293');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('56740808', 'Bui Danh Tung', '2002-08-08', 20, 'M', 'no company', '0393859464', true, NULL, '139138145674');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('19420909', 'Bui Danh Tung', '2002-09-09', 20, 'M', 'no company', '0393859464', true, NULL, '123141341942');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('11110505', 'Bui Danh Tung', '2002-05-05', 20, 'M', 'no company', '0393859464', true, NULL, '777766661111');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('42340804', 'Nguyen Doan Tuan', '2002-08-04', 20, 'M', 'no company', '0393859464', true, NULL, '817241324234');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('45210303', 'Nguyen Huu Thang', '2002-03-03', 20, 'M', 'no company', '0393859464', true, NULL, '134913124521');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('84830505', 'Nguyen Tung Lam', '2002-05-05', 20, 'M', 'no company', '0393859464', true, NULL, '124124218483');
-- INSERT INTO public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) VALUES ('11110603', 'Nguyen Tung Lam', '2002-06-03', 20, 'M', 'no company', '0393859464', true, NULL, '111111111111');


-- --
-- -- Data for Name: registration; Type: TABLE DATA; Schema: public; Owner: -
-- --

-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('14120401', '08:23:57', '08:23:57', NULL, '2020', true, '00000002');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('41150109', '08:26:01', '08:26:01', NULL, '2020', true, '00000001');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('25721004', '08:26:27', '08:26:27', NULL, '2020', true, '00000003');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('12930305', '08:29:49', '08:59:49', NULL, '2020', NULL, '00000002');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('56740808', '08:32:43', '09:02:43', NULL, '2020', NULL, '00000001');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('11110505', '08:36:46', '09:06:46', NULL, '2020', NULL, '00000002');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('42340804', '08:38:34', '09:08:34', NULL, '2020', NULL, '00000001');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('19420909', '08:33:45', '09:03:45', NULL, '2020', true, '00000003');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('84830505', '11:57:36', '12:27:36', NULL, '2020', NULL, '00000003');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('11110603', '13:02:17', '13:32:17', NULL, '2020', NULL, '00000002');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('45210303', '09:34:07', '10:04:07', NULL, '2020', true, '00000003');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('46320203', '08:19:30', '08:19:30', NULL, '2020', true, '00000002');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('24150901', '08:22:08', '08:22:08', NULL, '2020', true, '00000001');
-- INSERT INTO public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) VALUES ('90900707', '08:23:31', '08:23:31', NULL, '2020', true, '00000003');


-- --
-- -- Data for Name: room; Type: TABLE DATA; Schema: public; Owner: -
-- --

-- INSERT INTO public.room (room_id, status, num_of_waiting, manager_id, specialty_id) VALUES ('00000007', 't', 0, '20221   ', '2022');
-- INSERT INTO public.room (room_id, status, num_of_waiting, manager_id, specialty_id) VALUES ('00000004', 't', 0, '20211   ', '2021');
-- INSERT INTO public.room (room_id, status, num_of_waiting, manager_id, specialty_id) VALUES ('00000008', 't', 0, '20223   ', '2022');
-- INSERT INTO public.room (room_id, status, num_of_waiting, manager_id, specialty_id) VALUES ('00000006', 't', 0, '20215   ', '2021');
-- INSERT INTO public.room (room_id, status, num_of_waiting, manager_id, specialty_id) VALUES ('00000005', 't', 0, '20213   ', '2021');
-- INSERT INTO public.room (room_id, status, num_of_waiting, manager_id, specialty_id) VALUES ('00000009', 't', 0, '20225   ', '2022');
-- INSERT INTO public.room (room_id, status, num_of_waiting, manager_id, specialty_id) VALUES ('00000001', 'f', 2, '20201   ', '2020');
-- INSERT INTO public.room (room_id, status, num_of_waiting, manager_id, specialty_id) VALUES ('00000002', 'f', 3, '20203   ', '2020');
-- INSERT INTO public.room (room_id, status, num_of_waiting, manager_id, specialty_id) VALUES ('00000003', 'f', 1, '20205   ', '2020');


-- --
-- -- Data for Name: specialty; Type: TABLE DATA; Schema: public; Owner: -
-- --

-- INSERT INTO public.specialty (specialty_id, specialty) VALUES ('2020', 'Tai Mũi Họng');
-- INSERT INTO public.specialty (specialty_id, specialty) VALUES ('2021', 'Tim Mạch');
-- INSERT INTO public.specialty (specialty_id, specialty) VALUES ('2022', 'Mắt');


-- --
-- -- Name: appointment appointment_pk; Type: CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.appointment
--     ADD CONSTRAINT appointment_pk PRIMARY KEY (appointment_id);


-- --
-- -- Name: bill bill_pk; Type: CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.bill
--     ADD CONSTRAINT bill_pk PRIMARY KEY (bill_id);


-- --
-- -- Name: doctor doctor_pk; Type: CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.doctor
--     ADD CONSTRAINT doctor_pk PRIMARY KEY (doctor_id);


-- --
-- -- Name: medical medical_pk; Type: CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.medical
--     ADD CONSTRAINT medical_pk PRIMARY KEY (medical_id);


-- --
-- -- Name: medicine medicine_pk; Type: CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.medicine
--     ADD CONSTRAINT medicine_pk PRIMARY KEY (medical_id, bill_id);


-- --
-- -- Name: patient patient_pk; Type: CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.patient
--     ADD CONSTRAINT patient_pk PRIMARY KEY (patient_id);


-- --
-- -- Name: room room_pk; Type: CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.room
--     ADD CONSTRAINT room_pk PRIMARY KEY (room_id);


-- --
-- -- Name: specialty specialty_pk; Type: CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.specialty
--     ADD CONSTRAINT specialty_pk PRIMARY KEY (specialty_id);


-- --
-- -- Name: accounts users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.accounts
--     ADD CONSTRAINT users_email_key UNIQUE (email);


-- --
-- -- Name: doctor_status_index; Type: INDEX; Schema: public; Owner: -
-- --

-- CREATE INDEX doctor_status_index ON public.doctor USING btree (status);


-- --
-- -- Name: specialty_id_index; Type: INDEX; Schema: public; Owner: -
-- --

-- CREATE INDEX specialty_id_index ON public.specialty USING btree (specialty_id);


-- --
-- -- Name: appointment af_insert_app; Type: TRIGGER; Schema: public; Owner: -
-- --

-- CREATE OR REPLACE TRIGGER af_insert_app AFTER INSERT OR UPDATE OF end_time ON public.appointment FOR EACH ROW EXECUTE FUNCTION public.update_doctor_status();


-- --
-- -- Name: appointment des_num_of_wt; Type: TRIGGER; Schema: public; Owner: -
-- --

-- CREATE OR REPLACE TRIGGER des_num_of_wt AFTER INSERT ON public.appointment FOR EACH ROW EXECUTE FUNCTION public.des_num_of_waiting();


-- --
-- -- Name: registration inc_num_of_wt; Type: TRIGGER; Schema: public; Owner: -
-- --

-- CREATE OR REPLACE TRIGGER inc_num_of_wt BEFORE INSERT ON public.registration FOR EACH ROW EXECUTE FUNCTION public.inc_num_of_waiting();


-- --
-- -- Name: appointment ins_num_of_wt; Type: TRIGGER; Schema: public; Owner: -
-- --

-- CREATE OR REPLACE TRIGGER ins_num_of_wt BEFORE INSERT ON public.appointment FOR EACH ROW EXECUTE FUNCTION public.update_num_of_waiting();


-- --
-- -- Name: doctor up_rst_af_insert_app; Type: TRIGGER; Schema: public; Owner: -
-- --

-- CREATE OR REPLACE TRIGGER up_rst_af_insert_app AFTER UPDATE ON public.doctor FOR EACH ROW EXECUTE FUNCTION public.update_room_status();


-- --
-- -- Name: appointment appoint_fk_doctor; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.appointment
--     ADD CONSTRAINT appoint_fk_doctor FOREIGN KEY (doctor_id) REFERENCES public.doctor(doctor_id);


-- --
-- -- Name: appointment appoint_fk_patient; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.appointment
--     ADD CONSTRAINT appoint_fk_patient FOREIGN KEY (patient_id) REFERENCES public.patient(patient_id);


-- --
-- -- Name: appointment appoint_fk_room; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.appointment
--     ADD CONSTRAINT appoint_fk_room FOREIGN KEY (room_id) REFERENCES public.room(room_id);


-- --
-- -- Name: appointment appoint_fk_specialty; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.appointment
--     ADD CONSTRAINT appoint_fk_specialty FOREIGN KEY (specialty_id) REFERENCES public.specialty(specialty_id);


-- --
-- -- Name: bill bill_fk_appoint; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.bill
--     ADD CONSTRAINT bill_fk_appoint FOREIGN KEY (appointment_id) REFERENCES public.appointment(appointment_id);


-- --
-- -- Name: bill bill_fk_patient; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.bill
--     ADD CONSTRAINT bill_fk_patient FOREIGN KEY (patient_id) REFERENCES public.patient(patient_id);


-- --
-- -- Name: doctor doc_fk_room; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.doctor
--     ADD CONSTRAINT doc_fk_room FOREIGN KEY (room_id) REFERENCES public.room(room_id);


-- --
-- -- Name: doctor doc_fk_specialty; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.doctor
--     ADD CONSTRAINT doc_fk_specialty FOREIGN KEY (specialty_id) REFERENCES public.specialty(specialty_id);


-- --
-- -- Name: medicine medicine_fk_bill; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.medicine
--     ADD CONSTRAINT medicine_fk_bill FOREIGN KEY (bill_id) REFERENCES public.bill(bill_id);


-- --
-- -- Name: medicine medicine_fk_medical; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.medicine
--     ADD CONSTRAINT medicine_fk_medical FOREIGN KEY (medical_id) REFERENCES public.medical(medical_id);


-- --
-- -- Name: registration res_fk_patient; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.registration
--     ADD CONSTRAINT res_fk_patient FOREIGN KEY (patient_id) REFERENCES public.patient(patient_id);


-- --
-- -- Name: room room_fk_spe; Type: FK CONSTRAINT; Schema: public; Owner: -
-- --

-- ALTER TABLE ONLY public.room
--     ADD CONSTRAINT room_fk_spe FOREIGN KEY (specialty_id) REFERENCES public.specialty(specialty_id);


--
-- PostgreSQL database dump complete
--

SELECT * FROM doctor;