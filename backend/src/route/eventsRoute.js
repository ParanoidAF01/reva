import express from "express";
import {
    createEvent,
    getAllEvents,
    getEventById,
    updateEvent,
    deleteEvent,
    registerForEvent,
    unregisterFromEvent,
    getMyEvents,
    getMyOrganizedEvents
} from "../controllers/eventsController.js";
import { requireAdmin, verifyJWT } from "../middlewares/authMiddleware.js";

const eventsRoute = express.Router();

eventsRoute.use(verifyJWT);

eventsRoute.post("/", requireAdmin, createEvent);
eventsRoute.get("/", getAllEvents);
eventsRoute.get("/me", getMyEvents);
eventsRoute.get("/organized", requireAdmin, getMyOrganizedEvents);
eventsRoute.get("/:eventId", getEventById);
eventsRoute.put("/:eventId", requireAdmin, updateEvent);
eventsRoute.delete("/:eventId", requireAdmin, deleteEvent);

eventsRoute.post("/:eventId/register", registerForEvent);
eventsRoute.delete("/:eventId/register", unregisterFromEvent);

export default eventsRoute; 