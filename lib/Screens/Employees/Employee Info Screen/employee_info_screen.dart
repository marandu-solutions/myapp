import 'package:flutter/material.dart';
import 'package:myapp/models/employee_model.dart'; // Ajuste o caminho se necessário
import 'package:myapp/services/employee_service.dart'; // Ajuste o caminho se necessário

class EmployeeInfoScreen extends StatefulWidget {
  final EmployeeModel employee;

  const EmployeeInfoScreen({Key? key, required this.employee}) : super(key: key);

  @override
  _EmployeeInfoScreenState createState() => _EmployeeInfoScreenState();
}

class _EmployeeInfoScreenState extends State<EmployeeInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final EmployeeService _employeeService = EmployeeService();

  late TextEditingController _nameController;
  late TextEditingController _cpfController;
  late TextEditingController _phoneController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados do funcionário
    _nameController = TextEditingController(text: widget.employee.nomeCompleto);
    _cpfController = TextEditingController(text: widget.employee.cpf);
    _phoneController = TextEditingController(text: widget.employee.telefone);
  }

  @override
  void dispose() {
    // Libera os recursos dos controladores
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedData = {
          'nomeCompleto': _nameController.text,
          'cpf': _cpfController.text,
          'telefone': _phoneController.text,
        };

        await _employeeService.updateEmployee(widget.employee.uid, updatedData);

        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionário atualizado com sucesso!'), backgroundColor: Colors.green),
          );
          setState(() {
            _isEditing = false;
          });
        }
      } catch (e) {
         if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red),
            );
         }
      } finally {
        if(mounted){
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Funcionário' : widget.employee.nomeCompleto),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        actions: [
          // Botão que alterna entre editar e salvar
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined),
              tooltip: _isEditing ? 'Salvar Alterações' : 'Editar Funcionário',
              onPressed: () {
                if (_isEditing) {
                  _saveChanges();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        backgroundImage: widget.employee.fotoUrl.isNotEmpty
                            ? NetworkImage(widget.employee.fotoUrl)
                            : null,
                        child: widget.employee.fotoUrl.isEmpty
                            ? Text(
                                widget.employee.nomeCompleto.isNotEmpty ? widget.employee.nomeCompleto[0] : 'E',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // O nome também se torna editável
                      EditableInfoField(
                        isEditing: _isEditing,
                        controller: _nameController,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.employee.email, // E-mail não é editável
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Informações Pessoais',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                EditableInfoField(
                  isEditing: _isEditing,
                  controller: _cpfController,
                  label: 'CPF',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),
                EditableInfoField(
                  isEditing: _isEditing,
                  controller: _phoneController,
                  label: 'Telefone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // O status pode ser editado com um Switch
                _isEditing
                    ? SwitchListTile(
                        title: const Text('Funcionário Ativo'),
                        value: widget.employee.ativo,
                        onChanged: (bool value) {
                          // Lógica para atualizar o status 'ativo'
                        },
                        secondary: Icon(widget.employee.ativo ? Icons.check_circle_outline : Icons.highlight_off_outlined,
                            color: widget.employee.ativo ? Colors.green : Colors.grey),
                      )
                    : Row(
                        children: [
                          Icon(
                            widget.employee.ativo ? Icons.check_circle_outline : Icons.highlight_off_outlined,
                            color: widget.employee.ativo ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(widget.employee.ativo ? 'Ativo' : 'Inativo',
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                const SizedBox(height: 32),
                if (!_isEditing)
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Deletar Funcionário', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        // Lógica para confirmar e deletar o funcionário
                      },
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

// Widget auxiliar para alternar entre texto e campo de formulário
class EditableInfoField extends StatelessWidget {
  final bool isEditing;
  final TextEditingController controller;
  final String? label;
  final IconData? icon;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextInputType? keyboardType;

  const EditableInfoField({
    Key? key,
    required this.isEditing,
    required this.controller,
    this.label,
    this.icon,
    this.style,
    this.textAlign = TextAlign.start,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: controller,
          style: style,
          textAlign: textAlign,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            icon: icon != null ? Icon(icon, color: Colors.blue) : null,
            border: const UnderlineInputBorder(),
            contentPadding: const EdgeInsets.only(bottom: 4),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo não pode ser vazio';
            }
            return null;
          },
        ),
      );
    } else {
      // Se não estiver editando, exibe o InfoTile
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.blue, size: 20),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  if (label != null) const SizedBox(height: 2),
                  Text(
                    controller.text,
                    style: style ?? Theme.of(context).textTheme.titleMedium,
                    textAlign: textAlign,
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }
  }
}
