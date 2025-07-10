import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spanky/view/screens/widgets/customAddIcon.dart';

class NavBarBottom extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBarBottom({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: Platform.isAndroid ? 16 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white.withOpacity(0.8),
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey[700],
            showUnselectedLabels: false,
            currentIndex: currentIndex,
            onTap: onTap,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    Icons.home,
                    size: currentIndex == 0 ? 30 : 24,
                    color: currentIndex == 0 ? Colors.blue : Colors.grey[700],
                  ),
                ),
                label: '',
              ),

              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: FaIcon(
                    currentIndex == 1
                        ? FontAwesomeIcons.search
                        : FontAwesomeIcons.search,
                    color: currentIndex == 1 ? Colors.blue : Colors.grey[700],
                    size: currentIndex == 1 ? 30 : 24,
                  ),
                ),
                label: ' ',
              ),

              BottomNavigationBarItem(
                icon: Hero(tag: 'addIcon', child: CustomAddIcon()),
                label: '',
              ),

              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: FaIcon(
                    currentIndex == 3
                        ? FontAwesomeIcons.commentDots
                        : FontAwesomeIcons.commentDots,
                    color: currentIndex == 3 ? Colors.blue : Colors.grey[700],
                    size: currentIndex == 3 ? 30 : 24,
                  ),
                ),
                label: '',
              ),

              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: FaIcon(
                    currentIndex == 4
                        ? FontAwesomeIcons.solidUser
                        : FontAwesomeIcons.user,
                    color: currentIndex == 4 ? Colors.blue : Colors.grey[700],
                    size: currentIndex == 4 ? 30 : 24,
                  ),
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
