import 'package:flutter/material.dart';

class Tampilan3 extends StatefulWidget {
  const Tampilan3({super.key});

  @override
  State<Tampilan3> createState() => _Tampilan3State();
}

class _Tampilan3State extends State<Tampilan3> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeTitle;
  late Animation<double> _fadeDesc;
  late Animation<Offset> _slideTitle;
  late Animation<Offset> _slideDesc;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    _fadeTitle = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _fadeDesc = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );
    _slideTitle = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _slideDesc = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Color(0xFFB1F2BC)),
      child: Stack(
        children: [
          Positioned(
            left: -13,
            top: -8,
            child: Container(
              width: 544,
              height: 816,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background2.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SlideTransition(
                position: _slideTitle,
                child: FadeTransition(
                  opacity: _fadeTitle,
                  child: Text(
                    'Tentang Stroke',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF00722D),
                      fontSize: 50,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SlideTransition(
                position: _slideDesc,
                child: FadeTransition(
                  opacity: _fadeDesc,
                  child: Text(
                    'Stroke merupakan salah satu penyebab utama kematian dan kecacatan di dunia. Stroke terjadi akibat adanya gangguan aliran darah ke otak yang menyebabkan kerusakan permanen jika tidak segera ditangani.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF00722D),
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
