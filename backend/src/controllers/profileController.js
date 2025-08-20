import Profile from "../models/profile.js";
import User from "../models/user.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { maskAfterX } from "../utils/helpers.js";
import { sendProfileUpdateNotification } from "../utils/notificationService.js";

const getMyProfile = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    if (!userId) {
        throw new ApiError(401, "User not found");
    }

    const profile = await Profile.findOne({ user: userId })
        .populate('user', 'fullName email mobileNumber status connections eventsAttended');
    if (!profile) {
        throw new ApiError(404, "Profile not found");
    }

    return res.status(200).json(
        new ApiResponse(200, profile, "Profile retrieved successfully")
    );
});

const getProfileById = asyncHandler(async (req, res) => {
    const { userId } = req.params;
    if (!userId) {
        throw new ApiError(400, "User ID is required");
    }

    const currentUserId = req.user._id;
    if (!currentUserId) {
        throw new ApiError(401, "User not found");
    }

    const profile = await Profile.findOne({ user: userId })
        .populate('user', 'fullName email mobileNumber status connections eventsAttended');
    if (!profile) {
        throw new ApiError(404, "Profile not found");
    }

    const profileData = {
        _id: profile._id,
        user: {
            _id: profile.user._id,
            fullName: profile.user.fullName,
            email: profile.user.email,
            mobileNumber: profile.user.mobileNumber,
            status: profile.user.status
        },
        profilePicture: profile.profilePicture,
        location: profile.location,
        language: profile.language,
        experience: profile.experience,
        propertyType: profile.preferences.propertyType,
        interests: profile.preferences.interests,
        socialLinks: profile.socialLinks,
        connections: profile.user.connections?.length || 0,
        events: profile.user.eventsAttended?.length || 0
    };

    if (currentUserId.toString() === userId) {
        return res.status(200).json(
            new ApiResponse(200, profileData, "Profile retrieved successfully")
        );
    }

    const currentUser = await User.findById(currentUserId).select('connections');
    const isConnected = currentUser.connections.includes(userId);

    if (isConnected) {
        return res.status(200).json(
            new ApiResponse(200, profileData, "Profile retrieved successfully")
        );
    }

    const maskedProfileData = {
        ...profileData,
        user: {
            ...profileData.user,
            email: maskAfterX(profileData.user.email, 1),
            mobileNumber: maskAfterX(profileData.user.mobileNumber, 1),
        },
        propertyType: "***",
        interests: ["***"],
        connections: "***",
        events: "***"
    };

    return res.status(200).json(
        new ApiResponse(200, maskedProfileData, "Profile retrieved successfully")
    );
});

const updateProfile = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    if (!userId) {
        throw new ApiError(401, "User not found");
    }

    const profile = await Profile.findOne({ user: userId });
    if (!profile) {
        throw new ApiError(404, "Profile not found");
    }

    const updatedProfile = await Profile.findByIdAndUpdate(
        profile._id,
        { $set: req.body },
        { new: true, runValidators: true }
    );

    try {
        const updatedFields = Object.keys(req.body);
        if (updatedFields.length > 0) {
            await sendProfileUpdateNotification(userId, updatedFields.join(', '));
        }
    } catch (error) {
        console.error('Failed to send profile update notification:', error);
    }

    return res.status(200).json(
        new ApiResponse(200, updatedProfile, "Profile updated successfully")
    );
});

const getAllProfiles = asyncHandler(async (req, res) => {
    const { page = 1, limit = 10, search } = req.query;

    const query = {};
    if (search) {
        query.$or = [
            { 'user.fullName': { $regex: search, $options: 'i' } },
            { designation: { $regex: search, $options: 'i' } },
            { location: { $regex: search, $options: 'i' } }
        ];
    }

    const profiles = await Profile.find(query)
        .populate('user', 'fullName email mobileNumber')
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await Profile.countDocuments(query);

    return res.status(200).json(
        new ApiResponse(200, {
            users: profiles,
            totalPages: Math.ceil(count / limit),
            currentPage: page,
            totalUsers: count
        }, "Users retrieved successfully")
    );
});

export {
    getMyProfile,
    getProfileById,
    updateProfile,
    getAllProfiles
}; 