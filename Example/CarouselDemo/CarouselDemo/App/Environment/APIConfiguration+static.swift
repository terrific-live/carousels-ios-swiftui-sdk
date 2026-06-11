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

//extension APIConfiguration {
//    nonisolated(unsafe) static let testStoreConfiguration = APIConfiguration(
//        storeId: "uO5g9yzOTkR39JFG3ORP",
//        carouselId: "doS2DpZV4YIoYjR2YYQc",
//        baseURL: "https://terrific-staging-polls.web.app",
//    )
//
//    nonisolated(unsafe) static let testProductionConfiguration = APIConfiguration(
//        storeId: "hXMo5lp0IIMt73fguA66",
//        carouselId: "w6l3xMCBYjdYDaVgcUML",
//        baseURL: "https://terrific-live-polls.web.app",
//    )
//
//    nonisolated(unsafe) static let testVolodimirCarouselProductionConfiguration = APIConfiguration(
//        storeId: "1FEyyLAlBJY8000v5nfL",
//        carouselId: "sQsA6UF3MwDfIz4TZXM7",
//        baseURL: "https://terrific-live-polls.web.app",
//    )
//
//    nonisolated(unsafe) static let francTVConfiguration = APIConfiguration(
//        storeId: "nzRdWaBc1JPk2XN3B9bp",
//        carouselId: "X9HIgIk6D3xXDLehqh7U",
//        baseURL: "https://terrific-live-polls.web.app",
//        shopPageUrl: "https://www.france.tv/jeux-et-divertissements/"
//    )
//
//    nonisolated(unsafe) static let testStagingConfiguration = APIConfiguration(
//        storeId: "1ihKYs7lmGp0J2cj6Tom",
//        carouselId: "bcl1sZJUxVXzWa64hXLt",
//        baseURL: "https://terrific-staging-polls.web.app",
//        shopPageUrl: nil
//    )
//}
