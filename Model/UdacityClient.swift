//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 26.06.2021.
//

import Foundation
import MapKit

class UdacityClient {
    static let serviceName = "OnTheMapService"
    static var session: Session? = nil
    
    static var isAuthorised: Bool {
        guard let currentUser = Settings.currentUser else {
            return false
        }
        do {
            let password = try KeychainPasswordItem(service: serviceName, account: currentUser).readPassword()
            return password.count > 0
        } catch {
            return false
        }
    }
        
    enum Endpionts{
        
        static let base = "https://onthemap-api.udacity.com/v1/"
        
        case onTheMap(String)
        case session
        
        var stringValue: String {
            switch self {
                case .onTheMap(let param) : return Endpionts.base + "StudentLocation" + param
                case .session : return Endpionts.base + "session"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func savePassword(email: String, password: String) {
        do {
            try KeychainPasswordItem(service: serviceName, account: email).savePassword(password)
            Settings.currentUser = email
        } catch {
            ////  can send some logs
        }
    }
    
    class func deletePassword(email: String) {
        do {
            try KeychainPasswordItem(service: serviceName, account: email).deleteItem()
            Settings.currentUser = nil
            Settings.udacityUserID = nil
        } catch {
            ////  can send some logs
        }
    }
    
    class func getPassword(currentUser: String) -> String? {
        do {
            let password = try KeychainPasswordItem(service: serviceName, account: currentUser).readPassword()
            return password
        } catch {
          return nil
        }
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, responceType: ResponseType.Type, completion: @escaping(ResponseType?, String?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error?.localizedDescription)
                }
                
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
//            print(String(data: data, encoding: .utf8) ?? "")
            do {
                let responseObject = try decoder.decode(responceType, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
                
            } catch {
                do {
                    let statusObject = try decoder.decode(StatusResponce.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, statusObject.error)
                    }
                } catch {
                    DispatchQueue.main.async {
                       //print(error.localizedDescription)
                        completion(nil, error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func taskForHttpRequest<ResponceType: Decodable, RequestType: Codable>(url: URL, method:String, responceType: ResponceType.Type, requestBody: RequestType, completion: @escaping(ResponceType?, String?) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        let requestBodyData = try! encoder.encode(requestBody)
       // print(String(data: requestBodyData, encoding: .utf8) ?? "")
        urlRequest.httpBody =  requestBodyData
        
        
        let task = URLSession.shared.dataTask(with: urlRequest) {data, responce, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error?.localizedDescription)
                }
                return
            }
            
            let rightData = correctResponce(data: data)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            do {
//                print(String(data:data, encoding: .utf8) ?? "")
                let responceObject = try decoder.decode(responceType, from: rightData)
                DispatchQueue.main.async {
                    completion(responceObject, nil)
                }
            } catch {
                do {
                    let statusObject = try decoder.decode(StatusResponce.self, from: rightData)
                    DispatchQueue.main.async {
                        completion(nil, statusObject.error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
        
    }
    
    class func correctResponce(data: Data) -> Data {
        let responceStringRaw = String(data:data, encoding: .utf8) ?? ""
        return responceStringRaw.replacingOccurrences(of: ")]}'", with: "").data(using: .utf8) ?? data
    }
    
    class func login(username: String, password: String, completion: @escaping(Bool, String?)-> Void) {
        
        let udacityBody = Udacity(username: username, password: password)
        let request = AuthenticateRequest(udacity: udacityBody)
        let url = Endpionts.session.url
        
        taskForHttpRequest(url: url, method: "POST", responceType: AuthenticationResponce.self, requestBody: request) { responceObject, error in
            guard let responceObject = responceObject else {
                if isAuthorised {
                    deletePassword(email: username)
                }
                return completion(false, error)
            }
            
            self.session = responceObject.session
            if !isAuthorised{
                savePassword(email: username, password: password)
            }
    
            return completion(true, nil)
        }
        
    }
    
    class func getStudentsLodcations(completion: @escaping(Bool, String?) -> Void) {
        let url = Endpionts.onTheMap("?limit=100&order=-updatedAt").url
        taskForGetRequest(url: url, responceType: LocationResponce.self) { responceObject, error in
            guard let responceObject = responceObject else {
                return completion(false, error)
            }
            
            LocationModel.locations = responceObject.results
            LocationModel.locationsDownloaded = true
            return completion(true, nil)
        }
    }
    
    class func deleteSession(completion: @escaping(Bool, String?) -> Void) {
        var request = URLRequest(url: Endpionts.session.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
          if error != nil {
            DispatchQueue.main.async {
                return completion(false, error!.localizedDescription)
            }
          }
         // let newData = data?.subdata(in: 5..<data!.count)
            
//          print(String(data: newData!, encoding: .utf8)!)
            DispatchQueue.main.async {
                return completion(true, nil)
            }
        }
        task.resume()
    }
    
    class func setUserLocation(mediaURL: String, mapString: String, location: CLLocationCoordinate2D, completion: @escaping(Bool, String?) -> Void){
        let url: URL = Endpionts.onTheMap("").url
        let request = SetStudentLocationRequest(uniqueKey: "1243", firstName: "Ivan", lastName: "Ivanov", mediaURL: mediaURL, latitude: Float(location.latitude), longitude: Float(location.longitude), mapString: mapString)
        
        taskForHttpRequest(url: url, method: "POST", responceType: SetStudentLocationResponce.self, requestBody: request) { responceObject, error in
            guard let responceObject = responceObject else {
                return completion(false, error)
            }
            
            Settings.udacityUserID = responceObject.objectId
            return completion(true, nil)
        }
    }
    
    class func updateUserLocation(udacityUserId: String, mediaURL: String, mapString: String, location: CLLocationCoordinate2D, completion: @escaping(Bool, String?) -> Void){
        let url: URL = Endpionts.onTheMap("/\(udacityUserId)").url
        let request = SetStudentLocationRequest(uniqueKey: "1243", firstName: "Ivan", lastName: "Ivanov", mediaURL: mediaURL, latitude: Float(location.latitude), longitude: Float(location.longitude), mapString: mapString)
        
        taskForHttpRequest(url: url, method: "PUT", responceType: UpdateStudentLocationResponce.self, requestBody: request) { responceObject, error in
            guard error == nil else {
                return completion(false, error)
            }
            return completion(true, nil)
        }
    }
}

extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}
