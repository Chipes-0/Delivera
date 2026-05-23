import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../models/delivery_summary.dart';
import '../../services/deliveries_api.dart';
import '../../session.dart';
import '../../widgets/trip_summary_tile.dart';
import '../login.dart';
import '../reports/completed_trips.dart';
import 'create_trip.dart';
import 'trip_detail.dart';

class TripsHomePage extends StatefulWidget {
  const TripsHomePage({super.key});

  @override
  State<TripsHomePage> createState() => _TripsHomePageState();
}

class _TripsHomePageState extends State<TripsHomePage> {
  final _api = DeliveriesApi(baseUri: AppConfig.apiBaseUri);

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
      floatingActionButton: Session.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateTripPage()),
                );
                if (created == true && mounted) {
                  await _refresh();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viaje creado y asignado')),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo viaje'),
            )
          : null,
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
              if (Session.isAdmin)
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
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  Navigator.pop(context);
                  await Session.clear();
                  if (!context.mounted) return;
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false,
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
                    Session.isDriver
                        ? 'No tienes viajes asignados.'
                        : 'No hay viajes para mostrar.',
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
                return TripSummaryTile(
                  trip: trip,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripDetailPage(deliveryId: trip.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

