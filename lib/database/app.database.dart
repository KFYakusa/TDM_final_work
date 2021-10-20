import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trab_final/database/convite_dao.dart';

Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'dbConvites.db');
  return openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(conviteDao.tableSQL);
    },
    version: 1,
    onDowngrade: onDatabaseDowngradeDelete,
  );
}
