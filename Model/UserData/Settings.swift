
import Foundation

final class Settings {
    private enum Keys: String {
        case user = "current_user"
        case userID = "user_id"
    }
    
    static var currentUser: String? {
      get {
        guard let data = UserDefaults.standard.data(forKey: Keys.user.rawValue) else {
          return nil
        }
        return String(data: data, encoding: .utf16)
      }
      set {
        if let data = newValue?.data(using: .utf16) {
          UserDefaults.standard.set(data, forKey: Keys.user.rawValue)
        } else {
          UserDefaults.standard.removeObject(forKey: Keys.user.rawValue)
        }
      }
    }
    
    static var udacityUserID: String? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.userID.rawValue) else {
                return nil
            }
            return String(data: data, encoding: .utf16)
        }
        
        set {
            if let data = newValue?.data(using: .utf16) {
                UserDefaults.standard.set(data, forKey: Keys.userID.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.userID.rawValue)
            }
        }
    }
}
