import express from "express";
import authControllerRoute from "./authRoute.js";
import profileRoute from "./profileRoute.js";
import postsRoute from "./postsRoute.js";
import eventsRoute from "./eventsRoute.js";
import connectionRoute from "./connectionRoute.js";
import notificationRoute from "./notificationRoute.js";
import subscriptionRoute from "./subscriptionRoute.js";
import transactionRoute from "./transactionRoute.js";
import nfcCardRoute from "./nfcCardRoute.js";
import aadhaarRoute from "./aadhaarRoute.js";

const indexRoute = express.Router();

indexRoute.use('/auth', authControllerRoute);
indexRoute.use('/profiles', profileRoute);
indexRoute.use('/posts', postsRoute);
indexRoute.use('/events', eventsRoute);
indexRoute.use('/connections', connectionRoute);
indexRoute.use('/notifications', notificationRoute);
indexRoute.use('/subscriptions', subscriptionRoute);
indexRoute.use('/transactions', transactionRoute);
indexRoute.use('/nfc-cards', nfcCardRoute);
indexRoute.use('/aadhaar', aadhaarRoute);

export default indexRoute;