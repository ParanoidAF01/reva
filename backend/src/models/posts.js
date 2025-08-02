import mongoose from "mongoose";

const postsSchema = mongoose.Schema({
    author: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Users",
        required: true
    },
    content: {
        type: String,
        required: true,
        trim: true
    },
    images: [{
        type: String
    }],
    videos: [{
        type: String
    }],
    tags: [{
        type: String,
        trim: true
    }],
    category: {
        type: String,
        enum: ['General', 'Business', 'Technology', 'Health', 'Education', 'Entertainment', 'Sports', 'Other'],
        default: 'General'
    },
    likes: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Users"
    }],
    comments: [{
        user: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Users",
            required: true
        },
        content: {
            type: String,
            required: true
        },
        createdAt: {
            type: Date,
            default: Date.now
        }
    }],
    shares: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Users"
    }],
}, {
    timestamps: true
});

const Posts = mongoose.model("Posts", postsSchema);

export default Posts; 