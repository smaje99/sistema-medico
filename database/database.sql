-- Active: 1658088866111@@127.0.0.1@5432@sistema_medico
create database sistema_medico;

\c sistema_medico

create user administrator with password 'administrator';
grant all privileges on database sistema_medico to administrator;

create schema if not exists person;
create schema if not exists patient;
create schema if not exists "user";
create schema if not exists "service";
create schema if not exists scheduling;
create schema if not exists accountant;

create user client with password 'client';
grant
    select,
    insert,
    update,
    delete
on all tables in schema
    person,
    patient,
    "user",
    "service",
    scheduling,
    accountant
to client;

create extension if not exists "uuid-ossp";

create type DocumentType as enum ('R.C.', 'T.I.', 'C.C.', 'C.E.');
create type BloodType as enum ('AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-');
create type Gender as enum ('M', 'F');

create table if not exists person.Person (
    dni integer not null,
    "name" text not null,
    surname text not null,
    "address" text,
    email text not null,
    phone bigint not null,
    gender Gender not null,
    birthdate date not null,
    document_type DocumentType not null,
    blood_type BloodType,
    created_at timestamp not null default now(),

    constraint pk_person primary key (dni),
    constraint chk_phone check(length(phone::varchar) = 10)
);

create table if not exists "user"."action" (
    id uuid not null default uuid_generate_v4(),
    "name" varchar(25) not null,

    constraint pk_action primary key (id),
    constraint uq_name unique ("name")
);

create table if not exists "user"."view" (
    id uuid not null default uuid_generate_v4(),
    "name" varchar(50) not null,
    "route" varchar(255) not null,

    constraint pk_view primary key (id),
    constraint uq_view_name unique ("name"),
    constraint uq_view_route unique ("route")
);

create table if not exists "user"."role" (
    id uuid not null default uuid_generate_v4(),
    "name" varchar(50) not null,

    constraint pk_role primary key (id),
    constraint uq_role_name unique("name")
);

create table if not exists "user".Permission (
    id uuid not null default uuid_generate_v4(),
    view_id uuid not null,
    action_id uuid not null,

    constraint pk_permission primary key (id),
    constraint fk_view foreign key (view_id)
        references "user"."view" (id),
    constraint fk_action foreign key (action_id)
        references "user"."action" (id)
);

create table if not exists "user".RolePermission (
    id uuid not null default uuid_generate_v4(),
    is_active boolean not null default true,
    role_id uuid not null,
    permission_id uuid not null,

    constraint pk_role_permissions primary key (id),
    constraint fk_role foreign key (role_id)
        references "user"."role" (id),
    constraint fk_permission foreign key (permission_id)
        references "user".permission (id)
);

create table if not exists "user"."user" (
    dni bigint not null,
    username varchar(50) not null,
    "password" text not null,
    is_active bool not null default true,
    role_id uuid not null,

    constraint pk_user primary key (dni),
    constraint fk_person foreign key (dni)
        references person.person (dni),
    constraint fk_role foreign key (role_id)
        references "user"."role" (id),
    constraint uq_user_username unique (username)
);

create table if not exists "user".UserPermission (
    id uuid not null default uuid_generate_v4(),
    is_active boolean not null default true,
    user_dni bigint not null,
    permission_id uuid not null,

    constraint pk_user_permission primary key (id),
    constraint fk_user foreign key (user_dni)
        references "user"."user" (dni),
    constraint fk_permission foreign key (permission_id)
        references "user"."permission" (id)
);

create table if not exists "service".doctor (
    dni bigint not null,
    medical_license integer not null,

    constraint pk_doctor primary key (dni),
    constraint fk_user foreign key (dni)
        references "user"."user" (dni),
    constraint uq_doctor_medical_license unique (medical_license)
);

create table if not exists "service".Specialty (
    id uuid not null default uuid_generate_v4(),
    "name" text not null,

    constraint pk_specialty primary key (id)
);

create table if not exists "service".DoctorSpecialty (
    doctor_dni bigint not null,
    specialty_id uuid not null,
    degree_title text not null,
    degree_register integer not null,
    university text not null,

    constraint pk_doctor_specialty primary key (doctor_dni, specialty_id),
    constraint fk_doctor foreign key (doctor_dni)
        references "service".doctor (dni),
    constraint fk_specialty foreign key (specialty_id)
        references "service".specialty (id),
    constraint uq_doctor_specialty_degree_register unique (degree_register)
);

create table if not exists "service".Office (
    id uuid not null default uuid_generate_v4(),
    "name" text not null,

    constraint pk_office primary key (id),
    constraint uq_office_name unique (name)
);

create type ServiceType as enum ('presencial', 'domiciliaria');

create table if not exists "service"."service" (
    id uuid not null default uuid_generate_v4(),
    "name" text not null,
    observation text,
    cost decimal not null default 0,
    service_type ServiceType not null,
    is_active boolean not null default true,
    specialty_id uuid not null,

    constraint pk_service primary key (id),
    constraint fk_specialty foreign key (specialty_id)
        references "service"."specialty" (id)
);

create table if not exists "service".Diagnostic (
    code varchar(5) not null,
    "name" text not null,
    is_active boolean not null default true,

    constraint pk_diagnostic primary key (code)
);

create table if not exists "service".Exam (
    code varchar(5) not null,
    "name" text not null,
    is_active boolean not null default true,

    constraint pk_exam primary key (code)
);

create table if not exists "service".Medicine (
    code varchar(10) not null,
    "name" text not null,
    quantity integer not null default 0,
    unit varchar(5) not null,
    is_active boolean not null default true,

    constraint pk_medicine primary key (code),
    constraint chk_medicine_quantity check(quantity >= 0)
);

create table if not exists scheduling.Permit (
    id uuid not null default uuid_generate_v4(),
    reason text,
    is_active boolean not null default true,
    "start_date" timestamp not null,
    end_date timestamp not null,
    created_at timestamp not null default now(),
    doctor_dni bigint not null,

    constraint pk_permit primary key (id),
    constraint fk_doctor foreign key (doctor_dni)
        references "service".doctor (dni)
);

create type AppointmentType as enum ('presencial', 'domiciliaria');

create type SessionType as enum ('mañana', 'tarde', 'todo el día');

create table if not exists scheduling.Schedule (
    id uuid not null default uuid_generate_v4(),
    appointment_type AppointmentType not null,
    "session" SessionType not null,
    is_active boolean default true,
    doctor_dni bigint not null,
    office_id uuid,

    constraint pk_schedule primary key (id),
    constraint fk_doctor foreign key (doctor_dni)
        references "service".doctor (dni),
    constraint fk_office foreign key (office_id)
        references "service".office (id)
);

create table if not exists patient.Patient (
    dni bigint not null,

    constraint pk_patient primary key (dni),
    constraint fk_person foreign key (dni)
        references "person".person (dni)
);

create table if not exists patient.Allergy (
    id uuid not null default uuid_generate_v4(),
    "name" text not null,
    is_active boolean not null default true,

    constraint pk_allergy primary key (id)
);

create table if not exists patient.PatientAllergy (
    patient_dni bigint not null,
    allergy_id uuid not null,
    observation text,

    constraint pk_patient_allergy primary key (patient_dni, allergy_id),
    constraint fk_patient foreign key (patient_dni)
        references patient.patient (dni),
    constraint fk_allergy foreign key (allergy_id)
        references patient.allergy (id)
);

create table if not exists patient.Entity (
    id uuid not null default uuid_generate_v4(),
    nit char(11) not null,
    "name" text not null,
    "address" text not null,
    email text not null,
    phone bigint not null,
    has_agreement boolean not null default true,
    created_at timestamp not null default now(),

    constraint pk_entity primary key (id),
    constraint uq_entity_nit unique (nit),
    constraint uq_entity_email unique (email),
    constraint chk_entity_phone check(phone > 0)
);

create table if not exists patient.PatientEntity (
    id uuid not null default uuid_generate_v4(),
    is_active boolean not null default true,
    patient_dni bigint not null,
    entity_id uuid not null,

    constraint pk_patient_entity primary key (id),
    constraint fk_patient foreign key (patient_dni)
        references patient.patient (dni),
    constraint fk_entity foreign key (entity_id)
        references patient.entity (id)
);

create table if not exists scheduling.appointment (
    id uuid not null default uuid_generate_v4(),
    "date" timestamp not null,
    reason text,
    is_attending boolean not null default false,
    patient_id uuid not null,
    service_id uuid not null,
    schedule_id uuid not null,

    constraint pk_appointment primary key (id),
    constraint fk_patient foreign key (patient_id)
        references patient.patiententity (id),
    constraint fk_service foreign key (service_id)
        references "service"."service" (id),
    constraint fk_schedule foreign key (schedule_id)
        references scheduling.schedule (id)
);

create table if not exists scheduling.antecedent (
    file_uuid uuid not null,
    appointment_id uuid not null,

    constraint pk_actecedent primary key (file_uuid),
    constraint fk_appointment_id foreign key (appointment_id)
        references scheduling.appointment (id)
);

create table if not exists scheduling.Cancellation (
    id uuid not null default uuid_generate_v4(),
    reason text not null,
    appointment_id uuid not null,

    constraint pk_cancellation primary key (id),
    constraint fk_appointment foreign key (appointment_id)
        references scheduling.appointment (id)
);

create table if not exists patient.Record (
    id uuid not null default uuid_generate_v4(),
    observation text not null,
    created_at timestamp not null default now(),
    appointment_id uuid not null,

    constraint pk_record primary key (id),
    constraint fk_appointment foreign key (appointment_id)
        references scheduling.appointment (id)
);

create type BodyPartType as enum ('oral', 'rectal', 'axilar', 'oído', 'piel');

create table if not exists patient.VitalSigns (
    record_id uuid not null,
    respiration_rate integer not null,
    pulse_rate integer,
    body_part BodyPartType,
    body_temperature integer,
    systolic integer,
    diastolic integer,
    "weight" integer,
    height integer,

    constraint pk_vital_signs primary key (record_id),
    constraint fk_record foreign key (record_id)
        references patient.record (id)
);

create table if not exists patient.DiagnosticRecord (
    record_id uuid not null,
    diagnostic_code varchar(5) not null,
    observation text not null,

    constraint pk_diagnostic_record primary key (record_id, diagnostic_code),
    constraint fk_record foreign key (record_id)
        references patient.record (id),
    constraint fk_diagnostic foreign key (diagnostic_code)
        references "service".diagnostic (code)
);

create table if not exists patient.ExamRecord (
    record_id uuid not null,
    exam_code varchar (5) not null,
    indication text not null,

    constraint pk_exam_record primary key (record_id, exam_code),
    constraint fk_record foreign key (record_id)
        references patient.record (id),
    constraint fk_exam foreign key (exam_code)
        references "service".exam (code)
);

insert into person.person (
    dni,
    "name",
    surname,
    email,
    phone,
    gender,
    birthdate,
    document_type,
    blood_type
) values
    (14589657, 'John', 'Doe', 'j.doe@gmail.com', 3215894789, 'M', '1970-05-14', 'C.C.', 'B+'),
    (23458573, 'Mary', 'Doe', 'm.doe@gmail.com', 3245832093, 'F', '1983-09-23', 'C.C.', 'O+'),
    (1119456034, 'Avery', 'Doe', 'a.doe@gmail.com', 3167983876, 'M', '2012-12-04', 'T.I.', 'O+'),
    (11845765, 'Anne', 'Smith', 'a.smith@gmail.com', 3245436782, 'F', '1978-02-23', 'C.E.', 'A+'),
    (17459873, 'Mandy', 'McGonagar', 'm.mcgonagar@gmail.com', 3782346543, 'F', '1962-06-26', 'C.C.', 'AB+'),
    (56873498, 'Edward', 'Nolsen', 'e.nolsen@gmail.com', 3498347654, 'M', '1958-07-25', 'C.C.', 'O-');

insert into "user"."Action" ("name") values ('read'), ('write');

insert into "user"."view" ("name", "route") values ('Dashboard', 'dashboard');

insert into "user"."role" ("name") values ('administrador'), ('médico'), ('recepcionista');

insert into "user".permission (view_id, action_id) values
    ('c598fab1-faca-408f-8c61-79390b16ffdb', '8010f2c5-0bf5-4696-b43e-7dbde3e18c3b');

insert into "user".rolepermission (role_id, permission_id) values
    ('f6f3e9c7-b879-4644-8e63-7bb463961cf8', '34a9373d-4754-462f-b46f-573597878c1f'),
    ('baf197ab-87aa-401a-a226-5b21fb79c7fd', '34a9373d-4754-462f-b46f-573597878c1f'),
    ('4c2d2500-6115-4732-8cb1-507ea60b61f8', '34a9373d-4754-462f-b46f-573597878c1f');

insert into "user"."user" (dni, username, "password", role_id) values
    (14589657, 'j.doe', 'admin', 'f6f3e9c7-b879-4644-8e63-7bb463961cf8'),
    (23458573, 'm.doe', 'm2345', '4c2d2500-6115-4732-8cb1-507ea60b61f8'),
    (11845765, 'a.smith', 'a1184', 'baf197ab-87aa-401a-a226-5b21fb79c7fd');

insert into "service".doctor (dni, medical_license) values (11845765, 141516);

insert into "service".specialty ("name") values ('Medicina Interna');

insert into "service".doctorspecialty (
    doctor_dni,
    specialty_id,
    degree_title,
    degree_register,
    university
) values
    (
        11845765,
        'bb78510b-5c2b-4330-9386-2ac30380d74e',
        'Medicina Interna',
        124578,
        'Universidad Nacional de Colombia'
    );

insert into "service".office ("name") values ('Consultorio 1');

insert into "service"."service" (
    "name",
    cost,
    service_type,
    specialty_id
) values
    (
        'Cuidados paleativos para el dolor',
        80000,
        'presencial',
        'bb78510b-5c2b-4330-9386-2ac30380d74e'
    );

insert into "service".diagnostic (code, "name") values
    ('M45X', 'Espondolitis Anquilosante'),
    ('I50', 'Insuficiencia Cardíaca'),
    ('I10', 'Hipertensión Arterial');

insert into "service".exam (code, "name") values
    ('RMN', 'Resonancia Magnetica Nuclear'),
    ('RX', 'Radiografía'),
    ('ECO', 'Ecografía');

insert into "service".medicine (code, "name", quantity, unit)
values
    ('DFS50M', 'diclofenaco sodico', 50, 'mg'),
    ('DFS100M', 'diclofenaco sodico', 50, 'mg'),
    ('IB400M', 'ibuprofeno', 400, 'mg'),
    ('ATOR40M', 'atorvastatina', 40, 'mg');

insert into scheduling.permit ("start_date", end_date, doctor_dni)
values
    ('2022-07-26 08:00:00', '2022-07-28 18:00:00', 11845765);

insert into scheduling.schedule (
    appointment_type,
    "session",
    doctor_dni,
    office_id
) values ('presencial', 'todo el día', 11845765, '1b5ad114-37d6-47b8-b73a-3c1621bc2e91');

insert into patient.patient (dni)
values (1119456034), (56873498);

insert into patient.allergy ("name")
values ('rinitis alérgica'), ('penicilina'), ('látex');

insert into patient.patientallergy (patient_dni, allergy_id)
values (56873498, '01cbd4d8-17a8-4b57-9023-184a5a637f35');

insert into patient.entity (nit, "name", "address", email, phone)
values
    ('111111111-1', 'particular', 'in-sitio', 'ips@company.com', 3124567895),
    ('222222222-2', 'Sanitas E.P.S.', 'Calle 1', 'sanitas@company.com', 3692581474);

insert into patient.PatientEntity (patient_dni, entity_id)
values
    (1119456034, 'a67067eb-ae7c-4032-9e62-f96bd2ec9e88'),
    (56873498, 'ddbe40ec-ffa0-45a9-b871-a9168fee6131');

insert into scheduling.appointment ("date", patient_id, service_id, schedule_id)
values
    ('2022-08-01 08:00:00', 'f4861a36-86bb-459b-8f6e-3af5e9c0e453', '60e318f5-cec6-495d-b2a3-70b79941845b', '77fb22c8-b0bb-4042-a283-b24d4fdad5c4'),
    ('2022-09-01 08:00:00', 'f4861a36-86bb-459b-8f6e-3af5e9c0e453', '60e318f5-cec6-495d-b2a3-70b79941845b', '77fb22c8-b0bb-4042-a283-b24d4fdad5c4');
