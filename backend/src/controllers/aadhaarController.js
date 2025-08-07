import axios from "axios";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import env from "../utils/consts.js";
import { mask } from "../utils/helpers.js";

const QUICK_EKYC_API_KEY = env.aadhaar.key;
const QUICK_EKYC_API_URL = env.aadhaar.url;

export const generateAadhaarOtp = async (req, res, next) => {
    try {
        const { id_number } = req.body;
        if (!id_number) {
            throw new ApiError(400, "Aadhaar number is required");
        }
        const response = await axios.post(
            `${QUICK_EKYC_API_URL}/generate-otp`,
            {
                key: QUICK_EKYC_API_KEY,
                id_number
            },
            {
                headers: { "Content-Type": "application/json" }
            }
        );

        return res.status(200).json(new ApiResponse(200, response.data, "Aadhaar OTP request sent"));
    } catch (error) {
        if (error.response) {
            return res.status(error.response.status).json(new ApiError(error.response.status, error.response.data?.message || "Aadhaar OTP generation failed"));
        }
        next(error);
    }
};

export const submitAadhaarOtp = async (req, res, next) => {
    try {
        const { request_id, otp } = req.body;
        if (!request_id || !otp) {
            throw new ApiError(400, "Both request_id and otp are required");
        }
        const response = await axios.post(
            `${QUICK_EKYC_API_URL}/submit-otp`,
            {
                key: QUICK_EKYC_API_KEY,
                request_id,
                otp
            },
            {
                headers: { "Content-Type": "application/json" }
            }
        );

        return res.status(200).json(new ApiResponse(200, response.data, "Aadhaar OTP submitted"));
    } catch (error) {
        if (error.response) {
            return res.status(error.response.status).json(new ApiError(error.response.status, error.response.data?.message || "Aadhaar OTP submission failed"));
        }
        next(error);
    }
};
