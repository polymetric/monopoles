ArrayList<Monopole> poles;

void setup() {
  size(800, 800);
  frameRate(60);
  
  poles = new ArrayList<Monopole>();
  
  poles.add(new Monopole(400, 400, PoleType.NORTH, 10));
  poles.add(new Monopole(300, 350, PoleType.SOUTH, 10));
}

void draw() {
  background(32);
  for (Monopole p : poles) {
    p.tick();
    for (Monopole p2 : poles) {
      if (p != p2) {
        p.interact(p2);
      }
    }
    p.draw();
  }
}
