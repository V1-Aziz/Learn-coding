import express from 'express';

const app = express();
const port = 3000;

app.get("/", (req, res) => {
    console.log(req.rawHeaders)
    res.send("<h2>Hello, World!</h2>");
});

app.get("/AboutMe", (req,res)=>{
    res.send("<h2>My name is abdulaziz Alghamdi</h2>")
})

app.get("/ContactMe", (req,res)=>{
    res.send("<h2>0538554503</h2>")
})

app.listen(port, () => {
    console.log(`Server is running on ${port}`);
})