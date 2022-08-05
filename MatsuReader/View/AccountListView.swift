//
//  AccountListView.swift
//  MatsuReader
//
//  Created by user on 2022/08/02.
//

import SwiftUI

struct AccountListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.timestamp, ascending: true)],
        animation: .default
    )
    private var accounts: FetchedResults<Account>
    
    @State private var showAddServerSheet = false
    
    let setAccountCallback: (Account) -> Void
    
    var body: some View {
        List {
            ForEach(accounts) { account in
                NavigationLink {
                    NavigationStack {
                        BrowseView(account: account)
                    }
                } label: {
                    Text(account.url!.absoluteString)
                    if let userName = account.userName {
                        Text("ユーザ: \(userName)")
                    }
                }
            }
            .onDelete(perform: deleteItems)
            Button("アカウントを追加") {
                showAddServerSheet = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showAddServerSheet) {
            NavigationView {
                AddAccountView()
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { accounts[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

//struct ServerListView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountListView()
//    }
//}
