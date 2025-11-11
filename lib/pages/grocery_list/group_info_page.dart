import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _currentUserRole = 'member'; // Default to member

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  // Fetch group members and determine the current user's role
  Future<void> _fetchMembers() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase.rpc(
      'get_group_members_info',
      params: {'target_group_id': widget.group['id']},
    );

    // Determine user role from the fetched list
    final currentUserMember = data.firstWhere(
          (m) => m['user_id'] == userId,
      orElse: () => null,
    );

    setState(() {
      members = data;
      if (currentUserMember != null) {
        // Update the role state
        _currentUserRole = currentUserMember['role'] ?? 'member';
      }
    });
  }

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

  Future<void> _deleteGroup() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text(
          'Delete Group',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this group? All items and memberships will be permanently deleted.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
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
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6666), // Red accent
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await supabase.rpc(
          'delete_group_and_data',
          params: {'target_group_id': widget.group['id']},
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Group deleted successfully!')),
          );
          Navigator.pop(context, true);
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting group: ${e.toString()}')),
          );
        }
        debugPrint('Delete Group Error: $e');
      }
    }
  }

  Future<void> _leaveGroup() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text(
          'Leave Group',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: const Text(
          'Are you sure you want to leave this group? You will lose access to the list.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
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
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6666), // Red accent
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Leave',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await supabase
            .from('group_members')
            .delete()
            .eq('group_id', widget.group['id'])
            .eq('user_id', supabase.auth.currentUser!.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully left the group!')),
          );
          Navigator.pop(context, true);
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error leaving group: ${e.toString()}')),
          );
        }
        debugPrint('Leave Group Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inviteCode = widget.group['invite_code'];
    final isAdmin = _currentUserRole == 'admin'; // Determine admin status

    return Scaffold(
      appBar:
      AppBar(
        toolbarHeight: 70.0,
        title: const
        Text('Group Info',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        backgroundColor: const Color(0xFFAAEA61),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333), size: 30,),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invite Code Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              color: const Color(0xFF333333),
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
                      style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        inviteCode.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.normal, color: Colors.blue),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 22, color: Colors.white),
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
                final isCurrentUser = member['user_id'] == supabase.auth.currentUser!.id;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Spacing between boxes
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFAAEA61), // Green Box Color
                      borderRadius: BorderRadius.circular(10), // Border Radius
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Color(0xFF333333)), // Dark icon for contrast
                      title: Text(
                        member['display_name'] ?? member['email'],
                        style: TextStyle(
                          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                          color: const Color(0xFF333333), // Dark text
                        ),
                      ),
                      subtitle: Text(
                        'Role: ${member['role']} ${isCurrentUser ? '(You)' : ''}',
                        style: const TextStyle(
                          color: Color(0xFF333333), // Dark text
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          //conditional Action Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: isAdmin
                  ? //delete group button
              ElevatedButton(
                onPressed: _deleteGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6666),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('DELETE GROUP', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
              )
                  : //leave group button
              ElevatedButton(
                onPressed: _leaveGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF333333),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('LEAVE GROUP', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}