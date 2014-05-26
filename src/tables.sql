create table if not exists users (id integer primary key, name string);
create table if not exists floors (id integer primary key, name string);
create table if not exists towers (user integer, floor integer);
