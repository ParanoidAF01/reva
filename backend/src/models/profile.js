import mongoose from "mongoose";

const profileSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
        unique: true
    },

    profilePicture: {
        type: String,
        default: null
    },
    dateOfBirth: {
        type: Date,
    },
    gender: {
        type: String,
        enum: ["Male", "Female", "Other"]
    },
    designation: {
        type: String,
        enum: ["Builder", "Loan Provider", "Interior Designer", "Material Supplier", "Legal Advisor", "Vastu Consultant", "Home Buyer", "Property Investor", "Construction Manager", "Real Estate Agent", "Technical Consultant", "Other"],
    },
    experience: {
        type: Number,
    },
    location: {
        type: String,
    },
    
    organization: {
        type: {
            name: {
                type: String,
                default: null
            },
            registered: {
                type: Boolean,
                default: false
            },
            incorporationDate: {
                type: Date,
                default: null
            },
            companyType: {
                type: String,
                enum: ["Private Limited", "Public Limited", "LLP", "Partnership", "Other"],
                default: null
            },
            gstNumber: {
                type: String,
                default: null
            }
        },
        default: {}
    },
    preferences: {
        type: {
            operatingLocations: {
                type: String,
                enum: ["India", "International"],
            },
            interests: {
                type: [String],
                default: []
            },
            propertyType: {
                type: String,
                enum: ["Residential", "Commercial", "Industrial", "Agricultural", "Other"]
            },
            networkingPreferences: {
                type: String,
                enum: ["Business", "Technology", "Health", "Education", "Entertainment", "Sports", "Other"]
            },
            targetClients: {
                type: String,
                enum: ["Business", "Technology", "Health", "Education", "Entertainment", "Sports", "Other"]
            },
        },
        default: {}
    },
    specialization: {
        type: {
            reraRegistered: {
                type: Boolean,
                default: false
            },
            reraNumber: {
                type: String,
                default: null
            },
            networkingMembers: {
                type: [mongoose.Schema.Types.ObjectId],
                ref: "User",
                default: []
            },
            realEstateWebsite: {
                type: String,
                default: null
            },
            associatedBuilders: {
                type: [mongoose.Schema.Types.ObjectId],
                ref: "User",
                default: []
            },
        },
        default: {}
    },
    maskedAadharNumber: {
        type: String,
        default: null
    },
    socialMediaLinks: {
        type: {
            facebook: String,
            instagram: String,
            twitter: String,
            linkedin: String,
            youtube: String,
            website: String,
        },
        default: {}
    },
    alternateNumber: {
        type: String,
        default: null
    },
    kycVerified: {
        type: Boolean,
        default: null
    }
}, {
    timestamps: true,
});

const Profile = mongoose.model("Profile", profileSchema);

export default Profile; 