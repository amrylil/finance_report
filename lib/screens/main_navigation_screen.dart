import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laporan_keuangan_app/providers/dompet_provider.dart';
import 'package:laporan_keuangan_app/providers/kategori_provider.dart';
import 'package:laporan_keuangan_app/screens/dompet/dompet_list_screen.dart';
import 'package:provider/provider.dart';
import './home_screen.dart';
import './kategori_list_screen.dart';
import './transaksi_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late List<AnimationController> _iconAnimationControllers;

  final List<Widget> _screens = [
    HomeScreen(),
    DompetListScreen(),
    TransaksiListScreen(),
    KategoriListScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      color: Colors.indigo,
    ),
    NavigationItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      label: 'Dompet',
      color: Colors.green,
    ),
    NavigationItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Transaksi',
      color: Colors.orange,
    ),
    NavigationItem(
      icon: Icons.category_outlined,
      activeIcon: Icons.category,
      label: 'Kategori',
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animation controllers for each icon
    _iconAnimationControllers = List.generate(
      _navigationItems.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    // Animate the first icon
    _iconAnimationControllers[0].forward();

    // Load master data
    _loadMasterData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    for (var controller in _iconAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMasterData() async {
    try {
      await Future.wait([
        Provider.of<DompetProvider>(context, listen: false).fetchAndSetDompet(),
        Provider.of<KategoriProvider>(
          context,
          listen: false,
        ).fetchAndSetKategori(),
      ]);
    } catch (error) {
      // Handle error silently or show snackbar if needed
      debugPrint('Error loading master data: $error');
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Animate previous icon out
    _iconAnimationControllers[_currentIndex].reverse();

    // Animate new icon in
    _iconAnimationControllers[index].forward();

    setState(() {
      _currentIndex = index;
    });

    // Jump directly to the selected page
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        physics: NeverScrollableScrollPhysics(), // Disable swipe navigation
        onPageChanged: (index) {
          // This will only be called programmatically now
          // No need to call _onTabTapped here as it would create a loop
        },
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 90,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navigationItems[index];
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color:
                isSelected ? item.color.withOpacity(0.1) : Colors.transparent,
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _iconAnimationControllers[index],
              builder: (context, child) {
                final animationValue = _iconAnimationControllers[index].value;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:
                            isSelected
                                ? item.color.withOpacity(0.2 * animationValue)
                                : Colors.transparent,
                      ),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          key: ValueKey(isSelected),
                          size: 24 + (2 * animationValue),
                          color: isSelected ? item.color : Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: isSelected ? 12 : 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? item.color : Colors.grey[600],
                      ),
                      child: Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: EdgeInsets.only(top: 2),
                        height: 2,
                        width: 20 * animationValue,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}

// Alternative: Modern Bottom Navigation with Floating Style
class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;

  const ModernBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items:
              items
                  .map(
                    (item) => BottomNavigationBarItem(
                      icon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color:
                              currentIndex == items.indexOf(item)
                                  ? item.color.withOpacity(0.1)
                                  : Colors.transparent,
                        ),
                        child: Icon(item.icon),
                      ),
                      activeIcon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: item.color.withOpacity(0.15),
                        ),
                        child: Icon(item.activeIcon),
                      ),
                      label: item.label,
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
