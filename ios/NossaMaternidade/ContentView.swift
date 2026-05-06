//
//  ContentView.swift
//  NossaMaternidade
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @AppStorage("onboardingEmotionalComplete") private var emotionalComplete: Bool = false

    var body: some View {
        Group {
            if !emotionalComplete {
                OnboardingFlowView()
            } else if let profile = profiles.first, profile.hasAcceptedTerms {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            DataSeeder.seedIfNeeded(context: modelContext)
            configureTabBar()
        }
    }

    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        let inactive = UIColor(AppColor.inactiveTab)
        appearance.stackedLayoutAppearance.normal.iconColor = inactive
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: inactive]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Hoje")
                }
                .tag(0)

            DiaryView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Diário")
                }
                .tag(1)

            AgendaView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Agenda")
                }
                .tag(2)

            ContractionTimerView()
                .tabItem {
                    Image(systemName: "stopwatch.fill")
                    Text("Contrações")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
                .tag(4)
        }
        .tint(AppColor.sageGreen)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
