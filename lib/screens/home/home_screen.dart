import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget dashboardCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, size: 35, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      dashboardCard('Today Sales', '₹25,000', Icons.trending_up),
      dashboardCard('Today Expenses', '₹8,000', Icons.money_off),
      dashboardCard('Low Stock Items', '5', Icons.inventory),
      dashboardCard('AI Insights', '3 Suggestions', Icons.smart_toy),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Business Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Phones: keep the original single-column scrolling list.
            if (width < 700) {
              return ListView(children: cards);
            }

            // Tablets/desktop/Chrome: lay the cards out in a grid instead
            // of one long column, so they don't stretch edge-to-edge.
            final columns = width < 1100 ? 2 : 4;

            return GridView.builder(
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.6,
              ),
              itemBuilder: (context, index) => cards[index],
            );
          },
        ),
      ),
    );
  }
}
