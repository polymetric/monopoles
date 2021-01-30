class Magnet {
  float w, h;
  float strength;
  Monopole north, south;
  boolean updatedPolePosThisTick = false;
  Group group;
  
  Body body;
  
  public Magnet(Vec2 pos, float angle, float w, float h, BodyType bodyType, Group group, float strength, float density) {
    this.w = w;
    this.h = h;
    
    this.group = group;
    
    this.strength = strength;
    north = new Monopole(this, new Vec2(0, 0), PoleType.NORTH, strength);
    south = new Monopole(this, new Vec2(0, 0), PoleType.SOUTH, strength);
    
    // body definition
    BodyDef bd = new BodyDef();
    bd.type = bodyType;
    bd.position.set(pos);
    bd.angle = angle;
    
    // create body
    body = box2d.createBody(bd);
    
    // create shape
    PolygonShape polygon = new PolygonShape();
    polygon.setAsBox(w/2, h/2);
    
    // fixture definition
    FixtureDef fd = new FixtureDef();
    fd.shape = polygon;
    
    fd.density = density;
    fd.friction = 10000;
    fd.restitution = 0;
    
    // create fixture
    body.createFixture(fd);
  }
  
  void draw() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float angle = body.getAngle();
    
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-angle);
    fill(224);
    noStroke();
    rectMode(CENTER);
    rect(0, 0, box2d.scalarWorldToPixels(w), box2d.scalarWorldToPixels(h));
    popMatrix();
    
    north.draw();
    south.draw();
  }
  
  void updatePolePositions() {
    Vec2 offset = new Vec2(0, 0);
    offset.x = cos(this.body.getAngle());
    offset.y = sin(this.body.getAngle());
    offset.mulLocal(w/2 * 0.90);
    
    this.north.pos = this.body.getPosition().add(offset);
    offset.negateLocal();
    this.south.pos = this.body.getPosition().add(offset);
    
    this.north.strength = this.strength;
    this.south.strength = this.strength;
  }
  
  void interact(Magnet other) {
    this.north.interact(other.north);
    this.north.interact(other.south);
    this.south.interact(other.north);
    this.south.interact(other.south);
  }
}

enum Group {
  STATOR,
  ROTOR,
}
