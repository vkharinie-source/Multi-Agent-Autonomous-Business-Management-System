import 'package:flutter/material.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final searchController = TextEditingController();
  String selectedFilter = "All";

  static const double _mobileBreakpoint = 700;

  List<Map<String, dynamic>> products = [
    {
      "name": "Laptop",
      "category": "Electronics",
      "supplier": "ABC Suppliers",
      "stock": 8,
      "price": 55000,
    },
    {
      "name": "Mouse",
      "category": "Accessories",
      "supplier": "Tech World",
      "stock": 45,
      "price": 500,
    },
    {
      "name": "Keyboard",
      "category": "Accessories",
      "supplier": "Digital Hub",
      "stock": 12,
      "price": 1200,
    },
  ];

  List<String> filters = ["All", "Low Stock", "Electronics", "Accessories"];

  void openProductForm({Map<String, dynamic>? product, int? index}) {
    final name = TextEditingController(text: product?["name"] ?? "");
    final category = TextEditingController(text: product?["category"] ?? "");
    final supplier = TextEditingController(text: product?["supplier"] ?? "");
    final stock = TextEditingController(
      text: product?["stock"]?.toString() ?? "",
    );
    final price = TextEditingController(
      text: product?["price"]?.toString() ?? "",
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth < 500 ? screenWidth - 60 : 440.0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(product == null ? "Add Product" : "Edit Product"),
        content: SizedBox(
          width: formWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              input(name, "Product Name"),
              input(category, "Category"),
              input(supplier, "Supplier"),
              input(stock, "Stock Quantity", number: true),
              input(price, "Price", number: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final item = {
                "name": name.text,
                "category": category.text,
                "supplier": supplier.text,
                "stock": int.tryParse(stock.text) ?? 0,
                "price": int.tryParse(price.text) ?? 0,
              };

              setState(() {
                if (index == null) {
                  products.add(item);
                } else {
                  products[index] = item;
                }
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget input(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xffF8FAFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((p) {
      final search = searchController.text.toLowerCase();
      final matchSearch =
          p["name"].toString().toLowerCase().contains(search) ||
          p["category"].toString().toLowerCase().contains(search);

      if (selectedFilter == "Low Stock") return matchSearch && p["stock"] < 10;
      if (selectedFilter != "All") {
        return matchSearch && p["category"] == selectedFilter;
      }
      return matchSearch;
    }).toList();

    final totalStock = products.fold<int>(
      0,
      (sum, p) => sum + p["stock"] as int,
    );
    final lowStock = products.where((p) => p["stock"] < 10).length;
    final value = products.fold<int>(
      0,
      (sum, p) => sum + ((p["stock"] as int) * (p["price"] as int)),
    );

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < _mobileBreakpoint;

          return Column(
            children: [
              header(isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 26),
                  child: Column(
                    children: [
                      summaryCardsRow(
                        isMobile,
                        products.length,
                        totalStock,
                        lowStock,
                        value,
                      ),

                      SizedBox(height: isMobile ? 18 : 24),

                      Container(
                        padding: EdgeInsets.all(isMobile ? 16 : 22),
                        decoration: card(),
                        child: Column(
                          children: [
                            isMobile
                                ? Column(
                                    children: [
                                      searchField(),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        child: addProductButton(isMobile),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(child: searchField()),
                                      const SizedBox(width: 16),
                                      addProductButton(isMobile),
                                    ],
                                  ),

                            const SizedBox(height: 18),

                            SizedBox(
                              width: double.infinity,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: filters.map((f) {
                                    final active = selectedFilter == f;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: ChoiceChip(
                                        label: Text(f),
                                        selected: active,
                                        selectedColor: const Color(0xff2563EB),
                                        labelStyle: TextStyle(
                                          color: active
                                              ? Colors.white
                                              : const Color(0xff081A63),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        onSelected: (_) =>
                                            setState(() => selectedFilter = f),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isMobile ? 18 : 24),

                      aiCard(isMobile),

                      SizedBox(height: isMobile ? 18 : 24),

                      Container(
                        padding: EdgeInsets.all(isMobile ? 16 : 22),
                        decoration: card(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Product Inventory",
                              style: TextStyle(
                                fontSize: isMobile ? 19 : 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff081A63),
                              ),
                            ),
                            const SizedBox(height: 18),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final p = filtered[i];
                                final originalIndex = products.indexOf(p);
                                final low = p["stock"] < 10;

                                final actionButtons = Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => openProductForm(
                                        product: p,
                                        index: originalIndex,
                                      ),
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Color(0xff2563EB),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => setState(
                                        () => products.removeAt(originalIndex),
                                      ),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                );

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: low
                                          ? [
                                              const Color(0xfffffbeb),
                                              const Color(0xfffff7ed),
                                            ]
                                          : [
                                              Colors.white,
                                              const Color(0xffF8FAFF),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: low
                                          ? Colors.orange.shade200
                                          : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: isMobile
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 26,
                                                  backgroundColor: low
                                                      ? Colors.orange
                                                            .withValues(
                                                              alpha: 0.14,
                                                            )
                                                      : const Color(
                                                          0xff2563EB,
                                                        ).withValues(
                                                          alpha: 0.12,
                                                        ),
                                                  child: Icon(
                                                    low
                                                        ? Icons.warning_rounded
                                                        : Icons.inventory_2,
                                                    color: low
                                                        ? Colors.orange
                                                        : const Color(
                                                            0xff2563EB,
                                                          ),
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Text(
                                                    p["name"],
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff081A63),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "Category: ${p["category"]}  •  Supplier: ${p["supplier"]}",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (low)
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  top: 6,
                                                ),
                                                child: Text(
                                                  "⚠ Reorder needed",
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Stock: ${p["stock"]}",
                                                      style: TextStyle(
                                                        color: low
                                                            ? Colors.orange
                                                            : Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text("₹${p["price"]}"),
                                                  ],
                                                ),
                                                const Spacer(),
                                                actionButtons,
                                              ],
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              backgroundColor: low
                                                  ? Colors.orange.withValues(
                                                      alpha: 0.14,
                                                    )
                                                  : const Color(
                                                      0xff2563EB,
                                                    ).withValues(alpha: 0.12),
                                              child: Icon(
                                                low
                                                    ? Icons.warning_rounded
                                                    : Icons.inventory_2,
                                                color: low
                                                    ? Colors.orange
                                                    : const Color(0xff2563EB),
                                              ),
                                            ),
                                            const SizedBox(width: 18),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p["name"],
                                                    style: const TextStyle(
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff081A63),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    "Category: ${p["category"]}  •  Supplier: ${p["supplier"]}",
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  if (low)
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                        top: 6,
                                                      ),
                                                      child: Text(
                                                        "⚠ Reorder needed",
                                                        style: TextStyle(
                                                          color: Colors.orange,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "Stock: ${p["stock"]}",
                                                  style: TextStyle(
                                                    color: low
                                                        ? Colors.orange
                                                        : Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text("₹${p["price"]}"),
                                              ],
                                            ),
                                            const SizedBox(width: 20),
                                            actionButtons,
                                          ],
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget searchField() {
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: "Search product, category or supplier...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xffF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget addProductButton(bool isMobile) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: isMobile ? 16 : 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => openProductForm(),
      icon: const Icon(Icons.add),
      label: const Text("Add Product"),
    );
  }

  Widget header(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 28,
        isMobile ? 20 : 30,
        isMobile ? 16 : 28,
        isMobile ? 24 : 34,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff020A3D), Color(0xff2563EB), Color(0xff9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: isMobile ? 6 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Inventory Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Track products, stock levels, suppliers and low-stock alerts",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: isMobile ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const Spacer(),
            const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          ] else
            const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget summaryCardsRow(
    bool isMobile,
    int totalProducts,
    int totalStock,
    int lowStock,
    int value,
  ) {
    final cards = [
      summaryContent(
        "Total Products",
        "$totalProducts",
        Icons.inventory_2,
        const Color(0xff2563EB),
      ),
      summaryContent(
        "Total Stock",
        "$totalStock",
        Icons.store,
        const Color(0xff10B981),
      ),
      summaryContent(
        "Low Stock",
        "$lowStock",
        Icons.warning_rounded,
        const Color(0xffF97316),
      ),
      summaryContent(
        "Stock Value",
        "₹$value",
        Icons.currency_rupee,
        const Color(0xff9333EA),
      ),
    ];

    if (isMobile) {
      return SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) => Container(
            width: 190,
            padding: const EdgeInsets.all(18),
            decoration: card(),
            child: cards[index],
          ),
        ),
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i != 0) const SizedBox(width: 18),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: card(),
              child: cards[i],
            ),
          ),
        ],
      ],
    );
  }

  Widget summaryContent(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withValues(alpha: 0.13),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff081A63),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget aiCard(bool isMobile) {
    final lowItems = products.where((p) => p["stock"] < 10).toList();

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffEEF4FF), Color(0xffF5F3FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffC7D2FE)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isMobile ? 26 : 32,
            backgroundColor: const Color(0xff2563EB),
            child: Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: isMobile ? 26 : 34,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              lowItems.isEmpty
                  ? "AI Insight: Inventory looks healthy. No urgent reorder needed."
                  : "AI Insight: ${lowItems.first["name"]} stock is low. Suggested reorder quantity: 20 units.",
              style: TextStyle(
                fontSize: isMobile ? 14 : 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xff081A63),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
