import Foundation
import UserNotifications
import FirebaseMessaging
import LookheartPackage

class FCM {
    
    static let shared = FCM()
    
    func sendToken(){
        if let email = Keychain.shared.getString(forKey: "email"),
           let password = Keychain.shared.getString(forKey: "password"),
           let phone = Keychain.shared.getString(forKey: "phone"),
           let token = Keychain.shared.getString(forKey: "token") {
            
            sendTokenServerTask(email: email, password: password, phone: phone, token: token)
        }
    }
    
    func sendTokenServerTask(email: String, password: String, phone: String, token: String) {
        NetworkManager.shared.sendFireBaseToken(id: email, password: password, phone: phone, token: token) { result in
            switch result {
            case .success(let isAvailable):
                
                if isAvailable {
                    print("Send FCM Token : true")
                } else {
                    print("Send FCM Token : flase")
                }
                
            case .failure(let error):
                print("Send FCM Token : \(error)")
            }
        }
    }
    
    func createFCMToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
                return
            } else if let token = token {
                print("FCM create FCM Token: \(token)")
                Keychain.shared.setValue(token, forKey: "token")
                self.sendToken()
            }
        }
    }
    
    
    func isFirstToken() -> Bool {
        return Keychain.shared.getBool(forKey: "login") 
    }
}
