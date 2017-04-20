import Kitura
import SwiftyJSON

// Create a new router
let router = Router()

// Handle HTTP GET requests to /
router.get("/") {
    request, response, next in
    response.send("Hello, Web!")
    next()
}

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

// Return JSON
router.get("/json") { _, response, next in
    response.status(.OK).send(json: JSON(["hello" : "JSON"]))
    next()
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8090, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
