import mongoose from "mongoose";

const eventsSchema = mongoose.Schema({
    title: {
        type: String,
        required: true,
        trim: true
    },
    description: {
        type: String,
        required: true
    },
    image: {
        type: String,
        required: true
    },
    location: {
        type: String,
        required: true
    },
    address: {
        type: String,
        required: true
    },
    startDate: {
        type: Date,
        required: true
    },
    startTime: {
        type: Date,
        required: true
    },
    organizer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Users",
        required: true
    },
    attendees: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Users"
    }],
    maxAttendees: {
        type: Number,
        default: null
    },
    entryFee: {
        type: Number,
        default: 0
    },
    status: {
        type: String,
        enum: ['draft', 'published', 'cancelled', 'completed'],
        default: 'draft'
    }
}, {
    timestamps: true

});


const Events = mongoose.model("Events", eventsSchema);

export default Events;