import re

# 修改 produktliste_screen.dart
file_path = "/Users/marceloruediger/code/thriftshop/frontend/lib/screens/produkte/produktliste_screen.dart"

with open(file_path, "r") as f:
    content = f.read()

# Replace the AppBar section with cart badge
old_appbar = """      appBar: AppBar(
        title: const Text('Produkte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, Routes.warenkorb);
            },
          ),
        ],
      ),"""

new_appbar = """      appBar: AppBar(
        title: const Text('Produkte'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.warenkorb);
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartProvider.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),"""

if old_appbar in content:
    content = content.replace(old_appbar, new_appbar)
    # Add CartProvider import
    content = content.replace(
        "import '../../providers/product_provider.dart';",
        "import '../../providers/product_provider.dart';\nimport '../../providers/cart_provider.dart';",
    )
    with open(file_path, "w") as f:
        f.write(content)
    print("✓ produktliste_screen.dart updated successfully")
else:
    print("✗ Could not find pattern in produktliste_screen.dart")
    # Let's debug
    import re

    appbar_match = re.search(r"appBar: AppBar\([^)]+\)", content, re.DOTALL)
    if appbar_match:
        print(f"Found AppBar at: {appbar_match.start()}-{appbar_match.end()}")
        print(f"Content:\n{appbar_match.group()}")
