import 'package:flutter/material.dart';
import 'package:myapp/Screens/Employees/Employee%20Info%20Screen/employee_info_screen.dart';
import 'package:myapp/Screens/Employees/Employees%20List%20Screen/components/add_employee.dart';
import 'package:myapp/models/employee_model.dart';
import 'package:myapp/services/employee_service.dart';

class AdminEmployeesScreen extends StatefulWidget {
  const AdminEmployeesScreen({Key? key}) : super(key: key);

  @override
  _AdminEmployeesScreenState createState() => _AdminEmployeesScreenState();
}

class _AdminEmployeesScreenState extends State<AdminEmployeesScreen> {
  final EmployeeService _employeeService = EmployeeService();
  late Future<List<EmployeeModel>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _refreshEmployeeList();
  }

  void _refreshEmployeeList() {
    setState(() {
      _employeesFuture = _employeeService.getAllEmployees();
    });
  }

  void _showAddEmployeeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddEmployeeSheet(
            onEmployeeAdded: _refreshEmployeeList,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Funcionários'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              // Lógica para a busca será implementada aqui
            },
          ),
        ],
      ),
      body: FutureBuilder<List<EmployeeModel>>(
        future: _employeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar funcionários: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum funcionário encontrado.'));
          }

          final employees = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return EmployeeCard(employee: employee);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeSheet,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Adicionar Funcionário',
      ),
    );
  }
}

// Widget reutilizável para exibir as informações de cada funcionário
class EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;

  const EmployeeCard({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        // CORREÇÃO: Adicionada a lógica de navegação no onTap
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeInfoScreen(employee: employee),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: employee.fotoUrl.isEmpty
                    ? Text(
                        employee.nomeCompleto.isNotEmpty ? employee.nomeCompleto[0] : 'E',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    : ClipOval(
                        child: Image.network(
                          employee.fotoUrl,
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              employee.nomeCompleto.isNotEmpty ? employee.nomeCompleto[0] : 'E',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.nomeCompleto,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            employee.email,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
