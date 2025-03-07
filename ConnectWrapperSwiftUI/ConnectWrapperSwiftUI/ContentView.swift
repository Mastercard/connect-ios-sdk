//
//  ContentView.swift
//  ConnectWrapperSwiftUI
//
//  Created by Anupam Kumar on 07/03/25.
//

import SwiftUI
import Connect

struct ContentView: View {
    
    @State var connectUrlText: String = ""
    @FocusState var isTextFieldFocused: Bool
    @State var shouldLaunchConnect: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: getGradientColors(), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                        
            VStack(alignment: .center, spacing: 40) {
                Spacer()
                    .frame(height: 20)
                
                HStack{
                    Text("Connect SDK Demo App")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                }
                
                            
                Text("To get started copy/paste a Generated Connect URL value in the field below")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color(uiColor: UIColor(red: 254/255, green: 254/255, blue: 254/255, alpha: 0.1)))
                            .padding(.all, -10)
                            .padding(.vertical, -8)
                    }
                
                
                RoundedRectangle(cornerRadius: 5)
                    .frame(height: 56)
                    .foregroundStyle(Color.white)
                    .overlay {
                        TextField("Paste Generated Connect URL here.", text: $connectUrlText)
                            .padding()
                            .focused($isTextFieldFocused)
                    }
                    .onTapGesture {
                        isTextFieldFocused = true
                    }
                
                Button {
                    isTextFieldFocused = false
                    shouldLaunchConnect = true
                } label: {
                    RoundedRectangle(cornerRadius: 24)
                        .frame(height: 48)
                        .foregroundStyle(getButtonColor())
                        .overlay {
                            Text("Launch Connect")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(isButtonDisabled() ? Color(uiColor: UIColor(red: 254.0/255.0, green: 254.0/255.0, blue: 254.0/255.0, alpha: 0.32)) : Color.white)
                        }
                }
                .disabled(isButtonDisabled())
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .fullScreenCover(isPresented: $shouldLaunchConnect) {
            ConnectView(connectURLString: connectUrlText, delegate: self)
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    func getGradientColors() -> [Color] {
        return [
            Color(uiColor: UIColor(red: 0.518, green: 0.714, blue: 0.427, alpha: 1)),
            Color(uiColor: UIColor(red: 0.004, green: 0.537, blue: 0.616, alpha: 1)),
            Color(uiColor: UIColor(red: 0.008, green: 0.22, blue: 0.447, alpha: 1))
        ]
    }
    
    func getButtonColor() -> Color {
        if !isButtonDisabled()  {
            return Color(uiColor:UIColor(red: 254.0 / 255.0, green: 254.0 / 255.0, blue: 254.0 / 255.0, alpha: 0.24))
        }
        
        return Color(uiColor: UIColor(red: 254.0 / 255.0, green: 254.0 / 255.0, blue: 254.0 / 255.0, alpha: 0.16))
    }
    
    func isButtonDisabled() -> Bool {
        return connectUrlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func displayData(_ data: NSDictionary?) {
        print(data?.debugDescription ?? "no data in callback")
    }
}

extension ContentView: ConnectViewEventDelegate{
    func onCancel(_ data: NSDictionary?) {
        print("onCancel:")
        displayData(data)
        
        // Needed to dismiss the ConnectView
        shouldLaunchConnect = false
    }
    
    func onDone(_ data: NSDictionary?) {
        print("onDone:")
        displayData(data)
        
        // Needed to dismiss the ConnectView
        shouldLaunchConnect = false
    }
    
    func onError(_ data: NSDictionary?) {
        print("onError:")
        displayData(data)
        
        // Needed to dismiss the ConnectView
        shouldLaunchConnect = false
    }
    
    func onLoad() {
        print("onLoad:")
    }
    
    func onRoute(_ data: NSDictionary?) {
        print("onRoute:")
        displayData(data)
    }
    
    func onUser(_ data: NSDictionary?) {
        print("onUser:")
        displayData(data)
    }
}


#Preview {
    ContentView()
}
