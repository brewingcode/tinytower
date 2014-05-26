drop table if exists users;
create table if not exists users (id integer primary key, name string, quest integer);

drop table if exists floors;
create table if not exists floors (name string primary key, category string);
insert into floors(name, category) values
  ("Lobby", "none"),
  ("Residential", "none");

drop table if exists towers;
create table if not exists towers (user integer, story integer, floor string);

drop table if exists sessions;