function HouseKeeper(name, age, job){
    this.name = name,
    this.age = age,
    this.job = job
    this.cleaning = function (){
        alert("cleaning in progress");
        goToNextRoom();
        cleanRoom();
    }
}

var housekeeper3 = new HouseKeeper("m", 21, "clean");

