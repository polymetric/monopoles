class Box {
  float w, h;
  
  Body body;
  
  public Box(Vec2 pos, float w, float h, BodyType bodyType) {
    this.w = w;
    this.h = h;
    
    // body definition
    BodyDef bd = new BodyDef();
    bd.type = bodyType;
    bd.position.set(pos);
    
    // create body
    body = box2d.createBody(bd);
    
    // create shape
    PolygonShape polygon = new PolygonShape();
    polygon.setAsBox(w/2, h/2);
    
    // fixture definition
    FixtureDef fd = new FixtureDef();
    fd.shape = polygon;
    
    fd.density = 10;
    fd.friction = 0;
    fd.restitution = 0;
    
    // create fixture
    body.createFixture(fd);
  }
  
  void step() {
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
  }
}
