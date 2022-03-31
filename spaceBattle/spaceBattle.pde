Spaceship joe;                                          //Declare Joe
ArrayList<Spaceship> bots = new ArrayList<Spaceship>(); //Create array lists of powerups, userLasers, botLasers and StarField
ArrayList<Powerup> powerups = new ArrayList<Powerup>();
ArrayList<Laserbolt> userLasers = new ArrayList<Laserbolt>();
ArrayList<Laserbolt> botLasers = new ArrayList<Laserbolt>();
ArrayList<Star> starfield = new ArrayList<Star>();
String actionText = "";                                  //Declare and instantiates action text

boolean gameActive = true;                               //setsgame to active
boolean onTitleScreen = true;                            //sets user to be on title screen

int level = 1;                                           //Sets game to level 1


void setup() {
  size(1000, 800); //canvas size
  joe = new Spaceship(random(width/4, 2 * width/4), random(0, height)); //instantiates joe
  for(int i = 0; i < level; i++){
    bots.add(new Spaceship(random(3 * width/4, width), random(0, height))); //adds the amount of bots as the level of the game
  }
  

  
  for(int i = 0; i < 1000; i++){  //adds stars to the starfield
    starfield.add(new Star()); 
  }
  
  powerups.add(new Powerup(new PVector(random(width), random(height)), 90)); //adds one powerup to start with
}

void startNextLevel(){ //function is used to start next level
  joe.maxHealth *= 1.1;                     //Adds and resets health
  if(joe.maxHealth > 50) joe.maxHealth = 50;
  joe.health = joe.maxHealth;
  for(int i = 0; i < level; i++){           //Adds new bots
    bots.add(new Spaceship(random(3 * width/4, width), random(0, height)));
  }
}

void draw() {
  
  
  if(onTitleScreen){
    background(0);
    fill(255);
    textSize(30);
    textAlign(CENTER);
    text(
      "Welcome to space battle! \n" + 
      "Use the left and right arrow keys to rotate \n" +
      "Use the up arrow key to accelerate and space to shoot \n" +
      "Destroy the other space ships to move onto the next level \n" +
      "Shoot the powerups - they will give you buffs or hurt your enemy \n" +
      "Complete level 5 to beat the game \n" +
      "Press 'S' to begin \n", 
      width/2, 
      height/4
    );
    return;
  }
  
  if(bots.size() == 0){ //Check if all bots have been destroyed
    if(level >= 5){     //If level is above 5, send the win message
      fill(255);
       textSize(100);
       textAlign(CENTER);
       text("You win!", width/2, height/8);
       gameActive = false;
       return;
    }
    level++;                                              //if level under 5 add begin next level
    actionText = "Level " + level + " is now beginning";
    startNextLevel();
  }
  
  if(joe.health <= 0){                                    //if player died end the game
    gameActive = false;
  }
  
  if(!gameActive){                                        //if the game is not active, don't run the rest of the code
    return;
  }
  
  background(0); //draws black background
  
  for(Star s : starfield){  //displays and moves stars of the starfield
    s.display();
    s.move();
  }
  
  text("Level: " + level, 100, 50);  //Displays level
  
  
  for(Powerup p : powerups) {       //displays and moves powerups
    p.move();
    p.display();
  }
  
  if(frameCount % 540 == 0){     //adds new powerup every 540 frames
    powerups.add(new Powerup(new PVector(random(width), random(height)), 90));
  }
  
  textAlign(CENTER);                      //draws action text
  textSize(50);
  fill(255);
  text(actionText, width/2, 7 * height/8);

  
  Powerup removePowerup = null;                                  //declares variables to remove bots
  ArrayList<Spaceship> removeBots = new ArrayList<Spaceship>();
  //Loops through users lasers
  for(Spaceship bot : bots){        //loops through bots and userLasers
    for(Laserbolt ul : userLasers){
      //Checks for collision with bot
      float d = PVector.sub(bot.location, ul.end).mag();  //finds distance between laser and bot
      if(d < bot.size) {    //check if collided
        bot.health--;       //lower health and remove bot if at 0
        if(bot.health <= 0){
          removeBots.add(bot);
        }
        ul.start = new PVector(2000000, 2000000);   //remove laser
        ul.end = new PVector(2000000, 2000000); 
      }
      
      //checks for collision with powerup
      for(Powerup p : powerups){    //loop through powerup
        float di = PVector.sub(ul.end, p.location).mag();  //find distance between userLaser and powerup
        if(di < p.diameter/2.0){  //check if collided
          removePowerup = p;      //add to be removed
          switch(removePowerup.type){
            case 0:
              joe.health += 3;                //adds health to user
              joe.maxHealth += 3;
              actionText = "Increased health";
              break;
            case 1:
              joe.fireSpeed *= 1.05;          //increase fire speed
              if(joe.fireSpeed > 50){
                joe.fireSpeed = 50;
                actionText = "Max fire speed reached";
              }
              actionText = "Increased fire speed";
              break;
              case 2:
              if(bot.health < 4){            //hurt all bots
                bot.health = 0;
                removeBots.add(bot);
              } else {
                bot.health -= 3; 
              }
              actionText = "Hurt the bots";
              break;
          }
        }
      }
    }
  }
  
  if(removePowerup != null){        //if removePowerup was set, then remove it from powerups list
    powerups.remove(removePowerup);
  }
  
  for(Spaceship removeBot : removeBots){  //loop through removeBot list, remove every one from bot list
    bots.remove(removeBot); 
  }
  
  
  for(Laserbolt bl : botLasers){ //loop through botLasers
    float d = PVector.sub(joe.location, bl.end).mag(); //find distance between joe and laser
    if(d < joe.size) {  //check if collided
      joe.health--;        //hurt joe
      if(joe.health <= 0){  //if joe died, end the game
        gameActive = false;
        fill(255);
        textSize(100);
        textAlign(CENTER);
        text("You lose!", width/2, height/8);
      }
      bl.start = new PVector(2000000, 2000000); 
      bl.end = new PVector(2000000, 2000000); 
    }
  }
  
  for(Laserbolt ul : userLasers){ //loop through userLasers, display and move them
    ul.move();
    ul.display();
    
  }
  
  for(Laserbolt bl : botLasers){ //loop through botLasers, display and move them
    bl.move();
    bl.display();
    
  }
  
  for(Spaceship bot : bots){
    if(frameCount % 60 == 0 && bot.shooting){ //bot shoot lasers
      botLasers.add(new Laserbolt(bot.location, bot.direction, 10)); 
    }
  }

  if (keyPressed) { //check if user clicker one of the arrow keys
    if (keyCode == LEFT)  joe.direction.rotate(radians(-4));  //rotate left
    if (keyCode == RIGHT) joe.direction.rotate(radians(4));   //rotate right
    if (keyCode == UP){                                       //accelerate forward
      joe.acceleration = joe.direction.copy().setMag(0.1);
      joe.moving = true;
    }
  } else {
    joe.acceleration = new PVector(0, 0);                     //remove acceleration
    joe.moving = false;
  }
  
  
  for(Spaceship bot : bots){        //loop through bots
    bot.selfTurn(joe.location);     //turn the bot to face player
    if(dist(joe.location.x, joe.location.y, bot.location.x, bot.location.y) > 400){ //check if bot is far away from bot, if it is accelerate forward 
      bot.moving = true;
      bot.acceleration = bot.direction.copy().setMag(0.1); 
      bot.shooting = true;
    } else if(dist(joe.location.x, joe.location.y, bot.location.x, bot.location.y) < 200){ //check if bot is too close from bot, if it is turn around and accelerate backwards
      bot.moving = true;
      bot.boostAway(joe.location);
      bot.shooting = false;
    } else {                //otherwise dont accelerate and just shoot and joe
      bot.moving = false; 
      bot.shooting = true;
    }
    
    bot.move();         //move bot
    bot.display();      //draw bot
  }
  

  joe.move();    //move joe
  joe.display(); //draw joe
}

void keyPressed(){
  if(key == ' '){ //if space key pressed, then shoot
    userLasers.add(new Laserbolt(joe.location, joe.direction, joe.fireSpeed)); 
  }
  
  if(key == 's'){ //if s key pressed, exit title screen
    onTitleScreen = false; 
  }
  
}

class Laserbolt{   
  PVector start, end, velocity; //Create PVectors
  
  Laserbolt(PVector spaceshipLocation, PVector spaceshipDirection, float vel){ //constructor
    start = spaceshipLocation.copy();
    end = PVector.add(start, spaceshipDirection.setMag(30));
    velocity = spaceshipDirection.copy().setMag(vel);
  }
  
  void move(){          //move laser
    start.add(velocity);
    end.add(velocity);
  }
  
  void display(){ //display laser
    stroke(255);
    strokeWeight(2);
    line(start.x, start.y, end.x, end.y);
  }
  
}



class Powerup {
  PVector location, velocity; //declare variables
  float diameter;
  color c;
  int type;

  Powerup(PVector start, float _diameter) { //constructor
    diameter = _diameter;
    location = start.copy();
    velocity = PVector.random2D();
    type = int(random(0, 3));
    c = getColor();
  }

  void move() {  //move and wrap around canvas
    location.add(velocity);
    if (location.x < 0) location.x = width;
    if (location.x > width) location.x = 0;
    if (location.y < 0) location.y = height;
    if (location.y > height) location.y = 0;    
  }

  void display() { //display
    fill(0);
    stroke(c);
    circle(location.x, location.y, diameter);
  }
  
  color getColor(){ //conver type of powerup to color
    switch(type){
      case 0:
        return color(255, 0, 0);
      case 1:
        return color(0, 255, 0);
      case 2:
        return color(0, 0, 255);
      default:
        return color(255, 0, 0);
    }
    
  }
}



class Spaceship {
  PVector location, velocity, acceleration, direction;  //declare variables
  float d, size;
  color c;
  boolean moving;
  boolean shooting;
  int health, maxHealth;
  int fireSpeed;

  Spaceship(float x, float y) { //constructor
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    direction = new PVector(1, 0);
    d = 20;
    c = color(255);
    size = 30;
    moving = false;
    shooting = true;
    maxHealth = 10;
    health = 10;
    fireSpeed = 20;
  }

  void move() {  //move and wrap around
    velocity.add(acceleration).limit(2);
    location.add(velocity);
    if (location.x < 0) location.x = width;
    if (location.x > width) location.x = 0;
    if (location.y < 0) location.y = height;
    if (location.y > height) location.y = 0;
  }
  
  void selfTurn(PVector targetLocation){ //turn bot to face joe
    direction = new PVector(1, 0);
    float xVal = targetLocation.x - location.x;
    float yVal = targetLocation.y - location.y;
    float angle = atan(yVal / xVal); //inverse tan
    if(xVal < 0) angle += PI; 
    
    direction.rotate(angle);
    
  }
  
  void boostAway(PVector targetLocation){ //turn bot to face away from joe
    direction = new PVector(1, 0);
    float xVal = targetLocation.x - location.x;
    float yVal = targetLocation.y - location.y;  
    float angle = atan(yVal / xVal);  //inverse tan
    if(xVal < 0) angle += PI; 
    angle += PI; //add pie to rotate from looking at joe, to looking away
    
    direction.rotate(angle);
    acceleration = direction.copy().setMag(0.1); //boost away
  }

  void display() { //display 
    if(moving){ //check if moving
      for (int i = 0; i < 900; i++) {  //creates 900 dots to be the "boost"
        PVector d = acceleration.copy().rotate(radians(180));
        d.rotate(radians(10*randomGaussian()));
        d.normalize().mult( 40*abs(randomGaussian()) );
        PVector dotlocation = PVector.add(location, d);
        stroke(255);
        point(dotlocation.x, dotlocation.y);
      }
    }

    pushMatrix(); // save coordiante system
    translate(location.x, location.y); //move system to center 
    fill(0, 0, 0, 255);
    stroke(255);
    rect(-maxHealth* 10 /2, -100, maxHealth * 10, 25); //draw outline health
    color red = color(229, 49, 21);
    color green = color(58, 229, 21);
    float frac = map(health, 0, maxHealth, 0, 1);
    color clr = lerpColor(red, green, frac); //get color of health
    fill(clr);
    rect(-maxHealth* 10 /2, -100, health * 10, 25); //draw health
    rotate(direction.heading());
    stroke(255);
    fill(0);
    triangle(1.5*size, 0, -size, -size, -size, size);
    popMatrix(); //reset back to normal coordinate system
    
  }
}

class Star {
  PVector location, velocity; //declare variable
  float d;
  color c;
  
  Star(){ //constructor
    location = new PVector(random(width), random(height));
    d = random(1, 3);
    velocity = new PVector(-d, 0);
    c = color(255);
  }
  
  void display(){ //display
    fill(c);
    noStroke();
    circle(location.x, location.y, d);
    
  }
  
  void move(){ //move
    location.add(velocity);
    if(location.x < 0) location.x = width;
  }
  
  
}
