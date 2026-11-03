import 'package:flutter/material.dart';

void main() {
  runApp(const PhoenixTasks());
}

const Color red = Color(0xFFE53935);
const Color dark = Color(0xFF111111);
const Color cardColor = Color(0xFF1E1E1E);

class PhoenixTasks extends StatelessWidget {
  const PhoenixTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phoenix Tasks',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Task {
  String title;
  bool completed;

  Task({required this.title, this.completed = false});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> tasks = [];

  int selectedTab = 0;

  int get completed => tasks.where((task) => task.completed).length;

  int get pending => tasks.length - completed;

  List<Task> get filteredTasks {
    if (selectedTab == 1) {
      return tasks.where((task) => !task.completed).toList();
    }

    if (selectedTab == 2) {
      return tasks.where((task) => task.completed).toList();
    }

    return tasks;
  }

  void toggleTask(Task task) {
    setState(() {
      task.completed = !task.completed;
    });
  }

  void deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Tarea eliminada')));
  }

  void showTaskDialog({Task? task}) {
    final controller = TextEditingController(text: task?.title ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text(task == null ? 'Nueva tarea' : 'Editar tarea'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 80,
            decoration: InputDecoration(
              hintText: '¿Qué necesitas hacer?',
              prefixIcon: const Icon(Icons.edit, color: red),
              filled: true,
              fillColor: dark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: red),
              onPressed: () {
                final value = controller.text.trim();

                if (value.isEmpty) return;

                setState(() {
                  if (task == null) {
                    tasks.add(Task(title: value));
                  } else {
                    task.title = value;
                  }
                });

                Navigator.pop(context);
              },
              child: Text(task == null ? 'Agregar' : 'Guardar'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: dark,
        title: const Row(
          children: [
            Icon(Icons.bolt, color: red, size: 30),
            SizedBox(width: 8),
            Text(
              'PHOENIX',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            Text(
              ' TASKS',
              style: TextStyle(
                color: red,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => showTaskDialog(),
            icon: const Icon(Icons.add_circle_outline, color: red),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ORGANIZA TU DÍA',
                    style: TextStyle(
                      color: red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hola, ¿qué harás hoy?',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cada tarea completada es un paso adelante.',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 22),

                  // PROGRESS CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E1717), Color(0xFF351111)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TU PROGRESO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(progress * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('$completed de ${tasks.length} tareas'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 9,
                            backgroundColor: Colors.black26,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // STATISTICS
                  Row(
                    children: [
                      Expanded(
                        child: statisticCard(
                          'Pendientes',
                          '$pending',
                          Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: statisticCard(
                          'Completadas',
                          '$completed',
                          Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // FILTERS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  filterButton('Todas', 0),
                  const SizedBox(width: 10),
                  filterButton('Pendientes', 1),
                  const SizedBox(width: 10),
                  filterButton('Completadas', 2),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // TASK LIST
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 65,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tasks.isEmpty
                                ? 'Todavía no tienes tareas'
                                : 'No hay tareas en esta sección',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Agrega una nueva tarea para comenzar.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            leading: Checkbox(
                              value: task.completed,
                              activeColor: red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onChanged: (_) => toggleTask(task),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: task.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.completed
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              task.completed ? 'Completada' : 'Pendiente',
                              style: TextStyle(
                                color: task.completed
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                                fontSize: 12,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              color: cardColor,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  showTaskDialog(task: task);
                                } else {
                                  deleteTask(task);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Eliminar'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ADD BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: red,
        foregroundColor: Colors.white,
        onPressed: () => showTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text(
          'Nueva tarea',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget statisticCard(String title, String number, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: red, size: 25),
          const SizedBox(height: 10),
          Text(
            number,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget filterButton(String title, int index) {
    final selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? red : cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
