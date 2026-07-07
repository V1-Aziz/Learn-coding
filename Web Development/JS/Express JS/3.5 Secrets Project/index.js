//To see how the final website should work, run "node solution.js".
import express from "express";
import { dirname } from "path";
import { fileURLToPath } from "url";
import bodyParser from "body-parser";

const app = express();
const port = 3000;
const __dirname = dirname(fileURLToPath(import.meta.url));
var userIsAuthorised = false;

app.use(bodyParser.urlencoded({ extended: true}));

app.get("/", (req, res)=>{
    res.sendFile(__dirname+"/public/index.html");
});

function checkPassword(req, res, next){
    const password = req.body["password"]
    if(password == "ILoveProgramming"){
        userIsAuthorised = true;
    }
    next();
}

app.use(checkPassword);

app.post("/check", (req, res) => {
    if (userIsAuthorised){
        res.sendFile(__dirname+"/public/secret.html");
    } else{
        res.sendFile(__dirname+"/public/index.html");
    }
})

app.listen(port, () => {
  console.log(`Listening on port ${port}`);
});

//Make sure you have installed all the dependencies with "npm i".
//The password is ILoveProgramming
