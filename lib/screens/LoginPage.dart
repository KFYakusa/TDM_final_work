import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trab_final/screens/HomePage.dart';

class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>_LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GoogleSignIn ggleSign = GoogleSignIn();
  final _auth = FirebaseAuth.instance;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  Future<User?> _getUserGoogle() async{
    // ggleSign.signOut();
    return ggleSign.signIn()
        .then((googleSignInAccount) => googleSignInAccount!.authentication)
        .then((auth) =>GoogleAuthProvider.credential(idToken: auth.idToken, accessToken: auth.accessToken) )
        .then((credential)=>FirebaseAuth.instance.signInWithCredential(credential))
        .then((authResult){
      print("User: "+ authResult.user!.displayName!);
      return authResult.user;
    }).catchError((error){
      debugPrint("entering error");
      debugPrint(error.toString());
      return null;
    }) ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.red,
                ],),),
            child: Card(
                margin: EdgeInsets.only(top: 200, bottom: 200, left: 30, right: 30),
                elevation: 20,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Who are you?",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      Column(
                        children: [
                          // Padding(padding: const EdgeInsets.only(left:20,right:20),
                          //     child: MaterialButton(color: Colors.teal[100],
                          //       elevation: 10,
                          //       child: Row(mainAxisAlignment: MainAxisAlignment.start,
                          //         children: [
                          //           Icon(Icons.email, color: Theme.of(context).backgroundColor,),
                          //           SizedBox(width:20),
                          //           Text("Sign In with Email", style: TextStyle(
                          //               color: Theme.of(context).backgroundColor
                          //           ))
                          //         ],),
                          //       onPressed: (){
                          //         _showEmailDialog(context);
                          //       },
                          //     )
                          // ),
                          Padding(padding: const EdgeInsets.only(left: 20, right: 20),
                              child: MaterialButton(color: Colors.teal[100],
                                  elevation: 10,
                                  child: Row(mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(height: 30.0,width: 30.0,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image:AssetImage('assets/imgs/google-512x512.png'),
                                                  fit: BoxFit.cover),
                                              shape: BoxShape.circle),
                                        ),
                                        SizedBox(width: 20),
                                        Text("Sign In with Google",style: TextStyle(
                                            color: Theme.of(context).backgroundColor
                                        ))]),
                                  onPressed: (){
                                    _getUserGoogle().then((userRetorno){
                                      if(userRetorno != null){
                                        // _currentUser = userRetorno;
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(user: userRetorno, ggSign: ggleSign)));
                                      }
                                    }).catchError((onError)=>debugPrint(onError));
                                  }
                              )
                          ),
                        ],
                      )

                    ]
                ))));
  }
}