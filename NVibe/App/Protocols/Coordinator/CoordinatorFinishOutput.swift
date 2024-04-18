//
//  CoordinatorFinishOutput.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation

protocol CoordinatorFinishOutput {
    var finishFlow: (() -> Void)? { get set }
}
