import 'package:flutter/material.dart';
import 'package:on_time_fix/screens/customer/book_service_screen.dart';
import 'package:on_time_fix/screens/customer/my_bookings_screen.dart';

class CustomerMainNavigation extends StatefulWidget {
  const CustomerMainNavigation({super.key});

  @override
  State<CustomerMainNavigation> createState() => _CustomerMainNavigationState();
}

class _CustomerMainNavigationState extends State<CustomerMainNavigation> {
  int _selectedIndex = 0; // Tracks the active tab

  // List of the screens to show
  static const List<Widget> _widgetOptions = <Widget>[
    BookServiceScreen(),
    MyBookingsScreen(),
    // We can add a "Profile" screen here later
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body will be whichever screen is currently selected
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // Add the BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Book Service',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Bookings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor, // Use your theme color
        onTap: _onItemTapped,
      ),
    );
  }
}