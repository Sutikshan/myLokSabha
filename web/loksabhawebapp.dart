import 'dart:html' hide Point;
import 'package:google_maps/google_maps.dart' as GoogleMaps;
import 'model/loksabha.dart';

GoogleMaps.GMap map;
final LS2009Results ls2009 = new LS2009Results();
final GoogleMaps.LatLng nagpur = new GoogleMaps.LatLng(21.21235, 79.10517);

void main() {
  final mapOptions = new GoogleMaps.MapOptions()
    ..zoom =6
    ..center = nagpur
    ..mapTypeId = GoogleMaps.MapTypeId.ROADMAP
    ;
  map = new GoogleMaps.GMap(querySelector("#map_canvas"), mapOptions);
  ls2009.loadConstituencies(drawMap);  
}

void drawMap(loksabha) {
  // Construct the polygon.
           var constPolygonOptions = new GoogleMaps.PolygonOptions()
             ..paths=loksabha.Coordinates 
             ..strokeColor = '#FF0000'
             ..strokeOpacity = 1
             ..strokeWeight = 1
             ..fillColor = '#00FF00'
             ..fillOpacity = 0.35
             ..clickable=true
             ..map=map           
           ;           
           if (loksabha.ElectionData == null || loksabha.ElectionData.length == 0){
             constPolygonOptions.fillColor = '#0000FF';           
           }
           else if (loksabha.ElectionData[0].wCrimeCases != null && int.parse(loksabha.ElectionData[0].wCrimeCases) > 0) {
                constPolygonOptions.fillColor = '#FF0000';                
              } 
            var constPolygon = new GoogleMaps.Polygon(constPolygonOptions);
            constPolygon.onClick.listen((clickData){
              showWindow(loksabha, clickData.latLng);              
          });
}
void showWindow(loksabha, position){
  final infowindow = new GoogleMaps.InfoWindow(new GoogleMaps.InfoWindowOptions()
                    ..content = loksabha.Name
                    ..maxWidth = 200
                  );
                final marker = new GoogleMaps.Marker(new GoogleMaps.MarkerOptions()
                   ..position = position
                   ..map = map
                   ..title = loksabha.Name
                 );
                infowindow.open(map, marker);
                infowindow.onCloseclick.listen((data2){
                   marker.map = null;               
                });  
}