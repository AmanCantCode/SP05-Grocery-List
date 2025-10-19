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

  @override
  void initState() {
    super.initState();
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

  // In GroupPage._fetchItems()
  Future<void> _fetchItems() async {
    // Call the database function to fetch items and user names securely
    final data = await supabase.rpc(
      'get_group_grocery_items',
      params: {
        'target_group_id': widget.group['id'],
      },
    );
    // NOTE: RPC functions are typically fast and reliable, and the RLS logic
    // is now inside the function, simplifying the client code.

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
              //_fetchItems();
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
        title: Text(widget.group['name']),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
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
          ? const Center(child: Text('No items yet'))
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final item = _items[i];
          return Dismissible(
            key: Key(item['id']),
            background: Container(
              color: Colors.blue,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _editItem(item['id'], item['name']);
                return false;
              } else {
                _deleteItem(item['id']);
                return true;
              }
            },
            child: ListTile(
              title: Text(item['name']),
              // Use the clean 'display_name' field returned by the RPC function
              subtitle: Text('Added by: ${item['display_name'] ?? 'Unknown User'}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}