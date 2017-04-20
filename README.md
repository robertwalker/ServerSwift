Web Frameworks
==============

* [Kitura (kitura.com)](http://kitura.io)
* [Perfect (perfect.org)](http://perfect.org)
* [Vapor (vapor.codes)](http://vapor.codes)

Why Swift on the Server?
------------------------

* High performance
* Low memory footprint
* One language for desktop, mobile and the Web
* Code sharing between client and server

Performance and Memory
----------------------

* [The Computer Language Benchmark Game](http://benchmarksgame.alioth.debian.org/u64q/swift.html)
* [Linux (Ubuntu) Benchmarks for Server Side Swift vs Node.js](https://medium.com/@rymcol/linux-ubuntu-benchmarks-for-server-side-swift-vs-node-js-db52b9f8270b)
* [Server Side Swift vs. The Other Guys ](https://medium.com/@qutheory/server-side-swift-vs-the-other-guys-2-speed-ca65b2f79505)

Swift.org
=========

<https://swift.org>

Swift@IBM
=========

<https://developer.ibm.com/swift/>

IBM Swift Package Catalog
-------------------------

<https://developer.ibm.com/swift/the-ibm-swift-package-catalog/>

Kitura
======

[Kitura (kitura.io)](http://kitura.io)

### Creating a Kitura Application

```sh
mkdir CocoaHeads
cd CocoaHeads
swift package init --type executable
```

### Initial Project Structure

```sh
CocoaHeads
├── Package.swift
├── Sources
│   └── main.swift
└── Tests
```

### Configure the Swift Package Manager (Package.swift)

```swift
import PackageDescription

let package = Package(
    name: "CocoaHeads",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 6)
    ]
)
```

### Create Xcode Project Using Swfit Package Manager

```sh
swift package generate-xcodeproj
open CocoaHeads.xcodeproj
```

### Configure Router and Create the HTTP Server

Open `​Sources/main.swift`​ and replace the contents with:

```swift
import Kitura

// Create a new router
let router = Router()

// Handle HTTP GET requests to /
router.get("/") {
    request, response, next in
    response.send("Hello, Web!")
    next()
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8090, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
```

### Build and Run the Server

```sh
swift build
.build/debug/Cocoaheads
```

### Parsing Requests

```swift
// Parsing URL Encoded Parameters
router.get("/name/:name") { request, response, _ in
    let name = request.parameters["name"] ?? ""
    try response.send("Hello \(name)").end()
}

// Parsing Query Parameters
router.get("/name") { request, response, _ in
    let name = request.queryParameters["name"] ?? ""
    try response.send("Hello \(name)").end()
}

// Parsing JSON Posts
router.all("/name", middleware: BodyParser())
router.post("/name") { request, response, next in
    guard let parsedBody = request.body else {
        next()
        return
    }

    switch(parsedBody) {
    case .json(let jsonBody):
            let name = jsonBody["name"].string ?? ""
            try response.send("Hello \(name)").end()
    default:
        break
    }
    next()
}
```

### Returning a JSON Response

```swift
import SwiftyJSON
```

```swift
// Return JSON
router.get("/json") { _, response, next in
    response.status(.OK).send(json: JSON(["hello" : "JSON"]))
    next()
}
```

Perfect
=======

[Perfect.org](http://perfect.org)

### Creating a Perfect Application

```sh
mkdir CocoaHeads
cd CocoaHeads
swift package init --type executable
```

### Intial Project Structure

```sh
CocoaHeads
├── Package.swift
├── Sources
│   └── main.swift
└── Tests
```

### Configure the Swift Package Manager (Package.swift)

```swift
import PackageDescription
 
let package = Package(
    name: "CocoaHeads",
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2, minor: 0)
    ]
)
```

### Create Xcode Project Using Swfit Package Manager

```sh
swift package generate-xcodeproj
open CocoaHeads.xcodeproj
```

### Configure Router and Start the HTTP Server

Open `​Sources/main.swift`​ and replace the contents with:

```swift
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
 
// Create HTTP server.
let server = HTTPServer()
 
// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/", handler: { request, response in
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, Web!</body></html>")
    response.completed()
})
 
// Add the routes to the server.
server.addRoutes(routes)
 
// Set a listen port of 8181
server.serverPort = 8181
 
do {
    // Launch the HTTP server.
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
```

### Build and Run the Server

```sh
swift build
.build/debug/Cocoaheads
```

### Parsing Requests

```swift
// Parsing URL Encoded Parameters
routes.add(method: .get, uri: "/name/{name}", handler: { request, response in
    defer {
        response.completed()
    }
    
    guard let name = request.urlVariables["name"] else {
        response.status = HTTPResponseStatus.internalServerError
        return
    }
    
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, \(name)!</body></html>")
})

// Parsing Query Parameters
routes.add(method: .get, uri: "/name", handler: { request, response in
    defer {
        response.completed()
    }
    
    guard let name = request.param(name: "name", defaultValue: "Anonymous Person") else {
        response.status = HTTPResponseStatus.internalServerError
        return
    }
    
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, \(name)!</body></html>")
})

// Parsing JSON Posts
routes.add(method: .post, uri: "/name", handler: { request, response in
    defer {
        response.completed()
    }
    
    guard let encoded = request.postBodyString else {
        response.status = HTTPResponseStatus.internalServerError
        return
    }

    do {
        let decoded = try encoded.jsonDecode() as? [String:Any]
        if let name = decoded?["name"] {
            response.setHeader(.contentType, value: "text/html")
            response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, \(name)!</body></html>")
        }
        else {
            response.status = HTTPResponseStatus.internalServerError
            return
        }
    }
    catch {
        response.status = HTTPResponseStatus.internalServerError
        return
    }
})
```

### Returning a JSON Response

```swift
// Returning JSON
routes.add(method: .get, uri: "/json", handler: { request, response in
    defer {
        response.completed()
    }
    
    do {
        let data: [String: Any] = ["hello": "JSON"]
        let encoded = try data.jsonEncodedString()
        response.setHeader(.contentType, value: "application/json")
        response.appendBody(string: encoded)
    }
    catch {
        response.status = HTTPResponseStatus.internalServerError
        return
    }
})
```

Vapor
=====

[vapor.codes](http://vapor.codes)

### Installing the Vapor CLI

```sh
brew install vapor/tap/vapor
```

### Creating a Vapor Application

```sh
vapor new CocoaHeads
cd CocoaHeads
```

### Initial Project Structure

```sh
CocoaHeads
├── Config
│   ├── app.json
│   ├── clients.json
│   ├── crypto.json
│   ├── droplet.json
│   ├── production
│   │   └── app.json
│   └── servers.json
├── Localization
│   ├── default.json
│   ├── en-US.json
│   ├── es-US.json
│   ├── nl-BE.json
│   └── nl-NL.json
├── Package.swift
├── Procfile
├── Public
│   ├── images
│   │   └── vapor-logo.png
│   └── styles
│       └── app.css
├── README.md
├── Resources
│   └── Views
│       ├── base.leaf
│       └── welcome.leaf
├── Sources
│   └── App
│       ├── Controllers
│       │   └── PostController.swift
│       ├── Models
│       │   └── Post.swift
│       └── main.swift
├── app.json
└── license
```

### Create and Open a New Xcode Project

```sh
vapor xcode -y
```

### Build and Run the Server

```sh
vapor build
vapor run serve
```

### Scaffolding Generated by the Vapor Toolbox

`​Sources/App/main.swift`

```swift
import Vapor

let drop = Droplet()

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

drop.run()
```

`​Sources/App/Controllers/PostController.swift`

```swift
import Vapor
import HTTP

final class PostController: ResourceRepresentable {
    func index(request: Request) throws -> ResponseRepresentable {
        return try Post.all().makeNode().converted(to: JSON.self)
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var post = try request.post()
        try post.save()
        return post
    }

    func show(request: Request, post: Post) throws -> ResponseRepresentable {
        return post
    }

    func delete(request: Request, post: Post) throws -> ResponseRepresentable {
        try post.delete()
        return JSON([:])
    }

    func clear(request: Request) throws -> ResponseRepresentable {
        try Post.query().delete()
        return JSON([])
    }

    func update(request: Request, post: Post) throws -> ResponseRepresentable {
        let new = try request.post()
        var post = post
        post.content = new.content
        try post.save()
        return post
    }

    func replace(request: Request, post: Post) throws -> ResponseRepresentable {
        try post.delete()
        return try create(request: request)
    }

    func makeResource() -> Resource<Post> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func post() throws -> Post {
        guard let json = json else { throw Abort.badRequest }
        return try Post(node: json)
    }
}
```

`​Sources/App/Models/Post.swift`

```swift
import Vapor
import Fluent
import Foundation

final class Post: Model {
    var id: Node?
    var content: String
    
    init(content: String) {
        self.id = UUID().uuidString.makeNode()
        self.content = content
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        content = try node.extract("content")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "content": content
        ])
    }
}

extension Post {
    /**
        This will automatically fetch from database, using example here to load
        automatically for example. Remove on real models.
    */
    public convenience init?(from string: String) throws {
        self.init(content: string)
    }
}

extension Post: Preparation {
    static func prepare(_ database: Database) throws {
        //
    }

    static func revert(_ database: Database) throws {
        //
    }
}
```

### Create a New Database

We’ll use SQLite for this demo

```sh
mkdir Database
sqlite3 Database/cocoaheads.sqlite
echo 'Database' >> .gitignore
```

​Package.swift

```swift
import PackageDescription

let package = Package(
    name: "CocoaHeads",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/vapor/sqlite-provider", majorVersion: 1, minor: 1) // <-- SQLite provider
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)
```

### Regenerate Xcode Project with New Dependency

```sh
vapor xcode -y
```

### Initialize SQLite Fluent Provider

`​Sources/App/main.swift`

```swift
import Vapor
import VaporSQLite

let drop = Droplet()

do {
    try drop.addProvider(VaporSQLite.Provider.self)
}
catch {
    assertionFailure("Error adding provider: \(error)")
}

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

drop.run()
```

### Add SQLite Database Configuration

`Config/secrets/sqlite.json`

```json
{
  "path": "Database/cocoaheads.sqlite"
}
```

### A Fluent Model

`​Sources/App/Models/Post.swift`

```swift
import Vapor
import Fluent
import Foundation

final class Post: Model {
    var id: Node?
    var content: String
    var exists = false
    
    init(content: String) {
        self.content = content
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        content = try node.extract("content")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "content": content
        ])
    }
}
```

### Preparations

```swift
extension Post: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("posts") { posts in
            posts.id()
            posts.string("content")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("posts")
    }
}
```

### Add Database Preparations to the Droplet

`​Sources/App/main.swift`

```swift
// Database preparations
drop.preparations.append(Post.self)
```

### Getting the List of Posts

`​Sources/App/Controllers/PostController.swift`

```swift
func index(request: Request) throws -> ResponseRepresentable {
    return try Post.all().makeNode().converted(to: JSON.self)
}
```

If all went well this should respond with an empty `Array` of `Post` objects since we haven’t yet created any. So let’s do that now!

### Creating a Post

```swift
func create(request: Request) throws -> ResponseRepresentable {
    var post = try request.post()
    try post.save()
    return post
}
```

We’ll use [RESTed](https://itunes.apple.com/us/app/rested-simple-http-requests/id421879749?mt=12) to send a POST request to `​http://localhost:8080/posts`​ where the body of the HTTP request contains JSON.

`​POST: http://localhost:8080/posts`

```json
{
  "content": "This is my first post!"
}
```

We can now get the `Post` we created.

### Getting a Post

`GET: ​http://localhost:8080/posts/1`

```json
[
    {
        "content": "This is my first post!",
        "id": "1"
    }
]
```

We can also modify our `Post`.

### Update a Post

`​PATCH: http://localhost:8080/posts/1`

```json
{
  "content": "This is my edited post!"
}
```

Response

```json
{
    "content": "This is my edited post!",
    "id": "1"
}
```

### Delete a Post

`DELETE: http://localhost:8080/posts/1`

Response

```json
{}
```

### Clear Posts

`​DELETE: http://localhost:8080/posts`

Response

```json
[]
```

**WARNING:** This operation is obviously dangerous since it will destroy all posts in the table! Probalby not a feature you want to include in a production system.

### The Complete PostController

```swift
import Vapor
import HTTP

final class PostController: ResourceRepresentable {
    func index(request: Request) throws -> ResponseRepresentable {
        return try Post.all().makeNode().converted(to: JSON.self)
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var post = try request.post()
        try post.save()
        return post
    }

    func show(request: Request, post: Post) throws -> ResponseRepresentable {
        return post
    }

    func delete(request: Request, post: Post) throws -> ResponseRepresentable {
        try post.delete()
        return JSON([:])
    }

    func clear(request: Request) throws -> ResponseRepresentable {
        try Post.query().delete()
        return JSON([])
    }

    func update(request: Request, post: Post) throws -> ResponseRepresentable {
        let new = try request.post()
        var post = post
        post.content = new.content
        try post.save()
        return post
    }

    func replace(request: Request, post: Post) throws -> ResponseRepresentable {
        try post.delete()
        return try create(request: request)
    }

    func makeResource() -> Resource<Post> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func post() throws -> Post {
        guard let json = json else { throw Abort.badRequest }
        return try Post(node: json)
    }
}
```