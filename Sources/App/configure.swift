import Fluent
import FluentSQLiteDriver
import Vapor

// Called before your application initializes.
public func configure(_ app: Application) throws {
    // Serves files from `Public/` directory
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.http.server.configuration.hostname = "0.0.0.0"
    
    app.http.server.configuration.port = 8081
    
    app.routes.defaultMaxBodySize = "100mb"

    // Configure SQLite database
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Configure migrations
    app.migrations.add(CreateTodo())
    
    
    try routes(app)
}
