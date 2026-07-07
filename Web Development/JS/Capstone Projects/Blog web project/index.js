import express from "express";
import bodyparser from "body-parser";

const app = express();
const port = 3000;
let posts = [];
app.use(express.static("public"));

app.use (bodyparser.urlencoded({extended:true}));

app.get("/", (req,res) => {
    res.render("index.ejs", {posts});
});

app.get("/new", (req,res) =>{
    res.render("new.ejs");
});

app.post("/posts", (req, res)=>{
    const {title, content} = req.body;
    posts.push({id:Date.now(), title,content});
    res.redirect("/");
});

app.get("/edit/:id", (req,res)=>{
    const post = posts.find(p => p.id === Number(req.params.id));
    res.render("edit.ejs", {post})
});

app.post("/posts/:id", (req, res)=>{
    const post = posts.find(p => p.id === Number(req.params.id));
    post.title = req.body.title;
    post.content = req.body.content;
    res.redirect("/");
});

app.post("/posts/:id/delete",(req,res)=>{
    posts = posts.filter(p => p.id !== Number(req.params.id));
    res.redirect("/");
});

app.listen(port, () => {
    console.log(`Listening on port ${port}`);
});
