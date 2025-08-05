import User from "../models/user.js";
import ConnectionRequest from "../models/connectionRequest.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import {
    sendConnectionRequestNotification,
    sendConnectionAcceptedNotification,
    sendConnectionRemovedNotification
} from "../utils/notificationService.js";

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

    const pendingRequests = await ConnectionRequest.find({
        $or: [
            { fromUser: currentUserId, status: "pending" },
            { toUser: currentUserId, status: "pending" }
        ]
    });

    const pendingUserIds = pendingRequests.map(request => {
        if (request.fromUser.toString() === currentUserId.toString()) {
            return request.toUser;
        } else {
            return request.fromUser;
        }
    });

    const query = {
        _id: {
            $nin: [...currentUser.connections, currentUserId, ...pendingUserIds]
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

const sendConnectionRequest = asyncHandler(async (req, res) => {
    const currentUserId = req.user._id;
    if (!currentUserId) {
        throw new ApiError(400, "User ID is required");
    }

    const { toUserId } = req.body;
    if (!toUserId) {
        throw new ApiError(400, "User ID is required");
    }

    const targetUser = await User.findById(toUserId).select('_id fullName mobileNumber');
    if (!targetUser) {
        throw new ApiError(404, "User not found");
    }

    if (targetUser._id.toString() === currentUserId.toString()) {
        throw new ApiError(400, "You cannot send connection request to yourself");
    }

    const currentUser = await User.findById(currentUserId).select('connections');
    if (currentUser.connections.includes(targetUser._id)) {
        throw new ApiError(400, "You are already connected with this user");
    }

    const existingRequest = await ConnectionRequest.findOne({
        $or: [
            { fromUser: currentUserId, toUser: toUserId },
            { fromUser: toUserId, toUser: currentUserId }
        ]
    });

    if (existingRequest) {
        if (existingRequest.status === "pending") {
            throw new ApiError(400, "Connection request already exists");
        } else if (existingRequest.status === "accepted") {
            throw new ApiError(400, "You are already connected with this user");
        }
    }

    const connectionRequest = await ConnectionRequest.create({
        fromUser: currentUserId,
        toUser: toUserId,
    });

    await connectionRequest.populate([
        {
            path: 'fromUser',
            select: 'fullName mobileNumber profilePicture'
        },
        {
            path: 'toUser',
            select: 'fullName mobileNumber profilePicture'
        }
    ]);

    // Send notification to the target user
    try {
        await sendConnectionRequestNotification(
            toUserId,
            currentUserId,
            connectionRequest.fromUser.fullName
        );
    } catch (error) {
        console.error('Failed to send connection request notification:', error);
    }

    return res.status(201).json(
        new ApiResponse(201, {
            connectionRequest: {
                _id: connectionRequest._id,
                fromUser: connectionRequest.fromUser,
                toUser: connectionRequest.toUser,
                status: connectionRequest.status,
            }
        }, "Connection request sent successfully")
    );
});

const getPendingRequests = asyncHandler(async (req, res) => {
    const currentUserId = req.user._id;
    if (!currentUserId) {
        throw new ApiError(400, "User ID is required");
    }

    const { page = 1, limit = 10 } = req.query;

    const query = {
        toUser: currentUserId,
        status: "pending"
    };

    const pendingRequests = await ConnectionRequest.find(query)
        .populate({
            path: 'fromUser',
            select: 'fullName mobileNumber profilePicture profile',
            populate: {
                path: 'profile',
                select: 'designation location organization'
            }
        })
        .sort({ createdAt: -1 })
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await ConnectionRequest.countDocuments(query);

    return res.status(200).json(
        new ApiResponse(200, {
            pendingRequests,
            totalPendingRequests: count,
            currentPage: parseInt(page),
            totalPages: Math.ceil(count / limit)
        }, "Pending connection requests retrieved successfully")
    );
});

const respondToConnectionRequest = asyncHandler(async (req, res) => {
    const currentUserId = req.user._id;
    const { requestId } = req.params;
    const { action } = req.body;

    if (!requestId) {
        throw new ApiError(400, "Request ID is required");
    }

    if (!action || !["accept", "reject"].includes(action)) {
        throw new ApiError(400, "Action must be either 'accept' or 'reject'");
    }

    const connectionRequest = await ConnectionRequest.findOne({
        _id: requestId,
        toUser: currentUserId,
        status: "pending"
    }).populate('fromUser toUser');

    if (!connectionRequest) {
        throw new ApiError(404, "Connection request not found");
    }

    if (action === "accept") {
        connectionRequest.status = "accepted";
        await connectionRequest.save();

        await User.findByIdAndUpdate(currentUserId, {
            $push: { connections: connectionRequest.fromUser._id }
        });

        await User.findByIdAndUpdate(connectionRequest.fromUser._id, {
            $push: { connections: currentUserId }
        });

        // Send notification to the sender that their request was accepted
        try {
            await sendConnectionAcceptedNotification(
                connectionRequest.fromUser._id,
                currentUserId,
                connectionRequest.toUser.fullName
            );
        } catch (error) {
            console.error('Failed to send connection accepted notification:', error);
        }

        return res.status(200).json(
            new ApiResponse(200, {
                message: "Connection request accepted",
                connectionRequest
            }, "Connection request accepted successfully")
        );
    } else {
        connectionRequest.status = "rejected";
        await connectionRequest.save();

        return res.status(200).json(
            new ApiResponse(200, {
                message: "Connection request rejected",
                connectionRequest
            }, "Connection request rejected successfully")
        );
    }
});

const getSentRequests = asyncHandler(async (req, res) => {
    const currentUserId = req.user._id;
    const { page = 1, limit = 10, status } = req.query;

    const query = {
        fromUser: currentUserId
    };

    if (status && ["pending", "accepted", "rejected"].includes(status)) {
        query.status = status;
    }

    const sentRequests = await ConnectionRequest.find(query)
        .populate({
            path: 'toUser',
            select: 'fullName mobileNumber profilePicture profile',
            populate: {
                path: 'profile',
                select: 'designation location organization'
            }
        })
        .sort({ createdAt: -1 })
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await ConnectionRequest.countDocuments(query);

    return res.status(200).json(
        new ApiResponse(200, {
            sentRequests,
            totalSentRequests: count,
            currentPage: parseInt(page),
            totalPages: Math.ceil(count / limit)
        }, "Sent connection requests retrieved successfully")
    );
});

export {
    connectViaQR,
    getMyConnections,
    removeConnection,
    getConnectionSuggestions,
    getConnectionCount,
    sendConnectionRequest,
    getPendingRequests,
    respondToConnectionRequest,
    getSentRequests
}; 