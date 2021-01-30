class Bearing {
  float r;
  
  Body body;
  
  public Bearing(Vec2 pos, BodyType bodyType) {
    this.r = r;
    
    // body definition
    BodyDef bd = new BodyDef();
    bd.type = bodyType;
    bd.position.set(pos);
    
    // create body
    body = box2d.createBody(bd);
    
    // create shape
    CircleShape circle = new CircleShape();
    circle.m_radius = r;
    
    // fixture definition
    FixtureDef fd = new FixtureDef();
    fd.shape = circle;
    
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
    ellipseMode(RADIUS);
    circle(0, 0, r);
    popMatrix();
  }
}
