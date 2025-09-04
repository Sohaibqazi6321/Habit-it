import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Account'),
            subtitle: Text('Sign in for cloud sync'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.cloud_off_outlined),
            title: Text('Cloud Sync'),
            subtitle: Text('Disabled'),
            trailing: Switch(value: false, onChanged: null),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.file_download_outlined),
            title: Text('Export Data'),
            subtitle: Text('CSV export (Pro)'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Themes'),
            subtitle: Text('Pro feature'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Terms of Service'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Delete Account'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
