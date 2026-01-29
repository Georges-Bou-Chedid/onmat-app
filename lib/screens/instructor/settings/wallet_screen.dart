import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/instructor/instructor.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final Color primaryBrandColor = const Color(0xFFDF1E42);
  String selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final appLocalizations = AppLocalizations.of(context)!;

    final instructorService = Provider.of<InstructorService>(context);
    final instructor = instructorService.instructor;
    final bool hasCard = instructor?.hasPaymentMethod ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.myWallet)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            /// 1. DYNAMIC BALANCE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryBrandColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: primaryBrandColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      appLocalizations.totalBalance ?? "Total Outstanding Balance",
                      style: TextStyle(color: Colors.white.withOpacity(0.8))
                  ),
                  const SizedBox(height: 8),
                  Text(
                      "\$${instructor?.outstandingBalance.toStringAsFixed(2) ?? '0.00'}",
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryBrandColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        onPressed: hasCard
                            ? () => _showPaymentDialog(context, instructor?.outstandingBalance ?? 0.0, instructorService)
                            : () => _showAddCardSheet(context, instructorService),
                        child: Text(hasCard ? (appLocalizations.payNow ?? "Pay Now") : (appLocalizations.addCard ?? "Add Whish Card")),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// 2. FILTERED TRANSACTIONS HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalizations.recentUpgrades ?? "Recent Upgrades", style: Theme.of(context).textTheme.titleLarge),
                PopupMenuButton<String>(
                  icon: const Icon(Iconsax.filter_edit, color: Colors.grey),
                  onSelected: (value) => setState(() => selectedFilter = value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'all', child: Text("All Transactions")),
                    const PopupMenuItem(value: 'pending', child: Text("Pending Only")),
                    const PopupMenuItem(value: 'paid', child: Text("Paid Only")),
                  ],
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// 3. REAL-TIME TRANSACTION LIST
            StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(instructor?.userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text("No transactions found", style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    String getTransactionLabel(String? type) {
                      switch (type) {
                        case 'belt_upgrade':
                          return "Belt Upgrade";
                        case 'stripe_addition':
                          return "Stripe Added";
                        case 'join_fee':
                          return "Join Fee";
                        default:
                          return "Other Transaction";
                      }
                    }

                    var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return _buildTransactionTile(
                        context,
                        data['student_name'] ?? 'Unknown Student',
                        getTransactionLabel(data['type']),
                        "\$${(data['amount'] ?? 0.0).toStringAsFixed(2)}",
                        (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                        data['status'] ?? 'pending'
                    );
                  },
                );
              },
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// 4. PAYMENT METHOD SECTION
            _buildSectionHeader(context, appLocalizations.paymentMethod ?? "Payment Method"),
            const SizedBox(height: TSizes.spaceBtwItems),
            _buildPaymentMethodTile(dark, instructor, appLocalizations, instructorService),

            const SizedBox(height: 20),
            const Icon(Iconsax.info_circle, color: Colors.grey, size: 20),
            const SizedBox(height: 8),
            const Text(
              "IMPORTANT: To maintain account access, your Whish card will be automatically charged on the last day of every month. Failure to clear balance will result in account suspension.",
              style: TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// HELPER: Filtered Stream
  Stream<QuerySnapshot> _getFilteredStream(String? instructorId) {
    Query query = FirebaseFirestore.instance
        .collection('transactions')
        .where('instructor_id', isEqualTo: instructorId);

    if (selectedFilter != 'all') {
      query = query.where('status', isEqualTo: selectedFilter);
    }

    return query.orderBy('timestamp', descending: true).snapshots();
  }

  /// HELPER: Transaction Tile
  Widget _buildTransactionTile(BuildContext context, String name, String type, String amount, DateTime date, String status) {
    final bool isPaid = status == 'paid';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: isPaid ? Colors.green.withOpacity(0.1) : const Color(0xFFFDE8EB),
            child: Icon(isPaid ? Iconsax.tick_circle : Iconsax.arrow_up_3, size: 18, color: isPaid ? Colors.green : const Color(0xFFDF1E42))
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$type • ${DateFormat('MMM dd, yyyy').format(date)}", style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isPaid ? Colors.green : Colors.orange)),
          ],
        ),
      ),
    );
  }

  /// HELPER: Section Header
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  /// HELPER: Payment Method Tile
  Widget _buildPaymentMethodTile(bool dark, dynamic instructor, dynamic l10n, InstructorService service) {
    final bool hasCard = instructor?.hasPaymentMethod ?? false;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: dark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2))
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Iconsax.card, color: Colors.green),
        ),
        title: const Text("Whish Visa Card"),
        subtitle: Text(hasCard ? "Auto-pay enabled (•••• 4242)" : "Link your Whish card for auto-billing"),
        trailing: TextButton(
            onPressed: () => _showAddCardSheet(context, service),
            child: Text(hasCard ? (l10n.change ?? "Change") : (l10n.add ?? "Add"))
        ),
      ),
    );
  }

  /// DIALOG: Settle Balance
  void _showPaymentDialog(BuildContext context, double balance, InstructorService service) {
    if (balance <= 0) {
      Get.snackbar("All Caught Up", "You have no outstanding balance to pay.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [Icon(Iconsax.verify, color: Colors.green), SizedBox(width: 10), Text("Confirm Payment")],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Your Whish Visa card will be charged for your total outstanding balance."),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Payable:"),
                Text("\$${balance.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFDF1E42))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBrandColor),
            onPressed: () async {
              Navigator.pop(context);
              bool success = await service.settleOutstandingBalance();
              if (success) {
                Get.snackbar("Payment Successful", "Your balance has been cleared.", backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
              }
            },
            child: const Text("Pay Now", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// BOTTOM SHEET: Add Whish Card (Visa Details)
  void _showAddCardSheet(BuildContext context, InstructorService service) {
    final dark = THelperFunctions.isDarkMode(context);
    final cardNoController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),

              const Row(
                children: [
                  Icon(Iconsax.card, color: Colors.green),
                  SizedBox(width: 10),
                  Text("Whish Visa Card", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),

              // Restriction Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withOpacity(0.3))
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.info_circle, color: Colors.blue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Note: Enter your Whish Visa card details. Your card will be charged automatically at the end of each month.",
                        style: TextStyle(fontSize: 12, color: dark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Card Number
              _buildCardField("Card Number", "0000 0000 0000 0000", Iconsax.card, cardNoController),
              const SizedBox(height: 16),

              // Expiry and CVV
              Row(
                children: [
                  Expanded(child: _buildCardField("Expiry", "MM/YY", Iconsax.calendar_1, expiryController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCardField("CVV", "123", Iconsax.lock, cvvController)),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBrandColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () async {
                    if (cardNoController.text.length < 16) {
                      Get.snackbar("Invalid Card", "Please enter a valid card number.");
                      return;
                    }
                    // This enables has_payment_method and activates the auto-billing status
                    await service.updatePaymentMethodStatus(true);
                    Get.back();
                    Get.snackbar("Success", "Whish Card linked and Auto-Pay active!");
                  },
                  child: const Text("Link & Authorize Auto-Pay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardField(String label, String hint, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}