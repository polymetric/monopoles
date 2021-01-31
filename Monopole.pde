enum PoleType {
  NORTH,
  SOUTH 
}

class Monopole {
  Vec2 pos;
  float strength;
  PoleType poleType;
  Magnet parent;
  
  public Monopole(Magnet parent, Vec2 pos, PoleType poleType, float strength) {
    this.parent = parent;
    this.pos = pos;
    this.strength = strength;
    this.poleType = poleType;
  }
  
  void draw() {
    switch (poleType) {
      case NORTH:
        stroke(224, 32, 32);
        break;
      case SOUTH:
        stroke(32, 32, 224);
        break;
    }
    
    Vec2 posPixels = box2d.coordWorldToPixels(pos);
    
    strokeWeight(10);
    pushMatrix();
    translate(posPixels.x, posPixels.y);
    point(0, 0);
    popMatrix();
  }
  
  void interact(Monopole other) {
    if (parent.body.m_type == BodyType.STATIC) {
      if (forceArrowsEnabled) {
        ForceArrow arrow = new ForceArrow();
        arrow.origin = box2d.coordWorldToPixelsPVector(this.pos);
        arrow.force = new PVector(parent.strength * 5e-1, 0);
        arrow.force.rotate(-parent.body.getAngle());
        forceArrows.add(arrow);
      }
      return;
    }
    Vec2 force = other.pos.sub(this.pos);
    float dist = force.length();
    force.normalize();
    force.mulLocal(1 / (dist * dist));
    force.mulLocal(this.strength * other.strength);
    if (this.poleType == other.poleType) {
      force.negateLocal();
    }
    force.mulLocal(1e5);
    //System.out.printf("%24.12f ", force.length());
    parent.body.applyForce(force, this.pos);
    if (parent.body.m_type == BodyType.DYNAMIC && forceArrowsEnabled) {
      ForceArrow arrow = new ForceArrow();
      arrow.origin = box2d.coordWorldToPixelsPVector(this.pos);
      arrow.force = box2d.vectorWorldToPixelsPVector(force.mul(1e-4));
      forceArrows.add(arrow);
    }
  }
}
