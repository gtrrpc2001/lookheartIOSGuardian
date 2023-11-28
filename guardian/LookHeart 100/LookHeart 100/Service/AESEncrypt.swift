//
//  AESEncrypt.swift
//  LookHeart 100
//
//  Created by 정연호 on 2023/10/13.
//

import Foundation
import CryptoSwift

class AESEncrypt {
    
    static let shared = AESEncrypt()
    private let AESKEY = "MEDSYSLAB.CO.KR.LOOKHEART.ENCKEY"
    
    func encryptStringWithAES_ECB(text: String) -> String? {
        do {
            let aes = try AES(key: Array(AESKEY.utf8), blockMode: ECB(), padding: .pkcs7)

            let encrypted = try aes.encrypt(Array(text.utf8))
            return encrypted.toBase64()
        } catch {
            // 오류 처리
            print("Encryption error: \(error)")
            return nil
        }
    }
}
