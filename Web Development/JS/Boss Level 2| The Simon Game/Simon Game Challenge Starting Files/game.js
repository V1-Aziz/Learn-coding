//Here constant varibale.
var buttonColor = ["red", "blue", "green", "yellow"];
var gamePattren = [];
var userClickedPattern = [];
var started = false;
var level = 0;



$(".btn").click(function () {
    var userChosenColour = $(this).attr("id");
    userClickedPattern.push(userChosenColour);

    animatePress(userChosenColour);
    playSound(userChosenColour);
    checkAnswer(userClickedPattern.length - 1);
})

$(document).keydown(function () {
    if (!started) {
        $("#level-title").text("level " + level);
        nextSequence();
        started = true;
    }
})

function checkAnswer(currentLevel) {
    if (gamePattren[currentLevel] === userClickedPattern[currentLevel]) {
        console.log("success");
        if (userClickedPattern.length === gamePattren.length) {
            setTimeout(function () {
                nextSequence();
            }, 1000)
        }
    } else {
        console.log("wrong");
        playSound("wrong");
        $("body").addClass("game-over");
        setTimeout(function () {
            $("body").removeClass("game-over");
        }, 200)

        $("#level-title").text("Game Over, To Restart Press Any Key");

        startOver();
    }
}

function nextSequence() {
    userClickedPattern = [];

    level++;
    $("#level-title").text("level " + level);

    var randomNumber = Math.floor(Math.random() * 4);
    var randomChosenColour = buttonColor[randomNumber];
    gamePattren.push(randomChosenColour);
    playSound(randomChosenColour);

    $("#" + randomChosenColour).fadeIn(100).fadeOut(100).fadeIn(100);
}


function playSound(name) {
    var audio = new Audio("sounds/" + name + ".mp3");
    audio.play();
}

function animatePress(name) {
    $("#" + name).addClass("pressed");
    setTimeout(function () {
        $("#" + name).removeClass("pressed");
    }, 100)

}

function startOver() {
    level = 0;
    started = false;
    gamePattren = [];
}