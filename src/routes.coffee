index = (req, res) ->
  res.render 'index',
    title: 'Express'

exports.setup = (app) ->
  app.get('/', index)
