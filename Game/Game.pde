import processing.sound.*;
final static float MOVE_SPEED = 4;
final static float SPRITE_SCALE = 50.0 / 128;
final static float SPRITE_SIZE = 50;
final static float GRAVITY = 0.6;
final static float JUMP_SPEED = 15;
final static float COIN_SCALE = 0.4;
final static float HEIGHT = SPRITE_SIZE * 12;
final static float WIDTH = SPRITE_SIZE * 16;

final static int NEUTRAL_FACING = 0;
final static int RIGHT_FACING = 1;
final static int LEFT_FACING = 2;
final static float GROUND_LEVEL = HEIGHT - SPRITE_SIZE;

final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 120;
final static float VERTICAL_MARGIN = 60;

Player player;
boolean isGameOver, hasKey;
PImage flag, keys, snow, crate, red_brick, brown_brick, c, spider, playerImage, bg, chest, openChest;
float nextBorder, left_boundary, right_boundary, top_boundary, bottom_boundary, view_x, view_y;
SoundFile bgMusic, jump, coin, lifeLost, gameOver;
ArrayList < Sprite > platforms, coins, collectables, noCollision;
ArrayList < Enemy > enemies;
int score, level;

void setup() {
    size(800, 600);
    imageMode(CENTER);
    bg = loadImage("bg.png");
    c = loadImage("gold1.png");
    playerImage = loadImage("player_stand_right.png");
    spider = loadImage("spider_walk_right1.png");
    red_brick = loadImage("red_brick.png");
    brown_brick = loadImage("brown_brick.png");
    crate = loadImage("crate.png");
    snow = loadImage("snow.png");
    chest = loadImage("chest.png");
    openChest = loadImage("openChest.png");
    keys = loadImage("key.png");
    flag = loadImage("levelEnd.png");
    
    gameOver = new SoundFile(this, "gameOver.mp3");
    bgMusic = new SoundFile(this, "CiderTime.mp3");
    jump = new SoundFile(this, "jump.mp3");
    coin = new SoundFile(this, "coin.mp3");
    lifeLost = new SoundFile(this, "lifeLost.mp3");
    player = new Player(playerImage, 0.8);
    platforms = new ArrayList < Sprite > ();
    coins = new ArrayList < Sprite > ();
    enemies = new ArrayList < Enemy > ();
    collectables = new ArrayList < Sprite > ();
    noCollision = new ArrayList < Sprite > ();
    
    player.center_x = 150;
    player.center_y = 100;
    nextBorder = 4000;
    view_x = 0;
    view_y = 0;
    level = 1;
    score = 0;
    hasKey = false;
    isGameOver = false;
    
    bgMusic.play();
    createPlatforms("map.csv");
}

void draw() {
    background(bg);
    if (!isGameOver) {
        scroll();
        displayStuff();
        player.updateAnimation();
        resolvePlatformCollisions(player, platforms);
        checkDeath();
        collectCoins(); 
        nextLevel();
        textSize(32);
        fill(0, 0, 0);
        text("Level: " + level, view_x + 50, view_y + 50);
        text("Score: " + score, view_x + 50, view_y + 100);
        text("Lives: " + player.lives, view_x + 50, view_y + 150);
    } else {
        reset();
        fill(0, 0, 255);
        fill(0, 0, 255);
        text("GAME OVER!", 280, 100);
        if (player.lives <= 0){
            text("You lose!", 300, 150);
        }
        else{
            text("You win!", 300, 150);
        }
        text("Press SPACE to restart!", 215, 200);
        text("Score: " + score, 295, 250);    
    }
}
void collectCoins() {
    ArrayList < Sprite > collision_list = checkCollisionList(player, coins);
    if (collision_list.size() > 0) {
          coin.play();
        for (Sprite coin: collision_list) {
            coins.remove(coin);
            score++;
        }
    }
    collision_list = checkCollisionList(player, collectables);
        if (collision_list.size() > 0) {
            coin.play();
        for (int i = 0; i<collision_list.size(); i++) {
              collectables.remove(i);
              score+=5;
        }
    }  
}
void nextLevel(){
  if(player.center_x >= nextBorder){
    player.center_x = nextBorder + 1000;
    nextBorder += 5000;
    player.lives++;
    level++;
  }
  if (level >= 3){
    isGameOver = true;
  }
  
}
public boolean isOnPlatforms(Sprite s, ArrayList < Sprite > walls) {
    s.center_y += 5;
    ArrayList < Sprite > collision_list = checkCollisionList(s, walls);
    s.center_y -= 5;    
    return collision_list.size() > 0;
}
void reset(){
  bgMusic.stop();
  if(keyCode == 32){
    setup();
  }
}
void checkDeath() {
   boolean death = player.getBottom() > 650;
   for(int i =0; i<enemies.size(); i++){
          if(checkCollision(player, enemies.get(i))){
            if(player.getBottom() <= 15 + enemies.get(i).getTop()){
              enemies.remove(i);
              player.change_y = -5;
              coin.play();
              score++;
            }
            else{
              death = true;
           }
        }
   }
    if (player.lives == 0) {
       gameOver.play();
       isGameOver = true;
    }
    if (death) {
        player.lives--;
        lifeLost.play();
        view_y = 0;
        player.center_x = nextBorder - 3900;
        player.setBottom(550);
    }
}

void displayStuff() {
    for (Sprite s: platforms) {
        s.display();
    }
    for (Sprite c: coins) {
        c.display();
        ((AnimatedSprite) c).updateAnimation();
    }
    for (Sprite c : collectables){
      c.display();
    }
    for (Sprite c : noCollision){
      c.display();
    }
    for (Enemy e: enemies) {
        e.display();
        e.update();
        ((AnimatedSprite) e).updateAnimation();
    }
    player.display();
}
public void resolvePlatformCollisions(Sprite s, ArrayList < Sprite > walls) {
    s.change_y += GRAVITY;
    s.center_y += s.change_y;
    ArrayList < Sprite > col_list = checkCollisionList(s, walls);
    if (col_list.size() > 0) {
        Sprite collided = col_list.get(0);
        if (s.change_y > 0) {
            s.setBottom(collided.getTop());
        } else if (s.change_y < 0) {
            s.setTop(collided.getBottom());
        }
        s.change_y = 0;
    }
    s.center_x += s.change_x;
    col_list = checkCollisionList(s, walls);
    if (col_list.size() > 0) {
        Sprite collided = col_list.get(0);
        if (s.change_x > 0) {
            s.setRight(collided.getLeft());
        } else if (s.change_x < 0) {
            s.setLeft(collided.getRight());
        }
    }
}

boolean checkCollision(Sprite s1, Sprite s2) {
    boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
    boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
    if (noXOverlap || noYOverlap) {
        return false;
    } else {
        return true;
    }
}
public ArrayList < Sprite > checkCollisionList(Sprite s, ArrayList < Sprite > list) {
    ArrayList < Sprite > collision_list = new ArrayList < Sprite > ();
    for (Sprite p: list) {
        if (checkCollision(s, p))
            collision_list.add(p);
    }
    return collision_list;
}


void createPlatforms(String filename) {
    String[] lines = loadStrings(filename);
    for (int row = 0; row < lines.length; row++) {
        String[] values = split(lines[row], ",");
        for (int col = 0; col < values.length; col++) {
            if (values[col].equals("1")) {
                Sprite s = new Sprite(red_brick, SPRITE_SCALE);
                s.center_x = SPRITE_SIZE / 2 + col * SPRITE_SIZE;
                s.center_y = SPRITE_SIZE / 2 + row * SPRITE_SIZE;
                platforms.add(s);
            } else if (values[col].equals("2")) {
                Sprite s = new Sprite(snow, SPRITE_SCALE);
                s.center_x = SPRITE_SIZE / 2 + col * SPRITE_SIZE;
                s.center_y = SPRITE_SIZE / 2 + row * SPRITE_SIZE;
                platforms.add(s);
            } else if (values[col].equals("3")) {
                Sprite s = new Sprite(brown_brick, SPRITE_SCALE);
                s.center_x = SPRITE_SIZE / 2 + col * SPRITE_SIZE;
                s.center_y = SPRITE_SIZE / 2 + row * SPRITE_SIZE;
                platforms.add(s);
            } else if (values[col].equals("4")) {
                Sprite s = new Sprite(crate, SPRITE_SCALE);
                s.center_x = SPRITE_SIZE / 2 + col * SPRITE_SIZE;
                s.center_y = SPRITE_SIZE / 2 + row * SPRITE_SIZE;
                platforms.add(s);
            } else if (values[col].equals("5")) {
                Sprite s = new Coin(c, SPRITE_SCALE);
                s.center_x = SPRITE_SIZE / 2 + col * SPRITE_SIZE;
                s.center_y = SPRITE_SIZE / 2 + row * SPRITE_SIZE;
                coins.add(s);
            } else if (values[col].equals("6")) {
                Sprite s = new Sprite(openChest, SPRITE_SCALE);
                s.center_x = SPRITE_SIZE / 2 + col * SPRITE_SIZE;
                s.center_y = SPRITE_SIZE / 2 + row * SPRITE_SIZE;
                collectables.add(s);            
            } else if (values[col].equals("7")) {
                Sprite s = new Sprite(keys, SPRITE_SCALE);
                s.center_x = SPRITE_SIZE / 2 + col * SPRITE_SIZE;
                s.center_y = SPRITE_SIZE / 2 + row * SPRITE_SIZE;
                collectables.add(s);            
            } else if (values[col].equals("8")) {
                Sprite s = new Sprite(flag, SPRITE_SCALE);
                s.center_x = SPRITE_SIZE / 2 + col * SPRITE_SIZE;
                s.center_y = 415;
                noCollision.add(s);            
            } else if (values[col].equals("9")) {
                Sprite s = new Sprite(loadImage("tiles/tile34.png"), SPRITE_SCALE*2);
                s.center_x = SPRITE_SIZE / 2 + col * SPRITE_SIZE;
                s.center_y = SPRITE_SIZE / 2 + row * SPRITE_SIZE;
                platforms.add(s);            
            } else if (Integer.parseInt(values[col])>=60 && Integer.parseInt(values[col])<=70) {
                float gap = col * SPRITE_SIZE;
                float bLeft = 0;
                float bRight = (Integer.parseInt(values[col])%10 )* 50;
                Enemy enemy = new Enemy(spider, 50 / 72.0, bLeft + gap, bRight + gap);
                enemy.center_x = SPRITE_SIZE + col * SPRITE_SIZE;
                enemy.center_y = SPRITE_SIZE + row * SPRITE_SIZE - 15;
                enemies.add(enemy);
            }
            else{
            }
        }
    }
}



void scroll() {
    right_boundary = view_x + width - RIGHT_MARGIN;
    if (player.getRight() > right_boundary) {
        view_x += player.getRight() - right_boundary;
    }
    left_boundary = view_x + LEFT_MARGIN;
    if (player.getLeft() < left_boundary) {
        view_x -= (left_boundary - player.getLeft());
    }
    top_boundary = view_y + VERTICAL_MARGIN;
    if (player.getTop() < top_boundary) {
        view_y -= top_boundary - player.getTop();
    }
    bottom_boundary = view_y + height - VERTICAL_MARGIN;
    if (player.getBottom() > bottom_boundary) {
        view_y += player.getBottom() - bottom_boundary;
    }
    translate(-view_x, -view_y);
}
void keyPressed() {
    if (keyCode == 68) {
        player.change_x = MOVE_SPEED;
    } else if (keyCode == 65) {
        player.change_x = -MOVE_SPEED;
    }
    else if ((key == 'w' || keyCode == 32) && isOnPlatforms(player, platforms)) {
        player.change_y = -JUMP_SPEED;
        jump.play();
    }
}
void keyReleased() {
    if (keyCode == 65) {
        player.change_x = 0;
    } else if (keyCode == 68) {
        player.change_x = 0;
    }
}
