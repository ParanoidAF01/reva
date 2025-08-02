const jwt = require("jsonwebtoken");
const dotenv = require("dotenv");

dotenv.config();

const authcheck = async(req,res,next)=>{
    const blacklistedTokens = new Set();

    
    try{
    const authHeader = req.headers['x-auth-token'];
    let token = authHeader.split(' ')[1];
    if(blacklistedTokens.has(token)){
        return res.status(401).json({msg:"Token is loggedOut "});
    }
    const verifyToken  = jwt.verify(token,process.env.JWTSECRET);
    if(!verifyToken){
        return res.status(404).json({msg:"Token is not verified"});
    }
    req.user = verifyToken;
    next();
    }catch(e){
        console.error(e);
    return res.status(500).json({msg:"Error while authchecking",e});s
}


}

module.exports =authcheck;