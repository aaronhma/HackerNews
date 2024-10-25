//
//  SubmitPostView.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/13/24.
//

import SwiftUI

struct SubmitPostView: View {
    // https://github.com/meysam81/submit-hackernews/blob/main/main.sh
    // https://news.ycombinator.com/submitlink?u=%22+encodeURIComponent(document.location)+%22&t=%22+encodeURIComponent(document.title)
    @State private var title = ""
    @State private var url = ""
    @State private var text = ""
    
    @State private var invalidURL = false
    
    @AppStorage("accountUserName") private var accountUserName = AppSettings.accountUserName
    @AppStorage("accountAuth") private var accountAuth = AppSettings.accountAuth
    
    var body: some View {
        NavigationStack {
            Form {
                if accountUserName.isEmpty && accountAuth.isEmpty {
                    NavigationLink {
                        LoginView()
                    } label: {
                        HStack {
                            Image(systemName: "plus.bubble")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                                .clipShape(RoundedRectangle(cornerRadius: 32))
                            
                            VStack(alignment: .leading) {
                                Text("Join the community.")
                                    .bold()
                                
                                Text("Come for the news, stay for the community.")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                } else {
                    Text("This doesn't work yet, wait for the next release.")
                }
                
                Section {
                    TextField("Title", text: $title)
                }
                
                Section {
                    TextField("URL", text: $url)
                } footer: {
                    if invalidURL {
                        Text("This URL doesn't seem to be valid. Double-check it.")
                            .foregroundStyle(.red)
                    }
                }
                .onChange(of: url) {
                    invalidURL = !url.isValidURL()
                }
                
                Section {
                    TextField("Text", text: $text)
                }
                
                Section {
                    Button {
                        if url.isValidURL() {
                            title = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                            url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                            text = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                            
                            let urlString = "https://news.ycombinator.com/submitlink?u=%22\(url)%22&t=%22\(title)%22&s=%22\(text)%22"
                            print(urlString)
                        } else {
                            invalidURL = true
                        }
                    } label: {
                        Label("Submit", systemImage: "plus")
                    }
                    .disabled(title.isEmpty || url.isEmpty || text.isEmpty)
                } footer: {
                    Text("Before submitting, make sure you read the [Hacker News Community Guidelines](https://news.ycombinator.com/newsguidelines.html).")
                }
            }
            .navigationTitle("Submit Post")
        }
    }
}

#Preview {
    SubmitPostView()
}
