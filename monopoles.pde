import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;

final float PI_23RDS = PI * 2 / 3;

final int statorCoilCount = 21;
final int rotorMagnetCount = 14;

int time;

float voltage;
int phase;

boolean forceArrowsEnabled = false;

Box2DProcessing box2d;

Bearing bearing;
// this is used to link the first rotor magnet to the last one, and it's also used to measure the rotor angle
Magnet firstRotorMagnet;

ArrayList<Magnet> magnets;
ArrayList<Magnet> statorCoils;
ArrayList<Magnet> rotorMagnets;
ArrayList<ForceArrow> forceArrows;

void setup() {
  size(800, 800);
  smooth(8);
  frameRate(600);
  
  phase = 0;
  time = 0;
  firstRotorMagnet = null;

  box2d = new Box2DProcessing(this);
  box2d.createWorld(new Vec2(0, 0));
  
  magnets = new ArrayList<Magnet>();
  statorCoils = new ArrayList<Magnet>();
  rotorMagnets = new ArrayList<Magnet>();
  forceArrows = new ArrayList<ForceArrow>();
  
  //magnets.add(new Magnet(box2d.coordPixelsToWorld(600, 400), 0, 10, 10, BodyType.DYNAMIC, 1, 1));
  //magnets.add(new Magnet(box2d.coordPixelsToWorld(400, 400), 0, 10, 10, BodyType.STATIC, 10, 10));
  //magnets.get(0).body.applyTorque(1e5);
  //magnets.get(0).body.m_sweep.a = -PI / 2;
  
  // stator magnets
  for (int i = 0; i < statorCoilCount; i++) {
    float angle = ((float) i / statorCoilCount) * PI * 2;
    Vec2 pos = new Vec2(0, 0);
    
    pos.x = sin(angle) * 30;
    pos.y = cos(angle) * 30;
    
    Magnet m = new Magnet(pos, -angle - PI / 2, 10, 1, BodyType.STATIC, Group.STATOR, 0, 1);
    magnets.add(m);
    statorCoils.add(m);
  }
  
  bearing = new Bearing(new Vec2(0, 0), BodyType.STATIC);
  
  // rotor magnets
  Magnet lastMagnet = null;
  for (int i = 0; i < rotorMagnetCount; i++) {
    float angle = ((float) i / rotorMagnetCount) * PI * 2;
    Vec2 pos = new Vec2(0, 0);
    
    pos.x = sin(angle) * 10;
    pos.y = cos(angle) * 10;
    
    // alternate magnet rotation
    if (i % 2 == 0) {
      angle = -angle - PI / 2;
    } else {
      angle = -angle + PI / 2;
    }
    Magnet m = new Magnet(pos, angle, 10, 1, BodyType.DYNAMIC, Group.ROTOR, .5, 1);
    magnets.add(m);
    rotorMagnets.add(m);
    
    // figure out which magnet is adjacent
    if (lastMagnet != null) {
      // weld to adjacent magnet
      WeldJointDef jd = new WeldJointDef();
      //jd.localAnchorA = m.body.getPosition();
      //jd.initialize(m.body, lastMagnet.body, m.body.getPosition(), lastMagnet.body.getPosition());
      jd.initialize(m.body, lastMagnet.body, m.body.getPosition());
      jd.frequencyHz = 0;
      jd.dampingRatio = 1;
      box2d.world.createJoint(jd);
    }
    
    if (firstRotorMagnet == null) {
      firstRotorMagnet = m;
    }
    if (i == rotorMagnetCount - 1) {
      // weld to adjacent magnet
      WeldJointDef jd = new WeldJointDef();
      //jd.localAnchorA = m.body.getPosition();
      //jd.initialize(m.body, lastMagnet.body, m.body.getPosition(), lastMagnet.body.getPosition());
      jd.initialize(m.body, firstRotorMagnet.body, m.body.getPosition());
      jd.frequencyHz = 0;
      jd.dampingRatio = 1;
      box2d.world.createJoint(jd);
    }
    
    RevoluteJointDef jd = new RevoluteJointDef();
    jd.initialize(bearing.body, m.body, bearing.body.getWorldCenter());
    jd.motorSpeed = 0;
    jd.maxMotorTorque = 1e3;
    jd.enableMotor = true;
    box2d.world.createJoint(jd);
    
    lastMagnet = m;
  }
}

void draw() {
  background(32);
  
  // temp debug
  //if (mousePressed) {
  //  magnets.get(0).body.setTransform(box2d.coordPixelsToWorld(mouseX, mouseY), magnets.get(0).body.getAngle());
  //}
  
  // commutation
  float rotorpos = rotorMagnets.get(0).body.getAngle();
  // quantize angle to simulate an encoder or magnetic sensor
  int cpr = 2400;
  int rotorposI = (int) (rotorpos / (PI * 2) * cpr);
  rotorpos = (float) rotorposI / cpr * PI * 2;
  
  // PID
  float target = -atan2(mouseX-width/2, mouseY-height/2);
  float error = target - rotorpos;
  
  voltage = map(mouseY, 0, height, -24, 24);
  //voltage = error;
  
  rotorpos = (rotorpos + (PI / 2)) * (rotorMagnetCount / 2);
  
  // 3 phase
  for (int i = 0; i < statorCoilCount; i += 3) {
    statorCoils.get(i+0).strength = sin(rotorpos + PI_23RDS * 0) * voltage;
    statorCoils.get(i+1).strength = sin(rotorpos + PI_23RDS * 1) * voltage;
    statorCoils.get(i+2).strength = sin(rotorpos + PI_23RDS * 2) * voltage;
  }
  
  // 2 phase
  //for (int i = 0; i < statorCoilCount; i += 4) {
  //  statorCoils.get(i+0).strength = sin(rotorpos) *  voltage;
  //  statorCoils.get(i+1).strength = cos(rotorpos) *  voltage;
  //  statorCoils.get(i+2).strength = sin(rotorpos) * -voltage;
  //  statorCoils.get(i+3).strength = cos(rotorpos) * -voltage;
  //}
  
  //switch (phase) {
  //  case 0:
  //    for (int i = 0; i < statorCoilCount; i += 3) {
  //      statorCoils.get(i).strength = voltage;
  //      statorCoils.get(i+1).strength = 0;
  //      statorCoils.get(i+2).strength = 0;
  //    }
  //    break;
  //  case 1:
  //    for (int i = 0; i < statorCoilCount; i += 3) {
  //      statorCoils.get(i).strength = 0;
  //      statorCoils.get(i+1).strength = voltage;
  //      statorCoils.get(i+2).strength = 0;
  //    }
  //    break;
  //  case 2:
  //    for (int i = 0; i < statorCoilCount; i += 3) {
  //      statorCoils.get(i).strength = 0;
  //      statorCoils.get(i+1).strength = 0;
  //      statorCoils.get(i+2).strength = voltage;
  //    }
  //    break;
  //}
  
  // physics
  box2d.step(1.0/600, 10, 8);
  for (Magnet m : magnets) {
    m.updatePolePositions();
    m.draw();
    for (Magnet m2 : magnets) {
      if (m != m2 && m.group != m2.group) {
        m2.updatePolePositions();
        m.interact(m2);
      }
    }
  }
  
  // draw force arrows
  for (ForceArrow a : forceArrows) {
    a.draw();
  }
  forceArrows.clear();
  
  //System.out.printf("%12d %24.12f\n", time, firstRotorMagnet.body.m_torque / (PI * 2) * 60);
  System.out.printf("%12d %24.12f\n", time, firstRotorMagnet.body.getAngularVelocity() / (PI * 2) * 60);
  time += 1;
}

void keyPressed() {
  switch (key) {
    case 'r':
      setup();
      break;
    case 'p':
      phase = (phase + 1) % 3;
  }
}
