import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';

class Workareasetup extends StatefulWidget {
  const Workareasetup({super.key});

  @override
  State<Workareasetup> createState() => _WorkareasetupState();
}

class _WorkareasetupState extends State<Workareasetup> {
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng _center = const LatLng(11.5564, 104.9282); // Phnom Penh fallback
  bool _loadingLocation = true;

  double _radius = 150; // meters

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      var serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _loadingLocation = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _center = LatLng(pos.latitude, pos.longitude);
        _loadingLocation = false;
      });

      final c = await _mapController.future;
      await c.animateCamera(CameraUpdate.newLatLngZoom(_center, 14.5));
    } catch (_) {
      setState(() => _loadingLocation = false);
    }
  }

  Set<Circle> get _circles => {
    Circle(
      circleId: const CircleId('work_area'),
      center: _center,
      radius: _radius,
      fillColor: const Color(0xFF0BD6C6).withOpacity(0.18),
      strokeColor: const Color(0xFF0BD6C6).withOpacity(0.55),
      strokeWidth: 2,
    ),
  };

  Set<Marker> get _markers => {
    Marker(markerId: const MarkerId('center_pin'), position: _center),
  };

  String _kmNum(int n) {
    const m = {
      '0': '០',
      '1': '១',
      '2': '២',
      '3': '៣',
      '4': '៤',
      '5': '៥',
      '6': '៦',
      '7': '៧',
      '8': '៨',
      '9': '៩',
    };
    return n.toString().split('').map((c) => m[c] ?? c).join();
  }

  Future<void> _zoomIn() async {
    final c = await _mapController.future;
    c.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final c = await _mapController.future;
    c.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> _goToCenter() async {
    final c = await _mapController.future;
    c.animateCamera(CameraUpdate.newLatLng(_center));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 223, 226, 230),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.lightBg,
                size: 29,
              ),
            ),
          ),
        ),
        title: Text(
          AppStrings.tr("ការកំណត់តំបន់ការងារ"),
          style: GoogleFonts.hanuman(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Help"),
                      content: const Text(
                        "This is the Work Area Setup screen.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(
                  Icons.help_outline,
                  color: AppColors.lightBg,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: _loadingLocation
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _center,
                        zoom: 14.5,
                      ),
                      onMapCreated: (controller) {
                        if (!_mapController.isCompleted) {
                          _mapController.complete(controller);
                        }
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      markers: _markers,
                      circles: _circles,
                      onTap: (latLng) {
                        // Optional: allow user to change center by tapping
                        setState(() => _center = latLng);
                      },
                    ),
            ),
            Positioned(left: 16, right: 16, top: 10, child: _buildSearch()),
            Positioned(
              right: 16,
              top: 150,
              child: Column(
                children: [
                  _squareBtn(icon: Icons.add, onTap: _zoomIn),
                  const SizedBox(height: 8),
                  _squareBtn(icon: Icons.remove, onTap: _zoomOut),
                  const SizedBox(height: 18),
                  _roundBtn(icon: Icons.my_location, onTap: _goToCenter),
                ],
              ),
            ),

            // Bottom panel
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildBottomPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _squareBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.22),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _roundBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFFF2A100),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 52,
          height: 52,
          child: Icon(Icons.my_location, color: Colors.black, size: 22),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            cursorColor: AppColors.secondary,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
              ),
              hintText: AppStrings.tr('រាជធានីភ្នំពេញ, ​ប្រទេសកម្ពុជា'),
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.secondary,
                size: 22,
              ),
            ),
          ),
        ),
        Positioned(
          left: 100,
          right: 100,
          bottom: -18,
          child: Container(
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(25),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 11, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  AppStrings.tr("ភាពត្រឹមត្រូវ៖ ខ្ពស់ (៣ម)"),
                  style: GoogleFonts.hanuman(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 3, 21, 21),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  AppStrings.tr("កំណត់កាំនៃតំបន់"),
                  style: GoogleFonts.hanuman(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                _kmNum(_radius.round()),
                style: GoogleFonts.hanuman(
                  color: const Color(0xFFF2A100),
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.tr("ម៉ែត្រ"),
                style: GoogleFonts.hanuman(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            min: 50,
            max: 300,
            divisions: 5,
            value: _radius,
            activeColor: AppColors.secondary,
            inactiveColor: const Color(0xFF0BD6C6).withOpacity(0.25),
            onChanged: (v) => setState(() => _radius = v),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [50, 100, 150, 200, 250, 300]
                .map(
                  (n) => Text(
                    _kmNum(n),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E6B6A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Saved radius: ${_radius.round()}m")),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, 
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.tr( "រក្សាទុកតំបន់ការងារ"),
                    style: GoogleFonts.hanuman(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8), 
                  const Icon(Icons.check, size: 20, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
