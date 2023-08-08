import SwiftUI

@main
struct CheersApp: App {
    var body: some Scene {
        WindowGroup {
            HomePageView()
        }
    }
}

struct HomePageView: View {
    var body: some View {
        VStack {
            Image("logo")
            NavigationLink("Start Game", destination: PlayerSettingsView())
        }
    }
}

struct PlayerSettingsView: View {
    @State private var numberOfPlayers: Int = 2
    @State private var playerNames: [String] = ["", ""]

    var body: some View {
        VStack {
            Stepper("Number of Players: \(numberOfPlayers)", value: $numberOfPlayers, in: 2...10)
            ForEach(0..<numberOfPlayers, id: \.self) { index in
                TextField("Player \(index + 1) Name", text: $playerNames[index])
            }
            NavigationLink("Begin", destination: GameplayView(playerNames: playerNames))
        }
    }
}

struct GameplayView: View {
    let playerNames: [String]
    @State private var currentPrompt: String = ""
    private var gameData = GameData()
    
    var body: some View {
        VStack {
            Text(currentPrompt)
            Button("Next Prompt") {
                currentPrompt = gameData.getRandomPrompt() ?? "Error fetching prompt"
            }
        }
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
            return "All prompts exhausted!"  // Message when all prompts are used
        }
        usedPrompts.insert(randomPrompt)
        return randomPrompt
    }
}
