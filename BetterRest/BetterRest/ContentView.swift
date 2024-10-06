// Zheen H. Suseyi
//
// 10/06/2024
//
// BetterRest

/*
 Challenge:
 One of the best ways to learn is to write your own code as often as possible, so here are three ways you should try extending this app to make sure you fully understand what’s going on:

 Replace each VStack in our form with a Section, where the text view is the title of the section. Do you prefer this layout or the VStack layout? It’s your app – you choose!
 Replace the “Number of cups” stepper with a Picker showing the same range of values.
 Change the user interface so that it always shows their recommended bedtime using a nice and large font. You should be able to remove the “Calculate” button entirely.
 */

// importing CoreML since we have a Machine Learning algorithm which calculates what time the user should go to bed in order to get their desired sleep.
import CoreML
import SwiftUI

struct ContentView: View {
    // wakeUp variable set to defaultWakeTime which will be 7am
    @State private var wakeUp = defaultWakeTime
    // sleepAmount variable set to default amount of 8 hours
    @State private var sleepAmount = 8.0
    // coffeeAmount variable set to default amount of 1
    @State private var coffeeAmount = 1
    // coffee variable that will be used for our Picker selector
    let coffee = 1...20
    
    // Computed property for default wake-up time
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    // Computed property to calculate ideal bedtime dynamically using our ML algorithm
    var idealBedtime: String {
        // do block which will calculate using ML
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
            // catch block just in case
        } catch {
            return "Error: Unable to calculate bedtime."
        }
    }
    
    var body: some View {
        // VStack
            VStack {
                // BetterRest title
                Text("BetterRest")
                
                // font modifiers
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                
                // Form
                Form {
                    // Select Desired Wakeup Time
                    Section(header: Text("Select Desired Wakeup Time")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)) {
                        
                        // Datepicker that the user can select
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            
                    }
                    // Select Desired Sleep Amount
                    Section(header: Text("Selection Desired Sleep Amount")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        ) {
                        // Stepper that the user can select using .25 increments
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    // Select Amount of Coffee Consumed
                    Section(header: Text("Select Amount of Coffee Cups")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)) {
                            
                        // User can select how many cups using a Picker
                        Picker("How many cups", selection: $coffeeAmount) {
                            ForEach(coffee, id: \.self) { amount in
                                Text("\(amount) cups").tag(amount)
                            }
                        }
                    }
                    
                    // Shows the ideal bedtime for the user using the idealBedtime computed property
                    Section("Your Ideal Bedtime") {
                        Text(idealBedtime)
                            .font(.largeTitle)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center) // Center align the text
                    }
                }
            }
        }
    }

#Preview {
    ContentView()
}
