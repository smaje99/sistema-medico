create database if not exists sistema_medico;

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
    id int unsigned not null,
    `name` varchar(50) not null,

    constraint pk_role primary key (id),
    constraint uq_role_name unique(`name`)
);