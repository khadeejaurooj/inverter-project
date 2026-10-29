import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/app_theme.dart';
import '../ui/form_widgets.dart';
import '../ui/widgets.dart';
import '../viewmodel/add_device_viewmodel.dart';

class AddDeviceScreen extends StatelessWidget {
  final TextEditingController macController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  AddDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddDeviceViewModel>(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Add Device")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  IconBadge(
                      icon: Icons.add_circle_outline_rounded,
                      color: AppColors.primary,
                      size: 48),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Register a new inverter by its MAC address and give it a name you will recognise.",
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: macController,
                      decoration: const InputDecoration(
                        labelText: "MAC Address",
                        hintText: "AA:BB:CC:DD:EE:FF",
                        prefixIcon: Icon(Icons.lan_outlined),
                      ),
                      onChanged: (value) {
                        viewModel.clearMessage(); // Clears error when typing
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Inverter Name",
                        hintText: "e.g. Rooftop Inverter",
                        prefixIcon: Icon(Icons.label_outline_rounded),
                      ),
                      onChanged: (value) {
                        viewModel.clearMessage(); // Clears error when typing
                      },
                    ),
                    if (viewModel.message != null) ...[
                      const SizedBox(height: 16),
                      MessageBanner(
                        text: viewModel.message!,
                        isError:
                            viewModel.message != "Device added successfully!",
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              bool success = await viewModel.addDevice(
                                macController.text.trim(),
                                nameController.text.trim(),
                              );

                              if (success) {
                                Navigator.pop(
                                    context, true); // Return success to refresh
                              }
                            },
                      icon: viewModel.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.onPrimary),
                            )
                          : const Icon(Icons.add_rounded),
                      label: const Text("Add Device"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
