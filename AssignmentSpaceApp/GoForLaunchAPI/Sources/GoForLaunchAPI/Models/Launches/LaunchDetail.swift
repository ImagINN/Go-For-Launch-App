//
//  LaunchDetail.swift
//  GoForLaunchAPI
//
//  Created by Gokhan on 9.10.2025.
//

import Foundation

public struct LaunchDetail: Decodable {
    // Root
    public let id: String?
    public let name: String
    public let net: Date
    public let statusName: String?
    public let statusDescription: String?
    public let imageURL: String?

    // LSP (Launch Service Provider)
    public let lspName: String?
    public let lspTypeName: String?
    public let lspCountries: [String]?
    public let lspDescription: String?

    // Rocket (configuration)
    public let rocketFullName: String?
    public let rocketImageURL: String?
    public let rocketDescription: String?

    // Mission
    public let missionName: String?
    public let missionType: String?
    public let missionDescription: String?
    public let orbitName: String?

    // Program(s)
    public struct ProgramLite: Decodable {
        public let name: String?
        public let imageURL: String?
        public let description: String?

        private enum CodingKeys: String, CodingKey { case name, image, description }
        private struct Image: Decodable { let image_url: String? }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try? container.decodeIfPresent(String.self, forKey: .name)
            description = try? container.decodeIfPresent(String.self, forKey: .description)
            imageURL = try? container.decodeIfPresent(Image.self, forKey: .image)?.image_url
        }
    }
    public let programs: [ProgramLite]

    // MARK: - Decode
    private enum CodingKeys: String, CodingKey {
        case id, name, net, status, image
        case launch_service_provider, rocket, mission, program
    }

    private struct Status: Decodable {
        let name: String?
        let description: String?
    }

    private struct Image: Decodable {
        let image_url: String?
    }

    private struct LSP: Decodable {
        let name: String?
        let type: TypeName?
        let country: [Country]?
        let description: String?

        struct TypeName: Decodable { let name: String? }
        struct Country: Decodable { let name: String? }
    }

    private struct Rocket: Decodable {
        let configuration: Config?
        struct Config: Decodable {
            let full_name: String?
            let image: RImage?
            let description: String?
            struct RImage: Decodable { let image_url: String? }
        }
    }

    private struct Mission: Decodable {
        let name: String?
        let type: String?
        let description: String?
        let orbit: Orbit?
        struct Orbit: Decodable { let name: String? }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Root
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        net = try container.decode(Date.self, forKey: .net)

        if let status = try? container.decode(Status.self, forKey: .status) {
            statusName = status.name
            statusDescription = status.description
        } else {
            statusName = nil
            statusDescription = nil
        }

        imageURL = try? container.decodeIfPresent(Image.self, forKey: .image)?.image_url

        // LSP (Launch Service Provider)
        if let lsp = try? container.decode(LSP.self, forKey: .launch_service_provider) {
            lspName = lsp.name
            lspTypeName = lsp.type?.name
            lspCountries = lsp.country?.compactMap { $0.name }
            lspDescription = lsp.description
        } else {
            lspName = nil; lspTypeName = nil; lspCountries = nil; lspDescription = nil
        }

        // Rocket
        if let rocket = try? container.decode(Rocket.self, forKey: .rocket) {
            rocketFullName = rocket.configuration?.full_name
            rocketImageURL = rocket.configuration?.image?.image_url
            rocketDescription = rocket.configuration?.description
        } else {
            rocketFullName = nil; rocketImageURL = nil; rocketDescription = nil
        }

        // Mission
        if let mission = try? container.decode(Mission.self, forKey: .mission) {
            missionName = mission.name
            missionType = mission.type
            missionDescription = mission.description
            orbitName = mission.orbit?.name
        } else {
            missionName = nil; missionType = nil; missionDescription = nil; orbitName = nil
        }

        // Programs
        programs = (try? container.decodeIfPresent([ProgramLite].self, forKey: .program)) ?? []
    }
}
