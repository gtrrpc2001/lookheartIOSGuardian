import Foundation
import Alamofire

class NetworkManager {   

    private let baseURL = ""
    
    static let shared = NetworkManager()

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()
    
    func sendToken(id: String, password: String, phone: String, token: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let endpoint = "/msl/CheckLogin"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "empid": id,
            "pw": password,
            "phone": phone,
            "token": token
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    print("send Token response: \(responseString)")
                    
                    if responseString.contains("true"){
                        completion(.success(true))
                    } else if responseString.contains("false"){
                        completion(.success(false))
                    } else {
                        completion(.failure(NetworkError.invalidResponse)) // 예상치 못한 응답
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
            case .failure(let error):
                print("sendToken Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    
    
    func getBpmDataToServer(id: String, startDate: String, endDate: String, completion: @escaping (Result<[BpmData], Error>) -> Void) {
        
        var bpmData: [BpmData] = []
        let endpoint = "/mslbpm/api_getdata"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "eq": id,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    if !(responseString.contains("result = 0")) {
                        let newlineData = responseString.split(separator: "\n")
                        let splitData = newlineData[1].split(separator: "\r\n")
                        for data in splitData {
                            let fields = data.split(separator: "|")
                            
                            if fields.count == 7 {
                                if let bpm = Int(fields[4]), let temp = Double(fields[5]), let hrv = Int(fields[6]) {
                                    
                                    bpmData.append( BpmData(
                                        idx: String(fields[0]),
                                        eq: String(fields[1]),
                                        writetime: String(fields[2]),
                                        timezone: String(fields[3]),
                                        bpm: String(bpm),
                                        temp: String(temp),
                                        hrv: String(hrv)
                                    ))
                                }
                            }
                        }
                        
                        completion(.success(bpmData))
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
            case .failure(let error):
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    func getHourlyDataToServer(id: String, startDate: String, endDate: String, completion: @escaping (Result<[HourlyData], Error>) -> Void) {
                
        var hourlyData: [HourlyData] = []
        let endpoint = "/mslecgday/day"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "eq": id,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    if !(responseString.contains("result = 0")) {
                        let newlineData = responseString.split(separator: "\n")
                        let splitData = newlineData[1].split(separator: "\r\n")

                        for data in splitData {
                            let fields = data.split(separator: "|")

                            if fields.count == 12 {
                                if let step = Int(fields[7]), let distance = Int(fields[8]), let cal = Int(fields[9]), let activityCal = Int(fields[10]), let arrCnt = Int(fields[11]) {
                                    let record = HourlyData(
                                        eq: String(fields[0]),
                                        timezone: String(fields[2]),
                                        hour: String(fields[6]),
                                        step: String(step),
                                        distance: String(distance),
                                        cal: String(cal),
                                        activityCal: String(activityCal),
                                        arrCnt: String(arrCnt)
                                    )
                                    
                                    hourlyData.append(record)
                                }
                            }
                        }
                        
                        completion(.success(hourlyData))
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
            case .failure(let error):
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    
    
        
    func getArrDataToServer(idx: String, id: String, startDate: String, endDate: String, completion: @escaping (Result<[String], Error>) -> Void) {
        
        let endpoint = "/mslecgarr/test"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "idx": idx,
            "eq": id,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    if !responseString.contains("result") {
                        let splitData = responseString.components(separatedBy: "address\n")
                        let newlineData = splitData[1].components(separatedBy: "\n")
                        
                        let processedData = newlineData.map { element in
                            element
                                .replacingOccurrences(of: "|null\r", with: "")
                                .replacingOccurrences(of: "|null", with: "")
                                .replacingOccurrences(of: "\r", with: "")
                        }
                        completion(.success(processedData))
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
            case .failure(let error):
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }
        
    func getArrListToServer(id: String, startDate: String, endDate: String, completion: @escaping (Result<[ArrDateEntry], Error>) -> Void) {
        
        let endpoint = "/mslecgarr/arrWritetime?"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "eq": id,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let result = String(data: data, encoding: .utf8)
                    if !(result!.contains("result = 0")) {
                        completion(.success(try JSONDecoder().decode([ArrDateEntry].self, from: data)))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
                print("getArrListToServer Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    func selectArrDataToServer(id: String, startDate: String, completion: @escaping (Result<ArrData, Error>) -> Void) {
        
        let endpoint = "/mslecgarr/arrWritetime?"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "eq": id,
            "startDate": startDate,
            "endDate": ""
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let arrData = try JSONDecoder().decode([ArrEcgData].self, from: data)
                    let resultString = arrData[0].ecgpacket.split(separator: ",")
                    
                    if resultString.count > 500 {
                        let ecgData = resultString[4...].compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
                        
                        completion(.success(ArrData.init(
                            idx: "0",
                            writeTime: "0",
                            time: self.removeWsAndNl(resultString[0]),
                            timezone: "0",
                            bodyStatus: self.removeWsAndNl(resultString[2]),
                            type: self.removeWsAndNl(resultString[3]),
                            data: ecgData)))
                    } else {
                        completion(.success(ArrData.init(
                            idx: "",
                            writeTime: "",
                            time: "",
                            timezone: "",
                            bodyStatus: "응급 상황",
                            type: "응급 상황",
                            data: [])))
                    }
                    
                } catch {
                    print("check")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    func getRealBpmToServer(id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let endpoint = "/mslLast/Last"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "eq": id
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    
                    if let match = numberRegex.firstMatch(in: responseString, range: NSRange(location: 0, length: responseString.utf16.count)) {
                        let matchedString = (responseString as NSString).substring(with: match.range)
                        
                        completion(.success(matchedString))
                    } else {
                        completion(.failure(NetworkError.invalidResponse)) // 예상치 못한 응답
                    }
                    
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
            case .failure(let error):
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    
    func getProfileToServer(id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        
        let endpoint = "/msl/Profile"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "empid": id
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                
                    let decoder = JSONDecoder()
                    let userProfiles = try decoder.decode([UserProfile].self, from: data) // 디코딩
                    
                    var phoneNumbers: [String] = []
                    
                    for profile in userProfiles { // 프로필이 여러개 있을 경우 보호자 핸드폰 번호 저장
                        if let phones = profile.phone {
                            phoneNumbers.append(phones)
                        }
                    }
                    // 첫 번째 프로필을 기본 프로필로 설정하고, 핸드폰 번호 목록을 저장
                    if let primaryProfile = userProfiles.first {
                        UserProfileManager.shared.setUserProfile(primaryProfile)
                        UserProfileManager.shared.setPhoneNumbers(phoneNumbers)
                        completion(.success(primaryProfile))
                    } else {
                        completion(.failure(NetworkError.noData))
                    }
                    
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    func checkLoginToServer(id: String, pw: String, phone: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        print(id)
        print(pw)
        print(phone)
        let endpoint = "/msl/CheckLogin"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }

        let parameters: [String: Any] = [
            "empid": id,
            "pw": pw,
            "phone": phone
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    print("checkID Received response: \(responseString)")
                    
                    if responseString.contains("true"){
                        completion(.success(true))
                    } else if responseString.contains("false"){
                        completion(.success(false))
                    } else {
                        completion(.failure(NetworkError.invalidResponse)) // 예상치 못한 응답
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
            case .failure(let error):
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }

    private func request(url: URL, method: HTTPMethod, parameters: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
        
        // Alamofire
        AF.request(url, method: method, parameters: parameters,
                   encoding: (method == .get) ? URLEncoding.default : URLEncoding.httpBody)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
    enum NetworkError: Error {
        case invalidResponse
        case noData
        // 필요에 따라 추가적인 에러 케이스를 정의
    }
    
    
    // Ws : whitespaces & Nl : Newlines
    private func removeWsAndNl(_ string: Substring) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
