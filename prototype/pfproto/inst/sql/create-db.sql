drop database if exists pf_dev;
create database if not exists pf_dev;
use pf_dev;

# "Info" tables where rows get inserted but never altered
create table if not exists pet (
  pet_id int not null,
  shelter_id varchar(10) not null,
  name varchar(256) default null,
  status char(1) default null,
  age varchar(6) default null,
  size varchar(2) default null,
  sex char(1) default null,
  mix varchar(3) default null,
  description text default null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists pet_option (
  pet_id int not null,
  `option` varchar(20) not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists pet_breed (
  pet_id int not null,
  breed varchar(50) not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists pet_photo (
  pet_id int not null,
  photo_id int not null,
  size varchar(3) not null,
  url varchar(255) default null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists shelter (
  shelter_id varchar(10) not null,
  city varchar(256) default null,
  state varchar(256) default null,
  zip varchar(20) default null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

# "Analytics" tables used to track days on petfinder (dof)
create table if not exists initial_pets (
  pet_id int not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists shelter_last_update (
  shelter_id varchar(10) not null,
  last_update datetime not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists pet_current_dof (
  pet_id int not null,
  first_seen datetime not null,
  current_dof int null,
  current_dof_last_update datetime null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists pet_final_dof (
  pet_id int not null,
  final_dof int not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;
