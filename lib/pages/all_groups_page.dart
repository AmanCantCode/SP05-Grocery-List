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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text(
          'Create Group',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEEEEEE),
            hintText: 'Group name',
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Color(0xFF6E6E6E),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF6E6E6E),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),

          ElevatedButton(
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
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      title: const Text(
                        'Group Created!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Share this code with your friends:',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF333333)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$code',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFAAEA61), // Green for emphasis
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchGroups();
                          },
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
              } catch (e) {
                _showSnackbar('Error creating group: ${e.toString()}');
                debugPrint("Error creating group: $e");
                if(mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF333333),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Create',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinGroup() async {
    final codeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text(
          'Join Group',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEEEEEE),
            hintText: 'Enter Invite Code',
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Color(0xFF6E6E6E),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF6E6E6E),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              final codeText = codeController.text.trim();
              if (codeText.isEmpty) {
                // Assuming _showSnackbar is available
                _showSnackbar('Please enter an invite code.');
                return;
              }

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

                final groupResponse = await supabase
                    .from('groups')
                    .select('id')
                    .eq('invite_code', codeValue)
                    .maybeSingle();

                if (groupResponse == null) {
                  _showSnackbar('No group found with that invite code.');
                  return;
                }

                final groupId = groupResponse['id'] as String;

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

                await supabase.from('group_members').insert({
                  'group_id': groupId,
                  'user_id': currentUser.id,
                  'role': 'member',
                });

                _showSnackbar('Successfully joined the group! 🎉');
                if (mounted) Navigator.pop(context);
                await _fetchGroups();
              } catch (error) {
                _showSnackbar('Error joining group: $error');
                debugPrint('Error joining group: $error');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF333333),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Join',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateOrJoinDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Group Options',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _createGroup();
                    },
                    child: const Text(
                      'Create New Group',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAAEA61),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _joinGroup();
                    },
                    child: const Text(
                      'Join a Group',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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

          if (_groups.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                  child:
                  Text('No groups yet',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 25,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF333333),
                    ),
                  )
              ),
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
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
