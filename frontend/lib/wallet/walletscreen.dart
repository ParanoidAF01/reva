import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/wallet/wallettile.dart';

import '../notification/notification.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var height= MediaQuery.of(context).size.height;
    var width= MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF22252A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height*0.1,),Padding(
              padding:EdgeInsets.symmetric(horizontal: width*0.05),
              child: Row(
                children: [
                  TriangleIcon(size: 20 , color: Colors.white,),
                  SizedBox(width: width*0.25,),
                  Text("Wallet", style: GoogleFonts.dmSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white
                  ),),



                ],
              ),
            ),
            SizedBox(height: height*0.08,),
            Padding(
              padding:EdgeInsets.symmetric(horizontal: width*0.05),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFF2F2F2),
                    child: Icon(Icons.compare_arrows),
                  ),
                  SizedBox(width: width*0.03,),
                  Text("Transactions",style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 19.47,
                    color: Colors.white
                  ),),

                ],
              ),
            ),
            SizedBox(height: 10,),
            WalletTile(),
            WalletTile(),
            WalletTile(),
            WalletTile(),

          ],
        ),
      ),
    );
  }
}
