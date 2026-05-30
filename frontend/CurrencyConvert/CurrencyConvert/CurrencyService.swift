import Foundation
import Combine

@MainActor
class CurrencyService: ObservableObject {
    @Published var convertedAmount: Double?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func convert(amount: Double, from base: String, to target: String) async {
        isLoading = true
        errorMessage = nil
        convertedAmount = nil

        var components = URLComponents(string: "http://localhost:8000/api/exchange-rates/")!
        components.queryItems = [
            URLQueryItem(name: "base", value: base),
            URLQueryItem(name: "targets", value: target),
            URLQueryItem(name: "amount", value: String(amount))
        ]

        guard let url = components.url else {
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(ExchangeResponse.self, from: data)
            convertedAmount = decoded.convertedAmount
        } catch {
            errorMessage = "Failed to fetch rates. Is the backend running?"
        }

        isLoading = false
    }
}

private struct ExchangeResponse: Decodable {
    let convertedAmount: Double

    enum CodingKeys: String, CodingKey {
        case convertedAmount = "converted amount"
    }
}
