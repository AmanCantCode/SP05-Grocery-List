// // // import 'package:flutter/material.dart';
// // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // import 'group_page.dart';
// // //
// // // class GroupsPage extends StatefulWidget {
// // //   const GroupsPage({super.key});
// // //
// // //   @override
// // //   State<GroupsPage> createState() => _GroupsPageState();
// // // }
// // //
// // // class _GroupsPageState extends State<GroupsPage> {
// // //   final supabase = Supabase.instance.client;
// // //   List<dynamic> _groups = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchGroups();
// // //   }
// // //
// // //   Future<void> _fetchGroups() async {
// // //     final userId = supabase.auth.currentUser!.id;
// // //     final response = await supabase
// // //         .from('group_members')
// // //         //.select('groups(id, name, invite_code)')
// // //         .select('groups(id, name, invite_code)')
// // //         .eq('user_id', userId);
// // //
// // //     setState(() {
// // //       _groups = response.map((e) => e['groups']).toList();
// // //     });
// // //   }
// // //
// // //   Future<void> _createGroup() async {
// // //     final nameController = TextEditingController();
// // //
// // //     await showDialog(
// // //       context: context,
// // //       builder: (_) => AlertDialog(
// // //         title: const Text('Create Group'),
// // //         content: TextField(
// // //           controller: nameController,
// // //           decoration: const InputDecoration(hintText: 'Group name'),
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.pop(context),
// // //             child: const Text('Cancel'),
// // //           ),
// // //
// // //           TextButton(
// // //             onPressed: () async {
// // //               final name = nameController.text.trim();
// // //               if (name.isEmpty) return;
// // //
// // //               // Current user ID is no longer explicitly needed in the payload,
// // //               // but we keep the variable for clarity if needed elsewhere.
// // //               final currentUserId = supabase.auth.currentUser!.id;
// // //               final code = DateTime.now().millisecondsSinceEpoch;
// // //
// // //               try {
// // //                 //call database function
// // //                 final response = await supabase.rpc(
// // //                   'create_new_group_and_admin',
// // //                   params: {
// // //                     'group_name': name,
// // //                     'invite_code_val': code,
// // //                   },
// // //                 ).select().single(); // select().single() for clarity/consistency
// // //
// // //                 final group = response; // The function returns the created group
// // //
// // //                 Navigator.pop(context);
// // //
// // //                 // show invite code dialog
// // //                 showDialog(
// // //                   context: context,
// // //                   builder: (_) => AlertDialog(
// // //                     title: const Text('Group Created!'),
// // //                     content: Text('Invite Code: $code'),
// // //                     actions: [
// // //                       TextButton(
// // //                         onPressed: () {
// // //                           Navigator.pop(context);
// // //                           _fetchGroups(); // Refresh list
// // //                         },
// // //                         child: const Text('OK'),
// // //                       )
// // //                     ],
// // //                   ),
// // //                 );
// // //
// // //               } catch (e) {
// // //                 ScaffoldMessenger.of(context).showSnackBar(
// // //                   SnackBar(content: Text('Error creating group: $e')),
// // //                 );
// // //                 debugPrint("Error creating group: $e");
// // //               }
// // //             },
// // //             child: const Text('Create'),
// // //           ),
// // //           // TextButton(
// // //           //   onPressed: () async {
// // //           //     final name = nameController.text.trim();
// // //           //     if (name.isEmpty) return;
// // //           //     final currentUserId = supabase.auth.currentUser!.id;
// // //           //     final code = DateTime.now().millisecondsSinceEpoch;
// // //           //
// // //           //     try {
// // //           //       final group = await supabase
// // //           //           .from('groups')
// // //           //           .insert({
// // //           //         'name': name,
// // //           //         'invite_code': code,
// // //           //         'created_by': currentUserId,
// // //           //       })
// // //           //           .select()
// // //           //           .single();
// // //           //
// // //           //       // Add current user as admin to group_members
// // //           //       await supabase.from('group_members').insert({
// // //           //         'group_id': group['id'],
// // //           //         'user_id': currentUserId,
// // //           //         'role': 'admin',
// // //           //       });
// // //           //
// // //           //       Navigator.pop(context);
// // //           //
// // //           //       // Show invite code
// // //           //       showDialog(
// // //           //         context: context,
// // //           //         builder: (_) => AlertDialog(
// // //           //           title: const Text('Group Created!'),
// // //           //           content: Text('Invite Code: $code'),
// // //           //           actions: [
// // //           //             TextButton(
// // //           //               onPressed: () {
// // //           //                 Navigator.pop(context);
// // //           //                 _fetchGroups(); // Refresh list
// // //           //               },
// // //           //               child: const Text('OK'),
// // //           //             )
// // //           //           ],
// // //           //         ),
// // //           //       );
// // //           //     } catch (e) {
// // //           //       ScaffoldMessenger.of(context).showSnackBar(
// // //           //         SnackBar(content: Text('Error creating group: $e')),
// // //           //       );
// // //           //       debugPrint("Error creating group: $e");
// // //           //     }
// // //           //   },
// // //           //   child: const Text('Create'),
// // //           // ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text('Your Groups')),
// // //       body: _groups.isEmpty
// // //           ? const Center(child: Text('No groups yet'))
// // //           : ListView.builder(
// // //         itemCount: _groups.length,
// // //         itemBuilder: (context, index) {
// // //           final group = _groups[index];
// // //           return ListTile(
// // //             title: Text(group['name']),
// // //             onTap: () => Navigator.push(
// // //               context,
// // //               MaterialPageRoute(
// // //                 builder: (_) => GroupPage(group: group),
// // //               ),
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //       floatingActionButton: FloatingActionButton(
// // //         onPressed: _createGroup,
// // //         child: const Icon(Icons.add),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'group_page.dart';
// //
// // class GroupsPage extends StatefulWidget {
// //   const GroupsPage({super.key});
// //
// //   @override
// //   State<GroupsPage> createState() => _GroupsPageState();
// // }
// //
// // class _GroupsPageState extends State<GroupsPage> {
// //   final supabase = Supabase.instance.client;
// //   List<dynamic> _groups = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchGroups();
// //   }
// //
// //   Future<void> _fetchGroups() async {
// //     final userId = supabase.auth.currentUser!.id;
// //     final response = await supabase
// //         .from('group_members')
// //         .select('groups(id, name, invite_code)')
// //         .eq('user_id', userId);
// //
// //     setState(() {
// //       _groups = response.map((e) => e['groups']).toList();
// //     });
// //   }
// //
// //   // Helper function to show a snackbar
// //   void _showSnackbar(String message) {
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text(message)),
// //       );
// //     }
// //   }
// //
// //   // --- Group Creation Logic (Existing RPC) ---
// //
// //   Future<void> _createGroup() async {
// //     final nameController = TextEditingController();
// //
// //     await showDialog(
// //       context: context,
// //       builder: (_) => AlertDialog(
// //         title: const Text('Create Group'),
// //         content: TextField(
// //           controller: nameController,
// //           decoration: const InputDecoration(hintText: 'Group name'),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text('Cancel'),
// //           ),
// //
// //           TextButton(
// //             onPressed: () async {
// //               final name = nameController.text.trim();
// //               if (name.isEmpty) return;
// //
// //               final code = DateTime.now().millisecondsSinceEpoch;
// //
// //               try {
// //                 // Call database function (RPC)
// //                 await supabase.rpc(
// //                   'create_new_group_and_admin',
// //                   params: {
// //                     'group_name': name,
// //                     'invite_code_val': code,
// //                   },
// //                 ).select().single();
// //
// //                 if (mounted) Navigator.pop(context);
// //
// //                 // show invite code dialog
// //                 if (mounted) {
// //                   showDialog(
// //                     context: context,
// //                     builder: (_) => AlertDialog(
// //                       title: const Text('Group Created!'),
// //                       content: Text('Invite Code: $code'),
// //                       actions: [
// //                         TextButton(
// //                           onPressed: () {
// //                             Navigator.pop(context);
// //                             _fetchGroups(); // Refresh list
// //                           },
// //                           child: const Text('OK'),
// //                         )
// //                       ],
// //                     ),
// //                   );
// //                 }
// //               } catch (e) {
// //                 _showSnackbar('Error creating group: ${e.toString()}');
// //                 debugPrint("Error creating group: $e");
// //               }
// //             },
// //             child: const Text('Create'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // Future<void> _joinGroup() async {
// //   //   final codeController = TextEditingController();
// //   //
// //   //   await showDialog(
// //   //     context: context,
// //   //     builder: (_) => AlertDialog(
// //   //       title: const Text('Join Group'),
// //   //       content: TextField(
// //   //         controller: codeController,
// //   //         keyboardType: TextInputType.number,
// //   //         decoration: const InputDecoration(hintText: 'Enter Invite Code'),
// //   //       ),
// //   //       actions: [
// //   //         TextButton(
// //   //           onPressed: () => Navigator.pop(context),
// //   //           child: const Text('Cancel'),
// //   //         ),
// //   //         TextButton(
// //   //           onPressed: () async {
// //   //             final codeText = codeController.text.trim();
// //   //             if (codeText.isEmpty) return;
// //   //             final inviteCode = int.tryParse(codeText);
// //   //             if (inviteCode == null) {
// //   //               _showSnackbar('Invalid invite code format.');
// //   //               return;
// //   //             }
// //   //
// //   //             final currentUserId = supabase.auth.currentUser!.id;
// //   //
// //   //             // 1. Check if group exists
// //   //             final groupResponse = await supabase
// //   //                 .from('groups')
// //   //                 .select('id')
// //   //                 .eq('invite_code', inviteCode)
// //   //                 .single()
// //   //                 .limit(1);
// //   //
// //   //             if (groupResponse.isEmpty) {
// //   //               _showSnackbar('Group not found with that invite code.');
// //   //               if (mounted) Navigator.pop(context);
// //   //               return;
// //   //             }
// //   //             final groupId = groupResponse['id'];
// //   //
// //   //             // 2. Check if user is already a member
// //   //             final existingMember = await supabase
// //   //                 .from('group_members')
// //   //                 .select('user_id')
// //   //                 .eq('group_id', groupId)
// //   //                 .eq('user_id', currentUserId)
// //   //                 .limit(1);
// //   //
// //   //             if (existingMember.isNotEmpty) {
// //   //               _showSnackbar('You are already a member of this group!');
// //   //               if (mounted) Navigator.pop(context);
// //   //               return;
// //   //             }
// //   //
// //   //             // 3. Add user as a regular member
// //   //             try {
// //   //               await supabase.from('group_members').insert({
// //   //                 'group_id': groupId,
// //   //                 'user_id': currentUserId,
// //   //                 'role': 'member', // Default role for joining via code
// //   //               });
// //   //
// //   //               _showSnackbar('Successfully joined the group!');
// //   //               if (mounted) Navigator.pop(context);
// //   //               _fetchGroups(); // Refresh list
// //   //             } catch (e) {
// //   //               _showSnackbar('Error joining group: ${e.toString()}');
// //   //               debugPrint("Error joining group: $e");
// //   //             }
// //   //           },
// //   //           child: const Text('Join'),
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// //
// //
// //   Future<void> _joinGroup() async {
// //     final codeController = TextEditingController();
// //
// //     await showDialog(
// //       context: context,
// //       builder: (_) => AlertDialog(
// //         title: const Text('Join Group'),
// //         content: TextField(
// //           controller: codeController,
// //           keyboardType: TextInputType.number,
// //           decoration: const InputDecoration(hintText: 'Enter Invite Code'),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text('Cancel'),
// //           ),
// //           TextButton(
// //             onPressed: () async {
// //               final codeText = codeController.text.trim();
// //               if (codeText.isEmpty) return;
// //               final inviteCode = int.tryParse(codeText);
// //               if (inviteCode == null) {
// //                 _showSnackbar('Invalid invite code format.');
// //                 if (mounted) Navigator.pop(context);
// //                 return;
// //               }
// //
// //               final currentUserId = supabase.auth.currentUser!.id;
// //
// //               // 1. Check if group exists and get its ID
// //               Map<String, dynamic>? groupResponse;
// //               try {
// //                 groupResponse = await supabase
// //                     .from('groups')
// //                     .select('id')
// //                     .eq('invite_code', inviteCode)
// //                     .maybeSingle(); // Use maybeSingle for reliable null check
// //               } catch (e) {
// //                 debugPrint('Error checking group existence: $e');
// //                 _showSnackbar('An error occurred while searching for the group.');
// //                 if (mounted) Navigator.pop(context);
// //                 return;
// //               }
// //
// //               // Check if groupResponse is null (no group found)
// //               if (groupResponse == null || groupResponse.isEmpty) {
// //                 _showSnackbar('Group not found with that invite code.');
// //                 if (mounted) Navigator.pop(context);
// //                 return;
// //               }
// //               final groupId = groupResponse['id'];
// //
// //               // 2. Check if user is already a member
// //               List<dynamic> existingMember = [];
// //               try {
// //                 existingMember = await supabase
// //                     .from('group_members')
// //                     .select('user_id')
// //                     .eq('group_id', groupId)
// //                     .eq('user_id', currentUserId)
// //                     .limit(1);
// //               } catch (e) {
// //                 debugPrint('Error checking membership: $e');
// //                 _showSnackbar('An error occurred while checking membership.');
// //                 if (mounted) Navigator.pop(context);
// //                 return;
// //               }
// //
// //
// //               if (existingMember.isNotEmpty) {
// //                 _showSnackbar('You are already a member of this group!');
// //                 if (mounted) Navigator.pop(context);
// //                 return;
// //               }
// //
// //               // 3. Add user as a regular member
// //               try {
// //                 await supabase.from('group_members').insert({
// //                   'group_id': groupId,
// //                   'user_id': currentUserId,
// //                   'role': 'member', // Default role for joining via code
// //                 });
// //
// //                 _showSnackbar('Successfully joined the group!');
// //                 if (mounted) Navigator.pop(context);
// //                 _fetchGroups(); // Refresh list
// //               } catch (e) {
// //                 // This is the most critical catch block for silent failures.
// //                 _showSnackbar('Error adding you to the group. Check RLS or foreign keys.');
// //                 debugPrint('Error inserting new member: $e');
// //                 if (mounted) Navigator.pop(context);
// //               }
// //             },
// //             child: const Text('Join'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //   // --- FAB Action Sheet ---
// //
// //   void _showCreateOrJoinSheet() {
// //     showModalBottomSheet(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: <Widget>[
// //             ListTile(
// //               leading: const Icon(Icons.group_add),
// //               title: const Text('Create New Group'),
// //               onTap: () {
// //                 Navigator.pop(context); // Close the sheet
// //                 _createGroup();
// //               },
// //             ),
// //             ListTile(
// //               leading: const Icon(Icons.link),
// //               title: const Text('Join Group with Code'),
// //               onTap: () {
// //                 Navigator.pop(context); // Close the sheet
// //                 _joinGroup();
// //               },
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Your Groups')),
// //       body: _groups.isEmpty
// //           ? const Center(child: Text('No groups yet'))
// //           : ListView.builder(
// //         itemCount: _groups.length,
// //         itemBuilder: (context, index) {
// //           final group = _groups[index];
// //           return ListTile(
// //             title: Text(group['name']),
// //             onTap: () => Navigator.push(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (_) => GroupPage(group: group),
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: _showCreateOrJoinSheet, // Call the new sheet handler
// //         child: const Icon(Icons.add),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'group_page.dart';
//
// class GroupsPage extends StatefulWidget {
//   const GroupsPage({super.key});
//
//   @override
//   State<GroupsPage> createState() => _GroupsPageState();
// }
//
// class _GroupsPageState extends State<GroupsPage> {
//   final supabase = Supabase.instance.client;
//   List<dynamic> _groups = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchGroups();
//   }
//
//   Future<void> _fetchGroups() async {
//     final userId = supabase.auth.currentUser!.id;
//     final response = await supabase
//         .from('group_members')
//         .select('groups(id, name, invite_code)')
//         .eq('user_id', userId);
//
//     setState(() {
//       _groups = response.map((e) => e['groups']).toList();
//     });
//   }
//
//   // Helper function to show a snackbar
//   void _showSnackbar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
//
//   // --- Group Creation Logic (Existing RPC) ---
//
//   Future<void> _createGroup() async {
//     final nameController = TextEditingController();
//
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Create Group'),
//         content: TextField(
//           controller: nameController,
//           decoration: const InputDecoration(hintText: 'Group name'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//
//           TextButton(
//             onPressed: () async {
//               final name = nameController.text.trim();
//               if (name.isEmpty) return;
//
//               final code = DateTime.now().millisecondsSinceEpoch;
//
//               try {
//                 // Call database function (RPC)
//                 await supabase.rpc(
//                   'create_new_group_and_admin',
//                   params: {
//                     'group_name': name,
//                     'invite_code_val': code,
//                   },
//                 ).select().single();
//
//                 if (mounted) Navigator.pop(context);
//
//                 // show invite code dialog
//                 if (mounted) {
//                   showDialog(
//                     context: context,
//                     builder: (_) => AlertDialog(
//                       title: const Text('Group Created!'),
//                       content: Text('Invite Code: $code'),
//                       actions: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                             _fetchGroups(); // Refresh list
//                           },
//                           child: const Text('OK'),
//                         )
//                       ],
//                     ),
//                   );
//                 }
//               } catch (e) {
//                 _showSnackbar('Error creating group: ${e.toString()}');
//                 debugPrint("Error creating group: $e");
//               }
//             },
//             child: const Text('Create'),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   // --- FINAL FIXED: Group Joining Logic ---
//
//   // Future<void> _joinGroup() async {
//   //   final codeController = TextEditingController();
//   //
//   //   await showDialog(
//   //     context: context,
//   //     builder: (_) => AlertDialog(
//   //       title: const Text('Join Group'),
//   //       content: TextField(
//   //         controller: codeController,
//   //         keyboardType: TextInputType.number,
//   //         decoration: const InputDecoration(hintText: 'Enter Invite Code'),
//   //       ),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context),
//   //           child: const Text('Cancel'),
//   //         ),
//   //         TextButton(
//   //           onPressed: () async {
//   //             final codeText = codeController.text.trim();
//   //             if (codeText.isEmpty) return;
//   //
//   //             final inviteCode = int.tryParse(codeText);
//   //             if (inviteCode == null) {
//   //               _showSnackbar('Invalid invite code format.');
//   //               if (mounted) Navigator.pop(context);
//   //               return;
//   //             }
//   //
//   //             final currentUserId = supabase.auth.currentUser!.id;
//   //             final codeString = inviteCode.toString(); // Converted to string for the query
//   //
//   //             // 1. Check if group exists and get its ID
//   //             Map<String, dynamic>? groupResponse;
//   //             try {
//   //               // CRITICAL FIX: Use filter to explicitly cast the BIGINT DB column to text
//   //               // for reliable string comparison.
//   //               groupResponse = await supabase
//   //                   .from('groups')
//   //                   .select('id')
//   //                   .filter('invite_code::text', 'eq', codeString)
//   //                   .maybeSingle();
//   //             } catch (e) {
//   //               debugPrint('Error checking group existence: $e');
//   //               _showSnackbar('An internal error occurred while searching for the group.');
//   //               if (mounted) Navigator.pop(context);
//   //               return;
//   //             }
//   //
//   //             // Check if groupResponse is null (no group found)
//   //             if (groupResponse == null) {
//   //               _showSnackbar('Group not found with that invite code. Check the code.');
//   //               if (mounted) Navigator.pop(context);
//   //               return;
//   //             }
//   //             final groupId = groupResponse['id'];
//   //
//   //             // 2. Check if user is already a member
//   //             List<dynamic> existingMember = [];
//   //             try {
//   //               existingMember = await supabase
//   //                   .from('group_members')
//   //                   .select('user_id')
//   //                   .eq('group_id', groupId)
//   //                   .eq('user_id', currentUserId)
//   //                   .limit(1);
//   //             } catch (e) {
//   //               debugPrint('Error checking membership: $e');
//   //               _showSnackbar('An error occurred while checking membership.');
//   //               if (mounted) Navigator.pop(context);
//   //               return;
//   //             }
//   //
//   //             if (existingMember.isNotEmpty) {
//   //               _showSnackbar('You are already a member of this group!');
//   //               if (mounted) Navigator.pop(context);
//   //               return;
//   //             }
//   //
//   //             // 3. Add user as a regular member
//   //             try {
//   //               await supabase.from('group_members').insert({
//   //                 'group_id': groupId,
//   //                 'user_id': currentUserId,
//   //                 'role': 'member',
//   //               });
//   //
//   //               _showSnackbar('Successfully joined the group!');
//   //               if (mounted) Navigator.pop(context);
//   //               _fetchGroups();
//   //             } catch (e) {
//   //               _showSnackbar('Error adding you to the group. Check RLS or foreign keys.');
//   //               debugPrint('Error inserting new member: $e');
//   //               if (mounted) Navigator.pop(context);
//   //             }
//   //           },
//   //           child: const Text('Join'),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   // --- FINAL FIXED: Group Joining Logic (Using BigInt for Max Robustness) ---
//
//   Future<void> _joinGroup() async {
//     final codeController = TextEditingController();
//
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Join Group'),
//         content: TextField(
//           controller: codeController,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(hintText: 'Enter Invite Code'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               final codeText = codeController.text.trim();
//               if (codeText.isEmpty) return;
//
//               // Use BigInt to guarantee 64-bit handling
//               BigInt? inviteCodeBigInt;
//               try {
//                 inviteCodeBigInt = BigInt.parse(codeText);
//               } catch (_) {
//                 _showSnackbar('Invalid invite code format.');
//                 if (mounted) Navigator.pop(context);
//                 return;
//               }
//
//               final currentUserId = supabase.auth.currentUser!.id;
//               // CRITICAL: Use the BigInt's integer value for the query
//               final codeValue = inviteCodeBigInt.toInt();
//
//               debugPrint('Attempting to join with code (Int): $codeValue');
//
//               // 1. Check if group exists and get its ID
//               Map<String, dynamic>? groupResponse;
//               try {
//                 // Use the standard .eq() with the Dart int value
//                 groupResponse = await supabase
//                     .from('groups')
//                     .select('id')
//                     .eq('invite_code', codeValue)
//                     .maybeSingle();
//
//                 debugPrint('Group Query Response: $groupResponse');
//
//               } catch (e) {
//                 // This will catch an RLS issue on SELECT or a true DB error.
//                 debugPrint('Error checking group existence: $e');
//                 _showSnackbar('An internal error occurred while searching for the group.');
//                 if (mounted) Navigator.pop(context);
//                 return;
//               }
//
//               // Check if groupResponse is null (no group found)
//               if (groupResponse == null) {
//                 _showSnackbar('Group not found with that invite code. Check the code.');
//                 if (mounted) Navigator.pop(context);
//                 return;
//               }
//               final groupId = groupResponse['id'];
//
//               // 2. Check if user is already a member (This works, so we keep it)
//               List<dynamic> existingMember = [];
//               try {
//                 existingMember = await supabase
//                     .from('group_members')
//                     .select('user_id')
//                     .eq('group_id', groupId)
//                     .eq('user_id', currentUserId)
//                     .limit(1);
//               } catch (e) {
//                 debugPrint('Error checking membership: $e');
//                 _showSnackbar('An error occurred while checking membership.');
//                 if (mounted) Navigator.pop(context);
//                 return;
//               }
//
//               if (existingMember.isNotEmpty) {
//                 _showSnackbar('You are already a member of this group!');
//                 if (mounted) Navigator.pop(context);
//                 return;
//               }
//
//               // 3. Add user as a regular member (The final hurdle)
//               try {
//                 await supabase.from('group_members').insert({
//                   'group_id': groupId,
//                   'user_id': currentUserId,
//                   'role': 'member',
//                 });
//
//                 _showSnackbar('Successfully joined the group!');
//                 if (mounted) Navigator.pop(context);
//                 _fetchGroups();
//               } catch (e) {
//                 _showSnackbar('Error adding you to the group. Likely an RLS INSERT policy issue.');
//                 debugPrint('Error inserting new member: $e');
//                 if (mounted) Navigator.pop(context);
//               }
//             },
//             child: const Text('Join'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- FAB Action Sheet ---
//
//   void _showCreateOrJoinSheet() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             ListTile(
//               leading: const Icon(Icons.group_add),
//               title: const Text('Create New Group'),
//               onTap: () {
//                 Navigator.pop(context); // Close the sheet
//                 _createGroup();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.link),
//               title: const Text('Join Group with Code'),
//               onTap: () {
//                 Navigator.pop(context); // Close the sheet
//                 _joinGroup();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Your Groups')),
//       body: _groups.isEmpty
//           ? const Center(child: Text('No groups yet'))
//           : ListView.builder(
//         itemCount: _groups.length,
//         itemBuilder: (context, index) {
//           final group = _groups[index];
//           return ListTile(
//             title: Text(group['name']),
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => GroupPage(group: group),
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateOrJoinSheet, // Call the new sheet handler
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

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
