//
//  EntrypointSettingsResponseData.swift
//
//
//  Created on 20/1/23.
//

import Foundation

struct EntrypointSettingsResponseData: Codable {
    let content: ContentData
    let result: ResultData
}

extension EntrypointSettingsResponseData {
    struct ContentData: Codable {
        let objectType: String
        let displayName: String
        let application: ApplicationData
        let image: ImageData?
        let fields: FieldsData
        let assertions: AssertionsData
        let social: SocialData
        let id: String
    }
    
    struct ApplicationData: Codable {
        let objectType: String
        let id: String
    }
    
    struct ImageData: Codable {
        let mediaType: String
        let data: String
    }
    
    struct FieldsData: Codable {
        let objectType: String
        let items: [FieldItemData]
        let totalItems: Int
        let id: String
    }
    
    struct FieldItemData: Codable {
        let objectType: String
        let displayName: String
        let field: FieldData
        let tooltip: String
        let required: Bool
        let id: String
        let format: String?
        let placeholder: String?
        let order: Int
        let validations: ValidationsData?
    }
    
    struct ValidationsData: Codable {
        let regex: RegexData?
        let empty: EmptyData?
    }
    
    struct RegexData: Codable {
        let message: String
        let pattern: String
    }
    
    struct EmptyData: Codable {
        let message: String
    }
    
    struct FieldData: Codable {
        let objectType: String
        let type: FieldType
        let values: [FieldValueData]?
    }
    
    struct FieldValueData: Codable {
        let id: String
        let field: Int
        let type: String
        let value: String
    }
    
    enum FieldType: String, Codable {
        case string
        case area
        case choice
        case dropdown
        case localDate = "local_date"
        case multipleList = "multiple_list"
        case number
        case phone // any phone (it can be landline or mobile, if it is a mobile it is not necessary to include the country code)
        case email
        case nationalId = "national_id" // DNI or identifier of the country in question, can be painted as a string
        case phoneNumber = "phone_number" // mobile must be sent with the country code +<code><number>
        case password
        
        // some types are not supported yet
        case unknown // Any type not expected will be set as 'unknown'
    }
    
    struct AssertionsData: Codable {
        let objectType: String
        let items: [AssertionItemData]?
        let totalItems: Int
    }
    
    struct AssertionItemData: Codable {
        let objectType: String
        let displayName: String
        let extended: String?
        let type: String
        let typology: String
        let mandatory: Bool
        let links: [LinkData]?
    }
    
    struct LinkData: Codable {
        let objectType: String
        let displayName: String
        let url: String
        let id: String
    }
    
    struct SocialData: Codable {
        let objectType: String
        let items: [SocialItemData]
        let totalItems: Int
        let id: String
    }
    
    enum SocialProvider: String, Codable {
        case facebook = "facebook"
        case google = "google"
        case apple = "apple"
    }
    
    struct SocialItemData: Codable {
        let objectType: String
        let provider: SocialProvider
        let secret: String
        let scope: String?
        let id: String
    }
}

extension EntrypointSettingsResponseData.FieldType {
    public init(from decoder: Decoder) throws {
        self = try EntrypointSettingsResponseData.FieldType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

extension EntrypointSettingsResponseData {
    var canLoginWithFacebook: Bool {
        return content.social.items.contains { $0.provider == .facebook }
    }
    
    var canLoginWithApple: Bool {
        return content.social.items.contains { $0.provider == .apple }
    }
    
    var canLoginWithGoogle: Bool {
        return content.social.items.contains { $0.provider == .google }
    }
    
    static func mock() -> EntrypointSettingsResponseData {
        return .init(
            content: .init(
                objectType: "",
                displayName: "",
                application: .init(objectType: "", id: ""),
                image: .init(mediaType: "image/png", data: "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII"),
                fields: .init(
                    objectType: "",
                    items: [
                        .init(objectType: "field_config", displayName: "Correo electrónico", field: .init(objectType: "user_id", type: .email, values: nil), tooltip: "Introduce una dirección de email", required: true, id: "email", format: nil, placeholder: "Escribe tu email", order: 0, validations: .init(regex: .init(message: "El valor no cumple el patrón válido", pattern: "[_A-Za-z0-9-+]+(?:\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(?:\\.[A-Za-z0-9]+)*(?:\\.[A-Za-z]{2,})"), empty: .init(message:  "Este campo es obligatorio"))),
                        .init(objectType: "field_config", displayName: "Contraseña", field: .init(objectType: "password", type: .password, values: nil), tooltip: "De 6 a 20 caracteres, se permiten mayúsculas, minúsculas, números y caracteres especiales -_.:!@#$%&", required: true, id: "", format: nil, placeholder: "Escribe tu password", order: 0, validations: .init(regex: .init(message: "El valor no cumple el patrón válido", pattern: "\\+[1-9]\\d{1,14}"), empty: .init(message: "Este campo es obligatorio"))),
                        .init(objectType: "field_config", displayName: "Fecha de nacimiento", field: .init(objectType: "user_data", type: .localDate, values: nil), tooltip: "Escribe tu fecha de nacimiento en formato dd/mm/aaaa", required: true, id: "birthday", format: "dd/MM/yyyy", placeholder: nil, order: 0, validations: .init(regex: .init(message: "El valor no cumple el patrón válido", pattern: "[0-9]{2}/[0-9]{2}/[0-9]{4}"), empty: .init(message: "Este campo es obligatorio"))),
                        .init(objectType: "field_config", displayName: "País", field: .init(objectType: "user_data", type: .dropdown, values: [.init(id: "AD", field: 26, type: "country", value: "Andorra"), .init(id: "AE", field: 26, type: "country", value: "Emiratos Árabes Unidos")]), tooltip: "Indícanos tu país", required: false, id: "country", format: nil, placeholder: nil, order: 0, validations: .init(regex: nil, empty: .init(message: "Este campo es obligatorio")))
                    ],
                    totalItems: 4,
                    id: ""
                ),
                assertions: .init(
                    objectType: "assertions",
                    items: [
                        .init(objectType: "assertion", displayName: "He leído y acepto los %1$s y la %2$s", extended: nil, type: "terms", typology: "user", mandatory: true, links: [.init(objectType: "webpage", displayName: "términos y condiciones", url: "https://statics.ciam.demo.dru-id.com/viewer/legalterms/general_conditions/terms/es", id: "1"), .init(objectType: "webpage", displayName: "política de privacidad", url: "https://statics.ciam.demo.dru-id.com/viewer/legalterms/privacy_policy/privacidad/es", id: "2")]),
                        .init(objectType: "assertion", displayName: "Suscríbete a nuestra newsletter", extended: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Suspendisse ultrices gravida dictum fusce ut placerat orci. Rhoncus aenean vel elit scelerisque mauris pellentesque. Eros in cursus turpis massa.", type: "optin", typology: "user", mandatory: false, links: nil)
                    ],
                    totalItems: 2
                ),
                social: .init(objectType: "", items: [.init(objectType: "social_config", provider: .facebook, secret: "", scope: "email,public_profile,user_birthday,user_gender,user_likes,user_location,user_posts", id: ""), .init(objectType: "social_config", provider: .apple, secret: "", scope: "", id: "")], totalItems: 1, id: ""),
                id: ""
            ),
            result: .init(status: 200, elapsed: nil, node: nil, errors: nil)
        )
    }
}

