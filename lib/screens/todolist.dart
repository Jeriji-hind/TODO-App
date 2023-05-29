import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todolist/screens/add_page.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Visibility(
        visible: isLoading,
        child: const Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchdata,
          child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(onSelected: (value) {
                      if (value == 'edit') {
                        navigateToEditPage(item);
                      } else if (value == 'delete') {
                        deletebyId(id);
                      }
                    }, itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text('Edit'),
                          value: 'edit',
                        ),
                        PopupMenuItem(
                          child: Text('Delete'),
                          value: 'delete',
                        ),
                      ];
                    }),
                  ),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage, label: Text('Add task')),
    );
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodo(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchdata();
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodo(
        todo: item,
      ),
    );
    await Navigator.push(context, route);
    setState(() {
      fetchdata();
    });
  }

  Future<void> deletebyId(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);

    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtred = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtred;
      });
    } else {
      showErrormessage('Unable to delete task ! Try again.');
    }
  }

  Future<void> fetchdata() async {
    final url = 'https://api.nstack.in/v1/todos?page=&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    } else {}

    setState(() {
      isLoading = false;
    });
  }

  void showErrormessage(String message) {
    final snackbar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
