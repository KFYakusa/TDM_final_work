import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';



class MapPage extends StatefulWidget {

  LatLng? eventoPosicao;
  final Function? updateLng;
  MapPage({ this.eventoPosicao, this.updateLng});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controladorMapa = Completer();
  CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();
  Set<Marker> _marcadores = {};
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(20.5937, 78.9629)
  );

  _onMapCreated(GoogleMapController controlador){
    _controladorMapa.complete(controlador);
  }

  _newMarker(LatLng latLng) async{
    List<Placemark> listaEnderecos = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if(listaEnderecos != null && listaEnderecos.length>0){
      Placemark endereco = listaEnderecos[0];
      String rua = endereco.thoroughfare!;

      Marker marcador = Marker(
        markerId: MarkerId('marcador-${latLng.latitude}-${latLng.longitude}'),
        position: latLng,
        infoWindow: InfoWindow(title:rua)
      );

      setState(() {
        _marcadores.add(marcador);
        widget.updateLng!(latLng);
      });
    }
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controladorMapa.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_posicaoCamera));
  }


  _adicionarListenerLocalizacao() {
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _posicaoCamera = CameraPosition( target: LatLng(position.latitude, position.longitude), zoom: 15);
        _movimentarCamera();
      });
    });
  }



  @override
  void initState(){
    super.initState();
    if(widget.eventoPosicao != null){
      setState(() {
        Marker marcador = Marker(
          markerId: MarkerId('marcador-${widget.eventoPosicao!.latitude}-${widget.eventoPosicao!.longitude}'),
          position: widget.eventoPosicao!
        );
        _marcadores.add(marcador);
        _posicaoCamera = CameraPosition(target: widget.eventoPosicao!, zoom: 15);
        _movimentarCamera();

      });
    }else{
      _adicionarListenerLocalizacao();
    }
  }


  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }
  //
  // void _onMapCreated(GoogleMapController _ctrl) {
  //   _controller = _ctrl;
  //   _customInfoWindowController.googleMapController = _ctrl;
  //   _location.onLocationChanged.listen((event) {
  //     _controller!.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(
  //             target: LatLng(event.latitude!, event.longitude!), zoom: 15),
  //       ),
  //     );
  //     setState(() {
  //       _lat = event.latitude!;
  //       _lng = event.longitude!;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa"),
      ),
      body: Container(
        child: GoogleMap(
          markers: _marcadores,
          mapType: MapType.satellite,
          initialCameraPosition: _posicaoCamera,
          onMapCreated: _onMapCreated,
          onLongPress: _newMarker,
        ),
      ),
    );
  }







}