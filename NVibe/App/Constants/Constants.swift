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
    
    enum MessageError {
        static var noInternetConnection: String {
            "Pas de connection internet."
        }
        static var cannotRecoverData: String {
            "Impossible de recouvrir les données."
        }
        static var cannotStartItinerary: String {
            "Impossible de démarrer l'itinéraire."
        }
        static var defaultMessageError: String {
            "Une erreur s'est produite."
        }
        static var warning: String {
            "Attention!"
        }
        static var error: String {
            "Erreur"
        }
        static var locationDisabled: String {
            "Localisation désactivée, veuillez vous rendre dans les réglages pour modifier cela."
        }
        static var cannotRecoverLocation: String {
            "Impossible de récupérer votre position, veuillez essayer ultérieurement."
        }
        static var cannotDisplayAddresses: String {
            "Impossible d'afficher les adresses aux alentours, réessayer plus tard."
        }
    }
}
