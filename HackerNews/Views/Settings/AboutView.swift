//
//  AboutView.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/10/24.
//

import SwiftUI

struct AboutView: View {
    var appVersion: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0"
    }
    
    @AppStorage("showOnboarding") private var showOnboarding = AppSettings.showOnboarding
    
    var body: some View {
        NavigationStack {
            Image(uiImage: Bundle.main.icon ?? UIImage())
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .accentColor, radius: 5)
            
            Text("bark for Hacker News")
                .bold()
                .font(.largeTitle)
            
            Text("v\(appVersion)")
                .foregroundStyle(.secondary)
            
            Text("Developer Beta 1")
            
            Text("Made with 💖 & 😀\nby **Aaron Ma**.")
                .multilineTextAlignment(.center)
            
            Button {
                if let url = URL(string: "https://x.com/aaronhma") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Spacer()
                    Label("Twitter", systemImage: "bird.fill")
                        .bold()
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(.blue.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.blue, lineWidth: 2)
                }
            }
            .padding(.horizontal)
            
            Text("with 🥰 & 😘 from Earth, The Milky Way 🌎")
            
            Button {
                showOnboarding = true
            } label: {
                Text("Show Onboarding")
            }
            
            NavigationLink {
                NavigationStack {
                    List {
                        Section("API") {
                            NavigationLink {
                                ScrollView {
                                    Text("""
The MIT License (MIT)

Copyright (c) 2024 Y Combinator Hacker News

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
""")
                                    .navigationTitle("Hacker News")
                                }
                            } label: {
                                Text("Hacker News")
                            }
                        }
                        
                        Section("HTML Parser") {
                            NavigationLink {
                                ScrollView {
                                    Text("""
MIT License

Copyright (c) 2016 Nabil Chatbi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
""")
                                    .navigationTitle("SwiftSoup")
                                }
                            } label: {
                                Text("SwiftSoup")
                            }
                        }
                        
                        Section("Bark AI") {
                            NavigationLink {
                                ScrollView {
                                    Text("""
MIT License

Copyright 2023 SwiftBeta

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

""")
                                    .navigationTitle("SwiftOpenAI")
                                }
                            } label: {
                                Text("SwiftOpenAI")
                            }
                        }
                    }
                    .navigationTitle("Acknowledgements")
                }
            } label: {
                Text("Acknowledgements")
            }
        }
    }
}

#Preview {
    AboutView()
}
