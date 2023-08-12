import SwiftUI

class NavigationCoordinator: ObservableObject {
    enum ViewType {
        case home
        case playerSetup
        case gameplay
    }
    
    @Published var currentView: ViewType = .home
}

@main
struct CheersApp: App {
    @StateObject private var navigationCoordinator = NavigationCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationCoordinator)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator

    var body: some View {
        NavigationView {
            switch navigationCoordinator.currentView {
            case .home:
                HomePageView()
            case .playerSetup:
                PlayerSettingsView()
            case .gameplay:
                GameplayView(playerNames: [])
            }
        }
        .background(NavigationConfigurator { nc in
            nc.navigationBar.barTintColor = .black
            nc.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: "Helvetica-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)]
            nc.navigationBar.tintColor = .white
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NavigationCoordinator())
    }
}

struct HomePageView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .padding()
                NavigationLink(destination: PlayerSettingsView()) {
                    Image("StartButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                }
            }
        }
        .background(NavigationConfigurator { nc in
            nc.navigationBar.barTintColor = .black
            nc.navigationBar.titleTextAttributes = [.font: UIFont(name: "Helvetica-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)]
        })
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }
}

struct CustomNavigationBar: View {
    let title: String
    let leadingItem: AnyView?
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                leadingItem
                Spacer()
                Text(title)
                    .foregroundColor(.white)
                    .font(.custom("Helvetica-Bold", size: 30))
                Spacer()
            }
            .padding(.horizontal)
            Spacer()
        }
        .frame(height: 100)
        .background(Color.black)
    }
}

struct PlayerSettingsView: View {
    @State private var numberOfPlayers: Int = 2
    @State private var playerNames: [String] = ["", ""]
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Mate Setup", leadingItem: AnyView(
                Button(action: {
                    navigationCoordinator.currentView = .home
                }) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }))
            
            ZStack {
                Color.gray.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 15) {
                    ForEach(0..<numberOfPlayers, id: \.self) { index in
                        HStack {
                            TextField("Player \(index + 1) Name", text: Binding(
                                get: { self.playerNames[index] },
                                set: { self.playerNames[index] = $0 }))
                                .foregroundColor(.white)
                                .font(.system(size: 25))
                            
                            Spacer()

                            if numberOfPlayers < 10 {
                                Button(action: {
                                    self.numberOfPlayers += 1
                                    self.playerNames.append("")
                                }) {
                                    Image(systemName:"plus.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            
                            if numberOfPlayers > 2 {
                                Button(action: {
                                    self.numberOfPlayers -= 1
                                    self.playerNames.remove(at: index)
                                }) {
                                    Image(systemName:"minus.circle.fill").foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                    }

                    Spacer()

                    if playerNames.filter({ !$0.isEmpty }).count >= 2 {
                        NavigationLink(destination: GameplayView(playerNames: playerNames)) {
                            Image("PlayButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150)
                        }
                        .padding(.horizontal, 28)
                    }
                }
                .padding(.top, 28)
            }
        }
    }
}


struct GameplayView: View {
    let playerNames: [String]
    @State private var currentPrompt: String
    @State private var currentPlayerIndex: Int = 0
    private var gameData = GameData()
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: playerNames[currentPlayerIndex], leadingItem: AnyView(
                Button(action: {
                    navigationCoordinator.currentView = .home
                }) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }))
            
            Spacer()
            
            Text(currentPrompt)
                .font(Font.custom("Helvetica-Bold", size: 50))
                .padding()
            
            Spacer()
            
            Button(action: {
                currentPrompt = gameData.getRandomPrompt() ?? "Game Finished!"
                
                currentPlayerIndex = (currentPlayerIndex + 1) % playerNames.count
            }) {
                Image("NextMateButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    init(playerNames: [String]) {
        self.playerNames = playerNames
        self.gameData = GameData()
        self._currentPrompt = State(initialValue: gameData.getRandomPrompt() ?? "Error fetching prompt")
    }
}

class GameData {
    var prompts: [String] = ["Everyone Drinks",
        "Mate to your left drinks",
        "Mate to your right drinks",
        "Your neighbours drink",
        "You and a mate drink",
        "Switch drinks with the mate on your right",
        "Pick a mate to drink",
        "Skip your go",
        "Girls Drink",
        "Boys Drink",
        "Host Drinks",
        "Singles Drink",
        "Smokers Drink",
        "Mates with blond hair drink",
        "Mates with brunette hair drink",
        "Mates with dyed hair drink",
        "Mates with blue eyes drink",
        "Mates with brown eyes drink",
        "Mates with separated parents drink",
        "Mates with cracked phone screens drink",
        "Mates with a tattoo drink",
        "Mates with basic names drink",
        "Mates that don’t have an iPhone drink",
        "Mates that can’t drive drink",
        "Mates that posted a story today drink",
        "Mates wearing a bra drink",
        "Mates born between January - June drink",
        "Mates born between July - December drink",
        "All mates sip for every ex they have",
        "All mates sip for every piercing they have",
        "Last mate to use the toilet drink",
        "Sip for the amount of mates playing",
        "Youngest & oldest mate drink",
        "Tallest & shortest mate drink",
        "First & Last mate to arrive drink",
        "Most & least drunk mate drink",
        "Most & least followed mate on Instagram drink",
        "Swap clothes with the mate on your left",
        "Let a mate text off your phone",
        "Say “i love you” to the last person you texted",
        "Impersonate another player",
        "Call a parent",
        "Reveal your search history",
        "Pick the next song",
        "Take a group picture",
        "Mystery drink",
        "Body shot",
        "Staring contest",
        "Arm wrestle",
        "Race",
        "Heaven",
        "Paranoia",
        "Mr & Mrs",
        "Shot roulette",
        "Thumb war",
        "Rock Paper Scissors",
        "Fuck Marry Kill",
        "Truth or Dare",
        "Never have I ever…",
        "Waterfall",
        "Medusa",
        "Spin the bottle",
        "Suck & blow",
        "Thunderstruck",
        "Floor is lava",
        "Rhyme",
        "Categories",
        "Nose goes"]
    var usedPrompts: Set<String> = []
    
    func getRandomPrompt() -> String? {
        let availablePrompts = prompts.filter { !usedPrompts.contains($0) }
        guard let randomPrompt = availablePrompts.randomElement() else {
            return "Game Finished!"
        }
        usedPrompts.insert(randomPrompt)
        return randomPrompt
    }
}
