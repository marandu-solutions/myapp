// Arquivo: lib/Screens/Employees/Employees List Screen/employees_screen.dart

import 'package:flutter/material.dart';
import 'package:myapp/Screens/Employees/Employee%20Info%20Screen/employee_info_screen.dart';
import 'package:myapp/models/employee_model.dart';
import 'package:myapp/services/employee_service.dart';

import 'components/add_employee.dart';

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
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // O AddEmployeeSheet já está estilizado, apenas o invocamos.
        return AddEmployeeSheet(
          onEmployeeAdded: _refreshEmployeeList,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // A cor de fundo é herdada automaticamente.
      appBar: AppBar(
        title: const Text('Gestão de Funcionários'),
        // A estilização da AppBar é herdada do appBarTheme.
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Lógica para a busca
            },
          ),
        ],
      ),
      body: FutureBuilder<List<EmployeeModel>>(
        future: _employeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    color: theme.colorScheme.primary));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar funcionários: ${snapshot.error}',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.error)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 60,
                      color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum funcionário encontrado.',
                    style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione um novo funcionário no botão +',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final employees = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return EmployeeCard(
                  employee: employee, onRefresh: _refreshEmployeeList);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeSheet,
        // O estilo do FAB é herdado do tema.
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Funcionário',
      ),
    );
  }
}

// Widget reutilizável para exibir as informações de cada funcionário
class EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback onRefresh; // Callback para atualizar a lista

  const EmployeeCard(
      {Key? key, required this.employee, required this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      // O estilo do Card (cor, sombra, borda) é herdado do cardTheme.
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () async {
          // Navega para a tela de detalhes e aguarda um possível retorno
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeInfoScreen(employee: employee),
            ),
          );
          // Quando voltar da tela de detalhes, atualiza a lista
          onRefresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                backgroundImage: employee.fotoUrl.isNotEmpty
                    ? NetworkImage(employee.fotoUrl)
                    : null,
                child: employee.fotoUrl.isEmpty
                    ? Text(
                  employee.nomeCompleto.isNotEmpty
                      ? employee.nomeCompleto[0].toUpperCase()
                      : 'E',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.nomeCompleto,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.email_outlined,
                            color: colorScheme.onSurfaceVariant, size: 16),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            employee.email,
                            style: textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
