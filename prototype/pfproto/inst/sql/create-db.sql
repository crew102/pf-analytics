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
  size varchar(3) not null,
  url varchar(255) default null,
  photo_id int not null
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

create table if not exists blacklisted_pets (
  pet_id int not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists pet_tracking (
  pet_id int not null,
  first_seen datetime not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists pet_dof (
  pet_id int not null,
  dof int not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists shelter_activity (
  shelter_id varchar(10) not null,
  activity_date datetime not null,
  activity_type char(1) not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;
