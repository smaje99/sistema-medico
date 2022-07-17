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

create extension if not exists "uuid-ossp";

create table if not exists sistema_medico.Person (
    dni int unsigned not null,
    `name` text not null,
    surname text not null,
    `address` text,
    email text not null,
    phone int unsigned not null,
    gender enum('M', 'F', 'T') not null,
    birthdate datetime not null,
    document_type enum('R.C.', 'T.I.', 'C.C.', 'C.E.') not null,
    blood_type enum('AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-'),
    created_at timestamp not null default now(),

    constraint pk_person primary key (dni),
    constraint chk_person_phone check(length(convert(phone, char)) = 10)
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