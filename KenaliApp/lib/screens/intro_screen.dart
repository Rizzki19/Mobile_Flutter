import 'package:flutter/material.dart';
import 'tampilan1.dart';
import 'tampilan2.dart';
import 'tampilan3.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentPage < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: 3,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              if (index == 0) const Tampilan1(),
              if (index == 1) const Tampilan2(),
              if (index == 2) const Tampilan3(),

              // Dot Indicator
              Positioned(
                bottom: 70,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentPage == i ? 16 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentPage == i ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),

              // Tombol Next/Mulai
              Positioned(
                bottom: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(currentPage == 2 ? 'Mulai' : 'Lanjut'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
