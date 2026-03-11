import Addons
import Foundation
//
//  TravelInsuranceService.swift
//  TravelCertificate
//
//  Created by Sladan Nimcevic on 2025-03-11.
//  Copyright © 2025 Hedvig. All rights reserved.
//
import hCore

@MainActor
public class TravelInsuranceService {
    @Inject var service: TravelInsuranceClient

    public func getSpecifications() async throws -> [TravelInsuranceContractSpecification] {
        log.info("TravelInsuranceService: getSpecifications", error: nil, attributes: nil)
        return try await service.getSpecifications()
    }

    public func submitForm(dto: TravelInsuranceFormDTO) async throws -> URL {
        log.info("TravelInsuranceClient: submitForm", error: nil, attributes: ["data": dto])
        return try await service.submitForm(dto: dto)
    }

    public func getList(
        source: AddonSource
    ) async throws -> (
        list: [TravelCertificateModel], canAddTravelInsurance: Bool, banner: AddonBanner?
    ) {
        log.info("TravelInsuranceService: getList", error: nil, attributes: nil)
        return try await service.getList(source: source)
    }
}
