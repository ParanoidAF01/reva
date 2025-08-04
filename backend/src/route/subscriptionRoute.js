import express from "express";
import {
    checkSubscription,
    createSubscription,
    cancelSubscription,
    getSubscriptionHistory
} from "../controllers/subscriptionController.js";
import { verifyJWT } from "../middlewares/authMiddleware.js";

const subscriptionRoute = express.Router();

subscriptionRoute.use(verifyJWT);

subscriptionRoute.get("/check", checkSubscription);
subscriptionRoute.post("/create", createSubscription);
subscriptionRoute.post("/cancel", cancelSubscription);
subscriptionRoute.get("/history", getSubscriptionHistory);

export default subscriptionRoute; 