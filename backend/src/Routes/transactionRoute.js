import express from "express";
import {
    createTransaction,
    getAllTransactions,
    getTransactionById,
    getTransactionStats
} from "../controllers/transactionController.js";
import { verifyJWT } from "../middlewares/authMiddleware.js";

const transactionRoute = express.Router();

transactionRoute.use(verifyJWT);

transactionRoute.post("/", createTransaction);
transactionRoute.get("/", getAllTransactions);
transactionRoute.get("/stats", getTransactionStats);
transactionRoute.get("/:transactionId", getTransactionById);

export default transactionRoute; 