import 'dart:html';

import 'dart:math';


TextAreaElement board = TextAreaElement();
CanvasElement canvas = CanvasElement()..width = 300..height=300;

void main() {
  Element output = querySelector('#output');
  TextInputElement moves = TextInputElement();
  output.append(moves);
  output.append(BRElement());

  output.append(canvas);

  moves.onBlur.listen(handleMove);
}

String handleInput(Event e) => (e.target as InputElement).value;
void handleMove(Event e){
  List<String> input = handleInput(e).split(' ');
  Pawn pawn = Pawn(int.parse(input[0]), int.parse(input[1]), canvas);
  pawn.draw();
}

class Pawn{
  int row;
  int column;
  static const num radius = 24;
  static const num innerScale = 3/4;
  CanvasElement board;
  Pawn(this.row, this.column, this.board);

  void draw(){
    num centerX = column * radius * 3/2;
    num centerY = row * radius * sqrt(3) - column * radius * sqrt(3) / 2;
    drawHex(centerX , centerY, radius * innerScale, board);
    drawHex(centerX, centerY, radius, canvas);
    drawSpokes(centerX, centerY, radius * innerScale, radius, canvas);
  }
}
void drawHex(num x, num y, num r, CanvasElement canvas, {num rotation = 0}){
  CanvasRenderingContext2D ctx = canvas.context2D;
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  for(int i = 1; i <= 6; i++){
    ctx.lineTo(x + r*cos(i * pi/3), y + r*sin(i * pi/3));
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