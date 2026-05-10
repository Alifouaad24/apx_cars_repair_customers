import 'dart:convert';

import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,

          appBar: AppBar(
            elevation: 0,

            backgroundColor: Colors.white,

            title: const Text(
              "Select Address",
              style: TextStyle(color: Colors.black),
            ),

            iconTheme: const IconThemeData(color: Colors.black),
          ),

          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.indigo,

            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                mapController.move(controller.currentLocation, 15);
              });
            },

            child: const Icon(Icons.my_location, color: Colors.white),
          ),

          body: controller.isLoadingMap
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.70,

                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),

                            bottomRight: Radius.circular(24),
                          ),

                          child: FlutterMap(
                            mapController: mapController,

                            options: MapOptions(
                              initialCenter: controller.currentLocation,

                              initialZoom: 15,

                              onTap: (tapPosition, point) async {
                                await controller.getAddress(
                                  point.latitude,
                                  point.longitude,
                                );
                              },
                            ),

                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                                userAgentPackageName: 'com.apx.carsrepair',

                                tileProvider: NetworkTileProvider(),
                              ),

                              MarkerLayer(
                                markers: controller.selectedLocation != null
                                    ? [
                                        Marker(
                                          point: controller.selectedLocation!,
                                          width: 80,
                                          height: 80,
                                          child: const Icon(
                                            Icons.location_pin,
                                            size: 45,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ]
                                    : [],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(1),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.line1.isEmpty
                                          ? "No address selected"
                                          : controller.line1,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_post_office_outlined,
                                          size: 18,
                                          color: Colors.indigo.shade400,
                                        ),

                                        const SizedBox(width: 8),
                                        Text(
                                          controller.postalCode.isEmpty
                                              ? "-"
                                              : controller.postalCode,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 50),
                                        IconButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          icon: Icon(
                                            Icons.check,
                                            size: 18,
                                            color: Colors.indigo.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        children: [
          SizedBox(
            width: 110,

            child: Text(
              "$title :",

              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,

              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

Widget softInfoBox(IconData icon, String title, String value) {
  return Container(
    padding: const EdgeInsets.all(14),

    decoration: BoxDecoration(
      color: Colors.indigo.withOpacity(0.05),

      borderRadius: BorderRadius.circular(18),
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, size: 18, color: Colors.indigo),

        const SizedBox(height: 10),

        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),

        const SizedBox(height: 4),

        Text(
          value.isEmpty ? "-" : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
