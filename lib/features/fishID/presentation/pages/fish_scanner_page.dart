import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fyp/features/fishID/domain/entities/fish_info.dart';
import 'package:fyp/features/fishID/presentation/cubits/scan_cubit.dart';
import 'package:fyp/features/fishID/presentation/cubits/scan_state.dart';
import 'package:fyp/features/fishID/domain/entities/scan_result.dart';
import 'package:fyp/features/post/presentation/components/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

extension StringExtension on String {
  String capitalize() {
    return isNotEmpty
        ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}'
        : '';
  }
}

class FishScannerPage extends StatefulWidget {
  final String uid;
  const FishScannerPage({super.key, required this.uid});

  @override
  State<FishScannerPage> createState() => _FishScannerPageState();
}

class _FishScannerPageState extends State<FishScannerPage> {
  File? selectedImage;
  ScanResult? scanResult;
  String conservationStatus = '';

  Future<List<FishInfo>> loadFishData() async {
    final jsonString = await rootBundle.loadString(
      'assets/fish_data/fish_data.json',
    );
    final jsonData = jsonDecode(jsonString);
    final List list = jsonData['malaysian_sport_fish'];
    return list.map((e) => FishInfo.fromJson(e)).toList();
  }

  List<FishInfo> allFish = [];

  @override
  void initState() {
    super.initState();
    loadFishData().then((data) {
      setState(() {
        allFish = data;
      });

      // 🔍 Debug: print the entire list
      for (var fish in data) {
        print('📦 ${fish.toJson()}');
      }
    });
  }

  Future<void> pickImage() async {
    final image = await ImagePickerModal.show(context);
    if (image != null) {
      setState(() {
        selectedImage = image;
        scanResult = null;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to load image.")));
    }
  }

  Future<void> _scanImage() async {
    if (selectedImage != null) {
      context.read<ScanCubit>().scanFish(selectedImage!, widget.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Identify your Catch',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: BlocConsumer<ScanCubit, ScanState>(
        listener: (context, state) {
          if (state is ScanSuccess) {
            final result = state.result;

            final matchedFish = allFish.firstWhere(
              (fish) =>
                  fish.scientificName.trim().toLowerCase() ==
                  result.speciesName.trim().toLowerCase(),
              orElse:
                  () => FishInfo(
                    commonName: '',
                    scientificName: '',
                    conservationStatus: 'unknown',
                  ),
            );

            setState(() {
              scanResult = result;
              conservationStatus = matchedFish.conservationStatus;
            });
          }
        },

        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 250,
                      color: Colors.grey[200],
                      child:
                          selectedImage != null
                              ? Image.file(selectedImage!, fit: BoxFit.cover)
                              : const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Tap to select image",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (selectedImage != null && state is! ScanLoading)
                  ElevatedButton.icon(
                    onPressed: _scanImage,
                    icon: const Icon(Icons.search),
                    label: const Text("Scan with AI"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),

                if (state is ScanLoading) ...[
                  const SizedBox(height: 30),
                  Center(
                    child: LoadingAnimationWidget.dotsTriangle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      size: 70,
                    ),
                  ),
                ],

                if (scanResult != null) ...[
                  const SizedBox(height: 30),

                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Identification Result",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          const SizedBox(height: 12),
                          _buildInfoRow(
                            "Scientific Name:",
                            scanResult!.speciesName,
                            FontAwesomeIcons.fish,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            "Confidence:",
                            "${(scanResult!.confidence * 100).toStringAsFixed(2)}%",
                            Icons.percent,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            "Status:",
                            conservationStatus.isEmpty
                                ? "Unknown"
                                : conservationStatus.capitalize(),
                            Icons.info_outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              children: [
                TextSpan(
                  text: "$label ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
