--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2
-- Dumped by pg_dump version 14.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: des_num_of_waiting(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.des_num_of_waiting() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE oldNumWaiting int4;
BEGIN 
SELECT INTO oldNumWaiting num_of_waiting FROM room WHERE room_id = new.room_id;
IF oldNumWaiting > 0 THEN UPDATE room SET num_of_waiting = oldNumWaiting - 1 WHERE room_id = new.room_id;
END IF;
RETURN new;
END
$$;


ALTER FUNCTION public.des_num_of_waiting() OWNER TO postgres;

--
-- Name: inc_num_of_waiting(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.inc_num_of_waiting() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.inc_num_of_waiting() OWNER TO postgres;

--
-- Name: update_doctor_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_doctor_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF TG_OP = 'INSERT' THEN UPDATE doctor SET status = false WHERE doctor_id = new.doctor_id;
UPDATE registration SET status = true WHERE patient_id = new.patient_id;
ELSE UPDATE doctor SET status = true WHERE doctor_id = old.doctor_id;
END IF;
RETURN new;
END 
$$;


ALTER FUNCTION public.update_doctor_status() OWNER TO postgres;

--
-- Name: update_num_of_waiting(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_num_of_waiting() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.update_num_of_waiting() OWNER TO postgres;

--
-- Name: update_room_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_room_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE roomID text;
BEGIN
  SELECT into roomID new.room_id FROM room WHERE (SELECT COUNT(doctor_id) FROM doctor WHERE status = false  AND room_id = new.room_id) = (SELECT COUNT(doctor_id) FROM doctor WHERE room_id = new.room_id);
IF roomID IS NOT NULL THEN UPDATE room SET status = 'f' WHERE room_id = roomID ;
ELSE UPDATE room SET status = 't' WHERE room_id = new.room_id;
END IF;
RETURN  new;
END 
$$;


ALTER FUNCTION public.update_room_status() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    email character varying(255) NOT NULL,
    password character(8) NOT NULL,
    role character varying,
    doctor_id character(5),
    room_id character(8)
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: appointment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointment (
    appointment_id character(8) NOT NULL,
    start_time time without time zone,
    diagnosis text,
    specialty_id character(4) NOT NULL,
    room_id character(8),
    doctor_id character(5) NOT NULL,
    patient_id character(8) NOT NULL,
    expected_time time without time zone,
    end_time time without time zone
);


ALTER TABLE public.appointment OWNER TO postgres;

--
-- Name: bill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bill (
    bill_id character(10) NOT NULL,
    appointment_id character(8) NOT NULL,
    patient_id character(8) NOT NULL,
    examination_fee money,
    medicine_fee money,
    total_charges money,
    discounted_charges integer,
    date_time date
);


ALTER TABLE public.bill OWNER TO postgres;

--
-- Name: doctor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor (
    doctor_id character(5) NOT NULL,
    doctor_name character varying(40) NOT NULL,
    age integer NOT NULL,
    status boolean,
    specialty_id character(4) NOT NULL,
    room_id character(8) NOT NULL
);


ALTER TABLE public.doctor OWNER TO postgres;

--
-- Name: medical; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medical (
    medical_id character(8) NOT NULL,
    cost money,
    manufacturer character varying(60),
    medical_name character varying
);


ALTER TABLE public.medical OWNER TO postgres;

--
-- Name: medicine; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicine (
    medical_id character(8) NOT NULL,
    bill_id character(8) NOT NULL,
    quantity integer
);


ALTER TABLE public.medicine OWNER TO postgres;

--
-- Name: patient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient (
    patient_id character(8) NOT NULL,
    name character varying(40) NOT NULL,
    dob date NOT NULL,
    age integer,
    sex character(1),
    address character varying(120),
    phone_number character(10),
    status_of_insurance boolean,
    medical_history text,
    citizen_id character(12),
    CONSTRAINT patient_chk_sex CHECK (((sex = 'F'::bpchar) OR (sex = 'M'::bpchar)))
);


ALTER TABLE public.patient OWNER TO postgres;

--
-- Name: registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.registration (
    patient_id character(8) NOT NULL,
    registration_time time without time zone,
    expected_time time without time zone,
    instead_of character(8) DEFAULT NULL::bpchar,
    specialty_id character(4),
    status boolean,
    room_id character(8)
);


ALTER TABLE public.registration OWNER TO postgres;

--
-- Name: room; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.room (
    room_id character(8) NOT NULL,
    status character varying(20),
    num_of_waiting integer,
    manager_id character(8),
    specialty_id character(4) NOT NULL
);


ALTER TABLE public.room OWNER TO postgres;

--
-- Name: specialty; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specialty (
    specialty_id character(4) NOT NULL,
    specialty character varying(40)
);


ALTER TABLE public.specialty OWNER TO postgres;

--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounts (email, password, role, doctor_id, room_id) FROM stdin;
tung2082002@gmail.com	20082002	super_admin	\N	\N
doctor@gmail.com	11111111	doctor	20205	00000003
\.


--
-- Data for Name: appointment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.appointment (appointment_id, start_time, diagnosis, specialty_id, room_id, doctor_id, patient_id, expected_time, end_time) FROM stdin;
04030728	08:19:30	\N	2020	00000002	20204	46320203	\N	\N
01010728	08:22:08	\N	2020	00000001	20201	24150901	\N	\N
06070728	08:23:31	\N	2020	00000003	20206	90900707	\N	\N
03010728	08:23:57	\N	2020	00000002	20203	14120401	\N	\N
02090728	08:26:01	\N	2020	00000001	20202	41150109	\N	\N
05040728	08:26:27	Viem hong hat	2020	00000003	20205	25721004	09:35:16	09:36:07
05090728	09:36:40	Viem hong	2020	00000003	20205	19420909	13:03:41	13:04:09
05030728	13:04:26	\N	2020	00000003	20205	45210303	\N	\N
\.


--
-- Data for Name: bill; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bill (bill_id, appointment_id, patient_id, examination_fee, medicine_fee, total_charges, discounted_charges, date_time) FROM stdin;
05040728  	05040728	25721004	$100,000.00	$400,000.00	$500,000.00	500000	\N
05090728  	05090728	19420909	$100,000.00	$240,000.00	$340,000.00	340000	\N
\.


--
-- Data for Name: doctor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctor (doctor_id, doctor_name, age, status, specialty_id, room_id) FROM stdin;
20227	Nguyễn Tùng Lâm	30	t	2022	00000008
20213	NguyễnLương Duy	41	t	2021	00000005
20223	Lê Vũ Hoàng	32	t	2022	00000008
20221	NguyễnHoàng Hiếu	35	t	2022	00000007
20222	Trần Văn Hiếu	36	t	2022	00000007
20211	NguyễnKimCường	32	t	2021	00000004
20212	NguyễnNgọc Dũng	36	t	2021	00000004
20224	NguyễnHuyHoàng	42	t	2022	00000008
20215	Dương TiếnĐạt	38	t	2021	00000006
20216	Phạm Bá Đồng	35	t	2021	00000006
20214	Đào Kim Dương	39	t	2021	00000005
20204	Bùi Danh Tùng	30	f	2020	00000002
20201	NguyễnĐình ThànhAn	27	f	2020	00000001
20206	NguyễnKhắc Thái Bình	31	f	2020	00000003
20203	Nguyễn Văn Thiên Anh	29	f	2020	00000002
20202	Ngọ Việt Anh	35	f	2020	00000001
20205	VũQuang Anh	33	f	2020	00000003
\.


--
-- Data for Name: medical; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medical (medical_id, cost, manufacturer, medical_name) FROM stdin;
30000001	$50,000.00	\N	heroin
30000002	$30,000.00	\N	panysilin
30000003	$60,000.00	\N	cocain
30000004	$70,000.00	\N	glixerin
\.


--
-- Data for Name: medicine; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medicine (medical_id, bill_id, quantity) FROM stdin;
30000001	05040728	2
30000002	05040728	2
30000003	05040728	4
30000002	05090728	2
30000003	05090728	3
\.


--
-- Data for Name: patient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient (patient_id, name, dob, age, sex, address, phone_number, status_of_insurance, medical_history, citizen_id) FROM stdin;
23120202	Bui Danh Tung	2002-02-02	20	M	no company	0393859464	t	\N	999911112312
41420303	Bui Danh Tung	2002-03-03	20	M	no company	0393859464	t	\N	200213144142
46320404	Nguyen tung Lam	2002-04-04	20	M	no company	0393859464	t	\N	210341424632
24560909	Bui Danh Tung	2002-09-09	20	M	no company	0393859464	t	\N	202141242456
46320203	Bui Danh Tung	2002-02-03	20	M	no company	0393859464	t	\N	201413414632
24150901	Nguyen Tung Lam	2002-09-01	20	M	no company	0393859464	t	\N	381713412415
90900707	Nguyen Huu Tuan	2002-07-07	20	M	no company	0393859464	t	\N	219387629090
14120401	Bui Danh Tung	2002-04-01	20	M	no company	0393859464	t	\N	123145321412
41150109	Bui Danh Tung	2002-01-09	20	M	no company	0393859464	t	\N	219148134115
25721004	Bui Danh Tung	2002-10-04	20	M	no company	0393859464	t	\N	348241452572
12930305	Nguyen Thanh Long	2002-03-05	20	M	no company	0393859464	t	\N	293819381293
56740808	Bui Danh Tung	2002-08-08	20	M	no company	0393859464	t	\N	139138145674
19420909	Bui Danh Tung	2002-09-09	20	M	no company	0393859464	t	\N	123141341942
11110505	Bui Danh Tung	2002-05-05	20	M	no company	0393859464	t	\N	777766661111
42340804	Nguyen Doan Tuan	2002-08-04	20	M	no company	0393859464	t	\N	817241324234
45210303	Nguyen Huu Thang	2002-03-03	20	M	no company	0393859464	t	\N	134913124521
84830505	Nguyen Tung Lam	2002-05-05	20	M	no company	0393859464	t	\N	124124218483
11110603	Nguyen Tung Lam	2002-06-03	20	M	no company	0393859464	t	\N	111111111111
\.


--
-- Data for Name: registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.registration (patient_id, registration_time, expected_time, instead_of, specialty_id, status, room_id) FROM stdin;
14120401	08:23:57	08:23:57	\N	2020	t	00000002
41150109	08:26:01	08:26:01	\N	2020	t	00000001
25721004	08:26:27	08:26:27	\N	2020	t	00000003
12930305	08:29:49	08:59:49	\N	2020	\N	00000002
56740808	08:32:43	09:02:43	\N	2020	\N	00000001
11110505	08:36:46	09:06:46	\N	2020	\N	00000002
42340804	08:38:34	09:08:34	\N	2020	\N	00000001
19420909	08:33:45	09:03:45	\N	2020	t	00000003
84830505	11:57:36	12:27:36	\N	2020	\N	00000003
11110603	13:02:17	13:32:17	\N	2020	\N	00000002
45210303	09:34:07	10:04:07	\N	2020	t	00000003
46320203	08:19:30	08:19:30	\N	2020	t	00000002
24150901	08:22:08	08:22:08	\N	2020	t	00000001
90900707	08:23:31	08:23:31	\N	2020	t	00000003
\.


--
-- Data for Name: room; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.room (room_id, status, num_of_waiting, manager_id, specialty_id) FROM stdin;
00000007	t	0	20221   	2022
00000004	t	0	20211   	2021
00000008	t	0	20223   	2022
00000006	t	0	20215   	2021
00000005	t	0	20213   	2021
00000009	t	0	20225   	2022
00000001	f	2	20201   	2020
00000002	f	3	20203   	2020
00000003	f	1	20205   	2020
\.


--
-- Data for Name: specialty; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specialty (specialty_id, specialty) FROM stdin;
2020	Tai Mũi Họng
2021	Tim Mạch
2022	Mắt
\.


--
-- Name: appointment appointment_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT appointment_pk PRIMARY KEY (appointment_id);


--
-- Name: bill bill_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_pk PRIMARY KEY (bill_id);


--
-- Name: doctor doctor_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_pk PRIMARY KEY (doctor_id);


--
-- Name: medical medical_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical
    ADD CONSTRAINT medical_pk PRIMARY KEY (medical_id);


--
-- Name: medicine medicine_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicine
    ADD CONSTRAINT medicine_pk PRIMARY KEY (medical_id, bill_id);


--
-- Name: patient patient_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient
    ADD CONSTRAINT patient_pk PRIMARY KEY (patient_id);


--
-- Name: room room_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT room_pk PRIMARY KEY (room_id);


--
-- Name: specialty specialty_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialty
    ADD CONSTRAINT specialty_pk PRIMARY KEY (specialty_id);


--
-- Name: accounts users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: doctor_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX doctor_status_index ON public.doctor USING btree (status);


--
-- Name: specialty_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX specialty_id_index ON public.specialty USING btree (specialty_id);


--
-- Name: appointment af_insert_app; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER af_insert_app AFTER INSERT OR UPDATE OF end_time ON public.appointment FOR EACH ROW EXECUTE FUNCTION public.update_doctor_status();


--
-- Name: appointment des_num_of_wt; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER des_num_of_wt AFTER INSERT ON public.appointment FOR EACH ROW EXECUTE FUNCTION public.des_num_of_waiting();


--
-- Name: registration inc_num_of_wt; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER inc_num_of_wt BEFORE INSERT ON public.registration FOR EACH ROW EXECUTE FUNCTION public.inc_num_of_waiting();


--
-- Name: appointment ins_num_of_wt; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ins_num_of_wt BEFORE INSERT ON public.appointment FOR EACH ROW EXECUTE FUNCTION public.update_num_of_waiting();


--
-- Name: doctor up_rst_af_insert_app; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER up_rst_af_insert_app AFTER UPDATE ON public.doctor FOR EACH ROW EXECUTE FUNCTION public.update_room_status();


--
-- Name: appointment appoint_fk_doctor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT appoint_fk_doctor FOREIGN KEY (doctor_id) REFERENCES public.doctor(doctor_id);


--
-- Name: appointment appoint_fk_patient; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT appoint_fk_patient FOREIGN KEY (patient_id) REFERENCES public.patient(patient_id);


--
-- Name: appointment appoint_fk_room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT appoint_fk_room FOREIGN KEY (room_id) REFERENCES public.room(room_id);


--
-- Name: appointment appoint_fk_specialty; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment
    ADD CONSTRAINT appoint_fk_specialty FOREIGN KEY (specialty_id) REFERENCES public.specialty(specialty_id);


--
-- Name: bill bill_fk_appoint; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_fk_appoint FOREIGN KEY (appointment_id) REFERENCES public.appointment(appointment_id);


--
-- Name: bill bill_fk_patient; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_fk_patient FOREIGN KEY (patient_id) REFERENCES public.patient(patient_id);


--
-- Name: doctor doc_fk_room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doc_fk_room FOREIGN KEY (room_id) REFERENCES public.room(room_id);


--
-- Name: doctor doc_fk_specialty; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doc_fk_specialty FOREIGN KEY (specialty_id) REFERENCES public.specialty(specialty_id);


--
-- Name: medicine medicine_fk_bill; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicine
    ADD CONSTRAINT medicine_fk_bill FOREIGN KEY (bill_id) REFERENCES public.bill(bill_id);


--
-- Name: medicine medicine_fk_medical; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicine
    ADD CONSTRAINT medicine_fk_medical FOREIGN KEY (medical_id) REFERENCES public.medical(medical_id);


--
-- Name: registration res_fk_patient; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration
    ADD CONSTRAINT res_fk_patient FOREIGN KEY (patient_id) REFERENCES public.patient(patient_id);


--
-- Name: room room_fk_spe; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT room_fk_spe FOREIGN KEY (specialty_id) REFERENCES public.specialty(specialty_id);


--
-- PostgreSQL database dump complete
--

