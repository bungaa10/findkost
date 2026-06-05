import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/booking_provider.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<BookingProvider>().getBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Booking")),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.bookings.isEmpty
          ? const Center(child: Text("Belum ada booking"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: provider.bookings.length,

              itemBuilder: (_, index) {
                final booking = provider.bookings[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),

                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.home)),

                    title: Text(booking["nama_kost"]),

                    subtitle: Text("Status : ${booking["status"]}"),

                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: booking["status"] == "pending"
                            ? Colors.orange
                            : booking["status"] == "diterima"
                            ? Colors.green
                            : Colors.red,

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Text(
                        booking["status"],

                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
