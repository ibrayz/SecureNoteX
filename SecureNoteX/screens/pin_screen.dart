import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class PINScreen extends StatefulWidget {
  const PINScreen({super.key});

  @override
  State<PINScreen> createState() => _PINScreenState();
}

class _PINScreenState extends State<PINScreen> with SingleTickerProviderStateMixin {
  String _enteredPIN = '';
  bool _isSettingPIN = false;
  String _firstPIN = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _checkIfSettingPIN();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkIfSettingPIN() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('app_pin');
    setState(() {
      _isSettingPIN = pin == null || pin.isEmpty;
    });
  }

  void _onNumberPressed(String number) {
    if (_enteredPIN.length < 4) {
      setState(() {
        _enteredPIN += number;
      });

      if (_enteredPIN.length == 4) {
        _handlePINComplete();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPIN.isNotEmpty) {
      setState(() {
        _enteredPIN = _enteredPIN.substring(0, _enteredPIN.length - 1);
      });
    }
  }

  Future<void> _handlePINComplete() async {
    if (_isSettingPIN) {
      // İlk defa PIN oluşturuluyor - direkt kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_pin', _enteredPIN);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // Giriş yapılıyor - PIN kontrolü
      final prefs = await SharedPreferences.getInstance();
      final savedPIN = prefs.getString('app_pin');
      if (_enteredPIN == savedPIN) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        _shakeController.forward(from: 0);
        setState(() {
          _enteredPIN = '';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Yanlış PIN'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                _isSettingPIN ? 'PIN Oluştur (4 haneli)' : 'PIN Gir',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _enteredPIN.length
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 64),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildNumberRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildNumberRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildNumberRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 72),
                        _buildNumberButton('0'),
                        IconButton(
                          onPressed: _onDeletePressed,
                          icon: const Icon(Icons.backspace_outlined, color: Colors.white),
                          iconSize: 32,
                        ),
                      ],
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

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) => _buildNumberButton(number)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}