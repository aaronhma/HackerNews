//
//  TextSizeView.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/10/24.
//

import SwiftUI

struct TextSizeView: View {
    @AppStorage("fontName") private var fontName = AppSettings.fontName
    @AppStorage("fontSize") private var fontSize = AppSettings.fontSize
    
    @State private var fontSearch = ""
    
    var intProxy: Binding<Double>{
        Binding<Double>(get: {
            return Double(fontSize)
        }, set: {
            print($0.description)
            fontSize = Int($0)
        })
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack {
                        Slider(value: intProxy, in: 4...80, step: 1.0)
                        Text("Font size: \(fontSize)")
                    }
                    
                    Button(role: .destructive) {
                        fontSize = 17
                    } label: {
                        Text("Reset to system font size")
                    }
                    .disabled(fontSize == 17)
                } header: {
                    Text("Text Size")
                } footer: {
                    Text("This only applies to comments.")
                }
                
                Section {
                    NavigationLink {
                        NavigationStack {
                            List {
                                Section {} header: {
                                    Text("Custom Fonts")
                                } footer: {
                                    Text("Add custom fonts in Settings > General > Fonts.")
                                }
                                
                                Section("Available Fonts") {
                                    ForEach(UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }.filter { fontSearch.isEmpty ? true : $0.contains(fontSearch) }, id: \.self) { i in
                                        Button {
                                            fontName = i
                                        } label: {
                                            HStack {
                                                Text(i)
                                                    .font(.custom(i, size: CGFloat(fontSize)))
                                                
                                                Spacer()
                                                
                                                if fontName == i {
                                                    Image(systemName: "checkmark")
                                                        .foregroundStyle(.blue)
                                                }
                                            }
                                        }
                                        .foregroundStyle(.primary)
//                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .searchable(text: $fontSearch, prompt: "Search Fonts")
                            .navigationTitle("Choose Font")
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    } label: {
                        HStack {
                            Text("Choose Font")
                            Spacer()
                            Text(fontName)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Button(role: .destructive) {
                        fontName = ""
                    } label: {
                        Text("Reset to system font family")
                    }
                    .disabled(fontName.isEmpty)
                } header: {
                    Text("Font")
                } footer: {
                    Text("This only applies to comments.")
                }
                
                Section("Preview") {
                    Text("HN is a news aggregator where users can find and discuss the latest news and submit content on anything that gratifies one’s intellectual curiosity. YC alumni also post engineering, product, and design jobs on HN.")
                        .font(fontName.isEmpty ? .system(size: CGFloat(fontSize)) : .custom(fontName, size: CGFloat(fontSize)))
                }
            }
            .navigationTitle("Text Size & Font")
        }
    }
}

#Preview {
    TextSizeView()
}
