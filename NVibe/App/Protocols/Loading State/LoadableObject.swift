//
//  LoadableObject.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 19/04/2024.
//

import Foundation

/// Protocol to adopt for every ViewModel dealing with asynchronous requests.
enum LoadingState {
    case idle
    case loading
    case failed(Error)
    case loaded
}

protocol LoadableObject: AnyObject {
    var loadingState: LoadingState { get set }
}
