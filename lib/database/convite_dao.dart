import 'package:sqflite/sqflite.dart';
import 'package:trab_final/database/app.database.dart';
import 'package:trab_final/models/Convite.dart';





class conviteDao {

  static const String _tableName = 'convites';
  static const String _id = 'id';
  static const String _evento = 'evento';
  static const String _descricao = 'descricao';
  static const String _userLat = 'userLat';
  static const String _userLong = 'userLong';
  static const String tableSQL = 'CREATE TABLE $_tableName('
      '$_id INTEGER PRIMARY KEY, '
      '$_evento TEXT,'
      '$_descricao TEXT,'
      '$_userLat double,'
      '$_userLong double)';

  Future<int> save(Convite convite) async{
    final Database db = await getDatabase();
    Map<String, dynamic> conviteMap = toMap(convite);
    return db.insert(_tableName, conviteMap);
  }

  Future<int> update(Convite convite) async{
    final Database db = await getDatabase();
    Map<String, dynamic> conviteMap = toMap(convite);
    return db.update(_tableName, conviteMap, where: '$_id = ?', whereArgs: [convite.id]);
  }

  Future<int> delete(int id) async{
    final Database db = await getDatabase();
    return db.delete(_tableName, where: '$_id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> toMap(Convite convite) {
    final Map<String, dynamic> conviteMap = Map();
    conviteMap[_evento] = convite.evento;
    conviteMap[_descricao] = convite.descricao;
    conviteMap[_userLat] = convite.userLat;
    conviteMap[_userLong] = convite.userLong;
    return conviteMap;
  }

  Future<List<Convite>> findAll() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    List<Convite> convites = toList(result);
    return convites;
  }

  List<Convite> toList(List<Map<String, dynamic>> result) {
    final List<Convite> convites = [];
    for (Map<String, dynamic> row in result) {
      final Convite convite = Convite(
          row['$_id'],
          row[_evento],
          row[_descricao],
          row[_userLat],
          row[_userLong]
      );
      convites.add(convite);
    }
    return convites;
  }
}