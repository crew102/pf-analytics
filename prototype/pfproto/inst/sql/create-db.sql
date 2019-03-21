drop database if exists pf_dev;
create database if not exists pf_dev;
use pf_dev;

create table if not exists pet (
  pet_id int not null,
  shelter_id varchar(10) not null,
  name varchar(256) default null,
  age varchar(6) default null,
  size varchar(2) default null,
  sex char(1) default null,
  first_seen datetime not null,
  first_day_not_seen datetime default null,
  dof int default null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists initial_pets (
  pet_id int not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists blacklisted_pets (
  pet_id int not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

create table if not exists changed_ids (
  original_pet_id int not null,
  new_pet_id int not null
) ENGINE = InnoDB DEFAULT CHARSET = utf8;
