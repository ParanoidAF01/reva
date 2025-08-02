const express = require("express");
const dotenv = require("dotenv");
const indexRouting = require("./src/Routes/indexRoute");
const { default: mongoose } = require("mongoose");
const app = express();
dotenv.config();
app.use(express.json());

app.use('/index',indexRouting);

mongoose.connect(process.env.MONGODBURL,{
    useNewUrlParser: true,
    useUnifiedTopology: true,
});

app.listen(process.env.PORT,()=>{
    console.log("Server is Running on Port 3000");

});