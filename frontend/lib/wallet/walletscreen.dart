import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/wallet/wallettile.dart';
import '../notification/notification.dart';
import '../services/service_manager.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<dynamic> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await ServiceManager.instance.transactions.getAllTransactions();
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          transactions = response['data']['transactions'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height * 0.1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Row(
                children: [
                  const TriangleIcon(size: 20, color: Colors.white),
                  SizedBox(width: width * 0.25),
                  Text(
                    "Wallet",
                    style: GoogleFonts.dmSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.08),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFF2F2F2),
                    child: Icon(Icons.compare_arrows),
                  ),
                  SizedBox(width: width * 0.03),
                  Text(
                    "Transactions",
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 19.47,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                    ? const Center(child: Text("No transactions found", style: TextStyle(color: Colors.white)))
                    : Column(
                        children: transactions.map((tx) => WalletTile(
                          title: tx['title'] ?? 'Reva',
                          date: tx['date'] ?? '',
                          amount: tx['amount']?.toString() ?? '',
                          status: tx['status'] ?? '',
                          logo: tx['logo'] ?? "assets/logo.png",
                        )).toList(),
                      ),
          ],
        ),
      ),
    );
  }
}
