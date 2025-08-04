import express from "express";
import {
    createNotification,
    getMyNotifications,
    getNotificationById,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    deleteAllNotifications,
    sendSystemNotification,
    sendEventNotification,
    getNotificationStats
} from "../controllers/notificationController.js";
import { verifyJWT, requireAdmin } from "../middlewares/authMiddleware.js";

const notificationRoute = express.Router();

notificationRoute.use(verifyJWT);

notificationRoute.get("/me", getMyNotifications);
notificationRoute.get("/stats", getNotificationStats);
notificationRoute.get("/:notificationId", getNotificationById);

notificationRoute.patch("/:notificationId/read", markAsRead);
notificationRoute.patch("/mark-all-read", markAllAsRead);

notificationRoute.delete("/:notificationId", deleteNotification);
notificationRoute.delete("/delete-all", deleteAllNotifications);

notificationRoute.post("/create", requireAdmin, createNotification);

notificationRoute.post("/system", requireAdmin, sendSystemNotification);
notificationRoute.post("/event", requireAdmin, sendEventNotification);

export default notificationRoute; 