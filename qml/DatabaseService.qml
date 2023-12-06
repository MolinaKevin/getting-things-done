import QtQuick 2.0
import QtQuick.LocalStorage 2.0

QtObject {
    id: databaseService

    function getDatabase() {
        return LocalStorage.openDatabaseSync("GTD", "1.0", "StorageDatabase", 1000000);
    }

   function checkDBVersion() {
        var db = getDatabase();
        var version = 0; 

        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS DBVersion (version INTEGER)');
        });

        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS DBVersion (version INTEGER)');
            var result = tx.executeSql('SELECT version FROM DBVersion');
            if (result.rows.length === 0) {
                tx.executeSql('INSERT INTO DBVersion (version) VALUES (?)', [1]);
            }
        });

        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT version FROM DBVersion');
            if (rs.rows.length > 0) {
                version = rs.rows.item(0).version;
                console.log("Versión actual de la base de datos:", version);

                if (version === 0) {
                    console.log("Version es 0, eliminando bases de datos antiguas y estableciendo versión a 1");

                    tx.executeSql('DROP TABLE IF EXISTS GtdInbox');
                    tx.executeSql('DROP TABLE IF EXISTS GtdNoActionable');
                    tx.executeSql('DROP TABLE IF EXISTS GtdThings');

                    tx.executeSql('UPDATE DBVersion SET version = 1');
                } else {
                    console.log("Version de la base de datos:", version);
                }

            }
        });
        initializeDatabases();
    }
 

    function initializeDatabases() {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql(
              `CREATE TABLE IF NOT EXISTS GtdInbox(
                 id INTEGER PRIMARY KEY AUTOINCREMENT,
                 title TEXT,
                 details TEXT,
                 creationDate DATETIME,
                 source TEXT,
                 tags TEXT,
                 status TEXT,
                 priority INTEGER
               )`
            );
            tx.executeSql(
                `CREATE TABLE IF NOT EXISTS GtdNoActionable(
                 id INTEGER PRIMARY KEY AUTOINCREMENT, 
                 title TEXT, 
                 details TEXT, 
                 creationDate DATETIME, 
                 reviewDate DATETIME, 
                 category TEXT
               )`
            );
            tx.executeSql(
              `CREATE TABLE IF NOT EXISTS GtdThings(
                 id INTEGER PRIMARY KEY AUTOINCREMENT,
                 title TEXT,
                 details TEXT,
                 creationDate DATETIME,
                 dueDate DATETIME,
                 priority INTEGER,
                 status TEXT,
                 context TEXT,
                 project TEXT,
                 tags TEXT,
                 lastUpdated DATETIME
               )`
            );
        });
    }

    function addDataInbox(title, creationDate, details, source, tags, statu, priority) {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO GtdInbox (title, creationDate, details, source, tags, status, priority) VALUES (?, ?, ?, ?, ?, ?, ?)', [title, creationDate, details, source, tags, statu, priority]);
        });
    }

    function loadInbox() {
        var db = getDatabase();
        var res = [];
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM GtdInbox');
            for (var i = 0; i < rs.rows.length; i++) {
                res.push(rs.rows.item(i));
            }
        });
        return res;
    }

    function loadActionable() {
        var db = getDatabase();
        var res = [];
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM GtdThings');
            for (var i = 0; i < rs.rows.length; i++) {
                res.push(rs.rows.item(i));
            }
        });
        return res;
    }

    function loadNoActionable() {
        var db = getDatabase();
        var res = [];
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM GtdNoActionable');
            for (var i = 0; i < rs.rows.length; i++) {
                res.push(rs.rows.item(i));
            }
        });
        return res;
    }

    function removeFromDatabase(id,table) {
        var db = getDatabase();
        db.transaction(function(tx) {
            var query = 'DELETE FROM ' + table + '  WHERE id=?';
            tx.executeSql(query, [id]);
        });
    }

    function moveItemToNoActionable(id, details, reviewDate, category) {
        var db = getDatabase();
        db.transaction(function(tx) {
            var results = tx.executeSql('SELECT * FROM GtdInbox WHERE id=?', [id]);
            if (results.rows.length > 0) {
                var item = results.rows.item(0);
                tx.executeSql('INSERT INTO GtdNoActionable (title, details, creationDate, reviewDate, category) VALUES (?, ?, ?, ?, ?)',
                    [item.title, details, item.creationDate, reviewDate, category]);

                tx.executeSql('DELETE FROM GtdInbox WHERE id=?', [id]);
            } else {
                console.log("No se encontró el ítem con ID:", id);
            }
        });
    }

    function moveItemToActionable(id, details, dueDate, priority, status, context, project, tags) {
        var db = getDatabase();
        db.transaction(function(tx) {
            var results = tx.executeSql('SELECT * FROM GtdInbox WHERE id=?', [id]);
            if (results.rows.length > 0) {
                var item = results.rows.item(0);
                tx.executeSql('INSERT INTO GtdThings (title, details, creationDate, dueDate, priority, status, context, project, tags) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                    [item.title, details, item.creationDate, dueDate, priority, status, context, project, tags]);

                tx.executeSql('DELETE FROM GtdInbox WHERE id=?', [id]);
            } else {
                console.log("No se encontró el ítem con ID:", id);
            }
        });
    }
}

