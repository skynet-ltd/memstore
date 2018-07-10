import XCTest
@testable import memstore

var ms = Memstore();

final class memstoreTests: XCTestCase {
    override func setUp() {
        ms.upsert(id: "1",value: "Hello")
        ms.upsert(id: "2",value:"World")
    }

    func testKeys() {
        XCTAssertEqual(ms.keys().count,2)
    }

    func testValues() {
        XCTAssertEqual(ms.values().count,2)
    }
    
    func testGet() {
        XCTAssertEqual(ms.get(id:"2") as! String,"World")
    }
    
    
    func testDelete() {

        let expectation = self.expectation(description:"Scaling")

        ms.delete(id:"2"){ val in
            XCTAssertEqual(val as! String,"World")
            expectation.fulfill()        
        }
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(ms.keys().count,1)
        XCTAssertEqual(ms.values().count,1)
    }

    
    func testInsert() {

        ms.insert(id:"1",value:"Hahaha"){ val in
            XCTAssertEqual(val,false)
            
            ms.insert(id:"3",value:"World 2"){ val in 
                XCTAssertEqual(val,true)                
            }
        }
    }
    
    func testUpsert(){
        let expectation = self.expectation(description:"Scaling")

        ms.upsert(id:"1",value:"Hello 1"){
            expectation.fulfill()
        }

        waitForExpectations(timeout: 30, handler: nil)
        XCTAssertEqual(ms.get(id:"1") as! String,"Hello 1")
    }

    static var allTests = [
        ("keys", testKeys),
        ("values", testValues),
        ("get",testGet),
        ("delete",testDelete),
        ("insert",testInsert),
        ("upsert",testUpsert),
    ]
}
