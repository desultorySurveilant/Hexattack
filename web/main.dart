import 'dart:html';


TextAreaElement board = TextAreaElement();
void main() {
  Element output = querySelector('#output');
  TextInputElement moves = TextInputElement();
  output.append(moves);
  output.append(board);

  moves.onBlur.listen(handleMove);
}

String handleInput(Event e) => (e.target as InputElement).value;
void handleMove(Event e){
  List<String> input = handleInput(e).split(' ');
  Pawn pawn = Pawn(int.parse(input[0]), int.parse(input[1]), board);
  pawn.draw();
}

class Pawn{
  int row;
  int column;
  TextAreaElement board;
  Pawn(this.row, this.column, this.board);

  void draw(){
    board.text = "($row, $column)";
  }
}