import Foundation
import LookheartPackage

class ArrEmergencyManager {
    
    static let shared = ArrEmergencyManager()
    
    private var emergencyDate = ""
    private var isFirst = false // 최초 실행 방지
    
    func getArrCnt(startDate: String, endDate: String, completion: @escaping (Int?, Error?) -> Void) {
        
        NetworkManager.shared.getArrListToServer(startDate: startDate, endDate: endDate) { result in
            switch(result){
            case .success(let arrDateList):
                                
                let arrCnt = arrDateList.filter { $0.address == nil || $0.address == "" }.count
                completion(arrCnt, nil)
                
            case .failure(let error):
                print("getArrList error : \(error)")
                completion(nil, error)
            }
        }
    }
    
    func checkEmergency(startDate: String, endDate: String) {
        
        emergencyDate = emergencyDate.isEmpty ? startDate : emergencyDate
        
        NetworkManager.shared.getArrListToServer(startDate: emergencyDate, endDate: endDate) { [self] result in
            switch(result){
            case .success(let arrDateList):
                                
                for arrDate in arrDateList {
                    
                    if arrDate.address != nil && isFirst {
                        NotificationManager.shared.emergencyAlert(occurrenceTime: arrDate.writetime, location: arrDate.address!)
                    }
                    emergencyDate = arrDate.writetime
                }
                
                isFirst = true
                
            case .failure(let error):
                print("checkEmergency error : \(error)")
            }
        }
    }
    
}
