{knex} = require 'knex'

index = (req, res) ->
  id = req.session.userId
  if id
    knex.raw """
      select u.name as username, t.story, f.name
      from users u
      inner join towers t on t.user = u.id
      inner join floors f on f.name = t.floor
      where u.id = #{id}
      order by t.story desc
    """
    .then (resp) ->
      console.log "resp: ", resp
      if resp.length
        res.render 'index',
          title: 'Express'
          username: resp[0][0].username
          floors: resp[0]
      else
        res.send(500, 'unable to get a user')
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

exports.setup = (app) ->
  app.get('/', index)
  app.post('/setusername', setusername)
