{knex} = require 'knex'
_ = require 'underscore'

index = (req, res) ->
  id = req.session.userId
  if id?
    knex.raw("""
      select u.id, u.name as username, t.story, f.name
      from floors f
      left join towers t on f.name = t.floor
      left join users u on u.id = t.user
      order by t.story desc
  """).then (resp) ->
      user = _.find resp[0], (row) -> row.id is id
      if user
        res.render 'index',
          title: 'Express'
          username: user.username
          userFloors: _.filter resp[0], (row) -> row.id is id
          newFloors: _.map _.filter(resp[0], (row) -> row.id isnt id), (row) -> row.name
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

exports.setup = (app) ->
  app.get('/', index)
  app.post('/setusername', setusername)
  app.get('/newfloors', newfloors)
  app.post('/addfloor', addfloor)
