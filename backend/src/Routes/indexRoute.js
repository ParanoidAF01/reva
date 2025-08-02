import express from "express";
import authControllerRoute from "./authRoute.js";

const indexRoute = express.Router();

indexRoute.use('/auth',authControllerRoute);

export default indexRoute;