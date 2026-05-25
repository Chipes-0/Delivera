/// Base URL del API (sin barra final).
/// Android emulator: `http://10.0.2.2:PUERTO`
/// iOS simulator: `http://localhost:PUERTO`
/// Dispositivo físico: IP de tu PC, p. ej. `http://192.168.1.10:8000`
class AppConfig {
  static final Uri apiBaseUri = Uri.parse('http://10.0.2.2:8000');
}
