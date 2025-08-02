const express = require("express");
const authControllerRoute = require("./authRoute");
const indexRoute = express.Router();

indexRoute.use('/auth',authControllerRoute);

module.exports = indexRoute;