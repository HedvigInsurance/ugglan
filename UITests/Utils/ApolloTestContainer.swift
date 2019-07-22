//
//  ApolloContainer.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Apollo
#if canImport(ApolloWebSocket)
import ApolloWebSocket
#endif
import Disk
import FirebaseRemoteConfig
import Flow
import Foundation

struct ApolloEnvironmentConfig {
    let endpointURL: URL
    let wsEndpointURL: URL
    let assetsEndpointURL: URL
}

class ApolloContainer {
    static let shared = ApolloContainer()
    
    private var _client: ApolloClient?
    private var _store: ApolloStore?
    
    let initialRecords: RecordSet = [:]
    
    let networkTransport = MockNetworkTransport(body: [
        "data": [
            "messages": [],
            "nextChargeDate": Date(timeIntervalSinceNow: 0).description,
            "directDebitStatus": "ACTIVE",
            "bankAccount": [
                "__typename": "BankAccount",
                "bankName": "SEB",
                "descriptor": "8333"
            ],
            "insurance": [
                "__typename": "Insurance",
                "status": "ACTIVE",
                "type": "BRF",
                "activeFrom": Date(timeIntervalSinceNow: 0).description,
                "cost": [
                    "__typename": "InsuranceCost",
                    "monthlyNet": [
                        "__typename": "MonetaryAmountV2",
                        "amount": "169.00"
                    ],
                    "monthlyGross": [
                        "__typename": "MonetaryAmountV2",
                        "amount": "169.00"
                    ],
                    "monthlyDiscount": [
                        "__typename": "MonetaryAmountV2",
                        "amount": "0.00"
                    ]
                ],
                "perilCategories": [
                    [
                        "__typename": "PerilCategory",
                        "title": "Jag och min familj",
                        "description": "försäkras för",
                        "perils": [
                            [
                                "__typename": "Peril",
                                "id": "ME.LEGAL",
                                "title": "Juridisk tvist",
                                "description": "Om du hamnar i domstol så täcker Hedvig kostnaden för ditt ombud, och andra rättegångskostnader. Hedvig täcker också om någon skulle kräva dig på skadestånd för att du har skadat någon, eller någons saker."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "ME.TRAVEL.LUGGAGE.DELAY",
                                "title": "Rese-\ntrubbel",
                                "description": "Ibland klaffar inte allt som det ska när du ska ut i världen. Till exempel, om ditt bagage blir försenat ersätter Hedvig dig för att köpa saker du behöver. Och om det skulle bli oroligheter i landet du är i, som vid en naturkatastrof, så evakuerar Hedvig dig hem till Sverige."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "ME.ASSAULT",
                                "title": "Överfall",
                                "description": "En hemförsäkring skyddar även dig personligen. Om någon skulle utsätta dig för ett våldsbrott, till exempel misshandel eller rån ersätts du med ett fast belopp."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "ME.TRAVEL.SICK",
                                "title": "Sjuk på resa",
                                "description": "Få saker är roligare än att utforska världen, men det är mindre kul om man blir sjuk. Eller ännu värre, råkar ut för en olycka. Därför ersätts du både för missade resdagar och sjukhuskostnader. Är det riktigt illa står Hedvig för transporten hem till Sverige. Om du har skadats eller blivit sjuk utomlands och behöver akut vård, ring Hedvig Global Assistance dygnet runt på +45 38 48 94 61."
                            ]
                        ]
                    ],
                    [
                        "__typename": "PerilCategory",
                        "title": "Lm Ericssons väg 10",
                        "description": "försäkras för",
                        "perils": [
                            [
                                "__typename": "Peril",
                                "id": "HOUSE.RENT.FIRE",
                                "title": "Eldsvåda",
                                "description": "Du bor i en hyresrätt, det betyder att det är din hyresvärds försäkring som täcker skador på lägenheten som orsakas av en eldsvåda. Men oroa dig inte, om dina prylar skadas av elden ersätter Hedvig så klart det."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "HOUSE.RENT.WATER",
                                "title": "Vatten-\nläcka",
                                "description": "Du bor i en hyresrätt, det betyder att det är din hyresvärds försäkring som täcker skador på lägenheten som orsakas av en vattenläcka. Men oroa dig inte, om dina prylar skadas av vattnet ersätter Hedvig så klart det."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "HOUSE.RENT.WEATHER",
                                "title": "Oväder",
                                "description": "Du bor i en hyresrätt, det betyder att det är din hyresvärds försäkring som täcker skador på lägenheten som orsakas av ett oväder. Men oroa dig inte, om dina prylar skadas av ovädret ersätter Hedvig så klart det."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "HOUSE.BREAK-IN",
                                "title": "Inbrott",
                                "description": "Ditt hem är din borg. Skulle inkräktare bryta sig in för att stjäla dina saker så ersätter Hedvig dig för det."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "HOUSE.DAMAGE",
                                "title": "Skade-\ngörelse",
                                "description": "Om någon bryter sig in i din lägenhet för att vandalisera och förstöra så ersätter Hedvig dig för skadorna."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "HOUSE.RENT.APPLIANCES",
                                "title": "Vitvaror",
                                "description": "Plötsligt tackar din spis för sig eller så blir det kortslutning i din prisbelönta kaffemaskin. Hedvig ersätter skador på dina vitvaror, så länge det inte rör sig om skador som din hyresvärd är skyldig att ersätta."
                            ]
                        ]
                    ],
                    [
                        "__typename": "PerilCategory",
                        "title": "Våra prylar",
                        "description": "försäkras för",
                        "perils": [
                            [
                                "__typename": "Peril",
                                "id": "STUFF.CARELESS",
                                "title": "Drulle",
                                "description": "De flesta känner igen känslan av slow-motion när mobilen glider ur handen och voltar ner mot kall asfalt. 'Drulle' kallas ibland för otursförsäkring, och det är just vad det är. Om du har otur och dina prylar går sönder, så ersätts du för dem."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "STUFF.THEFT",
                                "title": "Stöld",
                                "description": "Prylar är till för att användas, i synnerhet favoriterna. Älskade väskor och jackor följer med på restaurang, datorn får komma med på kafé, plånboken och cykeln är med överallt. Om något stjäls av dig så ersätts du för det."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "STUFF.DAMAGE",
                                "title": "Skade-\ngörelse",
                                "description": "Varför vissa väljer att förstöra andras saker är en gåta. Hursomhelst så ersätts du när dina prylar förstörs av skadegörelse, eller i samband med att du blir överfallen."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "STUFF.RENT.FIRE",
                                "title": "Eldsvåda",
                                "description": "Om det skulle brinna i din lägenhet så ersätter Hedvig dina prylar som blir förstörda."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "STUFF.RENT.WATER",
                                "title": "Vatten-\nläcka",
                                "description": "Om du har en vattenläcka hemma så ersätter Hedvig dina prylar som blir förstörda."
                            ],
                            [
                                "__typename": "Peril",
                                "id": "STUFF.RENT.WEATHER",
                                "title": "Oväder",
                                "description": "Hedvig ersätter dig om ett oväder på något sätt skulle orsaka skador på dina prylar."
                            ]
                        ]
                    ]
                ]
            ],
            "member": [
                "__typename": "Member",
                "firstName": "Clara"
            ]
        ]
    ])
    
    let cache: InMemoryNormalizedCache
    let store: ApolloStore
    let client: ApolloClient
    var environment = ApolloEnvironmentConfig(
        endpointURL: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
        wsEndpointURL: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!,
        assetsEndpointURL: URL(string: "https://graphql.dev.hedvigit.com")!
    )
    
    init() {
        cache = InMemoryNormalizedCache(records: initialRecords)
        store = ApolloStore(cache: cache)
        
        WebSocketTransport.provider = MockWebSocket.self
        let websocketTransport = WebSocketTransport(request: URLRequest(url: URL(string: "http://localhost/dummy_url")!))
        
        let splitNetworkTransport = SplitNetworkTransport(
            httpNetworkTransport: networkTransport,
            webSocketNetworkTransport: websocketTransport
        )
        
        client = ApolloClient(networkTransport: splitNetworkTransport, store: store)
    }
    
    func initClient() -> Future<ApolloClient> {
        return Future(client)
    }
}
