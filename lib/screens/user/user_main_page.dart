import 'package:flutter/material.dart';
import 'package:destio/screens/user/user_dashboard.dart';
import 'package:destio/screens/user/bookmark.dart';
import 'package:destio/screens/user/profile.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    UserHomePage(),
    BookmarkPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildIcon(IconData iconData, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(iconData, color: Colors.black, size: 30),
        Container(
          margin: EdgeInsets.only(top: 0), // hilangkan jarak atas dot
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF127AC1) : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        child: Container(
          height: 50,
          color: const Color(0xFF56B8FF),
          child: Row(
            children: [
              // Expanded agar tiap item ukurannya sama dan melebar full ke pinggir
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(0),
                  child: Center(
                    child: _buildIcon(
                      _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                      _selectedIndex == 0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(1),
                  child: Center(
                    child: _buildIcon(
                      _selectedIndex == 1
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      _selectedIndex == 1,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(2),
                  child: Center(
                    child: _buildIcon(
                      _selectedIndex == 2 ? Icons.person : Icons.person_outline,
                      _selectedIndex == 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
