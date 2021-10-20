class Convite{
  final int id;
  String evento;
  String descricao;
  double userLat;
  double userLong;
  Convite(this.id,this.evento,this.descricao,this.userLat,this.userLong);

  @override
  String toString(){
    return 'Convite{ evento:$evento, descricao: $descricao, userLat: $userLat, userLong: $userLong}';
  }
}