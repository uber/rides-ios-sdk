//
//  ContentView.swift
//  UberSDK
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import SwiftUI
import UberAuth
import UberCore

class PrefillBuilder {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    
    var prefill: Prefill {
        .init(
            email: email,
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName
        )
    }
}

@Observable
final class Content {
    var selection: Item?
    var type: LoginType? = .authorizationCode
    var destination: LoginDestination? = .inApp
    var isTokenExchangeEnabled: Bool = true
    var shouldForceLogin: Bool = false
    var shouldForceConsent: Bool = false
    var isPrefillExpanded: Bool = false
    var response: AuthReponse?
    var prefillBuilder = PrefillBuilder()
    var isLoggedIn: Bool {
        UberAuth.isLoggedIn
    }
    
    func login() {
        
        var prompt: Prompt = []
        if shouldForceLogin { prompt.insert(.login) }
        if shouldForceConsent { prompt.insert(.consent) }
        
        let authProvider: AuthProviding = .authorizationCode(
            shouldExchangeAuthCode: isTokenExchangeEnabled,
            prompt: prompt
        )
        
        let authDestination: AuthDestination = {
            guard let destination else { return .inApp }
            switch destination {
            case .inApp: return .inApp
            case .native: return .native(appPriority: [.rides, .eats, .driver])
            }
        }()
        
        UberAuth.login(
            context: .init(
                authDestination: authDestination,
                authProvider: authProvider,
                prefill: isPrefillExpanded ? prefillBuilder.prefill : nil
            ),
            completion: { result in
                // Slight delay to allow for ASWebAuthenticationSession dismissal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    switch result {
                    case .success(let client):
                        self.response = AuthReponse(value: "\(client)")
                    case .failure(let error):
                        self.response = AuthReponse(value: error.localizedDescription)
                    }
                }
            }
        )
    }
    
    func logout() {
        UberAuth.logout()
        response = nil
    }
    
    func openUrl(_ url: URL) {
        UberAuth.handle(url)
    }
    
    enum Item: String, Hashable, Identifiable {
        case type = "Auth Type"
        case destination = "Destination"
        case tokenExchange = "Exchange Auth Code for Token"
        case forceLogin = "Always ask for Login"
        case forceConsent = "Always ask for Consent"
        case prefill = "Prefill Values"
        case firstName = "First Name"
        case lastName = "Last Name"
        case email = "Email"
        case phoneNumber = "Phone Number"
        
        
        var id: String { rawValue }
        
        var options: [any SelectionOption] {
            switch self {
            case .type:
                return LoginType.allCases
            case .destination:
                return LoginDestination.allCases
            default:
                return []
            }
        }
    }
}

struct ContentView: View {
    
    @Bindable var content: Content = .init()
    @State var isAuthTypeSheetPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            exampleList
                .navigationTitle("Uber iOS SDK")
        }
        .onOpenURL { content.openUrl($0) }
        .sheet(item: $content.selection, content: { item in
            switch item {
            case .type:
                SelectionView(
                    selection: $content.type,
                    options: LoginType.allCases
                )
                .presentationDetents([.height(200)])
            case .destination:
                SelectionView(
                    selection: $content.destination,
                    options: LoginDestination.allCases
                )
                .presentationDetents([.height(200)])
            default:
                EmptyView()
            }
        })
        .sheet(item: $content.response) { _ in
            AuthResponseView(response: $content.response)
                .presentationDetents([.height(200)])
        }
    }
    
    // MARK: Subviews
    
    @ViewBuilder
    private var exampleList: some View {
        List {
            Section(
                "Login",
                content: { loginSection }
            )
            Section(
                "Uber Button",
                content: { uberButtonSection }
            )
            Section(
                "Request a Ride Button",
                content: { rideRequestButtonSection }
            )
        }
    }
    
    @ViewBuilder
    private var loginSection: some View {
        
        textRow(.type, value: content.type?.description)
        textRow(.destination, value: content.destination?.description)
        toggleRow(.tokenExchange, value: $content.isTokenExchangeEnabled)
        toggleRow(.forceLogin, value: $content.shouldForceLogin)
        toggleRow(.forceConsent, value: $content.shouldForceConsent)
        toggleRow(.prefill, value: $content.isPrefillExpanded)
        
        if content.isPrefillExpanded {
            row {
                TextField(
                    Content.Item.firstName.rawValue,
                    text: $content.prefillBuilder.firstName
                )
            }
            row {
                TextField(
                    Content.Item.lastName.rawValue,
                    text: $content.prefillBuilder.lastName
                )
            }
            row {
                TextField(
                    Content.Item.email.rawValue,
                    text: $content.prefillBuilder.email
                )
            }
            row {
                TextField(
                    Content.Item.phoneNumber.rawValue,
                    text: $content.prefillBuilder.phoneNumber
                )
            }
        }
        
        Button(
            action: {
                content.isLoggedIn ? content.logout() : content.login()
            },
            label: {
                Text(content.isLoggedIn ? "Logout" : "Login")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        )
        .padding()
    }
    
    @ViewBuilder
    private var uberButtonSection: some View {
        UberButtonView()
            .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    private var rideRequestButtonSection: some View {
        RideRequestButtonView()
            .listRowInsets(EdgeInsets())
    }
    
    private func row(item: Content.Item? = nil,
                     @ViewBuilder content: () -> (some View),
                     showDisclosureIndicator: Bool = false,
                     tapHandler: (() -> Void)? = nil) -> some View {
        Button(
            action: { tapHandler?() },
            label: {
                HStack(spacing: 0) {
                    if let item { Text(item.rawValue) }
                    content()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    if showDisclosureIndicator { emptyNavigationLink }
                }
            }
        )
        .tint(.black)
    }
    
    private func textRow(_ item: Content.Item, value: String?) -> some View {
        row(
            item: item,
            content: { Text(value ?? "").foregroundStyle(.gray) },
            tapHandler: { content.selection = item }
        )
    }
    
    private func toggleRow(_ item: Content.Item, value: Binding<Bool>) -> some View {
        row(
            item: item,
            content: {
                Toggle(isOn: value, label: { EmptyView() })
            },
            showDisclosureIndicator: false,
            tapHandler: nil
        )
    }
    
    private let emptyNavigationLink: some View = NavigationLink.empty
        .frame(width: 17, height: 0)
        .frame(alignment: .leading)
}

#Preview {
    ContentView()
}
