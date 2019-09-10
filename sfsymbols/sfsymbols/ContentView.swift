//
//  ContentView.swift
//  sfsymbols
//
//  Created by An Trinh on 9/9/19.
//  Copyright © 2019 An Trinh. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var darkMode = true
    @State var searchText = ""
    
    @State var showingDetails = false
    @State var focusedSymbol = ""
    
    private let listLimit = 100
    
    var body: some View {
        NavigationView {
            List {
                Section(header: HStack {
                    TextField("Search", text: $searchText)
                        .disableAutocorrection(true)
                        .foregroundColor(Color.primary)
                        .frame(height: 50)
                        .padding([.leading, .trailing])
                    if !searchText.isEmpty {
                        Button(action: {
                            self.searchText = ""
                            UIApplication.shared.windows.first?.endEditing(true)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(Color.primary)
                                .padding()
                        }
                    }
                }) {
                    ForEach(filteredSymbols(self.searchText, restrictLimit: true), id: \.self) { symbol in
                        Button(action: {
                            self.focusedSymbol = symbol
                            self.showingDetails.toggle()
                        }) {
                            SymbolRow(symbol: symbol)
                        }
                    }
                    if filteredSymbols(self.searchText, restrictLimit: true).count == listLimit {
                        NavigationLink(destination:
                            List {
                                ForEach(filteredSymbols(self.searchText, restrictLimit: false), id: \.self) { symbol in
                                    Button(action: {
                                        self.focusedSymbol = symbol
                                        self.showingDetails.toggle()
                                    }) {
                                        SymbolRow(symbol: symbol)
                                    }
                                }
                        }.navigationBarTitle("", displayMode: .automatic)) {
                            Text("See all \(filteredSymbols(self.searchText, restrictLimit: false).count) symbols")
                                .font(.headline)
                                .bold()
                        }
                    }
                }
            }
            .navigationBarTitle("SF Symbols", displayMode: .automatic)
            .navigationBarItems(trailing: Button(action: {
                self.darkMode.toggle()
                self.reloadDarkMode(self.darkMode)
            }) {
                Image(systemName: self.darkMode ? "sun.max.fill" : "moon.circle.fill")
                    .imageScale(.large)
                    .padding()
            })
        }
        .onAppear() {
            self.reloadDarkMode(self.darkMode)
        }
        .sheet(isPresented: $showingDetails) {
            DetailView(symbol: self.focusedSymbol)
        }
    }
    
    func reloadDarkMode(_ darkMode: Bool) {
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = darkMode ? .dark : .light
    }
    
    func filteredSymbols(_ searchText: String, restrictLimit: Bool) -> [String] {
        var filteredSymbols = symbols
        if !searchText.isEmpty {
            filteredSymbols = symbols.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        
        // optimization due to rendering 1600+ cells causes 100% CPU lag for 10 seconds
        if restrictLimit && filteredSymbols.count > listLimit {
            var trimmedSymbols: [String] = []
            for symbol in filteredSymbols {
                trimmedSymbols.append(symbol)
                if trimmedSymbols.count == listLimit {
                    break
                }
            }
            filteredSymbols = trimmedSymbols
        }
        
        return filteredSymbols
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .colorScheme(.dark)
    }
}

struct SymbolRow: View {
    let symbol: String
    
    var body: some View {
        HStack {
            Image(systemName: symbol)
                .imageScale(.large)
                .frame(width: 40, height: 40)
            Text(symbol)
                .font(.headline)
                .bold()
        }
    }
}