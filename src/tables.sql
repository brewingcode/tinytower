drop table if exists users;
create table if not exists users (id integer primary key, name string);

drop table if exists floors;
create table if not exists floors (id integer primary key, name string);

drop table if exists towers;
create table if not exists towers (user integer, floor integer, story integer);
