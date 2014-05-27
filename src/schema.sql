CREATE TABLE users (id integer primary key, name string);
CREATE TABLE towers (user integer, story integer, floor string);
CREATE UNIQUE INDEX tower_one_story_per_user ON towers(user,story);
CREATE TABLE completed(mission string, user integer);
CREATE UNIQUE INDEX completed_index ON completed(mission, user);
CREATE TABLE floors (name string primary key, category string);
CREATE TABLE missions (name string, part1 integer, part2 integer, part3 integer);
