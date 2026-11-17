import Foundation

enum SharedContentLink {
    static func url(for contentID: Int) -> URL {
        URL(string: "https://\(AppInfo.universalLinkHost)/share/\(contentID)")!
    }

    static func contentID(from url: URL) -> Int? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.user == nil,
              components.password == nil,
              components.port == nil else { return nil }

        switch components.scheme?.lowercased() {
        case "soak":
            guard components.host?.lowercased() == "contents" else { return nil }
        case "https":
            guard components.host?.lowercased() == AppInfo.universalLinkHost else { return nil }
        default:
            return nil
        }

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
