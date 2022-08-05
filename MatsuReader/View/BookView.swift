//
//  BookView.swift
//  MatsuReader
//
//  Created by user on 2022/08/03.
//

import SwiftUI

struct LazyStack<Content: View>: View {
    let vertical: Bool
    @ViewBuilder
    let content: () -> Content
    
    var body: some View {
        if vertical {
            LazyVStack(spacing: 0) {
                content()
            }
        } else {
            LazyHStack(spacing: 0) {
                content()
            }
        }
    }
}

struct BookView: View {
    let client: APIClient
    let path: String
    @State var book: APIBook?
    @State var error: String?
    @State var vertical = false
    
    var body: some View {
        if let book {
            GeometryReader { proxy in
                ScrollViewReader { scrollProxy in
                    ScrollView(vertical ? .vertical : .horizontal) {
                        LazyStack(vertical: vertical) {
                            EmptyView().id(-1)
                            ForEach(Array(book.pages.enumerated()), id: \.element.id) { (i, page) in
                                PageView(client: client, page: page, scroller: scrollProxy, i: i)
                                    .frame(maxWidth: proxy.size.width, maxHeight: proxy.size.height)
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                    .id(i)
                            }
                            EmptyView().id(book.pages.count)
                        }
                    }
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if vertical {
                    ToolbarItem {
                        Button {
                            vertical = false
                        } label: {
                            Image(systemName: "square.split.2x1")
                        }
                    }
                } else {
                    ToolbarItem {
                        Button {
                            vertical = true
                        } label: {
                            Image(systemName: "square.split.1x2")
                        }
                    }
                    
                }
            }
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .task {
                    do {
                        book = try await client.getBook(path: path)
                    } catch {
                        self.error = "\(error)"
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
    }
}

//struct BookView_Previews: PreviewProvider {
//    static var previews: some View {
//        BookView()
//    }
//}
