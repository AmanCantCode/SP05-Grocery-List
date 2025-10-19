// // // import 'package:flutter/material.dart';
// // // import 'package:supabase_flutter/supabase_flutter.dart';
// // //
// // // class GroupInfoPage extends StatefulWidget {
// // //   final Map<String, dynamic> group;
// // //   const GroupInfoPage({super.key, required this.group});
// // //
// // //   @override
// // //   State<GroupInfoPage> createState() => _GroupInfoPageState();
// // // }
// // //
// // // class _GroupInfoPageState extends State<GroupInfoPage> {
// // //   final supabase = Supabase.instance.client;
// // //   List<dynamic> members = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchMembers();
// // //   }
// // //
// // //   Future<void> _fetchMembers() async {
// // //     final data = await supabase
// // //         .from('group_members')
// // //         .select('user_id, role, users(email)')
// // //         .eq('group_id', widget.group['id']);
// // //     setState(() => members = data);
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Group Info')),
// // //       body: members.isEmpty
// // //           ? const Center(child: CircularProgressIndicator())
// // //           : ListView.builder(
// // //         itemCount: members.length,
// // //         itemBuilder: (_, i) {
// // //           final member = members[i];
// // //           return ListTile(
// // //             title: Text(member['users']['email']),
// // //             subtitle: Text('Role: ${member['role']}'),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// //
// // class GroupInfoPage extends StatefulWidget {
// //   final Map<String, dynamic> group;
// //   const GroupInfoPage({super.key, required this.group});
// //
// //   @override
// //   State<GroupInfoPage> createState() => _GroupInfoPageState();
// // }
// //
// // class _GroupInfoPageState extends State<GroupInfoPage> {
// //   final supabase = Supabase.instance.client;
// //   List<dynamic> members = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchMembers();
// //   }
// //
// //   Future<void> _fetchMembers() async {
// //     // Call the database function to fetch the member list securely
// //     final data = await supabase.rpc(
// //       'get_group_members_info',
// //       params: {
// //         'target_group_id': widget.group['id'],
// //       },
// //     );
// //
// //     setState(() => members = data);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Group Info')),
// //       body: members.isEmpty
// //           ? const Center(child: CircularProgressIndicator())
// //           : ListView.builder(
// //         itemCount: members.length,
// //         itemBuilder: (_, i) {
// //           final member = members[i];
// //           return ListTile(
// //             title: Text(member['email']), // Use the simple 'email' key
// //             subtitle: Text('Role: ${member['role']}'),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class GroupInfoPage extends StatefulWidget {
//   final Map<String, dynamic> group;
//   const GroupInfoPage({super.key, required this.group});
//
//   @override
//   State<GroupInfoPage> createState() => _GroupInfoPageState();
// }
//
// class _GroupInfoPageState extends State<GroupInfoPage> {
//   final supabase = Supabase.instance.client;
//   List<dynamic> members = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchMembers();
//   }
//
//   // NOTE: This now uses the RPC function 'get_group_members_info'
//   Future<void> _fetchMembers() async {
//     final data = await supabase.rpc(
//       'get_group_members_info',
//       params: {
//         'target_group_id': widget.group['id'],
//       },
//     );
//     setState(() => members = data);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Access the invite code directly from the widget's group map
//     final inviteCode = widget.group['invite_code'];
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Group Info')),
//       body: Column( // Use Column to stack static info (code) and the list
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 1. Display Invite Code
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Invite Code:',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       inviteCode.toString(), // Display the code
//                       style: const TextStyle(fontSize: 18, color: Colors.blue),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.copy, size: 20),
//                       onPressed: () {
//                         // TODO: Implement copy to clipboard logic here
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Invite code copied!')),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // 2. Members Header
//           const Padding(
//             padding: EdgeInsets.only(left: 16.0, top: 10, bottom: 8),
//             child: Text(
//               'Members:',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//
//           // 3. Members List (Flexibly takes remaining space)
//           Expanded(
//             child: members.isEmpty
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//               itemCount: members.length,
//               itemBuilder: (_, i) {
//                 final member = members[i];
//                 // Assuming your RPC returns 'email' and 'role'
//                 return ListTile(
//                   title: Text(member['email']),
//                   subtitle: Text('Role: ${member['role']}'),
//                   leading: const Icon(Icons.person_outline),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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

