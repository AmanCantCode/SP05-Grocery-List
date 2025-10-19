import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'group_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> _groups = [];

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('group_members')
        .select('groups(id, name, invite_code)')
        .eq('user_id', userId);

    setState(() {
      _groups = response.map((e) => e['groups']).toList();
    });
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // --- Create Group Logic ---
  Future<void> _createGroup() async {
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Group name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final code = DateTime.now().millisecondsSinceEpoch;

              try {
                await supabase.rpc(
                  'create_new_group_and_admin',
                  params: {
                    'group_name': name,
                    'invite_code_val': code,
                  },
                ).select().single();

                if (mounted) Navigator.pop(context);

                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Group Created!'),
                      content: Text('Invite Code: $code'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchGroups();
                          },
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                }
              } catch (e) {
                _showSnackbar('Error creating group: ${e.toString()}');
                debugPrint("Error creating group: $e");
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // --- Join Group Logic ---
  Future<void> _joinGroup() async {
    final codeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Join Group'),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter Invite Code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final codeText = codeController.text.trim();
              if (codeText.isEmpty) {
                _showSnackbar('Please enter an invite code.');
                return;
              }

              // Convert to int for bigint column
              final codeValue = int.tryParse(codeText);
              if (codeValue == null) {
                _showSnackbar('Invalid invite code format.');
                return;
              }

              try {
                final currentUser = supabase.auth.currentUser;
                if (currentUser == null) {
                  _showSnackbar('You must be logged in to join a group.');
                  return;
                }

                // 1. Check if group exists
                final groupResponse = await supabase
                    .from('groups')
                    .select('id')
                    .eq('invite_code', codeValue)
                    .maybeSingle();

                debugPrint('Group Query Response: $groupResponse');

                if (groupResponse == null) {
                  _showSnackbar('No group found with that invite code.');
                  return;
                }

                final groupId = groupResponse['id'] as String;

                // 2. Check if user is already in group
                final existingMember = await supabase
                    .from('group_members')
                    .select()
                    .eq('group_id', groupId)
                    .eq('user_id', currentUser.id)
                    .maybeSingle();

                if (existingMember != null) {
                  _showSnackbar('You are already a member of this group.');
                  return;
                }

                // 3. Add user to group
                await supabase.from('group_members').insert({
                  'group_id': groupId,
                  'user_id': currentUser.id,
                  'role': 'member',
                });

                _showSnackbar('Successfully joined the group!');
                if (mounted) Navigator.pop(context);
                await _fetchGroups();
              } catch (error) {
                _showSnackbar('Error joining group: $error');
                debugPrint('Error joining group: $error');
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  // --- Bottom Sheet for Create/Join ---
  void _showCreateOrJoinSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Create New Group'),
              onTap: () {
                Navigator.pop(context);
                _createGroup();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Join Group with Code'),
              onTap: () {
                Navigator.pop(context);
                _joinGroup();
              },
            ),
          ],
        );
      },
    );
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Groups')),
      body: _groups.isEmpty
          ? const Center(child: Text('No groups yet'))
          : ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          return ListTile(
            title: Text(group['name']),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupPage(group: group),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOrJoinSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
