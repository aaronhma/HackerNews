//
//  Search.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/16/24.
//

import SwiftUI

struct Search: View {
    @State private var searchText = ""
    @State private var results: [SearchResults.Hit] = []
    
    @State private var recentSearches: [String] = []
    
    @Namespace() var namespace
    
    func fetchResults() {
        guard let url = URL(string: "https://hn.algolia.com/api/v1/search?query=\(searchText)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching results: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data returned from API")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(SearchResults.self, from: data)
                self.results = response.hits
            } catch let error as DecodingError {
                print("Error parsing response: \(error)")
                switch error {
                case .typeMismatch(let type, let context):
                    print("Type mismatch: \(type) - \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found: \(type) - \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("Key not found: \(key) - \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("Unknown error: \(error)")
                }
            } catch {
                print("Error parsing response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: searchText.isEmpty ? "xmark.circle" : "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .opacity(searchText.isEmpty ? 0.4 : 1)
                    }
                    .disabled(searchText.isEmpty)
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                
                List {
                    if searchText.isEmpty && !recentSearches.isEmpty {
                        Section("Recent Searches") {
                            ForEach(recentSearches, id: \.self) { i in
                                Button {
                                    searchText = i
                                } label: {
                                    Text(i)
                                }
                            }
                        }
                    }
                    
                    if !searchText.isEmpty {
                        Section("Users") {
                            NavigationLink {
                                if #available(iOS 18.0, *) {
                                    UserView(id: searchText)
                                        .navigationTransition(.zoom(sourceID: searchText, in: namespace))
                                } else {
                                    UserView(id: searchText)
                                }
                            } label: {
                                Image(systemName: "person.circle.fill")
                                    .foregroundStyle(Color.random())
                                
                                Text(searchText)
                            }
                            .onTapGesture {
                                recentSearches.append(searchText)
                            }
                        }
                    }
                    
                    Section("Submissions") {
                        ForEach(results) { i in
                            NavigationLink {
                                if #available(iOS 18.0, *) {
                                    StoryIDDetailView(id: Int(i.objectID)!)
                                        .navigationTransition(.zoom(sourceID: i.objectID, in: namespace))
                                } else {
                                    StoryIDDetailView(id: Int(i.objectID)!)
                                }
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(i.title)
                                        .font(.headline)
                                    
                                    Text("Score: \(i.points)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Search")
            }
            .onAppear {
                fetchResults()
            }
            .onChange(of: searchText) {
                fetchResults()
            }
        }
    }
}

#Preview {
    Search()
}
