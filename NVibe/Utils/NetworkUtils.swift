//
//  InternetConnection.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 21/04/2024.
//

import SystemConfiguration

final class NetworkUtils {
    static func isConnectedToInternet() -> Bool {
        /// Use of sockaddr-in to represent the default route.
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        /// Create the default route reachability.
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        /// Using default route reachability flags property to obtain current status of network reachability object.
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
