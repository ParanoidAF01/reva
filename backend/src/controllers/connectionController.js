import User from "../models/user.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";

const connectViaQR = asyncHandler(async (req, res) => {
    const currentUserId = req.user._id;

    const { mobileNumber } = req.query;
    if (!mobileNumber) {
        throw new ApiError(400, "Mobile number is required");
    }

    const mobileRegex = /^[0-9]{10}$/;
    if (!mobileRegex.test(mobileNumber)) {
        throw new ApiError(400, "Please enter a valid 10-digit mobile number");
    }

    const targetUser = await User.findOne({ mobileNumber }).select('_id fullName mobileNumber connections');
    if (!targetUser) {
        throw new ApiError(404, "User with this mobile number not found");
    }
    if (targetUser._id.toString() === currentUserId.toString()) {
        throw new ApiError(400, "You cannot connect with yourself");
    }

    const currentUser = await User.findById(currentUserId).select('connections');
    if (currentUser.connections.includes(targetUser._id)) {
        throw new ApiError(400, "You are already connected with this user");
    }

    await User.findByIdAndUpdate(currentUserId, {
        $push: { connections: targetUser._id }
    });

    await User.findByIdAndUpdate(targetUser._id, {
        $push: { connections: currentUserId }
    });

    return res.status(200).json(
        new ApiResponse(200, {
            message: "Connection established successfully",
            connectedUser: {
                _id: targetUser._id,
                fullName: targetUser.fullName,
                mobileNumber: targetUser.mobileNumber
            },
        }, "Connection established successfully")
    );
});

const getMyConnections = asyncHandler(async (req, res) => {
    const currentUserId = req.user._id;
    const { page = 1, limit = 10, search } = req.query;

    const user = await User.findById(currentUserId)
        .populate({
            path: 'connections',
            select: 'fullName mobileNumber profilePicture profile',
            populate: {
                path: 'profile',
                select: 'designation location organization'
            }
        })
        .select('connections');

    if (!user) {
        throw new ApiError(404, "User not found");
    }

    let connections = user.connections;

    if (search) {
        connections = connections.filter(connection =>
            connection.fullName.toLowerCase().includes(search.toLowerCase()) ||
            connection.mobileNumber.includes(search)
        );
    }

    const startIndex = (page - 1) * limit;
    const endIndex = page * limit;
    const paginatedConnections = connections.slice(startIndex, endIndex);

    return res.status(200).json(
        new ApiResponse(200, {
            connections: paginatedConnections,
            totalConnections: connections.length,
            currentPage: parseInt(page),
            totalPages: Math.ceil(connections.length / limit)
        }, "Connections retrieved successfully")
    );
});

const removeConnection = asyncHandler(async (req, res) => {
    const currentUserId = req.user._id;
    const { connectionId } = req.params;

    if (!connectionId) {
        throw new ApiError(400, "Connection ID is required");
    }

    const currentUser = await User.findById(currentUserId).select('connections');
    if (!currentUser.connections.includes(connectionId)) {
        throw new ApiError(404, "Connection not found");
    }

    await User.findByIdAndUpdate(currentUserId, {
        $pull: { connections: connectionId }
    });

    await User.findByIdAndUpdate(connectionId, {
        $pull: { connections: currentUserId }
    });

    return res.status(200).json(
        new ApiResponse(200, {}, "Connection removed successfully")
    );
});

const getConnectionSuggestions = asyncHandler(async (req, res) => {
    const currentUserId = req.user._id;
    const { page = 1, limit = 10, search } = req.query;

    const currentUser = await User.findById(currentUserId).select('connections');
    if (!currentUser) {
        throw new ApiError(404, "User not found");
    }

    const query = {
        _id: {
            $nin: [...currentUser.connections, currentUserId]
        }
    };

    if (search) {
        query.$or = [
            { fullName: { $regex: search, $options: 'i' } },
            { mobileNumber: { $regex: search, $options: 'i' } }
        ];
    }

    const suggestions = await User.find(query)
        .select('fullName mobileNumber profilePicture profile')
        .populate('profile', 'designation location organization')
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await User.countDocuments(query);

    return res.status(200).json(
        new ApiResponse(200, {
            suggestions,
            totalSuggestions: count,
            currentPage: parseInt(page),
            totalPages: Math.ceil(count / limit)
        }, "Connection suggestions retrieved successfully")
    );
});

const getConnectionCount = asyncHandler(async (req, res) => {
    const currentUserId = req.user._id;

    const user = await User.findById(currentUserId).select('connections');
    if (!user) {
        throw new ApiError(404, "User not found");
    }

    return res.status(200).json(
        new ApiResponse(200, {
            connectionCount: user.connections.length
        }, "Connection count retrieved successfully")
    );
});

export {
    connectViaQR,
    getMyConnections,
    removeConnection,
    getConnectionSuggestions,
    getConnectionCount
}; 