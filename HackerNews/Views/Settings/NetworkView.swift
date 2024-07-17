//
//  NetworkView.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/10/24.
//

import SwiftUI

struct NetworkView: View {
    @State private var openedNetwork = true
    @State private var openedNetworkOptions = false
    @State private var openedDataUsage = false
    @State private var clearCache = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    GroupBox {
                        if openedNetwork {
                            Divider()
                            
                            VStack(alignment: .leading) {
                                Toggle("Show Website Image Previews", isOn: .constant(true))
                                    .bold()
                                Text("Images will not display on section fronts to reduce data usage.")
                                    .padding(.top, 5)
                                    .foregroundStyle(.secondary)
                                Divider()
                                Toggle("Automatic Refresh", isOn: .constant(true))
                                    .bold()
                                Text("Content will not update automatically to reduce data usage.")
                                    .padding(.top, 5)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top)
                        }
                    } label: {
                        Button {
                            withAnimation {
                                openedNetwork.toggle()
                            }
                        } label: {
                            HStack {
                                Label("Network", systemImage: "network")
                                
                                Spacer()
                                
                                Image(systemName: openedNetwork ? "chevron.down" : "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.primary)
                        .symbolEffect(.bounce, value: openedNetwork)
                    }
                    .sensoryFeedback(.impact, trigger: openedNetwork)
                    
                    GroupBox {
                        if openedNetworkOptions {
                            Divider()
                            
                            VStack(alignment: .leading) {
                                Toggle("Allow Cellular Access", isOn: .constant(true))
                                    .bold()
                                Text("Content will not update automatically on **Cellular**.")
                                    .padding(.top, 5)
                                    .foregroundStyle(.secondary)
                                Divider()
                                Toggle("Allow Low Data Mode Access", isOn: .constant(true))
                                    .bold()
                                Text("Content will not update automatically on **Low Data Mode**.")
                                    .padding(.top, 5)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top)
                        }
                    } label: {
                        Button {
                            withAnimation {
                                openedNetworkOptions.toggle()
                            }
                        } label: {
                            HStack {
                                Label("Network Options", systemImage: "list.star")
                                
                                Spacer()
                                
                                Image(systemName: openedNetworkOptions ? "chevron.down" : "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.primary)
                        .symbolEffect(.bounce, value: openedNetworkOptions)
                    }
                    .sensoryFeedback(.impact, trigger: openedNetworkOptions)
                    
                    GroupBox {
                        if openedDataUsage {
                            Divider()
                            VStack(alignment: .leading) {
                                ProgressView(value: 69, total: 100)
                                    .progressViewStyle(.linear)
                                    .padding(.vertical)
                                
                                Text("bark will use up to ∞GB of storage space before clearing cache.")
                                    .bold()
                                    .font(.title3)
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading) {
                                Toggle("Automatically Download Stories", isOn: .constant(true))
                                    .bold()
                                Text("Stories will automatically download for offline reading.")
                                    .padding(.top, 5)
                                    .foregroundStyle(.secondary)
                                Divider()
                                Button {
                                    clearCache = true
                                } label: {
                                    HStack {
                                        Spacer()
                                        Label("Clear Cache", systemImage: "trash")
                                            .foregroundStyle(.white)
                                            .bold()
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .background(.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                .confirmationDialog("All downloaded stories will be removed on the next app launch.", isPresented: $clearCache, titleVisibility: .visible) {
                                    Button("Clear Cache", role: .destructive) {
                                        URLCache.shared.removeAllCachedResponses()
                                    }
                                }
                                .padding(.top)
                                Text("All downloaded stories & content will be removed.")
                                    .padding(.top, 5)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top)
                        }
                    } label: {
                        Button {
                            withAnimation {
                                openedDataUsage.toggle()
                            }
                        } label: {
                            HStack {
                                Label("Data Usage", systemImage: "internaldrive")
                                
                                Spacer()
                                
                                Image(systemName: openedDataUsage ? "chevron.down" : "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.primary)
                        .symbolEffect(.bounce, value: openedDataUsage)
                    }
                    .sensoryFeedback(.impact, trigger: openedDataUsage)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Network & Data Usage")
        }
    }
}

#Preview {
    NetworkView()
}
