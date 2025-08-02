const express = require("express");
const authController = require("../controllers/authController");
const authcheck = require("../middelwares/authMiddelware");
const authRoute = express.Router();

authRoute.post('/register',authController.Register); // done
authRoute.post('/login',authController.login); //done
authRoute.post('/sendOtp',authController.sendOtp);
authRoute.post('/sendOtp',authController.verifyOtp);
authRoute.post('/forgotPassword',authcheck,authController.forgotPassword); //done
authRoute.post('/logout',authcheck,authController.logout);
authRoute.post('/refreshtoken',authcheck,authController.refreshingacesstoken);


module.exports= authRoute;