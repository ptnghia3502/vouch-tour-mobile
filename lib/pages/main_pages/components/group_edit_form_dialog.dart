import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:vouch_tour_mobile/models/group_model.dart';
import 'package:vouch_tour_mobile/models/menu_model.dart';
import 'package:vouch_tour_mobile/services/api_service.dart';
import 'package:collection/collection.dart';

class GroupEditFormDialog extends StatefulWidget {
  final Group group;
  final Function(Group) onSubmit;

  const GroupEditFormDialog({
    Key? key,
    required this.group,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _GroupEditFormDialogState createState() => _GroupEditFormDialogState();
}

class _GroupEditFormDialogState extends State<GroupEditFormDialog> {
  TextEditingController groupNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  // Declare a variable to hold the selected menu
  List<Menu> menuList = [];
  Menu? selectedMenu;

  @override
  void initState() {
    super.initState();
    groupNameController.text = widget.group.groupName;
    descriptionController.text = widget.group.description;
    quantityController.text = widget.group.quantity.toString();
    startDate = widget.group.startDate;
    endDate = widget.group.endDate;
    fetchMenuList().then((_) {
      selectedMenu =
          menuList.firstWhereOrNull((menu) => menu.id == widget.group.menuId);
    });
  }

  Future<void> fetchMenuList() async {
    try {
      // Fetch the menu list from the API using ApiService
      final menus = await ApiService.fetchMenus();
      setState(() {
        menuList = menus;
      });
    } catch (e) {
      print('Failed to fetch menu list: $e');
    }
  }

  Future<void> updateGroup() async {
    final groupName = groupNameController.text;
    final description = descriptionController.text;
    final quantity = int.tryParse(quantityController.text) ?? 0;

    if (groupName.isEmpty ||
        description.isEmpty ||
        quantity <= 0 ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền vào tất cả chỗ trống')),
      );
      return;
    }

    final updatedGroup = Group(
      id: widget.group.id,
      groupName: groupName,
      description: description,
      quantity: quantity,
      startDate: startDate!,
      endDate: endDate!,
      status: widget.group.status,
      menuId: selectedMenu?.id ?? '',
    );

    try {
      await ApiService.updateGroup(updatedGroup);
      widget.onSubmit(updatedGroup); // Call the onSubmit callback
      Navigator.of(context).pop(true); // Pop the dialog and return true
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Cập nhật nhóm thành công!',
      );
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Cập nhật nhóm thất bại!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cập nhật nhóm Tour'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: groupNameController,
              decoration: const InputDecoration(labelText: 'Tên nhóm'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            TextField(
              controller: quantityController,
              decoration:
                  const InputDecoration(labelText: 'Số lượng thành viên'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      ).then((selectedDate) {
                        setState(() {
                          startDate = selectedDate;
                        });
                      });
                    },
                    child: Text(
                      startDate != null
                          ? 'Ngày bắt đầu: ${DateFormat('dd/MM/yyyy').format(startDate!)}'
                          : 'Hãy chọn ngày bắt đầu',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      ).then((selectedDate) {
                        setState(() {
                          endDate = selectedDate;
                        });
                      });
                    },
                    child: Text(
                      endDate != null
                          ? 'Ngày kết thúc: ${DateFormat('dd/MM/yyyy').format(endDate!)}'
                          : 'Hãy chọn ngày kết thúc',
                    ),
                  ),
                ),
              ],
            ),
            DropdownButton<Menu>(
              value: selectedMenu,
              onChanged: (Menu? newValue) {
                setState(() {
                  selectedMenu = newValue;
                });
              },
              items: menuList.map<DropdownMenuItem<Menu>>((Menu menu) {
                return DropdownMenuItem<Menu>(
                  value: menu,
                  child: Text(menu.title),
                );
              }).toList(),
              hint: const Text('Chọn Menu'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Pop the dialog and return false
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: updateGroup, // Call the updateGroup method
          child: const Text('Update'),
        ),
      ],
    );
  }
}
