import express from "express";
import { generateAadhaarOtp, submitAadhaarOtp } from "../controllers/aadhaarController.js";
import { verifyJWT } from "../middlewares/authMiddleware.js";

const aadhaarRoute = express.Router();

aadhaarRoute.post("/generate-otp", verifyJWT, generateAadhaarOtp);
aadhaarRoute.post("/submit-otp", verifyJWT, submitAadhaarOtp);

export default aadhaarRoute;
