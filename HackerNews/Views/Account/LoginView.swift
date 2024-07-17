//
//  LoginView.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/11/24.
//

import SwiftUI
import WebKit

struct LoginSafariView: UIViewRepresentable {
    let webView: WKWebView
    
    @AppStorage("accountUserName") private var accountUserName = AppSettings.accountUserName
    @AppStorage("accountAuth") private var accountAuth = AppSettings.accountAuth
    
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No need to access cookies here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: LoginSafariView
        
        init(_ parent: LoginSafariView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Get the cookies every time the site changes
            let websiteDataStore = WKWebsiteDataStore.default()
            websiteDataStore.httpCookieStore.getAllCookies { cookies in
                for cookie in cookies {
                    if cookie.name == "user" {
                        let user = cookie.value.components(separatedBy: "&")
                        self.parent.accountUserName = user[0]
                        self.parent.accountAuth = user[1]
                        print("FOUND VALUE: \(cookie.value) | \(cookie.value.components(separatedBy: "&")[1])")
                    }
                }
            }
        }
    }
}


struct LoginView: View {
    @State private var webView: WKWebView?
    
    @AppStorage("accountUserName") private var accountUserName = AppSettings.accountUserName
    @AppStorage("accountAuth") private var accountAuth = AppSettings.accountAuth
    
    func loadWebView() {
        let webView = WKWebView(frame: .zero)
        webView.load(URLRequest(url: URL(string: "https://news.ycombinator.com/login")!))
        self.webView = webView
    }
    
    var body: some View {
        VStack {
            if !accountUserName.isEmpty && !accountAuth.isEmpty {
                UserView(id: accountUserName)
            } else if let webView = webView {
                if #available(iOS 18.0, *) {
                    LoginSafariView(webView: webView)
                } else {
                    LoginSafariView(webView: webView)
                }
            } else {
                VStack {
                    Image(systemName: "y.square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 85, height: 85)
                        .foregroundStyle(.orange)
                    
                    Text("Hacker News Account")
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                        .bold()
                    
                    Text("One account for everything YC.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.top, 5)
                    
                    Text("Sign in to access your profile, submit posts, upvote, reply to posts and comments, and more.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 15)
                    
                    Button {
                        loadWebView()
                    } label: {
                        Label("Sign in", systemImage: "person.circle")
                    }
                    .padding(8)
                    .foregroundStyle(.white)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
                    .bold()
                    .padding(.top, 15)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 55)
            }
        }
    }
}

#Preview {
    LoginView()
}
