import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:trab_final/screens/FormConvite.dart';
import 'package:trab_final/screens/LoginPage.dart';
import 'package:trab_final/screens/MapPage.dart';

class HomePage extends StatefulWidget {
  User? _user;
  GoogleSignIn? _gglSignIn;
  HomePage({Key? key, User? user, GoogleSignIn? ggSign}) : super(key: key) {
    this._user = user;
    this._gglSignIn = ggSign;
  }
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dataController = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore _db = FirebaseFirestore.instance;

  _listenerInvites() async {
    final stream = await _db.collection("convites").snapshots();
    debugPrint("\n\nestá entrando no listener de Invites\n\n DADOS: ");
    stream.listen((data) {
      debugPrint("\n\n DADOS: " + data.toString() + "\n\n\n");
      _dataController.add(data);

      debugPrint("\n\n dados do controller: " + _dataController.stream.toString() + "\n\n\n");
    });
  }

  @override
  void initState() {
    super.initState();
    _listenerInvites();
  }

// METHOD DO TO LOGOUT
  Future<void> _logoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Gostaria de Sair?'),
          actions: <Widget>[
            TextButton(
              child: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Icon(Icons.exit_to_app, color: Colors.red),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                if (widget._gglSignIn != null) {
                  widget._gglSignIn!.signOut();
                }
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            )
          ],
        );
      },
    );
  }

  _editEvento(String eventoId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => FormConvite(docId: eventoId)));
  }

  _createEvento() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => FormConvite()));
  }

  _deleteEvento(String docId) {
    _db.collection("convites").doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: widget._user != null
              ? TextButton(
                  child: Container(
                      height: 40.0,
                      width: 40.0,
                      decoration:
                          BoxDecoration(image: DecorationImage(image: NetworkImage(widget._user!.photoURL!), fit: BoxFit.cover), shape: BoxShape.circle)),
                  onPressed: () {
                    _logoutDialog();
                  },
                )
              : null,
          title: Center(child: Text("Lista de Convites")),
          actions: [
            TextButton(
                child: Icon(Icons.notifications, color: Theme.of(context).backgroundColor),
                onPressed: () {
                  // Navigator.of(context).push(
                  //     PageRouteBuilder(
                  //         transitionsBuilder: (context, animation,secondaryAnimation,child){
                  //           const begin = Offset(1.0, 0.0);
                  //           const end = Offset.zero;
                  //           final tween =Tween(begin:begin,end:end);
                  //           final offsetAnimation = animation.drive(tween);
                  //           return SlideTransition(position: offsetAnimation, child:child);
                  //         },
                  //         pageBuilder: (BuildContext context, Animation<double> animation, Animation <double> secondaryAnimation){
                  //           debugPrint(widget._user.toString());
                  //
                  //            return HomePage();
                  //         }
                  //     ));
                }),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _dataController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("deu erro"));
              }
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.done:
                  QuerySnapshot querySnapshot = snapshot.data!;
                  List<DocumentSnapshot> eventos = querySnapshot.docs.toList();
                  return ListView.builder(
                      itemCount: eventos.length,
                      itemBuilder: (context, index) {
                        final evento = eventos[index];
                        return Card(
                            child: InkWell(
                                splashColor: Colors.yellowAccent,
                                onTap: () {},
                                child: ListTile(
                                  tileColor: Theme.of(context).scaffoldBackgroundColor,
                                  leading: IconButton(
                                    icon: const Icon(Icons.location_pin),
                                    color: Colors.white,
                                    onPressed: () {
                                      // return _abrirMapa(evento.id);
                                    },
                                  ),
                                  title: Text(evento.get("nome")),
                                  onTap: () {
                                    _editEvento(evento.id);
                                  },
                                  trailing: TextButton(
                                      onPressed: () => showDialog(
                                          context: context,
                                          builder: (BuildContext context) => AlertDialog(
                                              title: const Text("Excluir Convite?"),
                                              content: const Text('Certeza que deseja excluir este convite?'),
                                              actions: [
                                                TextButton(
                                                    child: Icon(Icons.close),
                                                    onPressed: () {
                                                      return Navigator.pop(context, 'Cancel');
                                                    }),
                                                TextButton(
                                                    child: Icon(Icons.delete_outline_outlined, color: Colors.red),
                                                    onPressed: () {
                                                      _deleteEvento(evento.id);
                                                      return Navigator.pop(context, "OK");
                                                    })
                                              ])),
                                      child: Icon(Icons.delete, color: Colors.red)),
                                )));
                      });
                case ConnectionState.waiting:
                  debugPrint("está aqui esperando resposta");
                  return Center(
                      child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            CircularProgressIndicator(
                              strokeWidth: 5,
                              backgroundColor: Theme.of(context).backgroundColor,
                              valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                            )
                          ])));

              }
            }),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            tooltip: "add new convite",
            backgroundColor: Theme.of(context).buttonColor,
            onPressed: () {
              final Future future = Navigator.push(context, MaterialPageRoute(builder: (context) {
                return FormConvite();
              }));
              future.then((convite) {
                setState(() {});
              });
            }));
    // return Center(child: Text("nenhum convite "));
  }
}

//
// Widget ItemConvite(BuildContext context, Convite _convite) {
//   // final conviteDao _dao = new conviteDao();
//
//   void _updateChecked(_movie) {
//     _dao.update(_movie);
//   }
//
//   void _excluirConvite(Convite _convite) {
//     _dao.delete(_convite.id);
//   }
//
//   return Card(
//       child: InkWell(
//           splashColor: Colors.yellowAccent,
//           onTap: () {},
//           child: ListTile(
//             tileColor: Theme.of(context).scaffoldBackgroundColor,
//             leading: IconButton(
//               icon: const Icon(Icons.location_pin),
//               color: Colors.white,
//               onPressed: () {},
//             ),
//             title: Text(_convite.evento),
//             onTap: () {
//               final Future future = Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return FormConvite(_convite);
//               }));
//               future.then((editReturn) {
//                 setState(() {});
//               }, onError: (e) {
//                 debugPrint("error editing" + e);
//               });
//             },
//             trailing: TextButton(
//                 onPressed: () => showDialog(
//                     context: context,
//                     builder: (BuildContext context) =>
//                         AlertDialog(title: const Text("Excluir Convite?"), content: const Text('Certeza que deseja excluir este convite?'), actions: [
//                           TextButton(
//                               child: Icon(Icons.close),
//                               onPressed: () {
//                                 return Navigator.pop(context, 'Cancel');
//                               }),
//                           TextButton(
//                               child: Icon(Icons.delete_outline_outlined, color: Colors.red),
//                               onPressed: () {
//                                 // _excluirFilme(_convite);
//                                 setState(() {});
//                                 return Navigator.pop(context, "OK");
//                               })
//                         ])),
//                 child: Icon(Icons.delete, color: Colors.red)),
//           )));
// } // ITEM Convite
