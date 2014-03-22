import 'dart:html' hide Point;
import 'package:json/json.dart';
import 'package:google_maps/google_maps.dart' as GoogleMaps;
import 'dart:collection';
GoogleMaps.GMap map;

final GoogleMaps.LatLng nagpur = new GoogleMaps.LatLng(21.21235, 79.10517);
//final GoogleMaps.LatLng Lakshdweep = new GoogleMaps.LatLng(10.5700, 72.6300);
var cname;
void main() {
  final mapOptions = new GoogleMaps.MapOptions()
    ..zoom =6
    ..center = nagpur
    ..mapTypeId = GoogleMaps.MapTypeId.ROADMAP
    ;
  map = new GoogleMaps.GMap(querySelector("#map_canvas"), mapOptions);
  loadConstWinners();
 loadContents(map);
}

GoogleMaps.InfoWindow infoWindow = new GoogleMaps.InfoWindow();
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
var contentString = """<div id="content">
      <div id="siteNotice">
      </div>
      <h4 id="firstHeading" class="firstHeading">${cname}</h4>
      <div id="bodyContent">
      </div>""";