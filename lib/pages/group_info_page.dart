import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Needed for Clipboard
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupInfoPage extends StatefulWidget {
  final Map<String, dynamic> group;
  const GroupInfoPage({super.key, required this.group});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> members = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  // Fetch group members using the RPC function
  Future<void> _fetchMembers() async {
    final data = await supabase.rpc(
      'get_group_members_info',
      params: {'target_group_id': widget.group['id']},
    );
    setState(() => members = data);
  }

  // ✅ Copy invite code to clipboard
  Future<void> _copyInviteCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite code copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inviteCode = widget.group['invite_code'];

    return Scaffold(
      appBar: AppBar(title: const Text('Group Info')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invite Code Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Invite Code:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        inviteCode.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.blue),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 22, color: Colors.grey),
                      onPressed: () => _copyInviteCode(inviteCode.toString()),
                      tooltip: 'Copy Code',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Members Header
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 10, bottom: 8),
            child: Text(
              'Members:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Members List
          Expanded(
            child: members.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: members.length,
              itemBuilder: (_, i) {
                final member = members[i];
                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(member['email']),
                  subtitle: Text('Role: ${member['role']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

