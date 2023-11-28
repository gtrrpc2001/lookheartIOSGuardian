//
//  Keychain.swift
//  LookHeart 100
//
//  Created by 정연호 on 2023/10/13.
//

import Foundation
import KeychainSwift

class Keychain {
    static let shared = Keychain()
    
    private let keychain = KeychainSwift()
     
    // 데이터를 설정하거나 업데이트하는 함수
    func setString(_ value: String, forKey key: String) -> Bool {
        return keychain.set(value, forKey: key)
    }
    
    // 데이터를 검색하는 함수
    func getString(forKey key: String) -> String? {
        return keychain.get(key) // 값이 없을 경우 nil 반환, 이는 옵셔널을 사용하여 처리
    }
    
    // 데이터를 설정하거나 업데이트하는 함수
    func setBool(_ value: Bool, forKey key: String) -> Bool {
        return keychain.set(value, forKey: key)
    }
    
    // 데이터를 검색하는 함수
    func getBool(forKey key: String) -> Bool {
        guard let stringValue = keychain.get(key) else { return false }
        return Bool(stringValue) ?? false
    }
    
    // 데이터를 삭제하는 함수
    func deleteString(forKey key: String) -> Bool {
        return keychain.delete(key)
    }
    
    // 모든 데이터를 삭제하는 함수
    func clear() -> Bool {
        return keychain.clear()
    }
}
