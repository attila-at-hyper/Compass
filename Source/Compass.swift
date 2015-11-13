import UIKit

public struct Compass {

  private static var internalScheme = ""

  public static var scheme: String {
    set { Compass.internalScheme = newValue }
    get { return "\(Compass.internalScheme)://" }
  }

  public static var routes = [String]()

  public typealias ParseCompletion = (route: String, arguments: [String : String]) -> Void

  public static func parse(url: NSURL, completion: ParseCompletion) -> Bool {
    let query = url.absoluteString.substringFromIndex(scheme.endIndex)

    for route in routes.sort({ $0 < $1 }) {
      guard let prefix = (route.characters
        .split { $0 == "{" }
        .map(String.init))
        .first else { continue }

      if (query.hasPrefix(prefix) || prefix.hasPrefix(query)) {
        let queryString = query.stringByReplacingOccurrencesOfString(prefix, withString: "")
        let queryArguments = paths(queryString)
        let routeArguments = paths(route).filter { $0.containsString("{") }

        var arguments = [String : String]()

        if queryArguments.count == routeArguments.count {
          for (index, key) in routeArguments.enumerate() {
            arguments[key] = index <= queryArguments.count && "\(query):" != prefix
              ? queryArguments[index] : nil
          }
          completion(route: route, arguments: arguments)
          return true
        }
      }
    }
    return false
  }

  public static func navigate(urn: String, scheme: String = Compass.scheme) {
    let stringURL = "\(scheme)\(urn)"
    guard let url = NSURL(string: stringURL) else { return }
    UIApplication.sharedApplication().openURL(url)
  }

  private static func paths(urn: String) -> [String] {
    return urn.characters
      .split { $0 == ":" }
      .map(String.init)
  }
}

