import Posts from "../models/posts.js";
import User from "../models/user.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import {
    sendPostLikeNotification,
    sendPostCommentNotification,
    sendPostShareNotification,
    sendPostMentionNotification
} from "../utils/notificationService.js";

const createPost = asyncHandler(async (req, res) => {
    const userId = req.user._id;

    const postData = {
        author: userId,
        ...req.body
    };

    const post = await Posts.create(postData);

    await User.findByIdAndUpdate(userId, { $push: { posts: post._id } });

    const populatedPost = await Posts.findById(post._id)
        .populate('author', 'fullName email profilePicture');

    return res.status(201).json(
        new ApiResponse(201, populatedPost, "Post created successfully")
    );
});

const getAllPosts = asyncHandler(async (req, res) => {
    const { page = 1, limit = 10, category, author } = req.query;

    const query = {};
    if (category) query.category = category;
    if (author) query.author = author;

    const posts = await Posts.find(query)
        .populate('author', 'fullName email profilePicture')
        .populate('likes', 'fullName')
        .populate('comments.user', 'fullName profilePicture')
        .sort({ createdAt: -1 })
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await Posts.countDocuments(query);

    return res.status(200).json(
        new ApiResponse(200, {
            posts,
            totalPages: Math.ceil(count / limit),
            currentPage: page,
            totalPosts: count
        }, "Posts retrieved successfully")
    );
});

const getPostById = asyncHandler(async (req, res) => {
    const { postId } = req.params;

    const post = await Posts.findById(postId)
        .populate('author', 'fullName email profilePicture')
        .populate('likes', 'fullName')
        .populate('comments.user', 'fullName profilePicture');

    if (!post) {
        throw new ApiError(404, "Post not found");
    }

    return res.status(200).json(
        new ApiResponse(200, post, "Post retrieved successfully")
    );
});

const updatePost = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { postId } = req.params;

    const post = await Posts.findById(postId);
    if (!post) {
        throw new ApiError(404, "Post not found");
    }

    if (post.author.toString() !== userId.toString()) {
        throw new ApiError(403, "You can only update your own posts");
    }

    const updatedPost = await Posts.findByIdAndUpdate(
        postId,
        { $set: req.body },
        { new: true, runValidators: true }
    ).populate('author', 'fullName email profilePicture');

    return res.status(200).json(
        new ApiResponse(200, updatedPost, "Post updated successfully")
    );
});

const deletePost = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { postId } = req.params;

    const post = await Posts.findById(postId);
    if (!post) {
        throw new ApiError(404, "Post not found");
    }

    if (post.author.toString() !== userId.toString()) {
        throw new ApiError(403, "You can only delete your own posts");
    }

    await Posts.findByIdAndDelete(postId);

    await User.findByIdAndUpdate(userId, { $pull: { posts: postId } });

    return res.status(200).json(
        new ApiResponse(200, {}, "Post deleted successfully")
    );
});

const toggleLike = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { postId } = req.params;

    const post = await Posts.findById(postId);
    if (!post) {
        throw new ApiError(404, "Post not found");
    }

    const isLiked = post.likes.includes(userId);

    if (isLiked) {
        await Posts.findByIdAndUpdate(postId, { $pull: { likes: userId } });
    } else {
        await Posts.findByIdAndUpdate(postId, { $push: { likes: userId } });

        // Send notification to post author when someone likes their post
        if (post.author.toString() !== userId.toString()) {
            try {
                const currentUser = await User.findById(userId).select('fullName');
                await sendPostLikeNotification(
                    post.author,
                    userId,
                    currentUser.fullName,
                    post.title || 'Your post'
                );
            } catch (error) {
                console.error('Failed to send like notification:', error);
            }
        }
    }

    const updatedPost = await Posts.findById(postId)
        .populate('author', 'fullName email profilePicture')
        .populate('likes', 'fullName');

    return res.status(200).json(
        new ApiResponse(200, updatedPost, `Post ${isLiked ? 'unliked' : 'liked'} successfully`)
    );
});

const addComment = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { postId } = req.params;
    const { content } = req.body;

    if (!content || content.trim() === '') {
        throw new ApiError(400, "Comment content is required");
    }

    const post = await Posts.findById(postId);
    if (!post) {
        throw new ApiError(404, "Post not found");
    }

    const comment = {
        user: userId,
        content: content.trim()
    };

    await Posts.findByIdAndUpdate(postId, { $push: { comments: comment } });

    // Send notification to post author when someone comments on their post
    if (post.author.toString() !== userId.toString()) {
        try {
            const currentUser = await User.findById(userId).select('fullName');
            await sendPostCommentNotification(
                post.author,
                userId,
                currentUser.fullName,
                post.title || 'Your post'
            );
        } catch (error) {
            console.error('Failed to send comment notification:', error);
        }
    }

    const updatedPost = await Posts.findById(postId)
        .populate('author', 'fullName email profilePicture')
        .populate('comments.user', 'fullName profilePicture');

    return res.status(200).json(
        new ApiResponse(200, updatedPost, "Comment added successfully")
    );
});

const deleteComment = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { postId, commentId } = req.params;

    const post = await Posts.findById(postId);
    if (!post) {
        throw new ApiError(404, "Post not found");
    }

    const comment = post.comments.id(commentId);
    if (!comment) {
        throw new ApiError(404, "Comment not found");
    }

    if (comment.user.toString() !== userId.toString() &&
        post.author.toString() !== userId.toString()) {
        throw new ApiError(403, "You can only delete your own comments or comments on your posts");
    }

    await Posts.findByIdAndUpdate(postId, { $pull: { comments: { _id: commentId } } });

    const updatedPost = await Posts.findById(postId)
        .populate('author', 'fullName email profilePicture')
        .populate('comments.user', 'fullName profilePicture');

    return res.status(200).json(
        new ApiResponse(200, updatedPost, "Comment deleted successfully")
    );
});

const getMyPosts = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { page = 1, limit = 10 } = req.query;

    const posts = await Posts.find({ author: userId })
        .populate('author', 'fullName email profilePicture')
        .populate('likes', 'fullName')
        .populate('comments.user', 'fullName profilePicture')
        .sort({ createdAt: -1 })
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await Posts.countDocuments({ author: userId });

    return res.status(200).json(
        new ApiResponse(200, {
            posts,
            totalPages: Math.ceil(count / limit),
            currentPage: page,
            totalPosts: count
        }, "Your posts retrieved successfully")
    );
});

export {
    createPost,
    getAllPosts,
    getPostById,
    updatePost,
    deletePost,
    toggleLike,
    addComment,
    deleteComment,
    getMyPosts
}; 