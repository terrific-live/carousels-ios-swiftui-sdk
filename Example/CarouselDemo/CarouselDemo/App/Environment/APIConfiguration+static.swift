//
//  APIConfiguration.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 26.02.2026.
//

import Foundation
import TerrificCarouselSDK

extension APIConfiguration {
    nonisolated(unsafe) static let testStoreConfiguration = APIConfiguration(
        storeId: "uO5g9yzOTkR39JFG3ORP",
        carouselId: "doS2DpZV4YIoYjR2YYQc",
        baseURL: "https://terrific-staging-polls.web.app",
    )

    nonisolated(unsafe) static let francTVConfiguration = APIConfiguration(
        storeId: "nzRdWaBc1JPk2XN3B9bp",
        carouselId: "X9HIgIk6D3xXDLehqh7U",
        shopPageUrl: "https://www.france.tv/jeux-et-divertissements/"
    )

    nonisolated(unsafe) static let francTVConfiguration2 = APIConfiguration(
        storeId: "nzRdWaBc1JPk2XN3B9bp",
        carouselId: "VtfTyGo3DT8xcDZML2H9",
        shopPageUrl: "https://www.france.tv/jeux-et-divertissements/"
    )
}
