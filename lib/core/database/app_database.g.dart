// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  HazardDao? _hazardDaoInstance;

  CacheDao? _cacheDaoInstance;

  ServiceDao? _serviceDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 4,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `hazards` (`id` TEXT NOT NULL, `title` TEXT NOT NULL, `iconUrl` TEXT NOT NULL, `url` TEXT NOT NULL, `lang` TEXT NOT NULL, `updatedAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `cache` (`key` TEXT NOT NULL, `jsonData` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, PRIMARY KEY (`key`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `services` (`id` TEXT NOT NULL, `title` TEXT NOT NULL, `iconUrl` TEXT NOT NULL, `url` TEXT NOT NULL, `lang` TEXT NOT NULL, `updatedAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  HazardDao get hazardDao {
    return _hazardDaoInstance ??= _$HazardDao(database, changeListener);
  }

  @override
  CacheDao get cacheDao {
    return _cacheDaoInstance ??= _$CacheDao(database, changeListener);
  }

  @override
  ServiceDao get serviceDao {
    return _serviceDaoInstance ??= _$ServiceDao(database, changeListener);
  }
}

class _$HazardDao extends HazardDao {
  _$HazardDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _hazardEntityInsertionAdapter = InsertionAdapter(
            database,
            'hazards',
            (HazardEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'iconUrl': item.iconUrl,
                  'url': item.url,
                  'lang': item.lang,
                  'updatedAt': item.updatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<HazardEntity> _hazardEntityInsertionAdapter;

  @override
  Future<List<HazardEntity>> findAll() async {
    return _queryAdapter.queryList('SELECT * FROM hazards ORDER BY id ASC',
        mapper: (Map<String, Object?> row) => HazardEntity(
            id: row['id'] as String,
            title: row['title'] as String,
            iconUrl: row['iconUrl'] as String,
            url: row['url'] as String,
            lang: row['lang'] as String,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Future<void> clearAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM hazards');
  }

  @override
  Future<void> insertAll(List<HazardEntity> hazards) async {
    await _hazardEntityInsertionAdapter.insertList(
        hazards, OnConflictStrategy.replace);
  }
}

class _$CacheDao extends CacheDao {
  _$CacheDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _cacheEntityInsertionAdapter = InsertionAdapter(
            database,
            'cache',
            (CacheEntity item) => <String, Object?>{
                  'key': item.key,
                  'jsonData': item.jsonData,
                  'timestamp': item.timestamp
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CacheEntity> _cacheEntityInsertionAdapter;

  @override
  Future<CacheEntity?> find(String key) async {
    return _queryAdapter.query('SELECT * FROM cache WHERE `key` = ?1',
        mapper: (Map<String, Object?> row) => CacheEntity(
            key: row['key'] as String,
            jsonData: row['jsonData'] as String,
            timestamp: row['timestamp'] as int),
        arguments: [key]);
  }

  @override
  Future<CacheEntity?> getLatestForecastCache() async {
    return _queryAdapter.query(
        'SELECT * FROM cache WHERE `key` LIKE \'forecast_%\' ORDER BY timestamp DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => CacheEntity(
            key: row['key'] as String,
            jsonData: row['jsonData'] as String,
            timestamp: row['timestamp'] as int));
  }

  @override
  Future<void> upsert(CacheEntity entity) async {
    await _cacheEntityInsertionAdapter.insert(
        entity, OnConflictStrategy.replace);
  }
}

class _$ServiceDao extends ServiceDao {
  _$ServiceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _serviceModelInsertionAdapter = InsertionAdapter(
            database,
            'services',
            (ServiceModel item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'iconUrl': item.iconUrl,
                  'url': item.url,
                  'lang': item.lang,
                  'updatedAt': item.updatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ServiceModel> _serviceModelInsertionAdapter;

  @override
  Future<List<ServiceModel>> findAll() async {
    return _queryAdapter.queryList('SELECT * FROM services ORDER BY id ASC',
        mapper: (Map<String, Object?> row) => ServiceModel(
            id: row['id'] as String,
            title: row['title'] as String,
            iconUrl: row['iconUrl'] as String,
            url: row['url'] as String,
            lang: row['lang'] as String,
            updatedAt: row['updatedAt'] as int));
  }

  @override
  Future<void> clearAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM services');
  }

  @override
  Future<void> insertAll(List<ServiceModel> services) async {
    await _serviceModelInsertionAdapter.insertList(
        services, OnConflictStrategy.replace);
  }
}
