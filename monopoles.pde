import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;

Box2DProcessing box2d;

ArrayList<Magnet> magnets;
ArrayList<ForceArrow> forceArrows;

void setup() {
  size(800, 800);
  frameRate(60);

  box2d = new Box2DProcessing(this);
  box2d.createWorld(new Vec2(0, 0));
  
  magnets = new ArrayList<Magnet>();
  forceArrows = new ArrayList<ForceArrow>();
  
  magnets.add(new Magnet(box2d.coordPixelsToWorld(500, 500), 10, 10, BodyType.DYNAMIC, 1, 10));
  magnets.add(new Magnet(box2d.coordPixelsToWorld(500, 300), 10, 10, BodyType.DYNAMIC, 1, 1));
  magnets.get(0).body.applyTorque(1e6);
}

void draw() {
  background(32);
  box2d.step();
  for (Magnet m : magnets) {
    m.updatePolePositions();
    m.draw();
    for (Magnet m2 : magnets) {
      if (m != m2) {
        m2.updatePolePositions();
        m.interact(m2);
      }
    }
  }
  for (ForceArrow a : forceArrows) {
    a.draw();
  }
  forceArrows.clear();
}

void keyPressed() {
  switch (key) {
    case 'r':
      setup();
      break;
  }
}
