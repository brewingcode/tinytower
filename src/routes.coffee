{knex} = require 'knex'

index = (req, res) ->
  id = req.session.userId
  if id
    knex('users')
    .join('towers', 'users.id', '=', 'towers.floor')
    .join('floors', 'towers.floor', '=', 'floors.id')
    # .where("users.id", "=", id)
    .then (resp) ->
      console.log "resp: ", resp
      res.render 'index',
        title: 'Express'
        user: resp[0]
        floors: []
  else
    knex('users').insert(name:'').then (resp) ->
      req.session.userId = resp[0]
      res.redirect("/")

exports.setup = (app) ->
  app.get('/', index)
