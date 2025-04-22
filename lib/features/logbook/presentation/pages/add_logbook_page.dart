import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  Future<void> _pickImage() async {
    final image = await ImagePickerModal.show(context);
    debugPrint("🧪 Picked image: ${image?.path}");
    if (image != null) {
      setState(() => selectedImage = image);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to load image.")));
    }
  }

  Future<void> _pickLocation() async {
    final result = await LocationPickerModal.show(context);
    if (result != null && result['name'] != null) {
      setState(() {
        locationController.text = result['name'];
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    String speciesName = speciesController.text;

    if (speciesName.isEmpty && selectedImage != null) {
      final isValid = await validateFishImage(selectedImage!);
      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid image. Use a clear JPEG under 5MB."),
          ),
        );
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
      imageUrl: selectedImage?.path,
      isReleased: isReleased,
    );

    context.read<LogbookCubit>().addEntry(entry);
  }

  List<String> fishSpeciesList = [];

  @override
  void initState() {
    super.initState();
    fishSpeciesList = globalFishSpeciesList;
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
            const SnackBar(content: Text("🎣 Catch saved successfully")),
          );
          Navigator.pop(context);
        } else if (state is LogbookError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("❌ ${state.message}")));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Add Your New Catch',
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

        body: BlocBuilder<ScanCubit, ScanState>(
          builder: (context, scanState) {
            return SingleChildScrollView(
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
                          color: Colors.grey[200],
                          height: 200,
                          width: double.infinity,
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
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (selectedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select an image first."),
                            ),
                          );
                          return;
                        }

                        final isValid = await validateFishImage(selectedImage!);
                        if (!isValid) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Invalid image. Use a clear JPEG under 5MB.",
                              ),
                            ),
                          );
                          return;
                        }

                        final scanCubit = context.read<ScanCubit>();
                        await scanCubit.scanFish(selectedImage!, widget.uid);
                        final scanState = scanCubit.state;

                        if (scanState is ScanSuccess) {
                          final scannedName =
                              scanState.result.commonName.trim();
                          scannedScientificName = scanState.result.speciesName;

                          if (scannedName.isNotEmpty) {
                            if (fishSpeciesList.contains(scannedName)) {
                              // ✅ Already in list: use it
                              speciesController.text = scannedName;
                            } else {
                              // ❌ Not in list: add and select
                              setState(() {
                                fishSpeciesList.add(scannedName);
                                speciesController.text = scannedName;
                              });
                            }
                          } else {
                            speciesController.text = "Unknown Fish";
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Scan failed: ${scanState is ScanError ? scanState.message : 'Unknown error'}",
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.search),
                      label: const Text("Scan with AI"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),
                    fishSpeciesList.isEmpty
                        ? const CircularProgressIndicator()
                        : Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.white, // dropdown background
                            dropdownMenuTheme: DropdownMenuThemeData(
                              menuStyle: MenuStyle(
                                maximumSize: MaterialStateProperty.all(
                                  const Size.fromHeight(100),
                                ), // ✅ Max height
                              ),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              value:
                                  speciesController.text.isNotEmpty
                                      ? speciesController.text
                                      : null,
                              isExpanded: true,
                              menuMaxHeight: 150,
                              decoration: const InputDecoration(
                                labelText: "Species",
                                prefixIcon: Icon(Icons.pets),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                              items:
                                  fishSpeciesList.map((species) {
                                    return DropdownMenuItem<String>(
                                      value: species,
                                      child: Text(
                                        species,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? selected) {
                                speciesController.text = selected ?? '';
                              },
                              validator: (val) {
                                if ((val == null || val.isEmpty) &&
                                    selectedImage == null) {
                                  return "Select a species or upload an image to scan";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),

                    if (scannedScientificName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Scientific name: $scannedScientificName",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // ✅ For Length & Weight (already side-by-side, just wrap in containers)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: lengthController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Length (cm)",
                                prefixIcon: Icon(Icons.straighten),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Enter length"
                                          : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: weightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Weight (kg)",
                                prefixIcon: Icon(Icons.monitor_weight),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Enter weight"
                                          : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Location Picker Box
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(
                          locationController.text.isEmpty
                              ? "Select Location"
                              : locationController.text,
                          style: TextStyle(
                            color:
                                locationController.text.isEmpty
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
                        onTap: _pickLocation,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Date & Time Side-by-Side
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_month),
                              title: Text(
                                DateFormat.yMMMMd().format(selectedDate),
                              ),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => selectedDate = picked);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.access_time),
                              title: Text(selectedTime.format(context)),
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (picked != null) {
                                  setState(() => selectedTime = picked);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text("Caught & Released"),
                      value: isReleased,
                      onChanged: (val) => setState(() => isReleased = val),
                    ),
                    const SizedBox(height: 20),
                    (isSubmitting || scanState is ScanLoading)
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                          onPressed:
                              isSubmitting
                                  ? null //disables the button
                                  : () async {
                                    setState(() => isSubmitting = true);
                                    await _submit();
                                    setState(() => isSubmitting = false);
                                  },
                          icon: const Icon(Icons.check),
                          label: const Text("Submit"),
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
