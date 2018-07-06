import ballerina/io;
import ballerina/http;
import ballerina/runtime;
import ballerina/task;
import ballerina/math;

int count;
task:Timer? timer;

endpoint http:Client clientEndpoint{
    url: "http://localhost:9094"
};

function main(string... args) {
    worker w1{
        (function() returns error?) onTriggerFunction = callService;

        function(error) onErrorFunction = serviceError;

        timer = new task:Timer(onTriggerFunction, onErrorFunction,
            3600000, delay = 500);

        timer.start();

        runtime:sleep(86400000);
    }



}

function callService() returns error?{
    http:Request req= new;
    io:println("Calling service");
    //json jsonMsg = {lat: 6.904626, lng: 79.864101};
    //req.setJsonPayload(jsonMsg);
    //req.setTextPayload("Colombo");

    var response = clientEndpoint->post("/",req);
    match response{
        http:Response resp => {
            io:println(resp.getTextPayload());
        }
        error err => { return err; }
    }
    return ();
}

function serviceError(error e) {
    io:print("[ERROR] service failed");
    io:println(e);
}



