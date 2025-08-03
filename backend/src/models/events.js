import mongoose from "mongoose";

const eventsSchema = mongoose.Schema({
    title: {
        type: String,
        required: true,
        trim: true
    },
    description: {
        type: String,
    },
    image: {
        type: String,
    },
    location: {
        type: String,
    },
    address: {
        type: String,
    },
    startDate: {
        type: Date,
    },
    startTime: {
        type: Date,
    },
    organizer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    attendees: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
    }],
    maxAttendees: {
        type: Number,
        default: 0
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