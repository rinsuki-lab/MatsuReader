//
//  BrowseView.swift
//  MatsuReader
//
//  Created by user on 2022/08/03.
//

import SwiftUI

struct BrowseView: View {
    @Environment(\.refresh) var refresh

    let account: Account
    var url: String = ""
    var title: String = "トップ"

    @State var client: APIClient?
    @State var onceLoaded = false
    @State var contents: [APIContent] = []
    @State var error: String? = nil
    
    var body: some View {
        if let client = client {
            List(contents) { content in
                switch content {
                case .book(let book):
                    NavigationLink {
                        BookView(client: client, path: book.url)
                    } label: {
                        Label {
                            Text(book.title)
                            if let subtitle = book.subtitle {
                                Text(subtitle)
                            }
                        } icon: {
                            Image(systemName: "book.closed")
                        }
                    }

                case .list(let list):
                    NavigationLink {
                        BrowseView(account: account, url: list.url, title: list.title, client: client)
                    } label: {
                        Image(systemName: "folder")
                        Text(list.title)
                        if let subtitle = list.subtitle {
                            Text(subtitle)
                        }
                    }.isDetailLink(false)
                }
            }
            .refreshable {
                print("!")
                await refreshContents()
            }
            .navigationTitle(title)
            .task {
                guard !onceLoaded else {
                    return
                }
                print("!!")
                await refreshContents()
                onceLoaded = true
            }
            .alert("エラー", isPresented: .constant(error != nil)) {
                Button("OK") {
                    error = nil
                }
            } message: {
                Text(error ?? "")
            }

        } else {
            VStack(spacing: 8) {
                Text("認証中…")
                Button("認証をやり直す") {
                    getClient()
                }
            }
            .padding()
            .task {
                try? await Task.sleep(nanoseconds: 1000_000)
                getClient()
            }
            .navigationTitle("認証")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func getClient() {
        client = APIClient(account: account)
    }
    
    @State var currentTask: Task<Void, Error>?
    
    func refreshContents() async {
        do {
            contents = try await client!.getContents(path: url)
        } catch {
            self.error = "\(error)"
        }
    }
}

//struct BrowseView_Previews: PreviewProvider {
//    static var previews: some View {
//        BrowseView()
//    }
//}
