//
//  Account+keychain.swift
//  MatsuReader
//
//  Created by user on 2022/08/02.
//

import Foundation
import KeychainAccess

extension Account {
    private var keychain: Keychain {
        Keychain(server: url!, protocolType: .https)
    }
    
    private var keychainUserName: String {
        return id!.uuidString + "." + userName!
    }
    
    func setPassword(_ password: String, requiresBiometricsAuthentication: Bool) throws {
        var keychain = self.keychain
        keychain = keychain.accessibility(.whenUnlocked)
        if requiresBiometricsAuthentication {
            keychain = keychain
                .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .biometryAny)
                .authenticationPrompt("サーバの接続用パスワードを保存")
        }
        try keychain.set(password.data(using: .utf8)!, key: keychainUserName)
    }
    
    func getPassword() throws -> String? {
        let keychain = self.keychain.authenticationPrompt("サーバの接続用パスワードの読み出し")
        return try keychain.get(keychainUserName)
    }
}
