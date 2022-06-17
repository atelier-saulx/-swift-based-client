import Foundation
import NakedJson

extension Json {
    static func from(string: String) -> Self? {
        guard let data = string.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode(Json.self, from: data)
            return json
            
        } catch {
            return nil
        }
    }
}
