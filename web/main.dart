import 'dart:html';
import 'dart:math';

CanvasElement canvas = CanvasElement()..width = 400..height=400;
List<Pawn> pawnList = <Pawn>[];
List<Tile> tileList = <Tile>[];
List<Mark> markList = <Mark>[];
List<Move> moveQueue = <Move>[];
List<Move> turnMarks = <Move>[];
Pawn selected;
Mode mode = Mode.neutral;

void main() {
  final Element output = querySelector('#output');
  output.append(canvas);
  tileList.addAll(superHex(3));
  for(final Tile tile in tileList){
    tile.draw();
  }
  pawnList.add(Pawn.coords(3, 3, <int>[0, 51, 0])..draw());
  pawnList.add(Pawn.coords(0, 0, <int>[0, 51, 0])..draw());
  pawnList.add(Pawn.coords(-2, -3, <int>[0, 51, 0])..draw());
  canvas.onClick.listen(handleClick);

}
void handleClick(MouseEvent e){
  canvas.context2D.setFillColorRgb(255, 255, 255);
  canvas.context2D.fillRect(0, 0, canvas.height, canvas.width);
  final Point<num> p = getEventPoint(e);
  for(final Pawn p in pawnList){
    p.color = p.baseColor;
  }
  markList.clear();
  if(mode == Mode.neutral){
    handleNeutralClick(p);
  }else if(mode == Mode.moving){
    handleMoveClick(p);
  }
  for(final Tile tile in tileList){
    tile.draw();
  } for(final Move move in turnMarks){
    move.draw();
  } for(final Mark mark in markList){
    mark.draw();
  } for(final Pawn pawn in pawnList){
    pawn.draw();
  } for(final Move move in moveQueue){
    move.draw();
  }
}
void handleNeutralClick(Point<num> p){
//  moveQueue.clear();
  final Pawn target = pawnList.firstWhere((Pawn w) => w.tile.pointInHex(p), orElse: ()=>null);
  if(target != null){
//    target.color = [255, 0, 0];
//    target.draw();
    final Iterable<Tile> adj = getAdjacents(target.tile);
    markList.addAll(adj.map((Tile t) => Mark(t, <int>[255, 255, 0])));
    moveQueue.removeWhere((Move m) => m.source == target.tile);
    selected = target;
    mode = Mode.moving;
  }
}
void handleMoveClick(Point<num> p){
  final Tile target = tileList.firstWhere((Tile w) => w.pointInHex(p), orElse: ()=>null);
  if(target != null){
    selected.color = selected.baseColor;
    final Iterable<Tile> adj = getAdjacents(selected.tile);
    if (adj.contains(target) && !pawnList.any((Pawn w)=> w.tile == target)){
      moveQueue.add(MoveMove(selected.tile, relativeDirection(selected.tile, target)));
//      selected.tile = target;
    }
  }
  selected = null;
  mode = Mode.neutral;
}
Direction relativeDirection(Tile origin, Tile target){
  final int rDelta = origin.row - target.row;
  final int cDelta = origin.column - target.column;
  if(cDelta == -1){
    return rDelta == -1 ? Direction.southeast : Direction.northeast;
  }else if(cDelta == 0){
    return rDelta == -1 ? Direction.south : Direction.north;
  }else{
    return rDelta == 0 ? Direction.southwest : Direction.northwest;
  }
}
Iterable<Tile> getAdjacents(Tile target) => tileList.where((Tile t){
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
  final List<Tile> ret = <Tile>[];
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
  static const int xOffset = 200;
  static const int yOffset = 200;

  final int row;
  final int column;
  final CanvasElement board;
  Tile(this.row, this.column, this.board);

  void draw([List<int> color]){
    final bool willColor = color != null;
    if(willColor){
      this.board.context2D.setFillColorRgb(color[0], color[1], color[2]);
    }
    drawHex(centerX , centerY, radius * innerScale, board, willColor);
    drawHex(centerX, centerY, radius, canvas);
    drawSpokes(centerX, centerY, radius * innerScale, radius, canvas);

  }
  void drawEdge(List<int> color, Direction direction){
    drawTrapezoid(centerX, centerY, direction, radius * innerScale, radius, canvas, color);
  }
  bool pointInHex(Point<num> p){
    final Point<num> rp = Point<num>((p.x - centerX).abs(), (p.y - centerY).abs());
    final bool vertTest = rp.x < radius * sqrt(3) / 2;
    final bool slopeTest = rp.y < radius - rp.x / 2;
    return vertTest && slopeTest;
  }
  num get centerX => column * radius * 3/2 + xOffset;
  num get centerY => row * radius * sqrt(3) - column * radius * sqrt(3) / 2 + yOffset;
}
Tile tileByCoords(int r, int c) => tileList.firstWhere((Tile t)=>
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
  void draw(){
    tile.draw(color);
  }
}
class Mark{
  final List<int> color;
  final Tile tile;
  Mark(this.tile, this.color);
  void draw(){
    tile.draw(color);
  }
}
void drawHex(num x, num y, num r, CanvasElement canvas, [bool fill = false]){
  final CanvasRenderingContext2D ctx = canvas.context2D;
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
  final CanvasRenderingContext2D ctx = canvas.context2D;
  ctx.beginPath();
  for(int i = 0; i < 6; i++){
    ctx.moveTo(x + r1*cos(i * pi/3), y + r1*sin(i * pi/3));
    ctx.lineTo(x + r2*cos(i * pi/3), y + r2*sin(i * pi/3));
  }
  ctx.stroke();
}

void drawTrapezoid(num centerX, num centerY, Direction direction,num r1, num r2, CanvasElement canvas, List<int> color) {
  final CanvasRenderingContext2D ctx = canvas.context2D;
  ctx.setFillColorRgb(color[0], color[1], color[2]);
  final double rotation = directionToRotation(direction);
  final double firstX = centerX + r1 * cos(rotation + pi/6);
  final double firstY = centerY + r1 * sin(rotation + pi/6);
  final double secondX = centerX + r2 * cos(rotation + pi/6);
  final double secondY = centerY + r2 * sin(rotation + pi/6);
  final double thirdX = centerX + r1 * cos(rotation - pi/6);
  final double thirdY = centerY + r1 * sin(rotation - pi/6);
  final double fourthX = centerX + r2 * cos(rotation - pi/6);
  final double fourthY = centerY + r2 * sin(rotation - pi/6);
  ctx.beginPath();
  ctx.moveTo(firstX, firstY);
  ctx.lineTo(secondX, secondY);
  ctx.lineTo(fourthX, fourthY);
  ctx.lineTo(thirdX, thirdY);
  ctx.closePath();
  ctx.fill();
  ctx.stroke();
}
Point<num> getEventPoint(MouseEvent e){
  final CanvasElement target = e.target;
  final Rectangle<num> rect = target.getBoundingClientRect();
  return Point<num>(e.client.x-rect.left, e.client.y-rect.top);
}
enum Mode{
  neutral,
  moving
}
enum Direction{
  northeast,
  north,
  northwest,
  southwest,
  south,
  southeast
}
abstract class Move{
  final Tile source;
  final Direction direction;
  bool executed = false;
  Move(this.source, this.direction);
  void draw();
  void call();
}
class MoveMove extends Move{
  MoveMove(Tile e, Direction d):super(e, d);
  @override
  void draw(){
    if(executed){
      for(final Direction d in Direction.values){
        drawTrapezoid(source.centerX, source.centerY, d, Tile.radius * Tile.innerScale, Tile.radius, canvas, <int>[0, 51, 0]);
      }
      drawTrapezoid(source.centerX, source.centerY, direction, Tile.radius * Tile.innerScale, Tile.radius, canvas, <int>[255, 255, 0]);
    }else{
      drawTrapezoid(source.centerX, source.centerY, direction, Tile.radius * Tile.innerScale, Tile.radius, canvas, <int>[255, 255, 0]);
    }
  }
  @override
  void call() {
    // TODO: implement call
  }
}
double directionToRotation(Direction direction) {
  switch (direction) {
    case Direction.southeast:
      return pi / 6;
      break;
    case Direction.south:
      return pi/2;
      break;
    case Direction.southwest:
      return 5 * pi / 6;
      break;
    case Direction.northwest:
      return 7 * pi / 6;
      break;
    case Direction.north:
      return 3 * pi / 2;
      break;
    case Direction.northeast:
      return 11 * pi / 6;
      break;
    default:
      throw(Error());
  }
}