//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import SwiftUI
import UberAuth

@Observable
final class Content {
    var selection: Item?
    var type: LoginType? = .authorizationCode
    var destination: LoginDestination? = .inApp
    var response: String?
    
    func login() {
        
        let authProvider: AuthProviding = .authorizationCode(
            shouldExchangeAuthCode: false
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
                prefill: nil
            ),
            completion: { result in
                switch result {
                case .success(let client):
                    print(client)
                    self.response = "\(client)"
                case .failure(let error):
                    self.response = error.localizedDescription
                }
            }
        )
    }
    
    func openUrl(_ url: URL) {
        UberAuth.handle(url)
    }
    
    enum Item: String, Hashable, Identifiable {
        case type = "Auth Type"
        case destination = "Destination"
        
        var id: String { rawValue }
        
        var options: [any SelectionOption] {
            switch self {
            case .type:
                return LoginType.allCases
            case .destination:
                return LoginDestination.allCases
            }
        }
    }
}

struct ContentView: View {
    
    @Bindable var content: Content = .init()
    @State var isAuthTypeSheetPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                exampleList
                Divider()
                responseSection
            }
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
            }
        })
    }
    
    // MARK: Subviews
    
    private var responseSection: some View {
        VStack {
            Text("Response:")
                .font(.title3)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal) {
                Text(content.response ?? "")
                    .selectionDisabled(false)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150)
    }
    
    private var exampleList: some View {
        List {
            Section(
                "Login",
                content: { loginSection }
            )
        }
    }
    
    @ViewBuilder
    private var loginSection: some View {
        
        row(
            item: .type,
            content: {
                Text(content.type?.description ?? "")
                    .foregroundStyle(.gray)
            },
            tapHandler: { content.selection = .type }
        )
        
        row(
            item: .destination,
            content: {
                Text(content.destination?.description ?? "")
                    .foregroundStyle(.gray)
            },
            tapHandler: { content.selection = .destination }
        )
        
        Button(
            action: { content.login() },
            label: {
                Text("Login")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        )
        .padding()
    }
    
    private func row(item: Content.Item? = nil,
                     @ViewBuilder content: () -> (some View),
                     tapHandler: (() -> Void)? = nil) -> some View {
        Button(
            action: { tapHandler?() },
            label: {
                HStack(spacing: 0) {
                    if let item { Text(item.rawValue) }
                    Spacer()
                    content()
                    emptyNavigationLink
                }
            }
        )
        .tint(.black)
    }
    
    private let emptyNavigationLink: some View = NavigationLink.empty
        .frame(width: 17, height: 0)
        .frame(alignment: .leading)
}

#Preview {
    ContentView()
}
