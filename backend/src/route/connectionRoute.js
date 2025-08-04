import express from "express";
import {
    connectViaQR,
    getMyConnections,
    removeConnection,
    getConnectionSuggestions,
    getConnectionCount,
    sendConnectionRequest,
    getPendingRequests,
    respondToConnectionRequest,
    getSentRequests
} from "../controllers/connectionController.js";
import { verifyJWT } from "../middlewares/authMiddleware.js";

const connectionRoute = express.Router();

connectionRoute.use(verifyJWT);

connectionRoute.get("/qr", connectViaQR);
connectionRoute.get("/", getMyConnections);
connectionRoute.get("/count", getConnectionCount);
connectionRoute.get("/suggestions", getConnectionSuggestions);
connectionRoute.delete("/:connectionId", removeConnection);

connectionRoute.post("/request", sendConnectionRequest);
connectionRoute.get("/pending-requests", getPendingRequests);
connectionRoute.put("/request/:requestId/respond", respondToConnectionRequest);
connectionRoute.get("/sent-requests", getSentRequests);

export default connectionRoute; 