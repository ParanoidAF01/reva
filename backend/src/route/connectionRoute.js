import express from "express";
import {
    connectViaQR,
    getMyConnections,
    removeConnection,
    getConnectionSuggestions,
    getConnectionCount
} from "../controllers/connectionController.js";
import { verifyJWT } from "../middlewares/authMiddleware.js";

const connectionRoute = express.Router();

connectionRoute.use(verifyJWT);

connectionRoute.get("/qr", connectViaQR);
connectionRoute.get("/", getMyConnections);
connectionRoute.get("/count", getConnectionCount);
connectionRoute.get("/suggestions", getConnectionSuggestions);
connectionRoute.delete("/:connectionId", removeConnection);

export default connectionRoute; 