//
//  ContentView.swift
//  MatsuReader
//
//  Created by user on 2022/08/02.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var account: Account?

    var body: some View {
        NavigationSplitView {
            AccountListView { account in
                self.account = account
            }
        } content: {
            if let account {
                NavigationStack {
                    BrowseView(account: account)
                }
            } else {
                Text("アカウントを選択してください")
            }
        } detail: {
            Text("アイテムを選択してください")
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
