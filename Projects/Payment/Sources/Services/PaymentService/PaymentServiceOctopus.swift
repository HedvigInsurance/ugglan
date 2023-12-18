import Apollo
import Foundation
import hCore
import hGraphQL

public class hPaymentServiceOctopus: hPaymentService {
    @Inject private var octopus: hOctopus

    public init() {}

    public func getPaymentData() async throws -> PaymentData? {
        let query = OctopusGraphQL.PaymentDataQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentData(with: data)
    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        let query = OctopusGraphQL.PaymentInformationQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentStatusData(data: data)
    }

    public func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        let query = OctopusGraphQL.DiscountsQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentDiscountsData.init(with: data)
    }

    public func getPaymentHistoryData() async throws -> [PaymentHistoryListData] {
        let query = OctopusGraphQL.PaymentHistoryDataQuery()
        //        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        let data = json.data(using: .utf8)!
        do {
            let object = try JSONSerialization.jsonObject(with: data) as! JSONObject
            let newData = object["data"] as! JSONObject
            let dataObject = try OctopusGraphQL.PaymentHistoryDataQuery.Data(jsonObject: newData)
            return PaymentHistoryListData.getHistory(with: dataObject.currentMember)

        } catch let ex {
            let ss = ""
        }
        return []
        //        return PaymentHistoryListData.getHistory(with: data.currentMember)
    }

    private let json = """
        {
          "data": {
            "currentMember": {
              "__typename": "Member",
              "redeemedCampaigns": [],
              "pastCharges": [
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 729,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-11-01",
                          "toDate": "2023-11-30",
                          "amount": {
                            "__typename": "Money",
                            "amount": 729,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 219,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-11-01",
                          "toDate": "2023-11-30",
                          "amount": {
                            "__typename": "Money",
                            "amount": 219,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2023-11-28",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": 948,
                    "currencyCode": "SEK"
                  },
                  "id": "37bfe6e8-4e91-430d-94c2-da352e523590",
                  "net": {
                    "__typename": "Money",
                    "amount": 948,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  }
                },
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 216.42,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-10-01",
                          "toDate": "2023-10-08",
                          "amount": {
                            "__typename": "Money",
                            "amount": 53.94,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        },
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-10-09",
                          "toDate": "2023-10-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 162.48,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 691.9,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-10-01",
                          "toDate": "2023-10-23",
                          "amount": {
                            "__typename": "Money",
                            "amount": 503.77,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        },
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-10-24",
                          "toDate": "2023-10-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 188.13,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2023-10-27",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": 908.32,
                    "currencyCode": "SEK"
                  },
                  "id": "6df6d056-3d64-4ac0-ad09-e48c72dcba2c",
                  "net": {
                    "__typename": "Money",
                    "amount": 908.32,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  }
                },
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 209,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-09-01",
                          "toDate": "2023-09-30",
                          "amount": {
                            "__typename": "Money",
                            "amount": 209,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 679,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-09-01",
                          "toDate": "2023-09-30",
                          "amount": {
                            "__typename": "Money",
                            "amount": 679,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2023-09-27",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "id": "e92827c6-1a9a-49c2-a089-9faacba0fcb0",
                  "net": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  }
                },
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 209,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-08-01",
                          "toDate": "2023-08-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 209,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 679,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-08-01",
                          "toDate": "2023-08-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 679,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2023-08-29",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "id": "064bfae5-dcdb-438a-ada2-927612cfb6d2",
                  "net": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  }
                },
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 209,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-07-01",
                          "toDate": "2023-07-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 209,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 679,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-07-01",
                          "toDate": "2023-07-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 679,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2023-07-27",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "id": "b956be5a-712c-45b6-9655-36fd8ab25da0",
                  "net": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  }
                },
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 209,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-06-01",
                          "toDate": "2023-06-30",
                          "amount": {
                            "__typename": "Money",
                            "amount": 209,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 679,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-06-01",
                          "toDate": "2023-06-30",
                          "amount": {
                            "__typename": "Money",
                            "amount": 679,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2023-06-27",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "id": "1fd9febb-9998-4846-a928-12ff16803f70",
                  "net": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  }
                },
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 209,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-05-01",
                          "toDate": "2023-05-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 209,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 679,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-05-01",
                          "toDate": "2023-05-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 679,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2023-05-29",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "id": "c2373441-3506-4e49-ae79-7a3a097c27ea",
                  "net": {
                    "__typename": "Money",
                    "amount": 438,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 450,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  }
                },
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 209,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-04-01",
                          "toDate": "2023-04-30",
                          "amount": {
                            "__typename": "Money",
                            "amount": 209,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 679,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-04-01",
                          "toDate": "2023-04-30",
                          "amount": {
                            "__typename": "Money",
                            "amount": 679,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": -1338,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-02-01",
                          "toDate": "2023-02-28",
                          "amount": {
                            "__typename": "Money",
                            "amount": -669,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        },
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-03-01",
                          "toDate": "2023-03-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": -669,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        },
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-04-01",
                          "toDate": "2023-04-30",
                          "amount": {
                            "__typename": "Money",
                            "amount": 0,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "YUH587 • VOLKSWAGEN, VW",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Car Insurance Full Coverage"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2023-04-25",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": -450,
                    "currencyCode": "SEK"
                  },
                  "id": "af6dc482-d61b-4cd6-a2a3-3ec75ffc9242",
                  "net": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 450,
                    "currencyCode": "SEK"
                  }
                },
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 209,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-03-01",
                          "toDate": "2023-03-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 209,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 679,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-03-01",
                          "toDate": "2023-03-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 679,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 669,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-03-01",
                          "toDate": "2023-03-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 669,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "YUH587 • VOLKSWAGEN, VW",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Car Insurance Full Coverage"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2023-03-28",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": 1557,
                    "currencyCode": "SEK"
                  },
                  "id": "438b2861-c270-4d4c-8da6-3b5106e89bcc",
                  "net": {
                    "__typename": "Money",
                    "amount": 1557,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  }
                },
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 209,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-02-01",
                          "toDate": "2023-02-28",
                          "amount": {
                            "__typename": "Money",
                            "amount": 209,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 679,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-02-01",
                          "toDate": "2023-02-28",
                          "amount": {
                            "__typename": "Money",
                            "amount": 679,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 669,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-02-01",
                          "toDate": "2023-02-28",
                          "amount": {
                            "__typename": "Money",
                            "amount": 669,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "YUH587 • VOLKSWAGEN, VW",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Car Insurance Full Coverage"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2023-02-28",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": 1557,
                    "currencyCode": "SEK"
                  },
                  "id": "b670e4f6-f75e-4dc0-8ab1-933f07636fdb",
                  "net": {
                    "__typename": "Money",
                    "amount": 1557,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  }
                },
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 209,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-01-01",
                          "toDate": "2023-01-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 209,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 679,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2023-01-01",
                          "toDate": "2023-01-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 679,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2023-01-27",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "id": "7b126e56-447c-4149-9863-66f9884757f5",
                  "net": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  }
                },
                {
                  "__typename": "MemberCharge",
                  "contractsChargeBreakdown": [
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 209,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2022-12-01",
                          "toDate": "2022-12-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 209,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Accident Insurance"
                          }
                        }
                      }
                    },
                    {
                      "__typename": "MemberChargeContractBreakdownItem",
                      "gross": {
                        "__typename": "Money",
                        "amount": 679,
                        "currencyCode": "SEK"
                      },
                      "periods": [
                        {
                          "__typename": "MemberChargeContractBreakdownItemPeriod",
                          "fromDate": "2022-12-01",
                          "toDate": "2022-12-31",
                          "amount": {
                            "__typename": "Money",
                            "amount": 679,
                            "currencyCode": "SEK"
                          },
                          "isPreviouslyFailedCharge": false
                        }
                      ],
                      "contract": {
                        "__typename": "Contract",
                        "exposureDisplayName": "Blåklintsvägen 1 • You + 3",
                        "currentAgreement": {
                          "__typename": "Agreement",
                          "productVariant": {
                            "__typename": "ProductVariant",
                            "displayName": "Home Insurance House & Villa"
                          }
                        }
                      }
                    }
                  ],
                  "date": "2022-12-27",
                  "discount": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "discountBreakdown": [],
                  "gross": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "id": "a5bed86a-e91c-4be2-822d-bd113d2c7d90",
                  "net": {
                    "__typename": "Money",
                    "amount": 888,
                    "currencyCode": "SEK"
                  },
                  "status": "SUCCESS",
                  "carriedAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  },
                  "settlementAdjustment": {
                    "__typename": "Money",
                    "amount": 0,
                    "currencyCode": "SEK"
                  }
                }
              ],
              "referralInformation": {
                "__typename": "MemberReferralInformation",
                "code": "1L2O02"
              }
            }
          }
        }
        """
}
