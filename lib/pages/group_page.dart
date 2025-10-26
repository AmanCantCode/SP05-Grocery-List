import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'group_info_page.dart';

class GroupPage extends StatefulWidget {
  final Map<String, dynamic> group;
  const GroupPage({super.key, required this.group});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> _items = [];
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _fetchGroupRole();
    _fetchItems();

    final channel = supabase.channel('grocery_items_channel');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'grocery_items',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'group_id',
        value: widget.group['id'],
      ),
      callback: (payload) {
        debugPrint('🔄 Change detected: ${payload.eventType}');
        _fetchItems();
      },
    );

    channel.subscribe();
  }

  Future<void> _fetchGroupRole() async {
    final data = await supabase
        .from('group_members')
        .select('role')
        .eq('user_id', supabase.auth.currentUser!.id)
        .eq('group_id', widget.group['id'])
        .maybeSingle();

    if (data != null && data.containsKey('role')) {
      setState(() {
        _currentUserRole = data['role'] as String;
      });
    }
  }

  Future<void> _fetchItems() async {
    final data = await supabase.rpc(
      'get_group_grocery_items',
      params: {
        'target_group_id': widget.group['id'],
      },
    );

    setState(() {
      _items = data;
    });
  }

  Future<void> _addItem() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Item'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Item name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final item = controller.text.trim();
              if (item.isEmpty) return;

              await supabase.from('grocery_items').insert({
                'group_id': widget.group['id'],
                'added_by': supabase.auth.currentUser!.id,
                'name': item,
              });

              Navigator.pop(context);
              await _fetchItems();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(String id) async {
    await supabase.from('grocery_items').delete().eq('id', id);
    _fetchItems();
  }

  Future<void> _editItem(String id, String currentName) async {
    final controller = TextEditingController(text: currentName);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Item'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await supabase.from('grocery_items').update({'name': controller.text}).eq('id', id);
              Navigator.pop(context);
              _fetchItems();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333), size: 30,),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFFAAEA61),
        title: Text(
          widget.group['name'],
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF333333), size: 30,),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupInfoPage(group: widget.group),
              ),
            ),
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(
          child: Text('No items yet',
            style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 25,
            fontWeight: FontWeight.normal,
            color: Color(0xFF333333),
            ),
          ),
        )
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final item = _items[i];
          final currentUserId = supabase.auth.currentUser!.id;

          final displayName = item['display_name'] ?? 'Unknown';
          final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

          final isOwner = item['added_by'] == currentUserId;
          final isAdmin = _currentUserRole == 'admin';
          final canModify = isOwner || isAdmin;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Clickable Initial Icon / Checkmark
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 32),
                  child: GestureDetector(
                    onTap: () async {
                      final newValue = !(item['is_checked'] ?? false);

                      // Optimistically update UI
                      setState(() {
                        item['is_checked'] = newValue;
                      });

                      // Update in database
                      await supabase
                          .from('grocery_items')
                          .update({'is_checked': newValue})
                          .eq('id', item['id']);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: (item['is_checked'] ?? false)
                            ? const Color(0xFFBBBBBB)
                            : const Color(0xFFEEEEEE),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: (item['is_checked'] ?? false)
                            ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF333333),
                          size: 28,
                        )
                            : Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Name and Item Box
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author Name
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF6E6E6E),
                          ),
                        ),
                      ),

                      // Item Box
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFAAEA61),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Dismissible(
                          key: Key(item['id']),
                          direction:
                          canModify ? DismissDirection.horizontal : DismissDirection.none,
                          background: Container(
                            color: const Color(0xFFE5F5C0),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.mode_edit_outlined,
                                color: Colors.black, size: 30),
                          ),
                          secondaryBackground: Container(
                            color: const Color(0xFFFF6666),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete_outline_outlined,
                                color: Colors.black, size: 30),
                          ),
                          confirmDismiss: (direction) async {
                            if (!canModify) return false;
                            if (direction == DismissDirection.startToEnd) {
                              _editItem(item['id'], item['name']);
                              return false;
                            } else {
                              _deleteItem(item['id']);
                              return true;
                            }
                          },
                          child: SizedBox(
                            height: 70,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 15.0, right: 15.0),
                                // child: Text(
                                //   item['name'],
                                //   style: const TextStyle(
                                //     fontFamily: 'Inter',
                                //     fontSize: 20,
                                //     fontWeight: FontWeight.normal,
                                //     color: Color(0xFF333333),
                                //   ),
                                // ),
                                child: Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xFF333333),
                                    decoration: (item['is_checked'] ?? false)
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationThickness: 1,
                                    decorationColor: const Color(0xFF333333),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
    );
  }
}