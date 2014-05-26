{knex} = require 'knex'

index = (req, res) ->
  id = req.session.userId
  if id
    showUser(id, req, res)
  else
    knex('users').insert(name:'').then (resp) ->
      id = resp[0]
      req.session.userId = id
      showUser(id, req, res)

showUser = (id, req, res) ->
  console.log "getting user: ", id
  knex('users').where(id:id).then (resp) ->
    console.log "resp: ", resp
    res.render 'index',
      title: 'Express'
      user: resp[0]

exports.setup = (app) ->
  app.get('/', index)
  