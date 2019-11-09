import 'dart:html';

import 'dart:math';



TextAreaElement board = TextAreaElement();
CanvasElement canvas = CanvasElement()..width = 400..height=400;
List<Pawn> pawnList = List();
List<Tile> tileList = List();
List<Mark> markList = List();
Pawn selected = null;
Mode mode = Mode.neutral;

void main() {
  Element output = querySelector('#output');
  output.append(canvas);
  tileList.addAll(superHex(4));
  tileList.forEach((t)=>t.draw());
  pawnList.add(Pawn.coords(3, 4, [0, 51, 0])..draw());
  pawnList.add(Pawn.coords(0, 0, [0, 51, 0])..draw());
  pawnList.add(Pawn.coords(-2, -3, [0, 51, 0])..draw());
  canvas.onClick.listen(handleClick);

}
void handleClick(MouseEvent e){
  canvas.context2D.setFillColorRgb(255, 255, 255);
  canvas.context2D.fillRect(0, 0, canvas.height, canvas.width);
  Point p = getEventPoint(e);
  pawnList.forEach((e) {
    e.color = e.baseColor;
  });
  markList.clear();
  if(mode == Mode.neutral){
    handleNeutralClick(p);
  }else if(mode == Mode.moving){
    handleMoveClick(p);
  }
  tileList.forEach((t)=>t.draw());
  markList.forEach((m) => m.draw());
  pawnList.forEach((p) => p.draw());
}
void handleNeutralClick(Point p){
  Pawn target = pawnList.firstWhere((w) => w.tile.pointInHex(p), orElse: ()=>null);
  if(target != null){
    target.color = [255, 0, 0];
    target.draw();
    Iterable<Tile> adj = getAdjacents(target.tile);
    markList.addAll(adj.map((t) => Mark(t, [255, 255, 0])));
    selected = target;
    mode = Mode.moving;
  }
}
void handleMoveClick(Point p){
  Tile target = tileList.firstWhere((w) => w.pointInHex(p), orElse: ()=>null);
  if(target != null){
    selected.color = selected.baseColor;
    Iterable<Tile> adj = getAdjacents(selected.tile);
    if (adj.contains(target) && !pawnList.any((w)=> w.tile == target)){
      selected.tile = target;
    }
  }
  mode = Mode.neutral;
}
Iterable<Tile> getAdjacents(Tile target) => tileList.where((t){
  final int rDelta = target.row - t.row;
  final int cDelta = target.column - t.column;
  if(rDelta.abs() + cDelta.abs() == 1){
    return true;
  }else if(rDelta == cDelta && rDelta.abs() == 1){
    return true;
  }else{
    return false;
  }
});
List<Tile> superHex(int n){
  List<Tile> ret = List();
  for(int i = -n; i <= n; i++){
    for(int j = max(-n, -n + i); j <= min(n, n + i); j++){
      ret.add(Tile(i, j, canvas));
    }
  }
  return ret;
}

class Tile{
  static const num radius = 24;
  static const num innerScale = 3/4;
  static const xOffset = 200;
  static const yOffset = 200;

  final int row;
  final int column;
  final CanvasElement board;
  Tile(this.row, this.column, this.board);
  Point p = Point(0,0);

  void draw([List<int> color]){
    bool willColor = color != null;
    if(willColor){
      this.board.context2D.setFillColorRgb(color[0], color[1], color[2]);
    }
    drawHex(centerX , centerY, radius * innerScale, board, willColor);
    drawHex(centerX, centerY, radius, canvas);
    drawSpokes(centerX, centerY, radius * innerScale, radius, canvas);

  }
  bool pointInHex(Point p){
    final Point rp = Point((p.x - centerX).abs(), (p.y - centerY).abs());
    bool vertTest = rp.x < radius * sqrt(3) / 2;
    bool slopeTest = rp.y < radius - rp.x / 2;
    return vertTest && slopeTest;
  }
  num get centerX => column * radius * 3/2 + xOffset;
  num get centerY => row * radius * sqrt(3) - column * radius * sqrt(3) / 2 + yOffset;
}
Tile tileByCoords(int r, int c) => tileList.firstWhere((t)=>
  t.row == r && t.column == c
, orElse: ()=>null);

class Pawn{
  final List<int> baseColor;
  List<int> color;
  Tile tile;
  Pawn(this.tile, this.baseColor){
    color = baseColor;
  }
  Pawn.coords(int r, int c, this.baseColor){
    color = baseColor;
    tile = tileByCoords(r, c);
  }
  draw(){
    tile.draw(color);
  }
}
class Mark{
  final List<int> color;
  final tile;
  Mark(this.tile, this.color);
  draw(){
    tile.draw(color);
  }
}
void drawHex(num x, num y, num r, CanvasElement canvas, [fill = false]){
  CanvasRenderingContext2D ctx = canvas.context2D;
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  for(int i = 1; i <= 6; i++){
    ctx.lineTo(x + r*cos(i * pi/3), y + r*sin(i * pi/3));
  }
  if(fill){
    ctx.fill();
  }
  ctx.stroke();
}
void drawSpokes(num x, num y, num r1, num r2, CanvasElement canvas){
  CanvasRenderingContext2D ctx = canvas.context2D;
  ctx.beginPath();
  for(int i = 0; i < 6; i++){
    ctx.moveTo(x + r1*cos(i * pi/3), y + r1*sin(i * pi/3));
    ctx.lineTo(x + r2*cos(i * pi/3), y + r2*sin(i * pi/3));
  }
  ctx.stroke();
}

Point getEventPoint(MouseEvent e){
  CanvasElement target = e.target;
  Rectangle rect = target.getBoundingClientRect();
  return Point(e.client.x-rect.left, e.client.y-rect.top);
}
enum Mode{
  neutral,
  moving
}