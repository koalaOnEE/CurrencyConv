import SwiftUI

struct ContentView: View {
    @StateObject private var service = CurrencyService()
    private let availableCurrencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY", "INR", "MXN", "BRL", "KRW"]

    @State private var amountText = ""
    @State private var baseCurrency = "USD"
    @State private var targetCurrency = "EUR"

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    TextField("Enter amount", text: $amountText)
                        .keyboardType(.decimalPad)
                }

                Section("Convert") {
                    Picker("From", selection: $baseCurrency) {
                        ForEach(availableCurrencies, id: \.self) { Text($0) }
                    }
                    Picker("To", selection: $targetCurrency) {
                        ForEach(availableCurrencies, id: \.self) { Text($0) }
                    }
                }

                Section {
                    Button("Convert") {
                        Task {
                            if let amount = Double(amountText) {
                                await service.convert(amount: amount, from: baseCurrency, to: targetCurrency)
                            }
                        }
                    }
                    .disabled(Double(amountText) == nil || service.isLoading)
                }

                if service.isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }

                if let result = service.convertedAmount {
                    Section("Result") {
                        HStack {
                            Text("\(amountText) \(baseCurrency)")
                            Spacer()
                            Text(String(format: "%.2f %@", result, targetCurrency))
                                .bold()
                        }
                    }
                }

                if let error = service.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Currency Converter")
        }
    }
}
