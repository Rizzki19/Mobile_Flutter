import 'package:flutter/material.dart';

class Tampilan2 extends StatefulWidget {
  const Tampilan2({super.key});

  @override
  State<Tampilan2> createState() => _Tampilan2State();
}

class _Tampilan2State extends State<Tampilan2> with SingleTickerProviderStateMixin {
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
      decoration: const BoxDecoration(
        color: Color(0xFFB1F2BC),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background1.png",
              fit: BoxFit.cover,
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
                    'Selamat Datang Di Kenali!',
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
            alignment: const Alignment(0, 0.3),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SlideTransition(
                position: _slideDesc,
                child: FadeTransition(
                  opacity: _fadeDesc,
                  child: Text(
                    'Kenali membantu Anda mengenali dan memahami risiko stroke secara mudah dan cepat. Dengan aplikasi ini, Anda dapat melakukan skrining mandiri untuk mengetahui apakah Anda berisiko tinggi, sedang, atau sehat dari penyakit stroke. Lindungi kesehatan Anda sejak dini!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF00722D),
                      fontSize: 12,
                      fontFamily: 'Poppins',
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
