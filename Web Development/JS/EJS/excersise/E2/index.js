// import express from 'express';

// const app = express();
// const port = 3000;

// app.get("/",(req, res)=>{
//     let bowl = ["Apples", "Oranges","Pears"];
//     res.render("index.ejs", {fruits: bowl});
// });

// app.listen(port,()=>{
//     console.log(`Server is running at ${port}`);
// });
import express from "express";
import bodyParser from "body-parser";

const app = express();
const port = 3000;

app.use(bodyParser.urlencoded({extended:true}));

app.get("/", (req, res) =>{
    res.render("index.ejs");
})

app.post("/submit", (req, res) =>{
    const numLetters = req.body["fName"].length + req.body["lName"].length;
    res.render("index.ejs", {numberOfLetters: numLetters});
})

app.listen(port,()=>{
    console.log(`Server is running in ${port}`);
})