//
//  Constants.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 20/04/2024.
//

import Foundation

enum Constants {
    enum AnnotationManager {
        static var pointIdentifer: String {
            "point_annotation_manager"
        }
        static var polylineIdentifier: String {
            "polyline_annotation_manager"
        }
    }
    
    enum PointAnnotation {
        static var start: String {
            "start-pin"
        }
        static var arrival: String {
            "arrival-pin"
        }
    }
}
