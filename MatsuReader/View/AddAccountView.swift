//
//  AddAccountView.swift
//  MatsuReader
//
//  Created by user on 2022/08/02.
//

import SwiftUI
import KeychainAccess
import LocalAuthentication

struct AddAccountView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State var serverURL: String = ""
    @State var useAuth: Bool = false
    @State var authUserName: String = ""
    @State var authPassword: String = ""
    @State var error: String? = nil
    @State var currentBiometryType = {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }()
    @State var requiresBiometricsAuthentication = false
    
    var body: some View {
        Form {
            Section {
                LabeledContent("サーバ") {
                    TextField("サーバ", text: $serverURL, prompt: Text("https://reader.example/api/" as String))
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            withAnimation {
            Section {
                Toggle("認証を使用", isOn: $useAuth.animation(.default))
                    if useAuth {
                        LabeledContent("ユーザ名") {
                            TextField("ユーザ名", text: $authUserName, prompt: Text("user"))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                            .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top)))
                        LabeledContent("パスワード") {
                            SecureField("パスワード", text: $authPassword, prompt: Text("password"))
                                .textInputAutocapitalization(.never)
                        }
                            .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top)))
                        Toggle("生体認証を要求する", isOn: $requiresBiometricsAuthentication)
                            .disabled(currentBiometryType == .none)
                    }
                }
            }
        }
        .navigationTitle("新規アカウント")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("キャンセル") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("追加") {
                    addItem()
                }
            }
        }
        .alert("エラー", isPresented: .constant(error != nil)) {
            Button("OK") {
                error = nil
            }
        } message: {
            Text(error ?? "")
        }
    }
    
    private func addItem() {
        withAnimation {
            do {
                guard let url = URL(string: serverURL) else {
                    error = "サーバのURLが正しくありません"
                    return
                }
                guard url.scheme == "http" || url.scheme == "https" else {
                    error = "サーバのURLはHTTPかHTTPSである必要があります"
                    return
                }
                let newItem = Account(context: viewContext)
                newItem.id = .init()
                newItem.url = url
                if useAuth {
                    guard authUserName.count > 0 else {
                        error = "ユーザ名が入力されていません"
                        return
                    }
                    guard authPassword.count > 0 else {
                        error = "パスワードが入力されていません"
                        return
                    }
                    newItem.userName = authUserName
                    try newItem.setPassword(authPassword, requiresBiometricsAuthentication: requiresBiometricsAuthentication)
                }
                newItem.timestamp = Date()
                try viewContext.save()
                dismiss()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AddServerView_Previews: PreviewProvider {
    static var previews: some View {
        AddAccountView()
    }
}
