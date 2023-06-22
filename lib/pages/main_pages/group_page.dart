import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vouch_tour_mobile/models/group_model.dart';
import 'package:vouch_tour_mobile/services/api_service.dart';
import 'package:vouch_tour_mobile/pages/main_pages/components/group_form_dialog.dart';

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<Group> groups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    try {
      final fetchedGroups = await ApiService.fetchGroups();
      setState(() {
        groups = fetchedGroups;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching groups: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingValue = screenWidth * 0.1;

    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : groups.isEmpty
              ? const Center(
                  child: Text('You have no groups available'),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingValue),
                  child: ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final startDate =
                          DateFormat('dd/MM/yyyy').format(group.startDate);
                      final endDate = group.endDate != null
                          ? DateFormat('dd/MM/yyyy').format(group.endDate)
                          : 'Not yet';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.groupName,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text('Mô tả nhóm: ${group.description}'),
                                  Text(
                                      'Số lượng thành viên: ${group.quantity}'),
                                  Text('Ngày bắt đầu: $startDate'),
                                  Text('Ngày kết thúc: $endDate'),
                                  Text('Trạng thái: In Progress'),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    // Handle edit button tap
                                    // Call the edit API and update the group
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    // Handle delete button tap
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this group?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              // Call the delete API and remove the group
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Delete'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => GroupFormDialog(
              onSubmit: (newGroup) {
                setState(() {
                  groups.add(newGroup);
                });
              },
            ),
          ).then((value) {
            if (value != null && value) {
              fetchGroups();
            }
          });
        },
      ),
    );
  }
}