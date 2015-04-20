//
//  BonjourTests.swift
//  CoPilotPlugin
//
//  Created by Sven Schmidt on 20/04/2015.
//  Copyright (c) 2015 feinstruktur. All rights reserved.
//

import Cocoa
import XCTest
import Nimble




class BonjourTests: XCTestCase {

    var resolved = false
    
    func test_publish() {
        let service = publish(service: CoPilotService, name: "Test")
        expect(service).toNot(beNil())
        
        var found: NSNetService!
        let b = Browser(service: CoPilotService) { service in
            found = service
        }

        expect(found).toEventuallyNot(beNil(), timeout: 5)
        expect(found.type) == "_copilot._tcp."
    }

    
    func test_resolve() {
        let publishedService = publish(service: CoPilotService, name: "Test")
        
        var resolvedService: NSNetService!
        self.resolved = false
        let b = Browser(service: CoPilotService) { service in
            resolvedService = service
            service.delegate = self
            service.resolveWithTimeout(1)
        }
        expect(self.resolved).toEventually(beTrue(), timeout: 2)
    }

}


class BrowserDelegate: NSObject, NSNetServiceBrowserDelegate {
    
    var serviceFound: (NSNetService -> Void)?
    
    init(serviceFound: (NSNetService -> Void)) {
        self.serviceFound = serviceFound
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        self.serviceFound?(aNetService)
    }
    
}


extension BonjourTests: NSNetServiceDelegate {
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        NSLog("### netServiceDidResolveAddress \(sender)")
        self.resolved = true
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        NSLog("### netService:didNotResolve \(errorDict)")
    }
    
    func netServiceDidStop(sender: NSNetService) {
        NSLog("### netServiceDidStop")
    }

}
