/* @pjs preload="tetra.ply, icos.ply, octa.ply, star.ply, torus.ply"; */

// Sample code for starting the meshes project

import processing.opengl.*;
import java.util.*;
float time = 0;  // keep track of passing of time (for automatic rotation)
boolean rotate_flag = false;       // automatic rotation of model?
boolean per_vertex_flag = false;       // start with non per vertex
boolean random_color_flag = false;    // start with white
List<Corner> geometryTable = new ArrayList<Corner>();
List<Corner> vertexTable = new ArrayList<Corner>();
color[] randomColorArray;
int[] oppositeTable;

// initialize stuff
void setup() {
  size(400, 400, OPENGL);  // must use OPENGL here !!!
  noStroke();     // do not draw the edges of polygons
}

// Draw the scene
void draw() {
  
  resetMatrix();  // set the transformation matrix to the identity (important!)

  background(0);  // clear the screen to black
  
  // set up for perspective projection
  perspective (PI * 0.333, 1.0, 0.01, 1000.0);
  
  // place the camera in the scene (just like gluLookAt())
  camera (0.0, 0.0, 5.0, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);
  
  scale (1.0, -1.0, 1.0);  // change to right-handed coordinate system
  
  // create an ambient light source
  ambientLight(102, 102, 102);
  
  // create two directional light sources
  lightSpecular(204, 204, 204);
  directionalLight(102, 102, 102, -0.7, -0.7, -1);
  directionalLight(152, 152, 152, 0, 0, -1);

  pushMatrix();

  fill(200, 200, 200);            // set polygon color to blue
  ambient (200, 200, 200);
  specular(0, 0, 0);
  shininess(1.0);
  
  rotate (time, 1.0, 0.0, 0.0);
  
  // THIS IS WHERE YOU SHOULD DRAW THE MESH
  if (!vertexTable.isEmpty()) {
    for (int i = 0; i < vertexTable.size(); i += 3) {
      Corner c0 = vertexTable.get(i);
      Corner c1 = vertexTable.get(i + 1);
      Corner c2 = vertexTable.get(i + 2);
//      println(c0 + " " + c1 + " "  + c2);
      float[] norm;
      
      if (random_color_flag) {
         fill(randomColorArray[i/3]);
      }
      
      beginShape();
      
      if (!per_vertex_flag) {
        norm = c0.faceNormal();
      } else {
        norm = c0.vertexNormal();
      }
      normal(norm[0], norm[1], norm[2]);
      vertex (c0.x, c0.y, c0.z);
      if (per_vertex_flag) {
       norm = c1.vertexNormal();
       normal(norm[0], norm[1], norm[2]);
      }
      vertex (c1.x, c1.y, c1.z);
      if (per_vertex_flag) {
       norm = c2.vertexNormal();
       normal(norm[0], norm[1], norm[2]);
      }
      vertex (c2.x, c2.y, c2.z);
      endShape(CLOSE);

    }
  }
//  beginShape();
//  normal (0.0, 0.0, 1.0);
//  vertex (-1.0, -1.0, 0.0);
//  vertex ( 1.0, -1.0, 0.0);
//  vertex ( 1.0,  1.0, 0.0);
//  vertex (-1.0,  1.0, 0.0);
//  endShape(CLOSE);
  
  popMatrix();
 
  // maybe step forward in time (for object rotation)
  if (rotate_flag)
    time += 0.02;
}

// handle keyboard input
void keyPressed() {
  if (key == '1') {
    read_mesh ("tetra.ply");
  }
  else if (key == '2') {
    read_mesh ("octa.ply");
  }
  else if (key == '3') {
    read_mesh ("icos.ply");
  }
  else if (key == '4') {
    read_mesh ("star.ply");
  }
  else if (key == '5') {
    read_mesh ("torus.ply");
  }
  else if (key == ' ') {
    rotate_flag = !rotate_flag;          // rotate the model?
  }else if (key == 'n') {
    //toggle per-vertex shading
    per_vertex_flag = !per_vertex_flag;
  }else if (key == 'r') {
    //randomly color faces
    random_color_flag = true;
    buildRandomTable();
  }else if (key == 'w') {
    //color faces white
    random_color_flag = false;
  }else if (key == 'd') {
    //calculate mesh dual
    buildDual();
    buildRandomTable();
  }else if (key == 'q' || key == 'Q') {
    exit();                               // quit the program
  }
}

// Read polygon mesh from .ply file
//
// You should modify this routine to store all of the mesh data
// into a mesh data structure instead of printing it to the screen.
void read_mesh (String filename)
{
  int i;
  String[] words;
  
  String lines[] = loadStrings(filename);
  
  words = split (lines[0], " ");
  int num_vertices = int(words[1]);
  println ("number of vertices = " + num_vertices);
  
  
  words = split (lines[1], " ");
  int num_faces = int(words[1]);
  println ("number of faces = " + num_faces);
  
  geometryTable = new ArrayList<Corner>();
  vertexTable = new  ArrayList<Corner>();
  
  // read in the vertices
  for (i = 0; i < num_vertices; i++) {
    words = split (lines[i+2], " ");
    float x = float(words[0]);
    float y = float(words[1]);
    float z = float(words[2]);
//    println ("vertex = " + x + " " + y + " " + z);
    geometryTable.add(new Corner(i, x,y,z));
  }
  
  randomColorArray = new color[num_faces];
  // read in the faces
  for (i = 0; i < num_faces; i++) {
    
    int j = i + num_vertices + 2;
    words = split (lines[j], " ");
    
    int nverts = int(words[0]);
    if (nverts != 3) {
      println ("error: this face is not a triangle.");
      exit();
    }
    
    int index1 = int(words[1]);
    int index2 = int(words[2]);
    int index3 = int(words[3]);
//    println ("face = " + index1 + " " + index2 + " " + index3);
//    println("nextSize: " + vertexTable.size());
    vertexTable.add(new Corner(vertexTable.size(), geometryTable.get(index1)));
    vertexTable.add(new Corner(vertexTable.size(), geometryTable.get(index2)));
    vertexTable.add(new Corner(vertexTable.size(), geometryTable.get(index3)));
    if (random_color_flag) {
      randomColorArray[i] = color(random(255),random(255),random(255)); 
    }
  }
  
  buildOppositeTable();
}

public void buildRandomTable() {
   randomColorArray = new color[vertexTable.size() / 3];
   for (int i = 0; i < vertexTable.size(); i += 3) {
     randomColorArray[i / 3] = color(random(255),random(255),random(255)); 
   } 
}

public void buildOppositeTable() {
  oppositeTable = new int[vertexTable.size()];
  for (Corner a : vertexTable) {
    for (Corner b : vertexTable) {
      if (a.n().v == b.p().v && a.p().v == b.n().v) {
         oppositeTable[a.i] = b.i;
         oppositeTable[b.i] = a.i;
      }
    }
  }
}

public void buildDual() {
  List<Corner> newGeometryTable = new ArrayList<Corner>();
  List<Corner> newVertexTable = new ArrayList<Corner>();
  for (int i = 0; i < vertexTable.size(); i += 3) {
     Corner newCorner = vertexTable.get(i).centroid(i/3); // create a centroid in Vertex Table at index of triangle
     newGeometryTable.add(newCorner);
  }
//  println("geometryTable : " + newGeometryTable);
  for (int i = 0; i < geometryTable.size(); i++) {
//      iterate through current vertices and create triangles that triangulate the shape formed
//      by the vertices of faces adjacent to every vertex.
      Corner startCorner = null;
//      println("i: " + i);
      for (Corner c : vertexTable) {
         if (c.v == i) {
            startCorner = c;
         } 
      }
      if (startCorner == null) {
         println("error"); 
      }
//      Now that we have the start corner we can go around this to create a shape in triangles
      
      
      List<Corner> adjacentCentroids = new ArrayList<Corner>();
      adjacentCentroids.add(newGeometryTable.get(startCorner.t()));
      Corner nextCorner = startCorner.s();
//      println("geometry Now: " + newGeometryTable);
      while (nextCorner != startCorner) {
//        println("this t: " + nextCorner.t());
        adjacentCentroids.add(newGeometryTable.get(nextCorner.t()));
        nextCorner = nextCorner.s();
      }
//      println("adj: " + adjacentCentroids);
      float[] location = new float[3];
      for (Corner c : adjacentCentroids) {
         location[0] += c.x / adjacentCentroids.size();
         location[1] += c.y / adjacentCentroids.size();
         location[2] += c.z / adjacentCentroids.size();
      }
//      println("x : " + location[0] + " y " + location[1] + " z " + location[2]);
      Corner center = new Corner(newGeometryTable.size(), location[0], location[1], location[2]);
      newGeometryTable.add(center);
      for (int j = 0; j < adjacentCentroids.size(); j++) {
          newVertexTable.add(new Corner(newVertexTable.size(), center));
          newVertexTable.add(new Corner(newVertexTable.size(), adjacentCentroids.get(j)));
//          the mod is to get you back to the start at the end

          newVertexTable.add(new Corner(newVertexTable.size(), adjacentCentroids.get((j + 1) % adjacentCentroids.size()))); 
          
      }
      
  }
  
  vertexTable = newVertexTable;
  geometryTable = newGeometryTable;
//  println("vertex Table: " + vertexTable + " size: " + vertexTable.size());
//  println("geomertry Table: " + geometryTable + " " + geometryTable.size());
  buildOppositeTable();
}


class Corner {
  public int i;
  public int v;
  public float x;
  public float y;
  public float z;
  
  public Corner(int v, float x, float y, float z) {
    this.v = v;
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public Corner(int i, Corner c) {
    this.i = i;
    this.v = c.v;
    this.x = c.x;
    this.y = c.y;
    this.z = c.z;
  }
  
  
  public int t() {
    return  i / 3;
  }

  public Corner n() {
    return vertexTable.get(3 * this.t() + (i + 1) % 3); 
  }

  public Corner p() {
     return this.n().n();
  }

  public Corner o() {
     return vertexTable.get(oppositeTable[i]);
  }

  public Corner s() {
     return this.n().o().n(); 
  }
  
  public Corner u() {
     return this.p().o().p(); 
  }

  float[] vertexNormal() {
     float[] normSum = this.faceNormal();
     Corner next = this.s();
     while(next != this) {
       float[] toAdd = next.faceNormal();
       normSum[0] += toAdd[0];
       normSum[1] += toAdd[1];
       normSum[2] += toAdd[2];
       next = next.s();  
     }
     float size = sqrt(normSum[0] * normSum[0] + normSum[1] * normSum[1] + normSum[2]* normSum[2]);
     normSum[0] /= size;
     normSum[1] /= size;
     normSum[2] /= size;
     return normSum;
  }

  public float[] toVector(Corner b) {
    return new float[]{b.x - x, b.y - y, b.z - z}; 
  }
  public float[] faceNormal() {
    float[] u = this.toVector(this.n());
    float[] v = this.toVector(this.p());
    
    float crossx = u[1] * v[2] - u[2] * v[1];
    float crossy = u[2] * v[0] - u[0] * v[2];
    float crossz = u[0] * v[1] - u[1] * v[0];
    return new float[]{crossx, crossy, crossz};
  }
  
  public Corner centroid(int newV) {
    Corner a = n();
    Corner b = p();
    float newX = (x + a.x + b.x) / 3.0;
    float newY = (y + a.y + b.y) / 3.0;
    float newZ = (z + a.z + b.z) / 3.0;
    return new Corner(newV, newX, newY, newZ);
  }
  
  public String toString() {
    return "Corner{i: " + i + ", v: " + v + ", x: " + x + ", y: " + y + ", z: " + z + "} ";
  }
}

