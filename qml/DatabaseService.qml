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
                } else if (version === 1) {
                    // New Inbox
                    tx.executeSql(`
                        CREATE TABLE IF NOT EXISTS GtdInbox_new (
                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                            title TEXT,
                            details TEXT,
                            creationDate DATETIME,
                            source TEXT,
                            tags TEXT
                        )`
                    );
                    tx.executeSql(`
                        INSERT INTO GtdInbox_new (id, title, details, creationDate, source, tags)
                        SELECT id, title, details, creationDate, source, tags FROM GtdInbox
                    `);
                    tx.executeSql('DROP TABLE IF EXISTS GtdInbox');
                    tx.executeSql('ALTER TABLE GtdInbox_new RENAME TO GtdInbox');
                    // New Things DB
                    tx.executeSql(`
                        CREATE TABLE IF NOT EXISTS GtdThings_new (
                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                            title TEXT,
                            details TEXT,
                            creationDate DATETIME,
                            dueDate DATETIME,
                            status TEXT,
                            contextId INTEGER,
                            projectId INTEGER,
                            tags TEXT,
                            lastUpdated DATETIME,
                            FOREIGN KEY (contextId) REFERENCES contexts(id)
                            FOREIGN KEY (projectId) REFERENCES projects(id)
                        );`
                    );
                    tx.executeSql(`
                        INSERT INTO GtdThings_new (id, title, details, creationDate, dueDate, status, tags, lastUpdated)
                        SELECT id, title, details, creationDate, dueDate, status, tags, lastUpdated FROM GtdThings
                    `);
                    tx.executeSql('DROP TABLE IF EXISTS GtdThings');
                    tx.executeSql('ALTER TABLE GtdThings_new RENAME TO GtdThings');

                    tx.executeSql('UPDATE DBVersion SET version = 2');
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
                 tags TEXT
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
                 status TEXT,
                 contextId INTEGER,
                 projectId INTEGER,
                 tags TEXT,
                 lastUpdated DATETIME,
                 FOREIGN KEY (contextId) REFERENCES contexts(id)
                 FOREIGN KEY (projectId) REFERENCES projects(id)
               )`
            );
            tx.executeSql(
                `CREATE TABLE IF NOT EXISTS contexts (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT UNIQUE
                )`
            );
            tx.executeSql(`
            CREATE TABLE IF NOT EXISTS projects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                description TEXT
            )
        `);

        });
    }

    function addDataInbox(title, creationDate, details, source, tags) {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO GtdInbox (title, creationDate, details, source, tags) VALUES (?, ?, ?, ?, ?)', [title, creationDate, details, source, tags]);
        });
    }

    function addContext(name) {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO contexts (name) VALUES (?)', [name]);
        });
    }

    function addProject(name,details) {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO projects (name,description) VALUES (?, ?)', [name, details]);
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
                var item = rs.rows.item(i);

                // Obtener el nombre del contexto
                var contextRs = tx.executeSql('SELECT name FROM contexts WHERE id = ?', [item.contextId]);
                item.contextName = contextRs.rows.length > 0 ? contextRs.rows.item(0).name : "Desconocido";

                // Obtener el nombre del proyecto
                var projectRs = tx.executeSql('SELECT name FROM projects WHERE id = ?', [item.projectId]);
                item.projectName = projectRs.rows.length > 0 ? projectRs.rows.item(0).name : "Desconocido";

                res.push(item);
            }
        });
            console.log("el testeo: " + JSON.stringify(res));
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

    function loadContexts() {
        var db = getDatabase();
        var contexts = [];
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT id, name FROM contexts');
            for (var i = 0; i < rs.rows.length; i++) {
                contexts.push(rs.rows.item(i));
            }
        });
        return contexts;
    }

    function loadProjects() {
        var db = getDatabase();
        var projects = [];
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT id, name, description FROM projects');
            for (var i = 0; i < rs.rows.length; i++) {
                projects.push(rs.rows.item(i));
            }
        });
        return projects;
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

    function moveItemToActionable(id, details, dueDate, status, context, project, tags) {
        var db = getDatabase();
        db.transaction(function(tx) {
            var results = tx.executeSql('SELECT * FROM GtdInbox WHERE id=?', [id]);
            if (results.rows.length > 0) {
                var item = results.rows.item(0);
                tx.executeSql('INSERT INTO GtdThings (title, details, creationDate, dueDate, status, contextId, projectId, tags) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                    [item.title, details, item.creationDate, dueDate, status, context, project, tags]);

                tx.executeSql('DELETE FROM GtdInbox WHERE id=?', [id]);
            } else {
                console.log("No se encontró el ítem con ID:", id);
            }
        });
    }
}

