import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,

          appBar: AppBar(
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
              controller.moveCamera(controller.currentLocation);
            },
            child: const Icon(Icons.my_location, color: Colors.white),
          ),

          body: controller.isLoadingMap
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      flex: 7,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(40.7128, -74.0060),
                          zoom: 3,
                        ),

                        onMapCreated: (GoogleMapController mapController) {
                          controller.mapController = mapController;
                        },

                        onTap: (LatLng point) async {
                          await controller.getAddress(
                            point.latitude,
                            point.longitude,
                          );
                        },

                        markers: controller.selectedLocation != null
                            ? {
                                Marker(
                                  markerId: const MarkerId("selected"),
                                  position: controller.selectedLocation!,
                                ),
                              }
                            : {},

                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                      ),
                    ),

                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 20,
                              color: Colors.black.withOpacity(0.05),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.line1.isEmpty
                                  ? "No address selected"
                                  : controller.line1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                const Icon(Icons.local_post_office),
                                const SizedBox(width: 8),
                                Text(
                                  controller.postalCode.isEmpty
                                      ? "-"
                                      : controller.postalCode,
                                ),

                                const Spacer(),

                                IconButton(
                                  onPressed: () => Get.back(),
                                  icon: const Icon(Icons.check),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
