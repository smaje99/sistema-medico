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

    constraint pk_user primary key (id),
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

create table if not exists sistema_medico.user (
    dni int unsigned not null,
    username varchar(50) not null,
    `password` text not null,
    is_active bool not null default true,
    `role` int unsigned not null,

    constraint pk_user primary key (dni),
    constraint fk_user_person foreign key (dni) references sistema_medico.person (dni),
    constraint uq_user_username unique (username),
    constraint fk_user_role foreign key (`role`) references sistema_medico.role (id)
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