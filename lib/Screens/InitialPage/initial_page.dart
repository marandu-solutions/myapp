// Arquivo: lib/screens/Dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import '../../themes.dart';

// --- Modelos de Dados para o Dashboard (Simulação) ---
// A lógica dos modelos foi mantida
class MetricData {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool isIncrease;

  MetricData({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    this.isIncrease = true,
  });
}

class FeedbackData {
  final String user;
  final String comment;
  final int rating;
  final String avatarUrl;

  FeedbackData({
    required this.user,
    required this.comment,
    required this.rating,
    required this.avatarUrl,
  });
}

// --- Tela Principal do Dashboard ---
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  // A lógica de dados de exemplo foi mantida, apenas as cores foram atualizadas para usar o tema
  static final List<MetricData> _metrics = [
    MetricData(title: 'Lucro Total (Mês)', value: 'R\$ 7.850', change: '+12.5%', icon: Icons.attach_money, color: AppTheme.colorSuccess),
    MetricData(title: 'Agendamentos (Mês)', value: '154', change: '+8.2%', icon: Icons.calendar_today, color: const Color(0xFF0D63F3)), // Cor primária do tema
    MetricData(title: 'Novos Clientes', value: '23', change: '+2.1%', icon: Icons.person_add_alt_1, color: AppTheme.colorWarning),
    MetricData(title: 'Taxa de Ocupação', value: '72%', change: '-1.8%', icon: Icons.pie_chart, color: Colors.purple, isIncrease: false),
  ];

  static final List<FeedbackData> _feedbacks = [
    FeedbackData(user: 'Ana Clara', comment: 'A quadra nova ficou excelente! Iluminação perfeita.', rating: 5, avatarUrl: ''),
    FeedbackData(user: 'Ricardo Mendes', comment: 'O processo de agendamento pelo app é muito rápido.', rating: 5, avatarUrl: ''),
    FeedbackData(user: 'Lúcia Ferreira', comment: 'Sugestão: poderiam adicionar bebedouros perto da quadra B.', rating: 4, avatarUrl: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // A cor de fundo é herdada do tema
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 1200 ? 2 : 4);

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: DashboardHeader()),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => MetricCard(metric: _metrics[index]),
                    childCount: _metrics.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                sliver: SliverToBoxAdapter(
                  child: constraints.maxWidth < 900
                      ? Column(
                    children: [
                      const ProfitChartCard(),
                      const SizedBox(height: 16),
                      FeedbackCard(feedbacks: _feedbacks),
                    ],
                  )
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 3, child: ProfitChartCard()),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: FeedbackCard(feedbacks: _feedbacks)),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

// --- Componentes da UI ---

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Painel de Controle', style: textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Resumo do desempenho do seu negócio.',
            style: textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final MetricData metric;
  const MetricCard({Key? key, required this.metric}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: metric.color.withOpacity(0.1),
              child: Icon(metric.icon, color: metric.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(metric.title, style: textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(metric.value, style: textTheme.headlineSmall),
                      const SizedBox(width: 8),
                      Text(
                        metric.change,
                        style: textTheme.labelLarge?.copyWith(
                          color: metric.isIncrease ? AppTheme.colorSuccess : AppTheme.colorError,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfitChartCard extends StatelessWidget {
  const ProfitChartCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lucro por Dia', style: textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final style = textTheme.bodySmall;
                          Widget text;
                          switch (value.toInt()) {
                            case 1: text = Text('Seg', style: style); break;
                            case 3: text = Text('Qua', style: style); break;
                            case 5: text = Text('Sex', style: style); break;
                            default: text = Text('', style: style); break;
                          }
                          // Apenas o widget de texto é retornado, como esperado pelas
                          // versões mais recentes da biblioteca fl_chart.
                          return text;
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5),
                        FlSpot(4, 4), FlSpot(5, 6), FlSpot(6, 6.5),
                      ],
                      isCurved: true,
                      color: colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackCard extends StatelessWidget {
  final List<FeedbackData> feedbacks;
  const FeedbackCard({Key? key, required this.feedbacks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feedbacks Recentes', style: textTheme.titleLarge),
            const SizedBox(height: 16),
            ...feedbacks.map((feedback) {
              final color = Colors.primaries[feedback.user.hashCode % Colors.primaries.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Text(
                        feedback.user[0],
                        style: TextStyle(color: color, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(feedback.user, style: textTheme.titleSmall),
                              const Spacer(),
                              ...List.generate(5, (index) => Icon(
                                index < feedback.rating ? Icons.star : Icons.star_border,
                                color: AppTheme.colorWarning,
                                size: 16,
                              )),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(feedback.comment, style: textTheme.bodyMedium),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
