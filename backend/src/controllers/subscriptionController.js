import Subscription from "../models/subscription.js";
import Transaction from "../models/transaction.js";
import User from "../models/user.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import {
    sendSubscriptionUpdateNotification,
    sendSubscriptionExpiryNotification
} from "../utils/notificationService.js";

const checkSubscription = asyncHandler(async (req, res) => {
    const userId = req.user._id;

    const subscription = await Subscription.findOne({
        user: userId,
        status: 'active',
        endDate: { $gte: new Date() }
    }).populate('user', 'fullName email');

    if (!subscription) {
        return res.status(200).json(
            new ApiResponse(200, {
                isSubscribed: false,
                subscription: null
            }, "User is not subscribed")
        );
    }

    return res.status(200).json(
        new ApiResponse(200, {
            isSubscribed: true,
            subscription: {
                id: subscription._id,
                plan: subscription.plan,
                billingCycle: subscription.billingCycle,
                amountPaid: subscription.amountPaid,
                startDate: subscription.startDate,
                endDate: subscription.endDate,
                autoRenew: subscription.autoRenew,
                paymentMethod: subscription.paymentMethod
            }
        }, "Subscription found")
    );
});

const createSubscription = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    if (!userId) {
        throw new ApiError(401, "Unauthorized");
    }

    const {
        plan,
        amountPaid,
        paymentMethod,
    } = req.body;
    if (!plan || !amountPaid || !paymentMethod) {
        throw new ApiError(400, "Missing required fields");
    }

    const existingActiveSubscription = await Subscription.findOne({
        user: userId,
        status: 'active'
    });
    if (existingActiveSubscription) {
        throw new ApiError(400, "User already has an active subscription");
    }

    const startDate = new Date();
    let endDate;

    switch (plan) {
        case 'monthly':
            endDate = new Date(startDate.getTime() + 30 * 24 * 60 * 60 * 1000);
            break;
        case 'annual':
            endDate = new Date(startDate.getTime() + 365 * 24 * 60 * 60 * 1000);
            break;
        case 'trial':
            endDate = new Date(startDate.getTime() + 7 * 24 * 60 * 60 * 1000);
            break;
        default:
            throw new ApiError(400, "Invalid billing cycle");
    }

    const subscription = await Subscription.create({
        user: userId,
        plan,
        amountPaid,
        status: 'active',
        startDate,
        endDate,
        paymentMethod
    });

    const transaction = await Transaction.create({
        user: userId,
        type: 'debit',
        amount: amountPaid,
        category: 'subscription',
        status: 'completed',
        paymentMethod
    });

    await User.findByIdAndUpdate(userId, {
        subscription: subscription._id
    });

    try {
        await sendSubscriptionUpdateNotification(
            userId,
            plan,
            'active'
        );
    } catch (error) {
        console.error('Failed to send subscription notification:', error);
    }

    const populatedSubscription = await Subscription.findById(subscription._id)
        .populate('user', 'fullName email');

    return res.status(201).json(
        new ApiResponse(201, populatedSubscription, "Subscription created successfully")
    );
});

const cancelSubscription = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    if (!userId) {
        throw new ApiError(401, "Unauthorized");
    }

    const { reason } = req.body;
    if (!reason) {
        throw new ApiError(400, "Cancellation reason is required");
    }

    const subscription = await Subscription.findOne({
        user: userId,
        status: 'active'
    });
    if (!subscription) {
        throw new ApiError(404, "No active subscription found");
    }

    subscription.status = 'cancelled';
    subscription.cancellationDate = new Date();
    subscription.cancellationReason = reason;
    await subscription.save();

    return res.status(200).json(
        new ApiResponse(200, subscription, "Subscription cancelled successfully")
    );
});

const getSubscriptionHistory = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { page = 1, limit = 10 } = req.query;

    const subscriptions = await Subscription.find({ user: userId })
        .sort({ createdAt: -1 })
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await Subscription.countDocuments({ user: userId });

    return res.status(200).json(
        new ApiResponse(200, {
            subscriptions,
            totalPages: Math.ceil(count / limit),
            currentPage: parseInt(page),
            totalSubscriptions: count
        }, "Subscription history retrieved successfully")
    );
});

export {
    checkSubscription,
    createSubscription,
    cancelSubscription,
    getSubscriptionHistory
}; 