{knex} = require 'knex'

index = (req, res) ->
  id = req.session.userId
  if id
    knex('users').where(id:id).then (resp) ->
      res.render 'index',
        title: 'Express'
        user: resp[0]
  else
    knex('users').insert(name:'').then (resp) ->
      req.session.userId = resp[0]
      res.redirect("/")

exports.setup = (app) ->
  app.get('/', index)
