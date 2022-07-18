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