{knex} = require 'knex'
_ = require 'underscore'

index = (req, res) ->
  id = req.session.userId
  if id?
    knex.raw """
      select u.id, u.name as username, t.story, f.name, f.category
      from floors f
      left join towers t on f.name = t.floor and t.user = #{id}
      left join users u on u.id = t.user
      order by t.story desc"""
    .then (resp) ->
      user = _.find resp[0], (row) -> row.id is id
      if user
        [userFloors, newFloors] = _.partition resp[0], (row) -> row.id is user.id

        newFloors = _.reject newFloors, (row) -> row.name is 'Residential'
        newFloors.push(name:'Residential',category:"(none)")

        hash = {}
        cat = ''
        for floor in _.sortBy(newFloors, (f) -> f.category)
          if cat isnt floor.category
            cat = floor.category
          hash[cat] ?= []
          hash[cat].push(floor.name)

        res.render 'index',
          title: 'Tiny Tower'
          username: user.username
          userFloors: userFloors
          newFloors: hash
      else
        res.send(400, 'unable to get a user')
  else
    knex('users').insert(name:'').then (resp) ->
      req.session.userId = resp[0]
      knex('towers').insert(user:resp[0], floor:"Lobby", story:1).then ->
        res.redirect("/")

setusername = (req, res) ->
  knex('users')
  .where('id', req.session.userId)
  .update(name: req.param('username'))
  .then ->
    res.send(200)

addfloor = (req, res) ->
  knex('towers').insert
    user: req.session.userId
    floor: req.param('floor')
    story: req.param('story')
  .then ->
    res.send(200)

removefloor = (req, res) ->
  if req.param('story') is '1'
    res.send(400, 'cannot remove the lobby')
  else
    knex('towers').where
      user:req.session.userId
      story: req.param('story')
    .delete()
    .then ->
      res.send(200)

missions = (req, res) ->
  user = req.session.userId
  knex.raw """
    select m.name, ifnull(c.user, 0) completed,
      t1.floor part1, t2.floor part2, t3.floor part3, m.part3 hasThird
    from missions m
    left join completed c on m.name = c.mission and (c.user = #{user} or c.user is null)
    left join towers t1 on m.part1 = t1.floor and (t1.user = #{user} or t1.user is null)
    left join towers t2 on m.part2 = t2.floor and (t2.user = #{user} or t2.user is null)
    left join towers t3 on m.part3 = t3.floor and (t3.user = #{user} or t3.user is null)
    order by m.name"""
  .then (resp) ->
    [finished, unfinished] = _.partition resp[0], (row) -> row.completed isnt 0
    [possible, impossible] = _.partition unfinished, (row) ->
      firstTwo = row.part1 and row.part2
      return firstTwo unless row.hasThird
      firstTwo and row.part3

    rowFilter = (row) -> row.name

    res.render 'missions',
      title: 'Missions'
      done: _.map finished, rowFilter
      possible: _.map possible, rowFilter
      impossible: _.map impossible, rowFilter

togglemission = (req, res) ->
  if req.param('which') is 'finish'
    knex('completed').insert
      mission: req.param('name'),
      user: req.session.userId
    .then ->
      res.send(200)
  else
    knex('completed').where
      user: req.session.userId
      mission: req.param('name')
    .delete()
    .then ->
      res.send(200)

clearsession = (req, res) ->
  req.session.destroy()
  req.session = null
  res.send(200)

exports.setup = (app) ->
  app.get('/', index)
  app.post('/setusername', setusername)
  app.post('/addfloor', addfloor)
  app.post('/removefloor', removefloor)
  app.get('/missions', missions)
  app.post('/togglemission', togglemission)
  app.get('/clearsession', clearsession)
