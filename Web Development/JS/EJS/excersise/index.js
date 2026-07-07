import express from 'express';

const app = express();
const port = 3000;

app.get("/",(req, res)=>{
    let bowl = ["Apples", "Oranges","Pears"];
    res.render("index.ejs", {fruits: bowl});
});

app.listen(port,()=>{
    console.log(`Server is running at ${port}`);
});