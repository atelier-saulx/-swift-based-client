//
//  BasedConfiguration.swift
//  
//
//  Created by Alexander van der Werff on 26/11/2021.
//

import Foundation

public struct BasedConfiguration {
    let cluster: String = "https://d15p61sp2f2oaj.cloudfront.net/"
    let org: String
    let project: String
    let env: String
    let name: String = "@based/edge"
    let key: String = ""
    let optionalKey: Bool = false
}
