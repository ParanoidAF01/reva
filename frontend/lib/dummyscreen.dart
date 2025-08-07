import 'package:flutter/material.dart';
import 'package:reva/authentication/signup/newmpin.dart';
import 'package:reva/authentication/signup/otpscreen.dart';
import 'package:reva/authentication/signup/profilestatusscreen.dart';
import 'package:reva/contacts/contacts.dart';
import 'package:reva/events/eventscreen.dart';
import 'package:reva/notification/notification.dart';
import 'package:reva/peopleyoumayknow/peopleyoumayknow.dart';
import 'package:reva/posts/postsScreen.dart';
import 'package:reva/request/requestscreen.dart';
import 'package:reva/subscription/subscriptionscreen.dart';
import 'package:reva/wallet/walletscreen.dart';

class DummyScreen extends StatelessWidget {
  const DummyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const PostsScreen()));
          }, child: const Text("post screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>const EventScreen()));
          }, child: const Text("events")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const WalletScreen()));
          }, child: const Text("wallet screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const RequestScreen()));
          }, child: const Text("Request screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const PeopleYouMayKnow()));
          }, child: const Text("people you may know screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const Contacts()));
          }, child: const Text("Contacts")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const NotificationScreen()));
          }, child: const Text("Notification")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const OtpScreen()));
          }, child: const Text("Otp Screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const NewMPIN(mobileNumber: '')));
          }, child: const Text("new mpin screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const ProfileStatusScreen()));
          }, child: const Text("Profile status screen")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const SubscriptionScreen()));
          }, child: const Text("Subscription screen")),
        ],
      ),
    );
  }
}
