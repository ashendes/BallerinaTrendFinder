import ballerina/test;
import ballerina/io;

documentation {
   Before Suite Function can be used to start the service
}
@test:BeforeSuite
function beforeSuiteFunc () {
    io:println("Start the Service!");
    boolean status = test:startServices(".");
}

documentation {
   Test function
}
@test:Config
function testFunction () {
    io:println("Do your service Tests!");
    test:assertTrue(true , msg = "Failed!");
}

documentation {
   After Suite Function is used to stop the service
}
@test:AfterSuite
function afterSuiteFunc () {
    io:println("Stop the service!");
    test:stopServices(".");
}