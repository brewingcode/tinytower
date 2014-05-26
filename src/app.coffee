
###
Module dependencies.
###
express = require("express")
http = require("http")
path = require("path")
store = require("connect-sqlite3")(express)
Knex = require("knex")

app = express()

Knex.knex = Knex.initialize
  client: 'sqlite3'
  connection:
    filename: '.app/data.db'
  debug: true

# all environments
app.use express.cookieParser()
app.use express.session
  store: new store
    dir: ".app"
    db: "data"
  secret: "f8d17b3f29390a9c842b"

app.set "port", process.env.PORT or 3000
app.set "views", path.join(__dirname, "../views")
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "../public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

# routes
routes = require("./routes")
routes.setup(app)

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
  return

