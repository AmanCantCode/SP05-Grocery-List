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

  void _showCreateOrJoinDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // tap outside to close
      barrierColor: Colors.black54, // dim background
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOptionButton(
                  text: 'Create New Group',
                  onPressed: () {
                    Navigator.pop(context);
                    _createGroup();
                  },
                ),
                const SizedBox(height: 15),
                _buildOptionButton(
                  text: 'Join a Group',
                  onPressed: () {
                    Navigator.pop(context);
                    _joinGroup();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildOptionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 400,
      height: 75,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFAAEA61),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(
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
      body: ListView(
        children: [
          SizedBox(height: 5,),
          SizedBox(
            width: 195,
            height: 120,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showCreateOrJoinDialog,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _showCreateOrJoinDialog,
                  child: Center(
                    child: Text(
                      'Start a new family!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              ),
            ),
          ),

          // --- Group List ---
          if (_groups.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text('No groups yet')),
            )
          else
            ..._groups.map((group) {
              return SizedBox(
                width: 195,
                height: 120,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAAEA61),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // child: ListTile(
                  //   title: Text(
                  //     group['name'],
                  //     style: const TextStyle(
                  //       fontFamily: 'Poppins',
                  //       fontSize: 25,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.black87,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  //   onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (_) => GroupPage(group: group),
                  //     ),
                  //   ),
                  // ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12), // matches container
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupPage(group: group),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        group['name'],
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),

    );
  }
}
