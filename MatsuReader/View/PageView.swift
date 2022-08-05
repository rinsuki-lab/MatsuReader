//
//  PageView.swift
//  MatsuReader
//
//  Created by user on 2022/08/03.
//

import SwiftUI

struct PageView: View {
    let client: APIClient
    let page: APIBook.Page
    let scroller: ScrollViewProxy
    let i: Int
    @State var image: Image?
    
    var body: some View {
        if let image {
            ZStack {
                image
                    .resizable()
                    .aspectRatio(.init(width: page.width, height: page.height), contentMode: .fit)
//                GeometryReader { reader in
//                    HStack {
//                        Button("←") {
//                            withAnimation {
//                                scroller.scrollTo(i + 1)
//                            }
//                        }
//                            .padding()
//                            .frame(width: reader.size.width / 4, height: reader.size.height)
//                        Spacer()
//                        Button("→") {
//                            withAnimation {
//                                scroller.scrollTo(i - 1)
//                            }
//                        }
//                            .padding()
//                            .frame(width: reader.size.width / 4, height: reader.size.height)
//                    }
//                }
            }
        } else {
            ProgressView()
                .frame(width: .init(page.width), height: .init(page.height))
                .aspectRatio(.init(width: page.width, height: page.height), contentMode: .fit)
                .task {
                    do {
                        try await Task.sleep(nanoseconds: 1_000_000)
                        image = try await client.getImage(path: page.url)
                    } catch {
                        if Task.isCancelled {
                            return
                        }
                        print(error)
                        fatalError()
                    }
                }
        }
    }
}

//struct PageView_Previews: PreviewProvider {
//    static var previews: some View {
//        PageView()
//    }
//}
