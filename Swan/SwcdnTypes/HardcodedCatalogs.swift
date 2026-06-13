// 
//  HardcodedCatalogs.swift - Swan
//
//  Created by Ben216k on 7/31/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation

// MARK: - SUCatalogSource

extension SUCatalogSource {

    static let goldenGateSeed = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-27seed-27-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 27 Golden Gate Developer Beta", type: .seed, id: "27seed"
    )
    
    /// unused until macOS Golden Gate Public Beta is released
    static let goldenGateBeta = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-27beta-27-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 27 Golden Gate Public Beta", type: .beta, id: "27beta"
    )
    
    /// unused until macOS Golden Gate is fully released
    static let goldenGateRelease = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-27-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 27 Golden Gate", type: .release, id: "27"
    )
    
    static let tahoeSeed = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-26seed-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 26 Tahoe Developer Beta", type: .seed, id: "26seed"
    )
    
    static let tahoeBeta = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-26beta-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 26 Tahoe Public Beta", type: .beta, id: "26beta"
    )
    
    static let tahoeRelease = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-26-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 26 Tahoe", type: .release, id: "26"
    )
    
    static let sequoiaSeed = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-15seed-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 15 Sequoia Developer Beta", type: .seed, id: "15seed"
    ) 

    static let sequoiaBeta = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-15beta-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 15 Sequoia Public Beta", type: .beta, id: "15beta"
    )

    static let sequoiaRelease = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-15-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 15 Sequoia", type: .release, id: "15"
    )

    static let sonomaSeed = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-14seed-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 14 Sonoma Developer Beta", type: .seed, id: "14seed"
    )

    static let sonomaBeta = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-14beta-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 14 Sonoma Public Beta", type: .beta, id: "14beta"
    )

    static let sonomaRelease = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 14 Sonoma", type: .release, id: "14"
    )

    static let bigSurSeed = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-10.16seed-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 11 Big Sur Developer Beta", type: .seed, id: "11seed"
    )

    static let bigSurBeta = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-10.16beta-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 11 Big Sur Public Beta", type: .beta, id: "11beta"
    )

    static let bigSurRelease = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 11 Big Sur", type: .release, id: "11"
    )

    static let montereySeed = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-12seed-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 12 Monterey Developer Beta", type: .seed, id: "12seed"
    )

    static let montereyBeta = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-12beta-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 12 Monterey Public Beta", type: .beta, id: "12beta"
    )

    static let montereyRelease = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 12 Monterey", type: .release, id: "12"
    )

    static let venturaSeed = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-13seed-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 13 Ventura Developer Beta", type: .seed, id: "13seed"
    )

    static let venturaBeta = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-13beta-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 13 Ventura Public Beta", type: .beta, id: "13beta"
    )

    static let venturaRelease = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 13 Ventura", type: .release, id: "13"
    )

    static let catalinaRelease = SUCatalogSource(
        url: URL(string: "https://swscan.apple.com/content/catalogs/others/index-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz")!,
        name: "macOS 10.15 Catalina", type: .release, id: "10.15"
    )

    /// All stored default catalogs
    static let allKnownCatalogs = [goldenGateSeed, tahoeSeed, tahoeBeta, tahoeRelease, sequoiaSeed, sequoiaBeta, sequoiaRelease, sonomaRelease, bigSurSeed, bigSurBeta, bigSurRelease, montereySeed, montereyBeta, montereyRelease, venturaSeed, venturaBeta, venturaRelease, catalinaRelease]

    /// Best to use in current day (currently macOS 15 Sequoia is in both betas, but has not been released)
    static let bestKnownCatalogs = [goldenGateSeed, tahoeSeed, tahoeBeta, tahoeRelease, sequoiaSeed, sequoiaBeta, sonomaRelease, bigSurBeta, montereySeed, montereyBeta, venturaSeed, venturaBeta]
}
