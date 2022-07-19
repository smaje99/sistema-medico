-- Active: 1658088866111@@127.0.0.1@5432@sistema_medico
create database sistema_medico;

\c sistema_medico

create user administrator with password 'administrator';
grant all privileges on database sistema_medico to administrator;

-- esquemas

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

-- tablas

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

create table if not exists patient.MedicineRecord (
    record_id uuid not null,
    medicine_code varchar (10) not null,
    indication text not null,
    dose integer not null default 1,

    constraint pk_medicine_record primary key (record_id, medicine_code),
    constraint fk_record foreign key (record_id)
        references patient.record (id),
    constraint fk_medicine foreign key (medicine_code)
        references "service".medicine (code),
    constraint chk_medicine_record_dose check(dose > 0)

);

create table if not exists patient.ServiceRecord (
    record_id uuid not null,
    service_id uuid not null,
    indication text not null,

    constraint pk_service_record primary key (record_id, service_id),
    constraint fk_record foreign key (record_id)
        references patient.record (id),
    constraint fk_service foreign key (service_id)
        references "service"."service" (id)
);

create table if not exists accountant.PaymentType (
    id uuid not null default uuid_generate_v4(),
    "name" text not null,

    constraint pk_payment_type primary key (id)
);

create table if not exists accountant.Payment (
    id uuid not null default uuid_generate_v4(),
    amount decimal not null default 0,
    is_paid boolean not null default false,
    created_at timestamp not null default now(),
    payment_type_id uuid not null,
    appointment_id uuid not null,

    constraint pk_payment primary key (id),
    constraint fk_payment_type foreign key (payment_type_id)
        references accountant.paymenttype (id),
    constraint fk_appointment foreign key (appointment_id)
        references scheduling.appointment (id)
);

create table if not exists accountant.Credit (
    id uuid not null default uuid_generate_v4(),
    amount decimal not null default 0,
    total_fees integer not null default 0,
    is_active boolean not null default true,
    payment_id uuid not null,

    constraint pk_credit primary key (id),
    constraint fk_payment foreign key (payment_id)
        references accountant.payment (id)
);

create table if not exists accountant.Fee (
    id uuid not null default uuid_generate_v4(),
    amount decimal not null default 0,
    created_at timestamp not null default now(),
    credit_id uuid not null,

    constraint pk_fee primary key (id),
    constraint fk_credit foreign key (credit_id)
        references accountant.credit (id)
);

-- registros

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


insert into accountant.paymenttype ("name") values ('contado'), ('crédito');

-- auditoria
create schema if not exists "audit";

create table if not exists "audit".Person_Aud (
    dni integer,
    "name" text,
    surname text,
    "address" text,
    email text,
    phone bigint,
    gender Gender,
    birthdate date,
    document_type DocumentType,
    blood_type BloodType,
    created_at timestamp,

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnPerson_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".person_aud values (
        new.dni,
        new."name",
        new.surname,
        new."address",
        new.email,
        new.phone,
        new.gender,
        new.birthdate,
        new.document_type,
        new.blood_type,
        new.created_at,
        user,
        now(),
        lower(TG_OP)
    );

    return new;
end
$$;

create or replace trigger trPerson_Aud
    before insert or update or delete
    on person.person
    for each row
    execute procedure "audit".fnPerson_Aud();

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
    (69854723, 'Marcus', 'Brown', 'm.brown@gmail.com', 3458915472, 'M', '1992-11-28', 'C.C.', 'A+');

create table if not exists "audit"."action_aud" (
    id uuid,
    "name" varchar(25),

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnAction_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".action_aud values (
        new.id,
        new."name",
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trAction_Aud
    before insert or update or delete
    on "user"."action"
    for each row
    execute procedure "audit".fnAction_Aud();

create table if not exists "audit"."view_aud" (
    id uuid,
    "name" varchar(50),
    "route" varchar(255),

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnView_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".view_aud values (
        new.id,
        new."name",
        new."route",
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trView_Aud
    before insert or update or delete
    on "user"."view"
    for each row
    execute procedure "audit".fnView_Aud();

create table if not exists "audit"."role_aud" (
    id uuid,
    "name" varchar(50),

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnRole_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".role_aud values (
        new.id,
        new."name",
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trRole_Aud
    before insert or update or delete
    on "user"."role"
    for each row
    execute procedure "audit".fnRole_Aud();

create table if not exists "audit".Permission_Aud (
    id uuid,
    view_id uuid,
    action_id uuid,

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnPermission_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".permission_aud values (
        new.id,
        new.view_id,
        new.action_id,
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trPermission_Aud
    before insert or update or delete
    on "user".permission
    for each row
    execute procedure "audit".fnPermission_Aud();

create table if not exists "audit".RolePermission_Aud (
    id uuid,
    is_active boolean,
    role_id uuid,
    permission_id uuid,

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnRolePermission_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".rolepermission_aud values (
        new.id,
        new.is_active,
        new.role_id,
        new.permission_id,
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trRolePermission_Aud
    before insert or update or delete
    on "user".rolepermission
    for each row
    execute procedure "audit".fnRolePermission_Aud();

create table if not exists "audit"."user_aud" (
    dni bigint,
    username varchar(50),
    "password" text,
    is_active bool,
    role_id uuid,

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnUser_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".user_aud values (
        new.dni,
        new.username,
        new."password",
        new.is_active,
        new.role_id,
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trUser_Aud
    before insert or update or delete
    on "user"."user"
    for each row
    execute procedure "audit".fnUser_Aud();

create table if not exists "audit".UserPermission_Aud (
    id uuid,
    is_active boolean,
    user_dni bigint,
    permission_id uuid,

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnUserPermission_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".userpermission_aud values (
        new.dni,
        new.is_active,
        new.user_id,
        new.permission_id,
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trUserPermission_Aud
    before insert or update or delete
    on "user".userpermission
    for each row
    execute procedure "audit".fnUserPermission_Aud();

create table if not exists "audit".Doctor_Aud (
    dni bigint,
    medical_license integer,

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnDoctor_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".doctor_aud values (
        new.dni,
        new.medical_license,
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trDoctor_Aud
    before insert or update or delete
    on "service".doctor
    for each row
    execute procedure "audit".fnDoctor_Aud();

create table if not exists "audit".Specialty_Aud (
    id uuid,
    "name" text,

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnSpecialty_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".specialty_aud values (
        new.id,
        new."name",
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trSpecialty_Aud
    before insert or update or delete
    on "service".specialty
    for each row
    execute procedure "audit".fnSpecialty_Aud();

create table if not exists "audit".DoctorSpecialty_Aud (
    doctor_dni bigint,
    specialty_id uuid,
    degree_title text,
    degree_register integer,
    university text,

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnDoctorSpecialty_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".doctorspecialty_aud values (
        new.doctor_dni,
        new.specialty_id,
        new.degree_title,
        new.degree_register,
        new.university,
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trDoctorSpecialty_Aud
    before insert or update or delete
    on "service".doctorspecialty
    for each row
    execute procedure "audit".fnDoctorSpecialty_Aud();

create table if not exists "audit".Office_Aud (
    id uuid,
    "name" text,

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnOffice_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".office_aud values (
        new.id,
        new."name",
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trOffice_Aud
    before insert or update or delete
    on "service".office
    for each row
    execute procedure "audit".fnOffice_Aud();

create table if not exists "audit"."service_aud" (
    id uuid,
    "name" text,
    observation text,
    cost decimal,
    service_type ServiceType,
    is_active boolean,
    specialty_id uuid,

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnService_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".service_aud values (
        new.id,
        new."name",
        new.observation,
        new.cost,
        new.service_type,
        new.is_active,
        new.specialty_id,
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trService_Aud
    before insert or update or delete
    on "service"."service"
    for each row
    execute procedure "audit".fnService_Aud();

create table if not exists "audit".Exam_Aud (
    code varchar(5),
    "name" text,
    is_active boolean,

    "user" varchar(50) not null,
    logged_at timestamp not null,
    process text not null
);

create or replace function "audit".fnExam_Aud()
    returns trigger
    language plpgsql
    as
$$
begin
    insert into "audit".exam_aud values (
        new.cpde,
        new."name",
        new.is_active,
        user,
        now(),
        TG_OP
    );

    return new;
end
$$;

create or replace trigger trExam_Aud
    before insert or update or delete
    on "service".exam
    for each row
    execute procedure "audit".fnExam_Aud();