import 'package:flutter/material.dart';

import '../../models/delivery_summary.dart';
import '../../services/deliveries_api.dart';
import '../reports/completed_trips.dart';
import 'trip_detail.dart';

class TripsHomePage extends StatefulWidget {
  const TripsHomePage({super.key});

  @override
  State<TripsHomePage> createState() => _TripsHomePageState();
}

class _TripsHomePageState extends State<TripsHomePage> {
  // Ajusta el host/puerto según donde corre tu backend.
  // Si pruebas en Android emulator: http://10.0.2.2:8000
  // Si pruebas en iOS simulator: http://localhost:8000
  final _api = DeliveriesApi(baseUri: Uri.parse('http://10.0.2.2:8000'));

  late Future<List<DeliverySummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.listDeliveries();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.listDeliveries();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                title: Text(
                  'Delivera',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text('Viajes'),
                selected: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart_outlined),
                title: const Text('Reportes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CompletedTripsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<DeliverySummary>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'No se pudieron cargar los viajes.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Reintentar'),
                  ),
                ],
              );
            }

            final trips = snapshot.data ?? const <DeliverySummary>[];
            if (trips.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'No hay viajes para mostrar.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Desliza hacia abajo para recargar.'),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = trips[index];
                final status = trip.status.isEmpty ? '—' : trip.status;
                return Card(
                  elevation: 1,
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: const Icon(Icons.route_outlined),
                    title: Text('Viaje ${trip.id}'),
                    subtitle: Text('Status: $status'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TripDetailPage(deliveryId: trip.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

