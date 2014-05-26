{knex} = require 'knex'

index = (req, res) ->
  id = req.session.userId
  if id
    knex.raw """
      select u.name as user, t.story, f.name, f.id
      from users u
      inner join towers t on t.user = u.id
      inner join floors f on f.id = t.floor
      where u.id = #{id}
      order by t.story desc
    """
    .then (resp) ->
      console.log "resp: ", resp
      if resp.length
        res.render 'index',
          title: 'Express'
          user: {name: resp[0]['user']}
          floors: resp[0]
      else
        res.send(500, 'unable to get a user')
  else
    knex('users').insert(name:'').then (resp) ->
      req.session.userId = resp[0]
      knex('towers').insert(user:resp[0], floor:1, story:1).then ->
        res.redirect("/")

exports.setup = (app) ->
  app.get('/', index)
