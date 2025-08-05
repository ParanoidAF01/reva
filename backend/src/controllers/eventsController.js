import Events from "../models/events.js";
import Transaction from "../models/transaction.js";
import User from "../models/user.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import {
    sendEventInvitationNotification,
    sendEventUpdateNotification,
    sendEventCancellationNotification
} from "../utils/notificationService.js";

const createEvent = asyncHandler(async (req, res) => {
    const userId = req.user._id;

    const eventData = {
        organizer: userId,
        ...req.body
    };

    const event = await Events.create(eventData);

    const populatedEvent = await Events.findById(event._id)
        .populate('organizer', 'fullName email')
        .populate('attendees', 'fullName email');

    return res.status(201).json(
        new ApiResponse(201, populatedEvent, "Event created successfully")
    );
});

const getAllEvents = asyncHandler(async (req, res) => {
    const { page = 1, limit = 10, status, search } = req.query;

    const query = {};
    if (status) query.status = status;
    if (search) {
        query.$or = [
            { title: { $regex: search, $options: 'i' } },
            { description: { $regex: search, $options: 'i' } },
            { location: { $regex: search, $options: 'i' } }
        ];
    }

    const events = await Events.find(query)
        .populate('organizer', 'fullName email')
        .populate('attendees', 'fullName email')
        .sort({ startDate: 1 })
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await Events.countDocuments(query);

    return res.status(200).json(
        new ApiResponse(200, {
            events,
            totalPages: Math.ceil(count / limit),
            currentPage: page,
            totalEvents: count
        }, "Events retrieved successfully")
    );
});

const getEventById = asyncHandler(async (req, res) => {
    const { eventId } = req.params;

    const event = await Events.findById(eventId)
        .populate('organizer', 'fullName email')
        .populate('attendees', 'fullName email');

    if (!event) {
        throw new ApiError(404, "Event not found");
    }

    return res.status(200).json(
        new ApiResponse(200, event, "Event retrieved successfully")
    );
});

const updateEvent = asyncHandler(async (req, res) => {
    const { eventId } = req.params;

    const event = await Events.findById(eventId);
    if (!event) {
        throw new ApiError(404, "Event not found");
    }

    const updatedEvent = await Events.findByIdAndUpdate(
        eventId,
        { $set: req.body },
        { new: true, runValidators: true }
    ).populate('organizer', 'fullName email')
        .populate('attendees', 'fullName email');

    if (event.attendees && event.attendees.length > 0) {
        try {
            await sendEventUpdateNotification(
                event.attendees,
                event.title,
                'updated'
            );
        } catch (error) {
            console.error('Failed to send event update notification:', error);
        }
    }

    return res.status(200).json(
        new ApiResponse(200, updatedEvent, "Event updated successfully")
    );
});

const deleteEvent = asyncHandler(async (req, res) => {
    const { eventId } = req.params;

    const event = await Events.findById(eventId);
    if (!event) {
        throw new ApiError(404, "Event not found");
    }

    if (event.attendees && event.attendees.length > 0) {
        try {
            await sendEventCancellationNotification(
                event.attendees,
                event.title
            );
        } catch (error) {
            console.error('Failed to send event cancellation notification:', error);
        }
    }

    await User.updateMany(
        { eventsAttended: eventId },
        { $pull: { eventsAttended: eventId } }
    );

    await Events.findByIdAndDelete(eventId);

    return res.status(200).json(
        new ApiResponse(200, {}, "Event deleted successfully")
    );
});

const registerForEvent = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { eventId } = req.params;

    const event = await Events.findById(eventId);
    if (!event) {
        throw new ApiError(404, "Event not found");
    }

    if (event.status !== 'published') {
        throw new ApiError(400, "Event is not available for registration");
    }

    if (event.attendees.includes(userId)) {
        throw new ApiError(400, "You are already registered for this event");
    }

    if (event.maxAttendees && event.attendees.length >= event.maxAttendees) {
        throw new ApiError(400, "Event is full");
    }

    await Events.findByIdAndUpdate(eventId, { $push: { attendees: userId } });

    await User.findByIdAndUpdate(userId, { $push: { eventsAttended: eventId } });

    if (event.entryFee > 0) {
        await Transaction.create({
            user: userId,
            type: 'debit',
            amount: event.entryFee,
            category: 'event_payment',
            status: 'completed',
            paymentMethod: req.body.paymentMethod || 'wallet'
        });
    }

    const updatedEvent = await Events.findById(eventId)
        .populate('organizer', 'fullName email')
        .populate('attendees', 'fullName email');

    return res.status(200).json(
        new ApiResponse(200, updatedEvent, "Successfully registered for event")
    );
});

const unregisterFromEvent = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { eventId } = req.params;

    const event = await Events.findById(eventId);
    if (!event) {
        throw new ApiError(404, "Event not found");
    }

    if (!event.attendees.includes(userId)) {
        throw new ApiError(400, "You are not registered for this event");
    }

    await Events.findByIdAndUpdate(eventId, { $pull: { attendees: userId } });

    await User.findByIdAndUpdate(userId, { $pull: { eventsAttended: eventId } });

    const updatedEvent = await Events.findById(eventId)
        .populate('organizer', 'fullName email')
        .populate('attendees', 'fullName email');

    return res.status(200).json(
        new ApiResponse(200, updatedEvent, "Successfully unregistered from event")
    );
});

const getMyEvents = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { page = 1, limit = 10 } = req.query;

    const events = await Events.find({ attendees: userId })
        .populate('organizer', 'fullName email')
        .populate('attendees', 'fullName email')
        .sort({ startDate: 1 })
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await Events.countDocuments({ attendees: userId });

    return res.status(200).json(
        new ApiResponse(200, {
            events,
            totalPages: Math.ceil(count / limit),
            currentPage: page,
            totalEvents: count
        }, "Your events retrieved successfully")
    );
});

const getMyOrganizedEvents = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { page = 1, limit = 10 } = req.query;

    const events = await Events.find({ organizer: userId })
        .populate('organizer', 'fullName email')
        .populate('attendees', 'fullName email')
        .sort({ startDate: 1 })
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .exec();

    const count = await Events.countDocuments({ organizer: userId });

    return res.status(200).json(
        new ApiResponse(200, {
            events,
            totalPages: Math.ceil(count / limit),
            currentPage: page,
            totalEvents: count
        }, "Your organized events retrieved successfully")
    );
});

export {
    createEvent,
    getAllEvents,
    getEventById,
    updateEvent,
    deleteEvent,
    registerForEvent,
    unregisterFromEvent,
    getMyEvents,
    getMyOrganizedEvents
}; 