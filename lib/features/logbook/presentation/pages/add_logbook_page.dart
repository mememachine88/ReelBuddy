// logbook/presentation/pages/add_catch_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/logbook/presentation/cubits/logbook_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/logbook_entry.dart';

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final entry = LogbookEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        uid: widget.uid,
        species: speciesController.text,
        length: double.parse(lengthController.text),
        weight: double.parse(weightController.text),
        catchDate: selectedDate,
        catchTime: selectedTime,
        location: locationController.text,
        imageUrl: selectedImage?.path,
        isReleased: isReleased,
      );

      // TODO: Submit to Cubit
      print("🎣 Submitted entry: ${entry.toJson()}");
      context.read<LogbookCubit>().addEntry(entry);
      Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Catch")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🐟 Image Preview
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
                            ? Image.file(selectedImage!, fit: BoxFit.cover)
                            : const Center(
                              child: Icon(Icons.add_a_photo, size: 40),
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🐠 Fish Information
              TextFormField(
                controller: speciesController,
                decoration: const InputDecoration(
                  labelText: "Species",
                  prefixIcon: Icon(Icons.pets),
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? "Enter species" : null,
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

              // 📍 Location
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: "Location",
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? "Enter location" : null,
              ),
              const SizedBox(height: 10),

              // 📆 Date
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: Text(DateFormat.yMMMMd().format(selectedDate)),
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

              // ⏰ Time
              ListTile(
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

              // ✅ Caught & Released
              SwitchListTile(
                title: const Text("Caught & Released"),
                value: isReleased,
                onChanged: (val) => setState(() => isReleased = val),
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
