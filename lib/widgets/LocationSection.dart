import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationSection extends StatefulWidget {
  const LocationSection({super.key});

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  final MapController _mapController = MapController();

  LatLng? _userLocation;
  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<Position>? _positionSubscription;

  BranchLocation? _selectedBranch;

  static const List<BranchLocation> _branches = [
    BranchLocation(
      name: 'Maharagama',
      position: LatLng(6.8480, 79.9265),
    ),
    BranchLocation(
      name: 'Gampaha',
      position: LatLng(7.0873, 79.9994),
    ),
    BranchLocation(
      name: 'Kandy',
      position: LatLng(7.2906, 80.6337),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initLocationFlow();
  }

  Future<void> _initLocationFlow() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permissions are permanently denied. Please enable them in Settings.';
          _isLoading = false;
        });

        await openAppSettings();
        return;
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage =
              'Location permission denied. Please allow access to use the map.';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLocation = userLatLng;
        _isLoading = false;
      });

      _moveTo(userLatLng, zoom: 15);

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((position) {
        final updated = LatLng(position.latitude, position.longitude);
        setState(() {
          _userLocation = updated;
        });
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _moveTo(LatLng target, {double zoom = 15}) {
    _mapController.move(target, zoom);
  }

  void _onBranchSelected(BranchLocation branch) {
    setState(() {
      _selectedBranch = branch;
    });

    if (_userLocation != null) {
      final centerLat =
          (_userLocation!.latitude + branch.position.latitude) / 2.0;
      final centerLng =
          (_userLocation!.longitude + branch.position.longitude) / 2.0;
      _moveTo(LatLng(centerLat, centerLng), zoom: 10);
    } else {
      _moveTo(branch.position, zoom: 13);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                _buildMap(),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (_errorMessage != null && !_isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Column(
                    children: [
                      _buildMapControlButton(
                        icon: Icons.add,
                        onTap: () {
                          final currentZoom =
                              _mapController.camera.zoom + 1.0;
                          _mapController.move(
                            _mapController.camera.center,
                            currentZoom,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMapControlButton(
                        icon: Icons.remove,
                        onTap: () {
                          final currentZoom =
                              _mapController.camera.zoom - 1.0;
                          _mapController.move(
                            _mapController.camera.center,
                            currentZoom,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMapControlButton(
                        icon: Icons.my_location,
                        backgroundColor: Colors.green,
                        onTap: () {
                          if (_userLocation != null) {
                            _moveTo(_userLocation!, zoom: 15);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildBranchSelectionSection(theme),
      ],
    );
  }

  Widget _buildMap() {
    final defaultCenter = _userLocation ?? const LatLng(7.8731, 80.7718);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: defaultCenter,
        initialZoom: _userLocation != null ? 15 : 7,
        maxZoom: 18,
        minZoom: 3,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.lankasmartmart.app',
        ),
        if (_userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _userLocation!,
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        if (_selectedBranch != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedBranch!.position,
                width: 40,
                height: 40,
                alignment: Alignment.bottomCenter,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 32,
                ),
              ),
            ],
          ),
        if (_userLocation != null && _selectedBranch != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  _userLocation!,
                  _selectedBranch!.position,
                ],
                strokeWidth: 4,
                color: Colors.green,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color backgroundColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        radius: 16,
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildBranchSelectionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Branch',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _branches.map((branch) {
            final bool isSelected = _selectedBranch?.name == branch.name;
            return ChoiceChip(
              label: Text(branch.name),
              selected: isSelected,
              onSelected: (_) => _onBranchSelected(branch),
              selectedColor: Colors.green,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class BranchLocation {
  final String name;
  final LatLng position;

  const BranchLocation({
    required this.name,
    required this.position,
  });
}

