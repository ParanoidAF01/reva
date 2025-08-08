import NFCCard from "../models/nfcCard.js";
import Transaction from "../models/transaction.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import {
    sendNFCCardCreatedNotification,
    sendNFCCardScannedNotification
} from "../utils/notificationService.js";

const requestNFCCard = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    if (!userId) {
        throw new ApiError(400, "User ID is required");
    }

    const existingPendingRequest = await NFCCard.findOne({
        user: userId,
        status: 'pending'
    });
    if (existingPendingRequest) {
        throw new ApiError(400, "You already have a pending NFC card request");
    }

    const existingActiveCard = await NFCCard.findOne({
        user: userId,
        status: 'active'
    });
    if (existingActiveCard && req.body.requestType === 'new') {
        throw new ApiError(400, "You already have an active NFC card");
    }

    const nfcCard = await NFCCard.create({
        user: userId,
        ...req.body
    });

    const transaction = await Transaction.create({
        user: userId,
        type: 'debit',
        amount: 4999,
        category: 'nfc_card_booking',
        status: 'completed',
        paymentMethod: req.body.paymentMethod || 'wallet'
    });

    const populatedCard = await NFCCard.findById(nfcCard._id)
        .populate('user', 'fullName email mobileNumber');

    try {
        await sendNFCCardCreatedNotification(
            userId,
            req.body.requestType || 'NFC'
        );
    } catch (error) {
        console.error('Failed to send NFC card notification:', error);
    }

    return res.status(201).json(
        new ApiResponse(201, populatedCard, "NFC card request submitted successfully")
    );
});

const getMyNFCCardStatus = asyncHandler(async (req, res) => {
    const userId = req.user._id;

    const nfcCards = await NFCCard.find({ user: userId })
        .populate('user', 'fullName email mobileNumber')
        .sort({ createdAt: -1 });

    return res.status(200).json(
        new ApiResponse(200, {
            cards: nfcCards,
        }, "NFC card status retrieved successfully")
    );
});

const getAllNFCCardRequests = asyncHandler(async (req, res) => {
    const { status, page = 1, limit = 10 } = req.query;
    const skip = (page - 1) * limit;

    let query = {};
    if (status) {
        query.status = status;
    }

    const nfcCards = await NFCCard.find(query)
        .populate('user', 'fullName email mobileNumber')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit));

    const total = await NFCCard.countDocuments(query);

    return res.status(200).json(
        new ApiResponse(200, {
            cards: nfcCards,
            pagination: {
                currentPage: parseInt(page),
                totalPages: Math.ceil(total / limit),
                totalRequests: total,
                hasNext: skip + nfcCards.length < total,
                hasPrev: page > 1
            }
        }, "NFC card requests retrieved successfully")
    );
});

const approveNFCCardRequest = asyncHandler(async (req, res) => {
    const adminId = req.user._id;
    if (!adminId) {
        throw new ApiError(400, "Admin ID is required");
    }

    const { cardId } = req.params;
    if (!cardId) {
        throw new ApiError(400, "Card ID is required");
    }

    const nfcCard = await NFCCard.findById(cardId)
        .populate('user', 'fullName email mobileNumber');
    if (!nfcCard) {
        throw new ApiError(404, "NFC card request not found");
    }

    if (nfcCard.status !== 'pending') {
        throw new ApiError(400, "Only pending requests can be approved");
    }

    nfcCard.status = 'active';
    await nfcCard.save();

    return res.status(200).json(
        new ApiResponse(200, updatedCard, "NFC card request approved successfully")
    );
});

const rejectNFCCardRequest = asyncHandler(async (req, res) => {
    const adminId = req.user._id;
    if (!adminId) {
        throw new ApiError(400, "Admin ID is required");
    }

    const { cardId } = req.params;
    if (!cardId) {
        throw new ApiError(400, "Card ID is required");
    }

    const nfcCard = await NFCCard.findById(cardId)
        .populate('user', 'fullName email mobileNumber');

    if (!nfcCard) {
        throw new ApiError(404, "NFC card request not found");
    }

    if (nfcCard.status !== 'pending') {
        throw new ApiError(400, "Only pending requests can be rejected");
    }

    nfcCard.status = 'rejected';
    await nfcCard.save();

    return res.status(200).json(
        new ApiResponse(200, nfcCard, "NFC card request rejected successfully")
    );
});

const deactivateNFCCard = asyncHandler(async (req, res) => {
    const adminId = req.user._id;
    if (!adminId) {
        throw new ApiError(400, "Admin ID is required");
    }

    const { cardId } = req.params;
    if (!cardId) {
        throw new ApiError(400, "Card ID is required");
    }

    const nfcCard = await NFCCard.findById(cardId)
        .populate('user', 'fullName email mobileNumber');

    if (!nfcCard) {
        throw new ApiError(404, "NFC card not found");
    }

    if (nfcCard.status !== 'active') {
        throw new ApiError(400, "Only active cards can be deactivated");
    }

    nfcCard.status = 'inactive';
    await nfcCard.save();

    return res.status(200).json(
        new ApiResponse(200, nfcCard, "NFC card deactivated successfully")
    );
});

const getNFCCardStats = asyncHandler(async (req, res) => {
    const totalRequests = await NFCCard.countDocuments();
    const pendingRequests = await NFCCard.countDocuments({ status: 'pending' });
    const approvedRequests = await NFCCard.countDocuments({ status: 'active' });
    const rejectedRequests = await NFCCard.countDocuments({ status: 'rejected' });
    const inactiveCards = await NFCCard.countDocuments({ status: 'inactive' });

    const recentRequests = await NFCCard.find()
        .populate('user', 'fullName email')
        .sort({ createdAt: -1 })
        .limit(5);

    return res.status(200).json(
        new ApiResponse(200, {
            statistics: {
                totalRequests,
                pendingRequests,
                approvedRequests,
                rejectedRequests,
                inactiveCards
            },
            recentRequests
        }, "NFC card statistics retrieved successfully")
    );
});

export {
    requestNFCCard,
    getMyNFCCardStatus,
    getAllNFCCardRequests,
    approveNFCCardRequest,
    rejectNFCCardRequest,
    deactivateNFCCard,
    getNFCCardStats
}; 