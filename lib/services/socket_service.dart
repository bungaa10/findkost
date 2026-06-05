import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  SocketService._internal();
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  io.Socket? _socket;
  bool _isConnected = false;
  String? _serverUrl;

  bool get isConnected => _isConnected;

  // Callbacks
  void Function(Map<String, dynamic>)? onBookingNotification;
  void Function(Map<String, dynamic>)? onBookingStatusUpdate;
  void Function()? onConnected;
  void Function()? onDisconnected;

  void connect({required String serverUrl}) {
    _serverUrl = serverUrl;

    if (_socket != null && _socket!.connected) {
      log('Socket already connected');
      onConnected?.call();
      return;
    }

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      log('✅ Socket connected: ${_socket!.id}');
      _isConnected = true;
      onConnected?.call();
    });

    _socket!.onDisconnect((_) {
      log('❌ Socket disconnected');
      _isConnected = false;
      onDisconnected?.call();
    });

    _socket!.onConnectError((data) {
      log('⚠️ Socket connect error: $data');
      _isConnected = false;
    });

    _socket!.onError((data) {
      log('⚠️ Socket error: $data');
    });
  }

  void registerUser({
    required int userId,
    required String userName,
    required String role,
  }) {
    if (_socket == null || !_isConnected) {
      log('⚠️ Cannot register: socket not connected');
      return;
    }

    _socket!.emit('register:user', {
      'userId': userId,
      'userName': userName,
      'role': role,
    });
    log('📝 User registered: $userName ($role)');

    // Set listeners setelah register
    _setupListeners();
  }

  void _setupListeners() {
    if (_socket == null) return;

    _socket!.off('booking:notification');
    _socket!.on('booking:notification', (data) {
      log('📨 Booking notification received: $data');
      if (data is Map) {
        onBookingNotification?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.off('booking:status_update');
    _socket!.on('booking:status_update', (data) {
      log('📨 Booking status update received: $data');
      if (data is Map) {
        onBookingStatusUpdate?.call(Map<String, dynamic>.from(data));
      }
    });
  }

  void sendBookingNotification({
    required int kostId,
    required String kostName,
    required int ownerId,
    required String studentName,
    required int bookingId,
    String message = 'Ada booking baru!',
  }) {
    if (_socket == null || !_isConnected) {
      log('⚠️ Cannot send notification: socket not connected');
      return;
    }

    _socket!.emit('booking:new', {
      'kostId': kostId,
      'kostName': kostName,
      'ownerId': ownerId,
      'studentName': studentName,
      'bookingId': bookingId,
      'message': message,
    });
    log('📤 Booking notification sent to owner $ownerId');
  }

  void sendBookingConfirm({
    required int bookingId,
    required int studentId,
    required String status,
    String message = 'Status booking Anda diperbarui',
  }) {
    if (_socket == null || !_isConnected) {
      log('⚠️ Cannot send confirm: socket not connected');
      return;
    }

    _socket!.emit('booking:confirm', {
      'bookingId': bookingId,
      'studentId': studentId,
      'status': status,
      'message': message,
    });
    log('📤 Booking confirm sent to student $studentId: $status');
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
  }
}