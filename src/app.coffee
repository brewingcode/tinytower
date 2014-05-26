
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
store = require("connect-sqlite3")(express)
app = express()

# all environments
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

app.use express.cookieParser()
app.use express.session
  store: new store,
  secret: "f8d17b3f29390a9c842b"

# development only
app.use express.errorHandler()  if "development" is app.get("env")

routes.setup(app)
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
  return

