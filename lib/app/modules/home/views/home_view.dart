import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Memperpanjang latar belakang di bawah Appbar
      appBar: AppBar(
        backgroundColor: Colors
            .transparent, // Mengatur latar belakang Appbar menjadi transparan
        elevation: 0, // Menghilangkan bayangan di bawah Appbar
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            // child: Image.asset(
            //   "images/bpdconsya.png",
            //   width: 100,
            //   height: 80,
            // ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD3D3D3), // Silver
              Color(0xFF4682B4), // Biru
            ],
          ),
        ),
        child: FutureBuilder(
          future: controller.loadData(),
          builder: (context, snapshot) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: snapshot.connectionState == ConnectionState.waiting
                  ? _buildLoadingWidget()
                  : snapshot.hasError
                      ? _buildErrorWidget(snapshot.error)
                      : _buildContentWidget(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: FadeTransition(
        opacity: const AlwaysStoppedAnimation(1),
        child: Image.asset(
          'images/bpdconsya.png',
          width: 300,
          height: 100,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Text('Error: $error'),
    );
  }

  Widget _buildContentWidget() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 200),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 227, 235, 88),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "images/icon.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "EIS",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Executive Information System",
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Roboto',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => controller.onTapLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 6, 72, 126),
                        minimumSize: Size(Get.width - 70, 40),
                      ),
                      child: const Text(
                        "L O G I N",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        const url =
                            'https://hcis.bankaltimtara.co.id/myHC/lost_password.php?UserName=';
                        try {
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        } catch (e) {
                          print('Error launching URL: $e');
                        }
                      },
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black),
                        overlayColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 6, 72, 126)
                                .withOpacity(0.2)),
                      ),
                      child: const Text(
                        "Lupa Kata Sandi?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
