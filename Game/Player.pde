public class Player extends AnimatedSprite{
  boolean inPlace;
  PImage[] standLeft;
  PImage[] standRight;
  int lives;
  public Player(PImage img, float scale){
    super(img, scale);
    lives = 3;
    direction = RIGHT_FACING;
    inPlace = true;
    standLeft = new PImage[1];
    standLeft[0] = loadImage("player_stand_left.png");
    standRight = new PImage[1];
    standRight[0] = loadImage("player_stand_right.png");
    moveLeft = new PImage[2];
    moveLeft[0] = loadImage("player_walk_left1.png");
    moveLeft[1] = loadImage("player_walk_left2.png");
    moveRight = new PImage[2];
    moveRight[0] = loadImage("player_walk_right1.png");
    moveRight[1] = loadImage("player_walk_right2.png"); 
    currentImages = standRight;
  }
  @Override
  public void updateAnimation(){
    inPlace = change_x == 0 && change_y ==0;
    super.updateAnimation();
    

  }
  @Override
  public void selectDirection(){
    if(change_x > 0)
      direction = RIGHT_FACING;
    else if(change_x < 0)
      direction = LEFT_FACING;    
  }
  @Override
  public void selectCurrentImages(){
   
    if(direction == RIGHT_FACING){
      if(inPlace){
        currentImages = standRight;
      }
      else
        currentImages = moveRight;
    }
    else{
      if(inPlace){
        currentImages = standLeft;
      }
      else{
        currentImages = moveLeft;
      }
    }

    
  }
}
