enum PoleType {
  NORTH,
  SOUTH 
}

class Monopole {
  PVector pos;
  PVector vel;
  float strength;
  PoleType poleType;
  
  public Monopole(float x, float y, PoleType poleType, float strength) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    this.strength = strength;
    this.poleType = poleType;
  }
  
  void tick() {
    pos.add(vel);
  }
  
  void draw() {
    stroke(224);
    strokeWeight(10);
    point(pos.x, pos.y);
  }
  
  void interact(Monopole other) {
    PVector force = other.pos.copy();
    force.sub(this.pos.copy());
    float dist = force.mag();
    force.normalize();
    force.div(dist * dist);
    force.mult(this.strength * other.strength);
    if (this.poleType == other.poleType) {
      force.mult(-1);
    }
    vel.add(force);
  }
}
