drop table if exists users;
create table if not exists users (id integer primary key, name string, quest integer);

drop table if exists floors;
create table if not exists floors (id integer primary key, name string, category string);
insert into floors(id, name, category) values
  (1, "Lobby", "none"),
  (2, "Residential", "none");

drop table if exists towers;
create table if not exists towers (user integer, floor integer, story integer);

drop table if exists sessions;