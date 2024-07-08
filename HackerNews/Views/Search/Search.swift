//
//  UserSearch.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/5/24.
//

import SwiftUI

struct Search: View {
    @State private var user = ""
    @State private var recentSearches: [String] = []
    
//    struct HackerNewsSearchResult: Codable {
//        let exhaustive: Exhaustive
//        let hits: [Hit]
//    }
//
//    struct Exhaustive: Codable {
//        let nbHits: Bool
//        let typo: Bool
//        let exhaustiveNbHits: Bool
//        let exhaustiveTypo: Bool
//    }
//
//    struct Hit: Codable {
//        let _highlightResult: HighlightResult
//        let _tags: [String]
//        let author: String
//        let children: [Int]
//        let created_at: String
//        let created_at_i: Int
//        let num_comments: Int
//        let objectID: String
//        let points: Int
//        let story_id: Int
//        let title: String
//        let updated_at: String
//        let url: String
//    }
//
//    struct HighlightResult: Codable {
//        let author: Highlight
//        let title: Highlight
//        let url: Highlight
//    }
//
//    struct Highlight: Codable {
//        let matchLevel: String
//        let matchedWords: [String]
//        let value: String
//    }

    
//    let searchTerm = "hacker news"
//    let urlString = "https://hn.algolia.com/api/v1/search?query=\(searchTerm)&tags=story&hitsPerPage=10&page=0"
//
//    if let url = URL(string: urlString) {
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                print("Error: \(error)")
//            } else if let data = data {
//                let decoder = JSONDecoder()
//                if let hits = try? decoder.decode(HackerNewsSearchResult.self, from: data) {
//                    for hit in hits {
//                        if let title = hit["title"] as? String, let url = hit["url"] as? String {
//                            print("Title: \(title)\nURL: \(url)\n")
//                        }
//                    }
//                }
//            }
//        }
//        task.resume()
//    }
    
    var body: some View {
        NavigationStack {
            List {
                if !user.isEmpty {
                    Section("Search Suggestions") {
                        NavigationLink {
                            UserView(id: user)
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(Color.random())
                            
                            Text(user)
                        }
                        .onTapGesture {
                            recentSearches.append(user)
                        }
                    }
                }
                
                if user.isEmpty {
                    Section("Recent Searches") {
                        if recentSearches.isEmpty {
                            HStack {
                                Spacer()
                                
                                VStack {
                                    Spacer()
                                    
                                    Image(systemName: "clock.arrow.circlepath")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                        .padding(.bottom, 10)
                                    
                                    Text("No Searches Yet")
                                        .font(.title)
                                        .bold()
                                        .padding(.bottom, 10)
                                    
                                    Text("Search any user and it'll appear here.")
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 50)
                                        .padding(.bottom, 30)
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                            }
                        }
                        
                        ForEach(recentSearches, id: \.self) { i in
                            NavigationLink {
                                UserView(id: i)
                            } label: {
                                Label(i, systemImage: "person")
                            }
                        }
                    }
                }
            }
            .searchable(text: $user, prompt: "Search for anything...")
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    Search()
}
