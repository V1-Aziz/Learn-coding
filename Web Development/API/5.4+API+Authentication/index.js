import express, { response } from "express";
import axios from "axios";

const app = express();
const port = 3000;
const API_URL = "https://secrets-api.appbrewery.com/";

//TODO 1: Fill in your values for the 3 types of auth.
const yourUsername = "Av1vev1";
const yourPassword = "Av1vev1";
const yourAPIKey = "d4e1ed30-1d04-4455-98f9-780f30eaa5cf";
const yourBearerToken = "c5d8d385-0c1f-48ca-856f-c3fd4f3f0c32";

app.get("/", (req, res) => {
  res.render("index.ejs", { content: "API Response." });
});

app.get("/noAuth", (req, res) => {
  //TODO 2: Use axios to hit up the /random endpoint
  //The data you get back should be sent to the ejs file as "content"
  //Hint: make sure you use JSON.stringify to turn the JS object from axios into a string.
  axios.get(API_URL + "random")
    .then((response)=>{
      res.render("index.ejs", {content: JSON.stringify(response.data)})
    })
});

app.get("/basicAuth", (req, res) => {
  //TODO 3: Write your code here to hit up the /all endpoint
  //Specify that you only want the secrets from page 2
  //HINT: This is how you can use axios to do basic auth:
  // https://stackoverflow.com/a/74632908
  /*
   axios.get(URL, {
      auth: {
        username: "abc",
        password: "123",
      },
    });
  */
 axios.get(API_URL + "all?page=2", {
    auth:{
    username: yourUsername,
    password: yourPassword,
  }
 })
  .then((response)=>{
    res.render("index.ejs", {content: JSON.stringify(response.data)})
  })

});

app.get("/apiKey", (req, res) => {
  //TODO 4: Write your code here to hit up the /filter endpoint
  //Filter for all secrets with an embarassment score of 5 or greater
  //HINT: You need to provide a query parameter of apiKey in the request.
  axios.get(API_URL+"filter",{
    params:{
      score: 5,
      apiKey: yourAPIKey,
    }
  })
  .then((response)=>{
    res.render("index.ejs",{content:JSON.stringify(response.data)})
  })
});

app.get("/bearerToken", (req, res) => {
  //TODO 5: Write your code here to hit up the /secrets/{id} endpoint
  //and get the secret with id of 42
  //HINT: This is how you can use axios to do bearer token auth:
  // https://stackoverflow.com/a/52645402
  /*
  axios.get(URL, {
    headers: { 
      Authorization: `Bearer <YOUR TOKEN HERE>` 
    },
  });
  */

  axios.get(API_URL+"secrets/42", {
    headers:{
      Authorization: `Bearer ${yourBearerToken}`,
    }
  })
  .then((response)=>{
    res.render("index.ejs", {content:JSON.stringify(response.data)})
  })
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
