import Vapor
import VaporSQLite

let drop = Droplet()

do {
    try drop.addProvider(VaporSQLite.Provider.self)
}
catch {
    assertionFailure("Error adding provider: \(error)")
}

// Database preparations
drop.preparations.append(Post.self)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

drop.run()
