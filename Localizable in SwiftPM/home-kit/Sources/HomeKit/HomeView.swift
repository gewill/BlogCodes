import Combine
import RswiftResources
import SwiftUI

enum Language: String, CaseIterable, Identifiable {
  case en
  case zh_Hans = "zh-Hans"

  var id: Self { self }

  var displayTitle: String {
    switch self {
    case .en: "English"
    case .zh_Hans: "简体中文"
    }
  }
}

class AppLocale {
  let preferredLanguage = CurrentValueSubject<Language, Never>(.en)
  var preferredString: _R.string {
    R.string(preferredLanguages: [preferredLanguage.value.rawValue])
  }

  static var shared = AppLocale()
  private init() {}
}

class HomeViewModel: ObservableObject {
  @Published var locale: Locale = Locale(identifier: Language.zh_Hans.rawValue)
  @Published var preferredLanguage: Language = AppLocale.shared.preferredLanguage.value

  var cancelables = Set<AnyCancellable>()

  init() {
    AppLocale.shared.preferredLanguage
      .removeDuplicates()
      .assign(to: \.preferredLanguage, on: self)
      .store(in: &cancelables)

    $preferredLanguage
      .sink { [weak self] language in
        guard let self else { return }
        print("perferredLanguages: \(language.rawValue)")
        AppLocale.shared.preferredLanguage.value = language
      }
      .store(in: &cancelables)

    $locale
      .sink { [weak self] locale in
        guard let self else { return }
        print("locale: \(locale)")
      }
      .store(in: &cancelables)
  }
}

public struct HomeView: View {
  @StateObject var viewModel = HomeViewModel()

  public init() {}

  public var body: some View {
    List {
      Text("This is Home View")

      Section {
        Text(LocalizedStringKey("home_title"))
          .font(.title)

        Text(R.string.localizable_en.home_title.developmentValue ?? "--")
        Text(R.string.localizable_zh.home_title.developmentValue ?? "--")

        Text(R.string.localizable(preferredLanguages: ["zh-Hans"]).hello_world)
        Text(R.string.localizable(preferredLanguages: ["en"]).hello_world)
        Text(R.string(preferredLanguages: ["zh-Hans"]).localizable.hello_world)
        // not work
        Text(R.string(preferredLanguages: [], locale: Locale(identifier: "zh-Hans")).localizable.hello_world)
      } header: {
        Text("Try R.string")
      }

      Section {
        Text("Preferred Languages \(viewModel.preferredLanguage.displayTitle)")
        Picker("Preferred Languages", selection: $viewModel.preferredLanguage) {
          ForEach(Language.allCases) {
            Text($0.displayTitle)
          }
        }
        .pickerStyle(.segmented)
        Text(AppLocale.shared.preferredString.localizable.hello_world)
      } header: {
        Text("Change R.string Preferred Languages")
      }

      Section {
        Text("Change locale").font(.title)
        Text("Will be overwrite by host app!").foregroundColor(.pink)
        Button(action: {
          viewModel.locale = Locale(identifier: Language.en.rawValue)
        }, label: {
          Text("Change locale english")
        })
        Button(action: {
          viewModel.locale = Locale(identifier: Language.zh_Hans.rawValue)
        }, label: {
          Text("Change locale chinese simplified")
        })
        Text(LocalizedStringKey(R.string.localizable.hello_world.key.description))
      } header: {
        Text("Change locale")
      }
    }
    .environment(\.locale, viewModel.locale)
  }
}

#Preview {
  HomeView()
}
