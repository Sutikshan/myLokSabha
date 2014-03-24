import 'dart:html' hide Point;
import 'package:google_maps/google_maps.dart' as GoogleMaps;
import 'model/loksabha.dart';

GoogleMaps.GMap map;
final LS2009Results ls2009 = new LS2009Results();
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
  ls2009.loadConstituencies(drawMap);
  //loadContents();
  //print ("success");
}

GoogleMaps.InfoWindow infoWindow = new GoogleMaps.InfoWindow();
void drawMap(loksabha){
  
  var criminalCount = 0;
  // Construct the polygon.
           var constPolygonOptions = new GoogleMaps.PolygonOptions()
             ..paths=loksabha.Coordinates 
             ..strokeColor = '#FF0000'
             ..strokeOpacity = 0.8
             ..strokeWeight = 1
             ..fillColor = '#00FF00'
             ..fillOpacity = 0.35
             ..clickable=true
             ..map=map           
           ;
           constPolygonOptions.fillColor = '#00FF00';
           if (loksabha.ElectionData == null || loksabha.ElectionData.length == 0){
             constPolygonOptions.fillColor = '#0000FF';  
           }
           else if (loksabha.ElectionData[0].wCrimeCases != null && int.parse(loksabha.ElectionData[0].wCrimeCases) > 0) {
                constPolygonOptions.fillColor = '#FF0000';
                criminalCount = criminalCount+1;
              } else {
                constPolygonOptions.fillColor = '#00FF00';           
              }
            var constPolygon = new GoogleMaps.Polygon(constPolygonOptions);
            constPolygon.onClick.listen((data){
             print(data);
           
              infoWindow.content = contentString;
              infoWindow.open(map, constPolygon);
              //print(data);        
          });
}
void loadContents(){
  for (var key in ls2009.allLokSabha.keys){
    drawMap(key);  
  }
  
  
      }
var contentString = """<div id="content">
      <div id="siteNotice">
      </div>
      <h4 id="firstHeading" class="firstHeading">${cname}</h4>
      <div id="bodyContent">
      </div>""";