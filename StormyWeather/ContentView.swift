//
//  ContentView.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 5/3/21.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var storm = StormViewModel() ;

    var body: some View {
        Text("The weather at your current location is:")
            .padding()

        Text(storm.weatherSummary)
            .padding()

        Text(storm.location)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
