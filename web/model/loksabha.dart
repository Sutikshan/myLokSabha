import 'dart:html' hide Point;
import 'package:json/json.dart';
import 'dart:collection';
import 'package:google_maps/google_maps.dart' as GoogleMaps;

class LokSabha {
  LokSabha(this.DPC_ID);   
  String get Id => DPC_ID;
  String get Name => DPC_NM;
  String get StateId => DB_STATEID;
  String get StateName => DSTATE_NM;
  String get LSDetailUrl => "http://www.indiavotes.com/pc/detail/$DPC_ID/$DB_STATEID/15";
  
  List<GoogleMaps.LatLng> Coordinates;
  List<LSElectionResult> ElectionData;
  
  var DPC_ID;
  var DPC_NM;
  var DB_STATEID;
  var DSTATE_NM;
  
  Map toJson() {
     return {"id": DPC_ID, "name": DPC_NM, "stateId": DB_STATEID, "stateName": DSTATE_NM, "ElecData2009": ElectionData};
   }
}
class LSElectionResult {  
  
  String get ElectionType => "Loksabha";
  String get ElectionYear => "2009";
  num get ElectionId      =>  15; //matches the indiavotes id - 15 for Loksabha 15 election.
  
  String get MPDetailUrl => "http://www.myneta.info/ls2009/candidate.php?candidate_id=$WADRId";  
  String get WinnerName => DWIN_NM;
  String get WinnerParty => DWIN_PRT;
  
  var RunnerUp;
  var RUParty;  
  var WVCount;
  var RUVCount;
  var totalV;
  var VMargin;
  var DPC_ID; // matches with DPC_ID of Loksabha constituency
  var DWIN_NM; //winner name
  var DWIN_PRT; // winner party

  //ADR Data    
  var WADRId; // match the myneta info id
  var WEdu;
  var WAssets;
  var WLia;
  var wCrimeCases;

}
class LS2009Results {
  
  HashMap<String, LokSabha> allLokSabha = new HashMap<String, LokSabha>();
  
  LokSabha loadLokSabhaData(var mp, var pcGeometry) {
    LokSabha lokSabha = new LokSabha(int.parse(mp["DPC_ID"]));
    lokSabha.DPC_NM = mp["DPC_NM"];
    lokSabha.DB_STATEID = int.parse(mp["DB_STATEID"]);
    lokSabha.DSTATE_NM = mp["DSTATE_NM"];
    lokSabha.Coordinates = new List<GoogleMaps.LatLng>();
    if (pcGeometry!= null && pcGeometry["coordinates"] != null && pcGeometry["coordinates"].length > 0) {
      for (var coord in pcGeometry["coordinates"][0]) {            
        if (coord != null) {
          lokSabha.Coordinates.add(new GoogleMaps.LatLng(coord[1], coord[0]));
        }
      }
    } else {
      print ("something wrong with " + lokSabha.DPC_NM  );
    }
    lokSabha.ElectionData = new List<LSElectionResult> ();
    LSElectionResult ls2009 = new LSElectionResult();
    lokSabha.ElectionData.add(ls2009);
    ls2009.DPC_ID = lokSabha.DPC_ID;
    ls2009.DWIN_NM = mp["DWIN_NM"];
    ls2009.DWIN_PRT = mp["DWIN_PRT"];
    ls2009.RunnerUp = mp["DRU_CND"];
    ls2009.RUParty = mp["DRU_PRT"];
    
    ls2009.RUVCount = mp["DRU_VOT"];
    ls2009.WVCount = mp["DCND_V"];
    
    ls2009.totalV = mp["DTOT_VOT"];
    ls2009.VMargin = num.parse(mp["DMAR_P"]);
    return lokSabha;
  }
  
  void loadConstituencies(drawMap){
    HttpRequest.getString('/loksabhaWebApp/data/pc2009.json').then((String jsonData){
      final data = parse (jsonData);
      for (var pc in data["features"]) {
        var pcProperties = pc["properties"];
        var pcGeometry = pc["geometry"];
        
        if (pcProperties["DPC_NM"] != null && pcProperties["DPC_NM"] != "") {
                allLokSabha.putIfAbsent(pcProperties["DPC_NM"], () => loadLokSabhaData(pcProperties, pcGeometry));
        }
      }
        loadADRData(drawMap);      
    });
  }
var totalAdr = 0;
  void loadADRData(drawMap){
  HttpRequest.getString('/loksabhaWebApp/data/winner2009.json').then((String jsonData){
    final winnerData = parse (jsonData);
        for (var mp in winnerData) {
          LokSabha ls = allLokSabha[mp["cty"]];
          totalAdr += 1;
          if (ls != null) {
            LSElectionResult lsElectionResult =  ls.ElectionData[0];
            lsElectionResult.WADRId = mp["id"];
            lsElectionResult.WAssets = mp["a"];
            lsElectionResult.WLia = mp["l"];
            lsElectionResult.wCrimeCases = mp["cc"];
            lsElectionResult.WEdu = mp["e"];            
            
          } else {
            // detail not found in ADR site.
            print (mp["cty"] + "--> Detail not found in indiavotes.in");
          }
          drawMap(ls);
        }
        print (totalAdr);
  });  
  }
}