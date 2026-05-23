import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_config.dart';
import '../../models/driver.dart';
import '../../services/deliveries_api.dart';
import '../../services/delivery_api.dart';
import '../../services/drivers_api.dart';

const _numericKeyboard = TextInputType.numberWithOptions(
  decimal: true,
  signed: false,
);

final _numericInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

const _unitOptions = <({String value, String label})>[
  (value: 'kg', label: 'Kilogramos (kg)'),
  (value: 't', label: 'Toneladas métricas (t)'),
  (value: 'lb', label: 'Libras (lb)'),
  (value: 'oz', label: 'Onzas (oz)'),
  (value: 'ton_us', label: 'Tonelada corta US (ton)'),
  (value: 'L', label: 'Litros (L)'),
  (value: 'mL', label: 'Mililitros (mL)'),
  (value: 'm3', label: 'Metros cúbicos (m³)'),
  (value: 'fl_oz', label: 'Onzas líquidas US (fl oz)'),
  (value: 'gal', label: 'Galones US (gal)'),
  (value: 'qt', label: 'Cuartos US (qt)'),
  (value: 'pt', label: 'Pintas US (pt)'),
  (value: 'pza', label: 'Piezas'),
  (value: 'caja', label: 'Cajas'),
  (value: 'bulto', label: 'Bultos'),
  (value: 'saco', label: 'Sacos'),
  (value: 'pallet', label: 'Pallets'),
];

class CreateTripPage extends StatefulWidget {
  final String? deliveryId;

  const CreateTripPage({super.key, this.deliveryId});

  bool get isEditing => deliveryId != null;

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinyController = TextEditingController();
  final _receiverController = TextEditingController();
  final _itemsController = TextEditingController();
  final _quantityController = TextEditingController();
  final _cargoValueController = TextEditingController();
  final _distanceController = TextEditingController();

  final _deliveriesApi = DeliveriesApi(baseUri: AppConfig.apiBaseUri);
  final _deliveryApi = DeliveryApi(baseUri: AppConfig.apiBaseUri);
  final _driversApi = DriversApi(baseUri: AppConfig.apiBaseUri);

  late Future<List<Driver>> _driversFuture;
  String? _selectedDriverId;
  String? _initialDriverId;
  String? _selectedUnity;
  bool _loadingTrip = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _driversFuture = _driversApi.listDrivers();
    if (widget.isEditing) {
      _loadingTrip = true;
      _loadTrip();
    }
  }

  Future<void> _loadTrip() async {
    try {
      final trip =
          await _deliveryApi.getDelivery(widget.deliveryId!);
      if (!mounted) return;
      _originController.text = trip.origin;
      _destinyController.text = trip.destiny;
      _receiverController.text = trip.receiverName;
      _itemsController.text = trip.itemsDescription;
      if (trip.quantity != null) {
        _quantityController.text = trip.quantity.toString();
      }
      if (trip.cargoValue != null) {
        _cargoValueController.text = trip.cargoValue.toString();
      }
      if (trip.distance != null) {
        _distanceController.text = trip.distance.toString();
      }
      if (trip.unity.isNotEmpty) {
        _selectedUnity = trip.unity;
      }
      _initialDriverId = trip.assignedTo;
      _selectedDriverId = trip.assignedTo;
      setState(() => _loadingTrip = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingTrip = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar el viaje: $e')),
      );
      Navigator.pop(context);
    }
  }

  List<DropdownMenuItem<String>> _unityDropdownItems() {
    final knownValues = _unitOptions.map((u) => u.value).toSet();
    final items = _unitOptions
        .map(
          (u) => DropdownMenuItem(
            value: u.value,
            child: Text(u.label),
          ),
        )
        .toList(growable: true);

    if (_selectedUnity != null &&
        _selectedUnity!.isNotEmpty &&
        !knownValues.contains(_selectedUnity)) {
      items.insert(
        0,
        DropdownMenuItem(
          value: _selectedUnity,
          child: Text(_selectedUnity!),
        ),
      );
    }
    return items;
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinyController.dispose();
    _receiverController.dispose();
    _itemsController.dispose();
    _quantityController.dispose();
    _cargoValueController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', '.'));
  }

  Map<String, dynamic> _buildPayload() {
    final body = <String, dynamic>{
      'origin': _originController.text.trim(),
      'destiny': _destinyController.text.trim(),
      'receiver_name': _receiverController.text.trim(),
      'items_description': _itemsController.text.trim(),
      'unity': _selectedUnity ?? '',
    };

    final quantity = _parseDouble(_quantityController.text);
    if (quantity != null) body['quantity'] = quantity;

    final cargoValue = _parseDouble(_cargoValueController.text);
    if (cargoValue != null) body['cargo_value'] = cargoValue;

    final distance = _parseDouble(_distanceController.text);
    if (distance != null) body['distance'] = distance;

    return body;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDriverId == null || _selectedDriverId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un repartidor')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      if (widget.isEditing) {
        await _deliveryApi.updateDelivery(
          widget.deliveryId!,
          _buildPayload(),
        );
        if (_selectedDriverId != _initialDriverId) {
          await _deliveryApi.assignDelivery(
            widget.deliveryId!,
            _selectedDriverId!,
          );
        }
      } else {
        final body = _buildPayload()..['assigned_to'] = _selectedDriverId;
        await _deliveriesApi.createDelivery(body);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'No se pudo actualizar el viaje: $e'
                : 'No se pudo crear el viaje: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingTrip) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Editar viaje' : 'Nuevo viaje'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar viaje' : 'Nuevo viaje'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Datos del viaje',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _originController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Origen',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa el origen' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _destinyController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Destino',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa el destino' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _distanceController,
              keyboardType: _numericKeyboard,
              inputFormatters: _numericInputFormatters,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Distancia (km)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mercancía',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _itemsController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Ingresa la descripción'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              keyboardType: _numericKeyboard,
              inputFormatters: _numericInputFormatters,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedUnity,
              decoration: const InputDecoration(
                labelText: 'Unidad',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Selecciona una unidad'),
              items: _unityDropdownItems(),
              onChanged: _submitting
                  ? null
                  : (value) => setState(() => _selectedUnity = value),
              validator: (_) =>
                  _selectedUnity == null ? 'Selecciona una unidad' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cargoValueController,
              keyboardType: _numericKeyboard,
              inputFormatters: _numericInputFormatters,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Valor de carga',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Receptor',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _receiverController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre del receptor',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Ingresa el nombre del receptor'
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              'Asignación',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Driver>>(
              future: _driversFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No se pudieron cargar los repartidores.'),
                      const SizedBox(height: 8),
                      Text(snapshot.error.toString()),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _driversFuture = _driversApi.listDrivers();
                          });
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  );
                }

                final drivers = snapshot.data ?? const <Driver>[];
                if (drivers.isEmpty) {
                  return const Text(
                    'No hay repartidores registrados. Crea usuarios con rol DELIVER antes de asignar.',
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedDriverId,
                  decoration: const InputDecoration(
                    labelText: 'Repartidor',
                    border: OutlineInputBorder(),
                  ),
                  items: drivers
                      .map(
                        (d) => DropdownMenuItem(
                          value: d.id,
                          child: Text(
                            d.name.isEmpty ? d.id : d.name,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _selectedDriverId = value),
                  validator: (_) => _selectedDriverId == null
                      ? 'Selecciona un repartidor'
                      : null,
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.isEditing
                            ? 'Guardar cambios'
                            : 'Crear y asignar viaje',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
