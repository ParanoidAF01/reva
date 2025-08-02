const { default: axios, Axios } = require("axios");
const users = require("../Models/users");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const {v4:uuidv4} = require("uuid");
const { set } = require("mongoose");

// registration
exports.Register = async(req,res)=>{
    try {
        const {firstName,lastName,mobileNumber,MPIN} = req.body;
        const mobilenumberfound = await users.findOne({mobileNumber});
        if(mobilenumberfound){
            return res.status(401).json({mag:"This Phone number is Already there there in Db "});
        }
        const bcryptmpin = await bcrypt.hash(MPIN,10);
        // const userId = uuidv4();
        let user = new users({
            firstName,
            lastName,
            mobileNumber,
            mpin:bcryptmpin,

        });
        await user.save();
        return res.status(200).json({msg:"User is Registered Successfully",id:uuidv4});

    } catch (error) {
        console.error(error);
        return res.status(500).json({msg:"Error while Signup",error});
    }
}

// login through username mpin
exports.login= async(req,res)=>{
    try{
        const {mobileNumber,mpin} = req.body;
        const mobileExist = await users.findOne({mobileNumber});
        if(!mobileExist){
            return res.status(400).json({msg:"This mobile number is not registered"});
        }
        const verifympin = await bcrypt.compare(mpin,mobileExist.mpin);
        if(!verifympin){
            return res.status(400).json({msg:"mpin is not correct"});
        }
        const acessToken = jwt.sign({id:mobileNumber},process.env.JWTSECRET,{expiresIn:"15m"});
        const refreshToken = jwt.sign({},process.env.REFRESHTOKEN,{expiresIn:"7d"});

        mobileExist.refreshToken = refreshToken;
        mobileExist.refreshTokenExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

        await mobileExist.save();

        return res.status(200).json({
            msg:"login Successfull",
            acessToken,
            refreshToken,
            id:mobileExist.id,
            mobilenumber:mobileExist.mobileNumber,
        });

    }catch(e){
        console.error(e);
        return res.status(500).json({msg:"Error while login",e});
    }
}

// send otp
exports.sendOtp= async(req,res)=>{
    try{
        const {mobileNumber} = req.body
        const otp = ("" + Math.floor(100000 + Math.random()*900000));
        const expiresIn = new Date(Date.now() + 5 * 60 * 1000);
        axios.post(process.env.VERIFYOTPURL,
            {
                "Text": `Use ${otp} as your User Verification code.Expires in 10 minutes This code is Confidential. Never Share it with anyone for your safety. LEXORA`,
                "Number":"91"+mobileNumber,
                "SenderId":"LEXORA",
                "DRNotifyUrl":"https://www.domainname.com/notifyurl",
                "DRNotifyHttpMethod":"POST",
                "Tool":"API"
            },
            
            {
            headers:{
                'Content-Type': 'application/json',
            },
            auth:{
                userName:process.env.OTPAUTHKEY,
                password:process.env.OTPAUTHTOKEN,
            },
        },
          
        ).then(async(res)=>{
            console.log("Response Recieved",res);
            const mobileExist = await users.findOne({mobileNumber});
            if(!mobileExist){
                return res.status(400).json({msg:"Mobile number Does not Exist in Db"});
            }
            mobileExist.otpVerified = true;
            await mobileExist.save();
        }).catch((err)=>{
            console.log("Error Occured",err);
        });
        
        
    }catch(e){
        console.error(e);
        return res.status(500).json({msg:"Error while Verifying Otp",e});
    }
}

exports.verifyOtp = async(req,res)=>{
    try{
        const {otp} = req.body;
    }catch(e){
        console.error(e);
        return res.status(500).json({msg:"Otp Verification issued",e});
    }
}

// forgot Password
exports.forgotPassword= async(req,res)=>{
    try{
        const {mobileNumber,newMpin } = req.body;
        const mobileExist = await users.findOne({mobileNumber});
        if(!mobileExist){
            return res.status(401).json({msg:"Mobile number does not exist"});
        }
        const bcryptmpin = await bcrypt.hash(newMpin,10);
        mobileExist.mpin = bcryptmpin;
        mobileExist.save();
        return res.status(200).json({msg:"Successfuly password change"});

    }catch(e){
        console.error(e);
        return res.status(500).json({msg:"Error while login",e});
    }
}

// logout
exports.logout= async(req,res)=>{
    try{
        const {refreshToken} = req.body;
        if(!refreshToken){
            return res.status(400).json({msg:"Refresh token required"});
        }
        const user = await users.findOne({refreshToken});
        if(user){
            user.refreshToken = null;
            user.accessToken = null;
            await user.save();
        }
        
        return res.status(200).json({msg:"Logout Successfully"});

    }catch(e){
        console.error(e);
        return res.status(500).json({msg:"Error while logout",e});
    }
}

exports.refreshingacesstoken = async(req,res)=>{
    const {refrestoken} = req.body;
    if(!refrestoken){
            return res.status(401).json({msg:"acess token is not present there"});
        }
    try {
        
        const user = await users.findOne({refrestoken});
        if(!user){
            return res.status(403).json({msg:"Refresh token invalid or not fiund "});
        }
        jwt.verify(refrestoken,process.env.refreshToken,async(err)=>{
            if(err){
                return res.status(403).json({msg:"Refresh token Expired Please login Again"});
            }
            const newAcesstoken = jwt.sign({id:mobileNumber},process.env.JWTSECRET,{expiresIn:"15m"});

            const newrefreshToken  = jwt.sign({},process.env.refreshToken,{expiresIn:"7d"},);
            user.refreshToken = newrefreshToken;
            await user.save();
            return res.status(200).json({
                    accessToken: newAcesstoken,
                    refreshToken: newrefreshToken
                });
        });

    } catch (error) {
        console.error(error);
        return res.status(500).json({msg:"Error while refreshing acesss token"})
    }
}
