const mongoose = require("mongoose");

const usersSchema = mongoose.Schema({
    firstName:{
        type:String,
        required:true
    },
    lastName:{
        type:String,
        required:true,
    },
    mobileNumber:{
        type:String,
        required:true,
        
    },
    mpin:{
        type:String,
        required:true,
        
    },
    otpVerified:{
        type:Boolean,
        // required:true,
    },
    refreshtoken:{
        type:String,
        require:true,
    },
    refreshTokenExpiresAt: {
        type: Date,
        default: () => new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    }
});

const users = new mongoose.model("Users",usersSchema);
module.exports = users;