import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fyp/main.dart';
import 'package:fyp/utils/fish_species_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:fyp/features/fishID/data/service/image_validator.dart';
import 'package:fyp/features/fishID/presentation/cubits/scan_cubit.dart';
import 'package:fyp/features/fishID/presentation/cubits/scan_state.dart';
import 'package:fyp/features/logbook/domain/entities/logbook_entry.dart';
import 'package:fyp/features/logbook/presentation/cubits/logbook_cubit.dart';
import 'package:fyp/features/logbook/presentation/cubits/logbook_state.dart';
import 'package:fyp/features/post/presentation/components/image_picker.dart';
import 'package:fyp/features/post/presentation/components/location_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddCatchPage extends StatefulWidget {
  final String uid;
  const AddCatchPage({super.key, required this.uid});

  @override
  State<AddCatchPage> createState() => _AddCatchPageState();
}

class _AddCatchPageState extends State<AddCatchPage> {
  final _formKey = GlobalKey<FormState>();
  final speciesController = TextEditingController();
  final lengthController = TextEditingController();
  final weightController = TextEditingController();
  final locationController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isReleased = false;
  File? selectedImage;
  String? scannedScientificName;
  bool isSubmitting = false;
  bool isScanning = false;
  double? selectedLat;
  double? selectedLng;

  Future<void> _pickImage() async {
    final image = await ImagePickerModal.show(context);
    if (image != null) {
      setState(() => selectedImage = image);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("\u274c Failed to load image.")),
      );
    }
  }

  Future<void> _pickLocation() async {
    final result = await LocationPickerModal.show(context);
    if (result != null && result['name'] != null) {
      setState(() {
        locationController.text = result['name'];
        selectedLat = result['lat'];
        selectedLng = result['lng'];
      });
    }
  }

  Future<void> _scanImage() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }

    setState(() => isScanning = true);

    final isValid = await validateFishImage(selectedImage!);
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid image. Use a clear JPEG under 5MB."),
        ),
      );
      setState(() => isScanning = false);
      return;
    }

    final scanCubit = context.read<ScanCubit>();
    await scanCubit.scanFish(selectedImage!, widget.uid);
    final scanState = scanCubit.state;

    if (scanState is ScanSuccess) {
      final scannedName = scanState.result.commonName.trim();
      scannedScientificName = scanState.result.speciesName;
      speciesController.text =
          scannedName.isNotEmpty ? scannedName : "Unknown Fish";
    } else if (scanState is ScanError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("\u274c ${scanState.message}")));
    }

    setState(() => isScanning = false);
  }

  Future<void> _submit() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate())
      return;

    // Set submitting state immediately to disable button
    setState(() => isSubmitting = true);

    try {
      String speciesName = speciesController.text;

      if (speciesName.isEmpty && selectedImage != null) {
        final isValid = await validateFishImage(selectedImage!);
        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid image. Use a clear JPEG under 5MB."),
            ),
          );
          setState(() => isSubmitting = false);
          return;
        }

        final scanCubit = context.read<ScanCubit>();
        await scanCubit.scanFish(selectedImage!, widget.uid);
        final scanState = scanCubit.state;

        if (scanState is ScanSuccess) {
          speciesName =
              scanState.result.commonName.trim().isEmpty
                  ? "Unknown Fish"
                  : scanState.result.commonName;
          speciesController.text = speciesName;
          scannedScientificName = scanState.result.speciesName;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Scan failed: ${scanState is ScanError ? scanState.message : 'Unknown error'}",
              ),
            ),
          );
          setState(() => isSubmitting = false);
          return;
        }
      }

      final entry = LogbookEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        uid: widget.uid,
        species: speciesName,
        length: double.parse(lengthController.text),
        weight: double.parse(weightController.text),
        catchDate: selectedDate,
        catchTime: selectedTime,
        location: locationController.text,
        latitude: selectedLat,
        longitude: selectedLng,
        imageUrl: selectedImage?.path,
        isReleased: isReleased,
      );

      await context.read<LogbookCubit>().addEntry(entry);

      // Note: We don't need to set isSubmitting = false here as the BlocListener
      // will handle navigation away from this page on successful submission
    } catch (e) {
      // Handle any unexpected errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("\u274c Error: ${e.toString()}")));
      setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    speciesController.dispose();
    lengthController.dispose();
    weightController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogbookCubit, LogbookState>(
      listener: (context, state) {
        if (state is LogbookEntryAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("\ud83c\udf3f Catch saved successfully"),
            ),
          );
          Navigator.pop(context);
        } else if (state is LogbookError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("\u274c ${state.message}")));
          // Make sure to reset the submitting state if there's an error
          setState(() => isSubmitting = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Your New Catch"),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 200,
                          color: Colors.grey[200],
                          child:
                              selectedImage != null
                                  ? Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                  : const Center(
                                    child: Icon(Icons.add_a_photo, size: 40),
                                  ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: isScanning || isSubmitting ? null : _scanImage,
                      icon:
                          isScanning
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                              : const Icon(Icons.search),
                      label: Text(
                        "Scan with AI",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: speciesController,
                      decoration: InputDecoration(
                        labelText: "Species",
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(top: 12, left: 12),
                          child: FaIcon(FontAwesomeIcons.fish, size: 20),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (val) {
                        if ((val == null || val.isEmpty) &&
                            selectedImage == null) {
                          return "Enter a species name or scan using AI";
                        }
                        return null;
                      },
                    ),
                    if (scannedScientificName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Scientific name: $scannedScientificName",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: lengthController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Length (cm)",
                              prefixIcon: Icon(Icons.straighten),
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? "Enter length"
                                        : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Weight (kg)",
                              prefixIcon: Icon(Icons.monitor_weight),
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? "Enter weight"
                                        : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(
                        locationController.text.isEmpty
                            ? "Select Location"
                            : locationController.text,
                      ),
                      onTap: isSubmitting ? null : _pickLocation,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.calendar_month),
                            title: Text(
                              DateFormat.yMMMMd().format(selectedDate),
                            ),
                            onTap:
                                isSubmitting
                                    ? null
                                    : () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: selectedDate,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null)
                                        setState(() => selectedDate = picked);
                                    },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.access_time),
                            title: Text(selectedTime.format(context)),
                            onTap:
                                isSubmitting
                                    ? null
                                    : () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: selectedTime,
                                      );
                                      if (picked != null)
                                        setState(() => selectedTime = picked);
                                    },
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text("Caught & Released"),
                      value: isReleased,
                      onChanged:
                          isSubmitting
                              ? null
                              : (val) => setState(() => isReleased = val),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: isSubmitting || isScanning ? null : _submit,
                      icon:
                          isSubmitting
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                                ),
                              )
                              : Icon(
                                Icons.check,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.inversePrimary,
                              ),
                      label: Text(
                        isSubmitting ? "Submitting..." : "Submit",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isSubmitting || isScanning)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: LoadingAnimationWidget.dotsTriangle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      size: 70,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
