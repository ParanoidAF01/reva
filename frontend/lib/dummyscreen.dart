import 'package:flutter/material.dart';
import 'package:reva/authentication/signup/newmpin.dart';
import 'package:reva/authentication/signup/otpscreen.dart';
import 'package:reva/authentication/signup/profilestatusscreen.dart';
import 'package:reva/contacts/contacts.dart';
import 'package:reva/events/eventscreen.dart';
import 'package:reva/notification/notification.dart';
import 'package:reva/peopleyoumayknow/peopleyoumayknow.dart';
import 'package:reva/posts/createpost.dart';
import 'package:reva/posts/postsScreen.dart';
import 'package:reva/request/requestscreen.dart';
import 'package:reva/subscription/subscriptionscreen.dart';
import 'package:reva/wallet/walletscreen.dart';

class DummyScreen extends StatelessWidget {
  const DummyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF22252A),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> PostsScreen()));
          }, child: Text("post screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>EventScreen()));
          }, child: Text("events")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> WalletScreen()));
          }, child: Text("wallet screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> RequestScreen()));
          }, child: Text("Request screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> PeopleYouMayKnow()));
          }, child: Text("people you may know screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> Contacts()));
          }, child: Text("Contacts")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> NotificationScreen()));
          }, child: Text("Notification")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> OtpScreen()));
          }, child: Text("Otp Screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> NewMPIN()));
          }, child: Text("new mpin screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileStatusScreen()));
          }, child: Text("Profile status screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> SubscriptionScreen()));
          }, child: Text("Subscription screen")),
        ],
      ),
    );
  }
}
