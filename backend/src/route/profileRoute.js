import express from "express";
import {
    getMyProfile,
    getProfileById,
    updateProfile,
    getAllProfiles
} from "../controllers/profileController.js";
import { requireAdmin, verifyJWT } from "../middlewares/authMiddleware.js";

const profileRoute = express.Router();

profileRoute.use(verifyJWT);

profileRoute.get("/me", getMyProfile);
profileRoute.get("/all", requireAdmin, getAllProfiles);
profileRoute.get("/:userId", getProfileById);
profileRoute.put("/", updateProfile);

export default profileRoute; 