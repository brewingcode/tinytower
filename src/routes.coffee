{knex} = require 'knex'

index = (req, res) ->
  id = req.session.userId
  if id
    knex('users')
    .join('towers', 'users.id', '=', 'towers.user')
    .join('floors', 'towers.floor', '=', 'floors.id', 'left')
    .where("users.id", "=", id)
    .then (resp) ->
      console.log "resp: ", resp
      if resp.length
        res.render 'index',
          title: 'Express'
          user: resp[0]
          floors: resp
      else
        res.send(500, 'unable to get a user')
  else
    knex('users').insert(name:'').then (resp) ->
      req.session.userId = resp[0]
      knex('towers').insert(user:resp[0], floor:1, story:1).then ->
        res.redirect("/")

exports.setup = (app) ->
  app.get('/', index)
