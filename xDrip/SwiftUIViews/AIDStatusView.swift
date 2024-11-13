//
//  AIDStatusView.swift
//  xdrip
//
//  Created by Paul Plant on 3/11/24.
//  Copyright © 2024 Johan Degraeve. All rights reserved.
//

import SwiftUI

struct AIDStatusView: View {
    // MARK: - environment objects
    
    /// reference to nightscoutSyncManager
    @EnvironmentObject var nightscoutSyncManager: NightscoutSyncManager
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // MARK: - private properties
    
    @State private var showingAlert = false
    
    // save typing
    /// is true if the user is using mg/dL units (pulled from UserDefaults)
    private let isMgDl: Bool = UserDefaults.standard.bloodGlucoseUnitIsMgDl
    
    /// a common string to show in case a property/value is nil
    private let nilString = "-"
    
    // MARK: - SwiftUI views
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if 1 == 2 {
                        Section(header: Text("Debug")) {
                            row(title: "Last Nightscout check", data: nightscoutSyncManager.deviceStatus.lastCheckedDate.formatted(date: .omitted, time: .standard))
                            row(title: "Last Updated", data: nightscoutSyncManager.deviceStatus.updatedDate.formatted(date: .omitted, time: .standard))
                            row(title: "Created At", data: nightscoutSyncManager.deviceStatus.createdAt.formatted(date: .omitted, time: .standard))
                        }
                    }
                    
                    Section(header: Text("System Status")) {
                        //                        let didLoop = (nightscoutSyncManager.deviceStatus.didLoop ?? false) ? Texts_Common.yes : Texts_Common.no
                        let lastLoop = nightscoutSyncManager.deviceStatus.lastLoopDate != .distantPast ? nightscoutSyncManager.deviceStatus.lastLoopDate.formatted(date: .omitted, time: .shortened) : nilString
                        let lastLoopAgo = nightscoutSyncManager.deviceStatus.lastLoopDate != .distantPast ? " (\(nightscoutSyncManager.deviceStatus.lastLoopDate.daysAndHoursAgo(appendAgo: true)))" : ""
                        
                        // show the app name and version number if available
                        if let appVersion = nightscoutSyncManager.deviceStatus.appVersion {
                            if appVersion.count < 10 {
                                row(title: "App name", data: "\(nightscoutSyncManager.deviceStatus.systemName() ?? nilString) (\(appVersion))")
                                
                                // if the version number string is too long, use two lines
                            } else {
                                HStack {
                                    Text("App name")
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 0) {
                                        Text(nightscoutSyncManager.deviceStatus.systemName() ?? nilString)
                                            .foregroundColor(.secondary)
                                        Text(appVersion)
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                            }
                            
                            // no version number available, so show only the app name
                        } else {
                            row(title: "AID app", data: nightscoutSyncManager.deviceStatus.systemName() ?? nilString)
                        }
                        
                        // show the active profile if available (AAPS)
                        if let activeProfile = nightscoutSyncManager.deviceStatus.activeProfile {
                            row(title: "Active profile", data: activeProfile)
                        }
                        
                        HStack {
                            Text("Uploader battery")
                            Spacer()
                            // show if the uploader is charging (AAPS)
                            if let uploaderBatteryChargingImage = nightscoutSyncManager.deviceStatus.uploaderBatteryChargingImage() {
                                uploaderBatteryChargingImage.chargingImage
                                    .foregroundStyle(uploaderBatteryChargingImage.chargingColor)
                                    .imageScale(.small)
                            }
                            
                            if let uploaderBatteryImage = nightscoutSyncManager.deviceStatus.uploaderBatteryImage() {
                                uploaderBatteryImage.batteryImage
                                    .foregroundStyle(uploaderBatteryImage.batteryColor)
                            }
                            
                            Text("\(nightscoutSyncManager.deviceStatus.uploaderBattery?.description ?? nilString) %")
                                .foregroundColor(.secondary)
                        }
                        
                        row(title: "Last loop cycle", data: "\(lastLoop)\(lastLoopAgo)")
                        
                        if UserDefaults.standard.nightscoutFollowType == .openAPS, nightscoutSyncManager.deviceStatus.device == "Trio" {
                            row(title: "Was enacted?", data: nightscoutSyncManager.deviceStatus.didLoop ? Texts_Common.yes : Texts_Common.no)
                        }
                    }
                    
                    Section(header: Text("AID Specific")) {
                        row(title: "Temp basal rate", data: (nightscoutSyncManager.deviceStatus.rate?.round(toDecimalPlaces: 1).description ?? "-") + " U/hr")
                        
                        row(title: "IOB", data: (nightscoutSyncManager.deviceStatus.iob?.round(toDecimalPlaces: 2).stringWithoutTrailingZeroes ?? nilString) + " U")
                        
                        row(title: "COB", data: (nightscoutSyncManager.deviceStatus.cob?.round(toDecimalPlaces: 0).stringWithoutTrailingZeroes ?? nilString) + " g")
                        
                        if let isf = nightscoutSyncManager.deviceStatus.isf {
                            row(title: "ISF", data: isf.round(toDecimalPlaces: 0).stringWithoutTrailingZeroes)
                        }
                        
                        if let sensitivityRatio = nightscoutSyncManager.deviceStatus.sensitivityRatio {
                            row(title: "Autosens", data: sensitivityRatio.round(toDecimalPlaces: 1).description)
                        }
                        
                        if let insulinReq = nightscoutSyncManager.deviceStatus.insulinReq {
                            row(title: "Required insulin", data: insulinReq.round(toDecimalPlaces: 2).description + " U")
                        }
                        
                        if let tdd = nightscoutSyncManager.deviceStatus.tdd {
                            row(title: "TDD", data: tdd.round(toDecimalPlaces: 1).description + " U")
                        }
                        
                        if let currentTarget = nightscoutSyncManager.deviceStatus.currentTarget {
                            row(title: "Current target", data: "\(currentTarget.description) \(UserDefaults.standard.bloodGlucoseUnitIsMgDl ? Texts_Common.mgdl : Texts_Common.mmol)")
                        }
                        
                        if let eventualBG = nightscoutSyncManager.deviceStatus.eventualBG {
                            row(title: "Eventual BG", data: "\(eventualBG.description) \(UserDefaults.standard.bloodGlucoseUnitIsMgDl ? Texts_Common.mgdl : Texts_Common.mmol)")
                        }
                    }
                    
                    Section(header: Text("Pump")) {
                        row(title: "Status", data: nightscoutSyncManager.deviceStatus.pumpStatus?.capitalized ?? nilString)
                        row(title: "Reservoir", data: (nightscoutSyncManager.deviceStatus.pumpReservoir?.round(toDecimalPlaces: 1).description ?? nilString) + " U")
                        row(title: "Battery", data: (nightscoutSyncManager.deviceStatus.pumpBatteryPercent?.description ?? nilString) + " %")
                        
                        if let baseBasalRate = nightscoutSyncManager.deviceStatus.baseBasalRate {
                            row(title: "Scheduled basal rate", data: baseBasalRate.round(toDecimalPlaces: 1).description + " U/hr")
                        }
                    }
                    
                    Section(header: Text("AID response")) {
                        if let reasonValuesArray = nightscoutSyncManager.deviceStatus.reasonValuesArray() {
                            ForEach(reasonValuesArray, id: \.self) { reasonValue in
                                Text(reasonValue.trimmingCharacters(in: .whitespaces))
                                    .foregroundStyle(Color(.colorSecondary))
                            }
                        } else {
                            Text("Nothing enacted or suggested in current Nightscout response at \(nightscoutSyncManager.deviceStatus.updatedDate.formatted(date: .omitted, time: .shortened))")
                        }
                    }
                }
            }
            .navigationTitle("AID Follow Status")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Texts_Common.Cancel, action: {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                }
            }
        }
        .colorScheme(.dark)
    }
    
    // MARK: - private functions
    
    /// returns a row view so that all rows are the same
    /// - parameters:
    ///   - title: the title text
    ///   - data: the value text
    /// - returns:
    ///   - a view with the formatted row inside it
    private func row(title: String, data: String) -> AnyView {
        // wrap the HStack in an AnyView so that it can be returned back to the caller
        let rowView = AnyView(HStack {
            Text(title)
            Spacer()
            Text(data)
                .foregroundColor(.secondary)
        })
        
        return rowView
    }
}

struct AIDStatusView_Previews: PreviewProvider {
    static var previews: some View {
        AIDStatusView()
    }
}
