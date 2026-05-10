import re

# Modify main_navigation.dart - add cart badge to shopping cart tab icon
file_path = (
    "/Users/marceloruediger/code/thriftshop/frontend/lib/widgets/main_navigation.dart"
)

with open(file_path, "r") as f:
    content = f.read()

# Replace the bottomNavigationBar section
old_bottomnav = """      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: _getNavItems(),
        ),
      ),"""

new_bottomnav = """      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _getNavItems().length,
                  (index) {
                    final item = _getNavItems()[index];
                    final isSelected = index == _currentIndex;
                    return GestureDetector(
                      onTap: () => _onItemTapped(index),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isSelected
                                    ? (item.activeIcon as Icon).icon
                                    : (item.icon as Icon).icon,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          if (index == 1 && cartProvider.itemCount > 0)
                            Positioned(
                              right: 4,
                              top: 0,
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
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),"""

if old_bottomnav in content:
    content = content.replace(old_bottomnav, new_bottomnav)
    # Add CartProvider import
    if "CartProvider" not in content:
        content = content.replace(
            "import '../exports.dart';",
            "import '../exports.dart';\nimport '../providers/cart_provider.dart';",
        )
    with open(file_path, "w") as f:
        f.write(content)
    print("✓ main_navigation.dart updated successfully")
else:
    print("✗ Could not find pattern in main_navigation.dart")
    # Debug
    print("Searching for BottomNavigationBar...")
    if "BottomNavigationBar" in content:
        idx = content.find("BottomNavigationBar")
        print(f"Found at index {idx}")
        print(content[idx : idx + 500])
