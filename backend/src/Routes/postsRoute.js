import express from "express";
import {
    createPost,
    getAllPosts,
    getPostById,
    updatePost,
    deletePost,
    toggleLike,
    addComment,
    deleteComment,
    getMyPosts
} from "../controllers/postsController.js";
import { verifyJWT } from "../middlewares/authMiddleware.js";

const postsRoute = express.Router();

postsRoute.use(verifyJWT);

postsRoute.post("/", createPost);
postsRoute.get("/", getAllPosts);
postsRoute.get("/me", getMyPosts);
postsRoute.get("/:postId", getPostById);
postsRoute.put("/:postId", updatePost);
postsRoute.delete("/:postId", deletePost);

postsRoute.post("/:postId/like", toggleLike);
postsRoute.post("/:postId/comments", addComment);
postsRoute.delete("/:postId/comments/:commentId", deleteComment);

export default postsRoute; 