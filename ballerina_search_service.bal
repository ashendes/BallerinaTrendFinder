import wso2/twitter;
import ballerina/io;
import ballerina/http;
import ballerina/config;
import ballerina/time;
import ballerina/log;

endpoint twitter:Client twitter{
    clientId: config:getAsString("consumerKey"),
    clientSecret: config:getAsString("consumerSecret"),
    accessToken: config:getAsString("accessToken"),
    accessTokenSecret: config:getAsString("accessTokenSecret")
};

endpoint http:Listener listener{
   port:9094
};

endpoint http:Client geo_Locator{
   url: "http://query.yahooapis.com"
};


@http:ServiceConfig {
    basePath: "/"
}
service<http:Service> findTag bind listener{
    @http:ResourceConfig{
        methods:["POST"],
        path:"/"
    }
    message (endpoint caller, http:Request request){
        http:Response response = new;
        //http:Request  req = new;
        time:Time time = time:currentTime();
        //string placeName = check request.getTextPayload();
        //io:println(placeName);
        //string encodedPlaceName = check http:encode(placeName, "UTF-8");
        ////userDefinedSecureOperation(untaint placeName);
        //string requestPath = "/v1/public/yql?q=select* from geo.places where text%3D\"Colombo\"&format=json";
        //io:println(requestPath);
        //var response1 = geo_Locator->get(requestPath);
        //match locationResponse {
        //    twitter:Location[] trendingLocations => {
        //        int i = 0;
        //        while (i<3){
        //            string placeName;
        //            try{
        //                placeName = <string>trendingLocations[i].name;
        //            } catch (error err){
        //                break;
        //            }
        //            io:println(placeName);
        //            var trendsResponse = twitter->getTopTrendsByPlace(trendingLocations[i].woeid);
        //            match trendsResponse{
        //                twitter:Trends[] trends => {
        //                    int j = 0;
        //                    while (j<5){
        //                        io:println(trends[0].trends[j].name);
        //                        io:println("----");
        //                        j++;
        //                    }
        //                }
        //                twitter:TwitterError e => io:println(e);
        //            }
        //            i++;
        //            io:println("---------------------------------------------");
        //        }
        //    }(year, month, day) = time.getDate();
        //    twitter:TwitterError e => io:println(e);
        //}
        int year;
        int month;
        int day;
        (year, month, day) = time.getDate();
        string status = "Top trends for hour " +time.hour() + " on "+day+"/"+month+"/"+year+":\n";
        var trendsResponse = twitter->getTopTrendsByPlace(1);
        match trendsResponse{
            twitter:Trends[] trends => {
                twitter:Trend[] topTrends = sort(trends[0].trends);
                int j = 0;
                while (j<10){
                    //io:println(trends[0].trends[j].name);
                    int tweetVolume = <int>topTrends[j].tweetVolume/1000;
                    string newRecord = j+1 +". " + <string>topTrends[j].name + " | "+ tweetVolume+"K tweets";
                    string temp = status + newRecord;
                    if(temp.length() > 270){
                        status+="\n";
                        break;
                    }
                    status += newRecord;
                    //io:println("----");
                    if(j!=9){
                        status+="\n";
                    }
                    j++;
                }
            }
            twitter:TwitterError e => io:println(e);
        }
        io:println(status);

        var tweetResponse = twitter -> tweet(status);
        match tweetResponse{
            twitter:Status tweet => {
                response.setTextPayload("Tweet successful");
            }
            twitter:TwitterError e => {
                response.setTextPayload("[ERROR] Status Code: " + e.statusCode + " | Message: "+ e.message);
            }
        }

        _ = caller -> respond(response);
    }
}

function sort(twitter:Trend[] unsortedArray) returns @untainted twitter:Trend[] {
    twitter:Trend[] sortedArray = [];
    int i=0;
    int j=0;
    twitter:Trend key;
    while(i< lengthof unsortedArray){
        key = unsortedArray[i];
        j=i-1;
        while(j>=0 && unsortedArray[j].tweetVolume < key.tweetVolume){
            unsortedArray[j+1] = unsortedArray[j];
            j-=1;
        }
        unsortedArray[j+1] = key;
        i++;
    }

    return unsortedArray;
}
