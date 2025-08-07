import express from "express";
import { generateAadhaarOtp, submitAadhaarOtp } from "../controllers/aadhaarController.js";

const aadhaarRoute = express.Router();

aadhaarRoute.post("/generate-otp", generateAadhaarOtp);
aadhaarRoute.post("/submit-otp", submitAadhaarOtp);

export default aadhaarRoute;
