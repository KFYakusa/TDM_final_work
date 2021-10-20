import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trab_final/database/convite_dao.dart';
import 'package:trab_final/models/Convite.dart';
import 'package:trab_final/screens/MapPage.dart';

class FormConvite extends StatefulWidget{

  final String? docId;

  FormConvite({this.docId});

  @override
  State<StatefulWidget> createState() {
    return _FormConviteState();
  }
}

class _FormConviteState extends State<FormConvite>{
  FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _controllerEvento = TextEditingController();
  final TextEditingController _controllerDescricao = TextEditingController();
  LatLng? _latLng;
  Map<String,dynamic> convite = Map();


  updateLatLng(LatLng novo){
    _latLng = novo;
  }

  _abrirMapa(LatLng? old) {
      Navigator.push(context,MaterialPageRoute(builder: (_) => MapPage( eventoPosicao: old, updateLng: updateLatLng )));
  }


  final _inviteFormKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    if(widget.docId != null){
     _getEvento(widget.docId!);
    }
  }

  _getEvento(String eventoId) async{
    DocumentSnapshot? eventoSnapshot = await _db.collection("convites").doc(eventoId).get();
    _controllerEvento.text = eventoSnapshot.get("nome");
    _controllerDescricao.text = eventoSnapshot.get("descricao");
    _latLng = LatLng(eventoSnapshot.get("latitude"), eventoSnapshot.get("longitude"));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:AppBar(
          title: Text("Convite"),
        ),
        body: Form(
            key: _inviteFormKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _controllerEvento,
                  decoration: InputDecoration(
                      icon: Icon(Icons.event_note ),
                      hintText: "Nome do evento do convite",
                      labelText: "Nome do Evento",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue ),
                      )
                  ),
                  validator: (value){
                    if(value==null || value.isEmpty){
                      return "enter some text";
                    }else if(value.contains('@')){
                      return "não pode ter '@' no nome do convite";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _controllerDescricao,
                  decoration:InputDecoration(
                      icon:Icon(Icons.description),
                      hintText: "O que vai ter lá?",
                      labelText: "Descrição do convite",
                      enabledBorder: UnderlineInputBorder(
                        borderSide:BorderSide(color:Colors.blue),
                      )
                  ),
                  validator: (value){

                    if(value==null || value.isEmpty){
                      return "enter some Description";
                    }
                    return null;
                  },
                ),
                ElevatedButton.icon(onPressed: (){
                  _abrirMapa(_latLng);
                }, label:Text("localização"), icon:Icon( Icons.location_on_outlined )),
                Center(
                    child:ElevatedButton(
                      onPressed: (){
                        if(_inviteFormKey.currentState!.validate()){
                          if(widget.docId != null)
                            _updateConvite(context);
                          else
                            _criarConvite(context);
                        }
                      },child:Text("confirmar"),
                    )
                )

              ],
            )
        )
    );
  } // @override Build Function

  void _criarConvite(BuildContext context) async{
    convite["nome"] = _controllerEvento.text;
    convite["descricao"] = _controllerDescricao.text;
    convite["longitude"] = _latLng!.longitude;
    convite["latitude"] = _latLng!.latitude;

    _db.collection("convites").add(convite).then((value) => Navigator.pop(context));

  }

  void _updateConvite(BuildContext context){


    convite["nome"] = _controllerEvento.text;
    convite["descricao"] = _controllerDescricao.text;
    convite["longitude"] = _latLng!.longitude;
    convite["latitude"] = _latLng!.latitude;
    _db.collection("convites").doc(widget.docId).set(convite).then((value) => Navigator.pop(context));
  }


}