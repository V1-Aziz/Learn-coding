var diceNumber = [1,2,3,4,5,6];
var numebrChoiceOne = Math.floor((Math.random()*6));
var numebrChoiceTwo = Math.floor((Math.random()*6));
document.querySelector(".img1").setAttribute('src', `./images/dice${diceNumber[numebrChoiceOne]}.png`);
document.querySelector(".img2").setAttribute('src', `./images/dice${diceNumber[numebrChoiceTwo]}.png`);

if (numebrChoiceOne>numebrChoiceTwo){
    document.querySelector("h1").innerHTML = "🚩 Player 1 Wins";
} else if (numebrChoiceOne<numebrChoiceTwo){
    document.querySelector("h1").innerHTML = "Player 2 Wins 🚩";
} else {
    document.querySelector("h1").innerHTML = "❗Draw❗";
}