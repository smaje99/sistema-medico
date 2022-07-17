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

create table if not exists sistema_medico.role (
    id int unsigned not null auto_increment,
    `name` varchar(50) not null,

    constraint pk_role primary key (id),
    constraint uq_role_name unique(`name`)
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