import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _apiUrl = "https://api.calorieninjas.com/v1/nutrition";
String get _apiKey => dotenv.env['CAL_API_KEY'] ?? '';

// Simple data class to hold fetched nutrition information
class NutritionData {
  final String name;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double sugarG;
  final double fiberG;
  final double sodiumMg;

  NutritionData.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? 'N/A',
        calories = (json['calories'] as num?)?.toDouble() ?? 0.0,
        proteinG = (json['protein_g'] as num?)?.toDouble() ?? 0.0,
        carbsG = (json['carbohydrates_total_g'] as num?)?.toDouble() ?? 0.0,
        fatG = (json['fat_total_g'] as num?)?.toDouble() ?? 0.0,
        sugarG = (json['sugar_g'] as num?)?.toDouble() ?? 0.0,
        fiberG = (json['fiber_g'] as num?)?.toDouble() ?? 0.0,
        sodiumMg = (json['sodium_mg'] as num?)?.toDouble() ?? 0.0;
}

// --- NUTRITION SCREEN (The page content, ready for navigation) ---
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final TextEditingController _queryController = TextEditingController();
  List<NutritionData>? _results;
  bool _isLoading = false;
  String? _errorMessage;

  // --- Network Request Logic ---
  Future<void> _getNutrition() async {
    final query = _queryController.text.trim();

    final apiKey = _apiKey;

    if (query.isEmpty) {
      setState(() => _errorMessage = 'Please enter a food item to search.');
      return;
    }

    // API key check is simplified since a key is now provided
    if (apiKey.isEmpty) {
      setState(() => _errorMessage = 'API Key is missing.');
      return;
    }

    setState(() {
      _isLoading = true;
      _results = null;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('$_apiUrl?query=${Uri.encodeComponent(query)}');
      final response = await http.get(
        uri,
        headers: {"X-Api-Key": apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        if (items.isEmpty) {
          setState(() => _errorMessage = 'No nutrition data found for "$query".');
        } else {
          setState(() {
            _results = items.map((item) => NutritionData.fromJson(item)).toList();
          });
        }
      } else {
        setState(() {
          _errorMessage = 'API Error: ${response.statusCode}. Please try again.';
          debugPrint('API Error Body: ${response.body}');
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network Error: Could not connect.');
      debugPrint('Exception: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Helper widget to display a single nutrition row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF333333)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
          ),
        ],
      ),
    );
  }

  // Widget to display the full nutrition card, styled like the GroupPage items
  Widget _buildResultCard(NutritionData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFAAEA61), // Light green background from GroupPage
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.name.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333), // Dark text color
              ),
            ),
            // Subtler divider to fit the theme
            const Divider(height: 20, thickness: 1, color: Color(0xFFE5F5C0)),

            _buildInfoRow('Calories', '${data.calories.toStringAsFixed(1)} kcal'),
            _buildInfoRow('Protein', '${data.proteinG.toStringAsFixed(1)} g'),
            _buildInfoRow('Carbs', '${data.carbsG.toStringAsFixed(1)} g'),
            _buildInfoRow('Fat', '${data.fatG.toStringAsFixed(1)} g'),

            const Divider(height: 20, thickness: 1, color: Color(0xFFE5F5C0)),

            _buildInfoRow('Sugar', '${data.sugarG.toStringAsFixed(1)} g'),
            _buildInfoRow('Fiber', '${data.fiberG.toStringAsFixed(1)} g'),
            _buildInfoRow('Sodium', '${data.sodiumMg.toStringAsFixed(0)} mg'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        backgroundColor: const Color(0xFFAAEA61),
        title: Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
          child: Image.asset('assets/images/Logo.png',
            width: 50,
            height: 50,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Search Input ---
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _queryController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Search food item",
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: Color(0xFF1B1B1B),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onFieldSubmitted: (_) => _getNutrition(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _getNutrition,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero, // ensures no weird spacing
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      //child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Center(
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                )

              ],
            ),
            const SizedBox(height: 20),

            // --- Results / Status Area ---
            if (_isLoading && _results == null)
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Fetching nutrition data...', style: TextStyle(color: Color(0xFF6E6E6E))),
                  ],
                ),
              ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

            // --- Nutrition Results List ---
            if (_results != null && _results!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results!.length,
                  itemBuilder: (context, index) {
                    return _buildResultCard(_results![index]);
                  },
                ),
              ),

            if (_results == null && !_isLoading && _errorMessage == null)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Text(
                  'Search for a food item \nto see its nutrition breakdown.'
                      '\n\nTip: Include amounts like \n“2 eggs” or “1 cup rice”.'
                      '\n\nIf no amount is given,\n results are for 100g.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter',fontSize: 18, color: Color(0xFF6E6E6E)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}
