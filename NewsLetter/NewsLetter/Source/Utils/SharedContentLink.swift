import Foundation

enum SharedContentLink {
    static func url(for contentID: Int) -> URL {
        URL(string: "soak://contents/share/\(contentID)")!
    }

    static func contentID(from url: URL) -> Int? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == "soak",
              components.host?.lowercased() == "contents",
              components.user == nil,
              components.password == nil,
              components.port == nil else { return nil }

        let path = components.path.components(separatedBy: "/")
        guard path.count == 3,
              path[0].isEmpty,
              path[1] == "share",
              !path[2].isEmpty,
              path[2].utf8.allSatisfy({ (48...57).contains($0) }),
              let contentID = Int(path[2]),
              contentID > 0 else { return nil }

        return contentID
    }
}
