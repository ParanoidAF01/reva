import express from "express";
import {
    requestNFCCard,
    getMyNFCCardStatus,
    getAllNFCCardRequests,
    approveNFCCardRequest,
    rejectNFCCardRequest,
    deactivateNFCCard,
    getNFCCardStats
} from "../controllers/nfcCardController.js";
import { verifyJWT, requireAdmin } from "../middlewares/authMiddleware.js";
import { asyncHandler } from "../middlewares/errorHandler.js";

const nfcCardRoute = express.Router();

nfcCardRoute.post('/request', verifyJWT, asyncHandler(requestNFCCard));
nfcCardRoute.get('/my-status', verifyJWT, asyncHandler(getMyNFCCardStatus));

nfcCardRoute.get('/all-requests', verifyJWT, requireAdmin, asyncHandler(getAllNFCCardRequests));
nfcCardRoute.put('/approve/:cardId', verifyJWT, requireAdmin, asyncHandler(approveNFCCardRequest));
nfcCardRoute.put('/reject/:cardId', verifyJWT, requireAdmin, asyncHandler(rejectNFCCardRequest));
nfcCardRoute.put('/deactivate/:cardId', verifyJWT, requireAdmin, asyncHandler(deactivateNFCCard));
nfcCardRoute.get('/stats', verifyJWT, requireAdmin, asyncHandler(getNFCCardStats));

export default nfcCardRoute; 