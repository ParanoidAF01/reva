import Transaction from "../models/transaction.js";
import User from "../models/user.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import {
    sendWalletTransactionNotification,
    sendWalletLowBalanceNotification
} from "../utils/notificationService.js";

const createTransaction = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    if (!userId) {
        throw new ApiError(401, "Unauthorized");
    }

    const {
        type,
        amount,
    } = req.body;
    if (!type || !amount) {
        throw new ApiError(400, "Missing required fields");
    }

    const transaction = await Transaction.create({
        user: userId,
        type,
        amount,
        ...req.body
    });

    await User.findByIdAndUpdate(userId, {
        $push: { transactions: transaction._id }
    });

    // Send notification for transaction
    try {
        await sendWalletTransactionNotification(
            userId,
            type,
            amount
        );
    } catch (error) {
        console.error('Failed to send transaction notification:', error);
    }

    const populatedTransaction = await Transaction.findById(transaction._id)
        .populate('user', 'fullName email');

    return res.status(201).json(
        new ApiResponse(201, populatedTransaction, "Transaction created successfully")
    );
});

const getAllTransactions = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { page = 1, limit = 10, type, category, status, paymentMethod } = req.query;

    const query = { user: userId };
    if (type) query.type = type;
    if (category) query.category = category;
    if (status) query.status = status;
    if (paymentMethod) query.paymentMethod = paymentMethod;

    const transactions = await Transaction.find(query)
        .populate('user', 'fullName email')
        .sort({ createdAt: -1 })
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await Transaction.countDocuments(query);

    return res.status(200).json(
        new ApiResponse(200, {
            transactions,
            totalPages: Math.ceil(count / limit),
            currentPage: parseInt(page),
            totalTransactions: count
        }, "Transactions retrieved successfully")
    );
});

const getTransactionById = asyncHandler(async (req, res) => {
    const { transactionId } = req.params;
    const userId = req.user._id;

    const transaction = await Transaction.findById(transactionId)
        .populate('user', 'fullName email');

    if (!transaction) {
        throw new ApiError(404, "Transaction not found");
    }

    if (transaction.user._id.toString() !== userId.toString()) {
        throw new ApiError(403, "Access denied");
    }

    return res.status(200).json(
        new ApiResponse(200, transaction, "Transaction retrieved successfully")
    );
});

const getTransactionStats = asyncHandler(async (req, res) => {
    const userId = req.user._id;

    const totalTransactions = await Transaction.countDocuments({ user: userId });
    const totalAmount = await Transaction.aggregate([
        { $match: { user: userId } },
        { $group: { _id: null, total: { $sum: "$amount" } } }
    ]);

    const typeStats = await Transaction.aggregate([
        { $match: { user: userId } },
        { $group: { _id: "$type", count: { $sum: 1 }, total: { $sum: "$amount" } } }
    ]);

    const categoryStats = await Transaction.aggregate([
        { $match: { user: userId } },
        { $group: { _id: "$category", count: { $sum: 1 }, total: { $sum: "$amount" } } }
    ]);

    return res.status(200).json(
        new ApiResponse(200, {
            totalTransactions,
            totalAmount: totalAmount[0]?.total || 0,
            typeStats,
            categoryStats
        }, "Transaction statistics retrieved successfully")
    );
});

export {
    createTransaction,
    getAllTransactions,
    getTransactionById,
    getTransactionStats
}; 