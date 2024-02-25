import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: FutureBuilder.debugRethrowError,
      home: LeadListScreen(),
    );
  }
}

class LeadListScreen extends StatefulWidget {
  @override
  _LeadListScreenState createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  final TextEditingController _filterController = TextEditingController();
  List<Lead> _leads = [];
  List<Lead> _filteredLeads = [];

  @override
  void initState() {
    super.initState();
    _getLeads();
  }

  Future<void> _getLeads() async {
    const apiUrl = 'https://api.thenotary.app/lead/getLeads';
    final requestBody = {'notaryId': '643074200605c500112e0902'};

    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );
    print('API response: ${response.body}');
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['leads'] != null) {
        List<dynamic> leadsData = jsonResponse['leads'];

        setState(() {
          _leads = leadsData.map((lead) => Lead.fromJson(lead)).toList();
          _filteredLeads = List.from(_leads);
        });
      } else {
        // Handle null or unexpected response
        print('API response: ${response.body}');
      }
    } else {
      // Handle errors
      print('Failed to load leads. Error: ${response.statusCode}');
    }
  }

  void _filterLeads(String keyword) {
    setState(() {
      _filteredLeads = _leads
          .where((lead) =>
              lead.fullName.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Tutorial'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'List view search',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _filterController,
              onChanged: (value) {
                _filterLeads(value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _filterController.clear();
                    _filterLeads('');
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLeads.length,
              itemBuilder: (context, index) {
                final lead = _filteredLeads[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Colors.blue,
                      child: Text(
                        lead.firstName.isNotEmpty ? lead.firstName[0].toUpperCase() : '',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(lead.firstName),
                    subtitle: Text('City: ${lead.city}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Lead {
  final String firstName;
  final String lastName;
  final String city;

  Lead({required this.firstName, required this.lastName, required this.city});

  String get fullName => '$firstName $lastName';

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      firstName: json['firstName'],
      lastName: json['lastName'],
      city: json['city'],
    );
  }
}
