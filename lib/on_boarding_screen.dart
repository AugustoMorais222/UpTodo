import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_page.dart';
import 'on_boarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Organize suas tarefas',
      'subtitle': 'Crie listas e mantenha o foco no que importa.',
      'image': '../assets/onboard-001.png'
    },
    {
      'title': 'Crie rotinas diárias',
      'subtitle': 'Defina hábitos saudáveis e cumpra suas metas.',
      'image': '../assets/onboard-002.png'
    },
    {
      'title': 'Acompanhe seu progresso',
      'subtitle': 'Visualize seu desempenho e conquistas.',
      'image': '../assets/onboard-003.png'
    },
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (_, index) => OnboardingPage(
              title: _pages[index]['title']!,
              subtitle: _pages[index]['subtitle']!,
              image: _pages[index]['image']!,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.blue
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _currentPage == _pages.length - 1
                      ? _finishOnboarding
                      : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Começar'
                        : 'Próximo',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                Container( height: 10),
                ElevatedButton(
                  onPressed: () => {
                    _finishOnboarding()
                  }, 
                  child: const Text('Pular')
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
