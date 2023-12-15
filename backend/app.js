var express = require("express");
var cookieParser = require("cookie-parser");
var logger = require("morgan");
const path = require("path");

const session = require("express-session");
const MySQLStore = require("express-mysql-session")(session);
require("dotenv").config();

var app = express();

const filesRouter = require("./routes/filesRouter");
const usersRouter = require("./routes/usersRouter");
const postsRouter = require("./routes/postsRouter");
const followsRouter = require("./routes/followRouter");
const messagesRouter = require("./routes/messagesRouter");

const options = {
  host: "localhost",
  port: 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PW,
  database: "instagram",
};

const sessionStore = new MySQLStore(options);

app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    store: sessionStore,
    saveUninitialized: true,
    cookie: {
      httpOnly: false,
      maxAge: 24 * 3600 * 1000 * 30, //1 month of saved cookie
    },
  })
);

sessionStore
  .onReady()
  .then(() => {
    console.log("MySQLStore ready");
  })
  .catch((error) => {
    console.error(error);
  });

app.use(logger("dev"));
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

app.get("/", (req, res) => {
  res.send("Welcome!");
});

app.use("/media", filesRouter);
app.use("/user", usersRouter);
app.use("/posts", postsRouter);
app.use("/follows", followsRouter);
app.use("/messages", messagesRouter);

module.exports = app;
