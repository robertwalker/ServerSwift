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
