import 'dart:html' hide Point;
import 'package:json/json.dart';
import 'dart:collection';

class Loksabha {
  var DPC_ID;
  var DPC_NM;

  num DB_STATEID;
  var DSTATE_NM;

  String get LSDetailUrl => "http://www.indiavotes.com/pc/detail/$DPC_ID/$DB_STATEID/15";

  List<Coordinate> Coordinates;
  List<LSElectionResult> ElectionData;
}
class Coordinate {
  num Lat;
  num Long;
}

class LSElectionResult {
  num DPC_ID; // matches with MPC_NO of Loksabha constituency
  var DWIN_NM; //winner name
  var DWIN_PRT; // winner party
  
  
  String get ElectionType => "Loksabha";
  String get ElectionYear => "2009";
  num get ElectionId      =>  15; //matches the indiavotes id - 15 for Loksabha 15 election. 
  
  var WinnerCandidateId; // match the myneta info id
  String get MPDetailUrl => "http://www.myneta.info/ls2009/candidate.php?candidate_id=$WinnerCandidateId";
  
  String get WinnerName => DWIN_NM;
  String get WinnerParty => DWIN_PRT;
  var RunnerUp;
  var RunnerUpParty;
  var TotalVote;
  var WinnerVoteCount;
  var RunnerUpVoteCount;
}
class LS2009Results {
  HashMap mpData = new HashMap();
  
  void loadConstWinners(){
    HttpRequest.getString('/sampleWebApp/data/winner2009.json').then((String jsonData){
      final winnerData = parse (jsonData);
      for (var mp in winnerData) {
        mpData.putIfAbsent(mp["cty"],()=> mp);
      }
      loadContents(map);
    });
    }

void loadContents(map){
  HttpRequest.getString('/sampleWebApp/data/pc2009.json').then((String jsonData){
  final data = parse (jsonData); 
  var criminalCount = 0;
  for (var pc in data["features"]) {
    
    if (pc["geometry"] != null){
      
      if (pc["geometry"]["coordinates"] != null && pc["geometry"]["coordinates"][0] != null){
        
        var constCoords = [];
        for (var coord in pc["geometry"]["coordinates"][0]) {
          
          if (coord != null){
            constCoords.add(new GoogleMaps.LatLng(coord[1], coord[0]));
          }
        }
        // Construct the polygon.
         var constPolygonOptions = new GoogleMaps.PolygonOptions()
           ..paths=constCoords
           ..strokeColor = '#FF0000'
           ..strokeOpacity = 0.8
           ..strokeWeight = 1
           ..fillColor = '#00FF00'
           ..fillOpacity = 0.35
           ..clickable=true
           ..map=map
           
         ;
         var constProperties = pc["properties"];
         var mp = mpData[constProperties["DPC_NM"]];
       //  print (mp);
         if (mp == null ){
           constPolygonOptions.fillColor = '#00FF00';
           print(constProperties["DPC_NM"]); //TODO explore these constituency name, these are not being find within ADR json.
           if (constProperties["DPC_NM"] == null){
             print ("dpc_nm was null, alternatives - ${constProperties}");
           }
         } else if ( mp["cc"] != null && mp["cc"] != "0"){
           constPolygonOptions.fillColor = '#FF0000';
           //print(mp["cc"]);
           criminalCount = criminalCount+1;
         } else {
           constPolygonOptions.fillColor = '#00FF00';           
         }
         var constPolygon = new GoogleMaps.Polygon(constPolygonOptions);
         constPolygon.onClick.listen((data){
           print (constProperties);
           print (mp);
           cname = constProperties["MPC_NAME"];
       
        
           infoWindow.content = contentString;
           infoWindow.open(map, constPolygon);
           //print(data);           
         });
      }
     
    }
   
  }
  print(criminalCount);
  });
  
}
}