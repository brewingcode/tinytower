{knex} = require 'knex'
_ = require 'underscore'

index = (req, res) ->
  id = req.session.userId
  if id?
    knex.raw """
      select u.id, u.name as username, t.story, f.name
      from floors f
      left join towers t on f.name = t.floor
      left join users u on u.id = t.user
      order by t.story desc"""
    .then (resp) ->
      user = _.find resp[0], (row) -> row.id is id
      if user
        res.render 'index',
          title: 'Tiny Tower'
          username: user.username
          userFloors: _.filter resp[0], (row) -> row.id is id
          newFloors: _.map _.filter(resp[0], (row) -> not row.id), (row) -> row.name
      else
        res.send(500, 'unable to get a user')
  else
    knex('users').insert(name:'').then (resp) ->
      req.session.userId = resp[0].id
      knex('towers').insert(user:resp[0], floor:"Lobby", story:1).then ->
        res.redirect("/")

setusername = (req, res) ->
  knex('users')
  .where('id', req.session.userId)
  .update(name: req.param('username'))
  .then ->
    res.send(200)

newfloors = (req, res) ->
  knex('towers').where('id', req.sessionId).then (userFloors) ->
    knex('floors').whereNotIn('name', userFloors.map (row) -> row.floor).then (newFloors) ->
      res.json
        suggestions: newFloors.map (row) -> row.name

addfloor = (req, res) ->
  knex('towers').insert
    user: req.session.userId
    floor: req.param('floor')
    story: req.param('story')
  .then ->
    res.send(200)

missions = (req, res) ->
  knex.raw """
    select m.name, ifnull(c.user, 0) completed
    from missions m
    left join completed c on m.name = c.mission
    where c.user = #{req.session.userId} or c.user is null
    order by m.name"""
  .then (resp) ->
    console.log "resp: ", resp
    res.render 'missions',
      done: _.map _.filter(resp[0], (row) -> row.completed isnt 0), (row) -> row.name
      possible: _.map _.filter(resp[0], (row) -> row.completed is 0), (row) -> row.name

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
    .delete()
    .then ->
      res.send(200)

exports.setup = (app) ->
  app.get('/', index)
  app.post('/setusername', setusername)
  app.get('/newfloors', newfloors)
  app.post('/addfloor', addfloor)
  app.get('/missions', missions)
  app.post('/togglemission', togglemission)
