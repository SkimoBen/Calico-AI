//
//  SavedInfo.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-10.
//

import Foundation

//structure for saving runtime data
struct UserRunTime {
    var totalRunTime: Double
    var monthlyRunTime: Double
}

//This class is what manages the data for run time use. stores total and monthly runtime.

class RunTimeHelper {
    private let totalRunTimeKey = "totalRunTimeKey"
    private let monthlyRunTimeKey = "monthlyRunTimeKey"
    private let lastUpdatedKey = "lastUpdatedKey"

    func save(runTime: UserRunTime) {
        UserDefaults.standard.set(runTime.totalRunTime, forKey: totalRunTimeKey)
        UserDefaults.standard.set(runTime.monthlyRunTime, forKey: monthlyRunTimeKey)
        UserDefaults.standard.set(Date(), forKey: lastUpdatedKey)
    }
    //call getRunTime to check if the paywall should appear, or if they need to be rate limitted.
    func getRunTime() -> UserRunTime {
        let totalRunTime = UserDefaults.standard.double(forKey: totalRunTimeKey)
        var monthlyRunTime = UserDefaults.standard.double(forKey: monthlyRunTimeKey)
        
        //this part is just for resetting the monthly run time to 0 at the start of a new month.
        let lastUpdated = UserDefaults.standard.object(forKey: lastUpdatedKey) as? Date ?? Date()
        let calendar = Calendar.current
        if calendar.component(.month, from: Date()) != calendar.component(.month, from: lastUpdated) {
            monthlyRunTime = 0.0
            UserDefaults.standard.set(monthlyRunTime, forKey: monthlyRunTimeKey)
        }

        return UserRunTime(totalRunTime: totalRunTime, monthlyRunTime: monthlyRunTime)
    }
}
