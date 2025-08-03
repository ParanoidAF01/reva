import express from "express";
import authControllerRoute from "./authRoute.js";
import profileRoute from "./profileRoute.js";
import postsRoute from "./postsRoute.js";
import eventsRoute from "./eventsRoute.js";
import connectionRoute from "./connectionRoute.js";
import notificationRoute from "./notificationRoute.js";

const indexRoute = express.Router();

indexRoute.use('/auth', authControllerRoute);
indexRoute.use('/profiles', profileRoute);
indexRoute.use('/posts', postsRoute);
indexRoute.use('/events', eventsRoute);
indexRoute.use('/connections', connectionRoute);
indexRoute.use('/notifications', notificationRoute);

export default indexRoute;