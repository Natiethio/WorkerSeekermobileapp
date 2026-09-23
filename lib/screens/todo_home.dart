import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoHome extends StatefulWidget {
  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  final List<Todo> todos = [];
  final TextEditingController textController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Controllers used in modal:
  final TextEditingController _modalTitleController = TextEditingController();
  final TextEditingController _modalDateController = TextEditingController();
  DateTime? _modalPickedDate;

  String searchTerm = "";

  // updated addTodo to accept optional deadline so existing callers keep working
  void addTodo([DateTime? deadline]) {
    final title = textController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      todos.add(Todo(title: title, deadline: deadline));
      textController.clear();
    });
  }

  // internal add used by modal
  void _addTodoFromModal() {
    final title = _modalTitleController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      todos.add(Todo(title: title, deadline: _modalPickedDate));
    });

    // clear modal controllers
    _modalTitleController.clear();
    _modalDateController.clear();
    _modalPickedDate = null;

    Navigator.of(context).pop();

    showTopSnackBar(context, "Task added successfully!", success: true);
  }

  void deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
    showTopSnackBar(context, "Deleted Successfully", success: true);
  }

  void _editTodo(int index) {
    final todo = todos[index];
    _modalTitleController.text = todo.title;
    _modalPickedDate = todo.deadline;
    _modalDateController.text = todo.deadline != null
        ? '${todo.deadline!.day.toString().padLeft(2, '0')}/${todo.deadline!.month.toString().padLeft(2, '0')}/${todo.deadline!.year}'
        : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Edit Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),

                    // Title input
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(minHeight: 50),
                      child: TextField(
                        controller: _modalTitleController,
                        decoration: InputDecoration(
                          hintText: 'Enter task name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Color(0xFFF1AB15),
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 22),

                    // Deadline input
                    TextField(
                      controller: _modalDateController,
                      readOnly: true,
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _modalPickedDate ?? now,
                          firstDate: DateTime(now.year - 5),
                          lastDate: DateTime(now.year + 5),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFFF1AB15),
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Color(0xFFF1AB15),
                                  ),
                                ),
                                dialogTheme: DialogThemeData(
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          _modalPickedDate = picked;
                          _modalDateController.text =
                              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                          setState(() {});
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter Deadline date',
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: Color(0xFFF1AB15),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFFF1AB15),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),

                    SizedBox(height: 50),

                    // Save changes button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final newTitle = _modalTitleController.text.trim();
                          if (newTitle.isEmpty) {
                            showTopSnackBar(
                              context,
                              "Please enter a task name",
                              success: false,
                            );
                            return;
                          }

                          setState(() {
                            todos[index].title = newTitle;
                            todos[index].deadline = _modalPickedDate;
                          });

                          Navigator.of(context).pop();
                          showTopSnackBar(
                            context,
                            "Task updated successfully!",
                            success: true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF1AB15),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
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
      },
    );
  }


  void showTopSnackBar(
    BuildContext context,
    String message, {
    bool success = false,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    final Color bgColor = success ? Colors.green : Colors.red;
    final IconData leftIcon = success ? Icons.check : Icons.close;
    final Color leftIconColor = success ? Colors.green : Colors.red;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 25,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: bgColor,
              // borderRadius: const BorderRadius.only(
              //   bottomLeft: Radius.circular(10),
              //   bottomRight: Radius.circular(10),
              // ),
            ),
            child: Row(
              children: [
                // -------- Left status icon (tap to close) --------
                GestureDetector(
                  onTap: () => entry.remove(),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Icon(leftIcon, size: 20, color: leftIconColor),
                  ),
                ),

                const SizedBox(width: 12),

                // -------- Message --------
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (entry.mounted) entry.remove();
    });
  }

  // show modal bottom sheet with semi-transparent backdrop and two inputs
  Future<void> _showAddTaskModal() async {
    _modalTitleController.clear();
    _modalDateController.clear();
    _modalPickedDate = null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // allow rounded white container
      barrierColor: Colors.black.withOpacity(0.5),
      // 50% black overlay
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Add new task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),

                    // Title input
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(minHeight: 50),
                      child: TextField(
                        controller: _modalTitleController,
                        decoration: InputDecoration(
                          hintText: 'Enter task name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                            ), // Default border color
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                            ), // When not focused
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Color(0xFFF1AB15), // Orange when focused
                              width:
                                  1, // Optional: make it thicker when focused
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 14,
                          ),
                          isDense: true,
                          constraints: BoxConstraints(
                            minHeight: 50, // Ensure minimum height
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 22),

                    // Deadline date input (readOnly -> showDatePicker)
                    TextField(
                      controller: _modalDateController,
                      readOnly: true,
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _modalPickedDate ?? now,
                          firstDate: DateTime(now.year - 5),
                          lastDate: DateTime(now.year + 5),
                          // Theme the date picker with orange color
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFFF1AB15),
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Color(
                                      0xFFF1AB15,
                                    ), // Button text color
                                  ),
                                ),
                                dialogTheme: DialogThemeData(
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          _modalPickedDate = picked;
                          _modalDateController.text =
                              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                          setState(() {}); // update modal UI if needed
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter Deadline date',
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: Color(0xFFF1AB15),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFFF1AB15),
                            width: 1,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),

                    SizedBox(height: 50),

                    // Add Task button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_modalTitleController.text.trim().isEmpty) {
                            showTopSnackBar(
                              context,
                              "Please enter a task name",
                              success: false,
                            );

                            return;
                          }
                          _addTodoFromModal();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF1AB15),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Add task',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = todos
        .where((t) => t.title.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade200,

      // ---------------------- APP BAR ----------------------
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.menu, size: 30, color: Colors.black87),
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=10"),
            ),
          ],
        ),
      ),

      // ---------------------- BODY WITH NESTED SCROLL ----------------------
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              // Sticky Search Bar + Header
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: _HeaderDelegate(
                  child: Container(
                    color: Colors.grey.shade200,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ---- SEARCH BAR ----
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: (v) => setState(() => searchTerm = v),
                            decoration: InputDecoration(
                              hintText: "Search",
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        // ---- TITLE ----
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "All ToDos",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: filteredTodos.isEmpty
              ? Center(
                  child: Text("No tasks yet", style: TextStyle(fontSize: 16)),
                )
              : ListView.builder(
                  // No shrinkWrap or NeverScrollableScrollPhysics needed here.
                  // This allows the NestedScrollView to handle scrolling naturally.
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom:
                        100, // Adds space at the bottom so items don't overlap the Add button
                  ),
                  itemCount: filteredTodos.length,
                  itemBuilder: (context, index) {
                    final item = filteredTodos[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: item.isDone,
                            onChanged: (val) {
                              setState(() {
                                item.isDone = val ?? false;
                              });
                            },
                            activeColor: Color(0xFFF1AB15),
                            checkColor: Colors.white,
                            fillColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return Color(0xFFF1AB15);
                              }
                              return Colors.transparent;
                            }),
                            side: BorderSide(
                              color: Color(0xFFF1AB15),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: item.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: item.isDone
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                                if (item.deadline != null) ...[
                                  SizedBox(height: 6),
                                  Text(
                                    '${item.deadline!.day.toString().padLeft(2, '0')}/${item.deadline!.month.toString().padLeft(2, '0')}/${item.deadline!.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(color: Colors.white),
                                child: IconButton(
                                  icon: Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    final realIndex = todos.indexOf(
                                      filteredTodos[index],
                                    );
                                    _editTodo(realIndex);
                                  },
                                ),
                              ),
                              const SizedBox(width: 7),
                              Container(
                                decoration: BoxDecoration(),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    final realIndex = todos.indexOf(
                                      filteredTodos[index],
                                    );
                                    deleteTodo(realIndex);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),

      // ---------- BOTTOM: single Add new task button (opens modal) ----------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 25), //L,T,R,B
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _showAddTaskModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF1AB15),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 24),
                SizedBox(width: 8),
                Text(
                  'Add new task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------- STICKY HEADER DELEGATE ----------------------
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _HeaderDelegate({required this.child});

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 150;

  @override
  double get minExtent => 150;

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => false;
}
