//
//  OSLog+Ext.swift
//  
//
//  Created by Alexander van der Werff on 04/12/2021.
//

import Foundation
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let dataFlow = OSLog(subsystem: subsystem, category: "dataFlow")
}

func dataInfo(_ msg: String...) {
#if DEBUG
    os_log("Data %{public}@ logged in", log: OSLog.dataFlow, type: .info, msg)
#endif
}
