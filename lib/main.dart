import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const HairCareApp());
}

class HairCareApp extends StatelessWidget {
  const HairCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hair Care Assistant',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HairInputScreen(),
    );
  }
}

class HairInputScreen extends StatefulWidget {
  const HairInputScreen({super.key});

  @override
  State<HairInputScreen> createState() => _HairInputScreenState();
}

class _HairInputScreenState extends State<HairInputScreen> {
  final TextEditingController _issuesController = TextEditingController();
  String _schedule = "";
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _generateSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    String userIssues = _issuesController.text;

    // --- Call GPT API ---
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer YOUR_OPENAI_API_KEY"
      },
      body: json.encode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": "You are a hair care assistant. Create weekly schedules."
          },
          {
            "role": "user",
            "content":
                "Create a 1-week hair care schedule for: $userIssues. Give simple day-wise plan."
          }
        ],
        "max_tokens": 300
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String scheduleText =
          data["choices"][0]["message"]["content"] ?? "Error generating schedule";

      setState(() {
        _schedule = scheduleText;
      });

      prefs.setString("schedule", scheduleText);

      // Example notification
      _notificationsPlugin.show(
        0,
        "Hair Care Reminder",
        "Don’t forget your first step today!",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            "hair_channel",
            "Hair Care",
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } else {
      setState(() {
        _schedule = "Failed to get schedule. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hair Care Assistant")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _issuesController,
              decoration: const InputDecoration(
                labelText: "Enter your hair issues",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateSchedule,
              child: const Text("Generate Schedule"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_schedule),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
