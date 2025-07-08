// Arquivo: lib/screens/Dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

// --- Modelos de Dados para o Dashboard (Simulação) ---
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

  // Dados de exemplo (mock data)
  static final List<MetricData> _metrics = [
    MetricData(title: 'Lucro Total (Mês)', value: 'R\$ 7.850', change: '+12.5%', icon: Icons.attach_money, color: Colors.green),
    MetricData(title: 'Agendamentos (Mês)', value: '154', change: '+8.2%', icon: Icons.calendar_today, color: Colors.blue),
    MetricData(title: 'Novos Clientes', value: '23', change: '+2.1%', icon: Icons.person_add_alt_1, color: Colors.orange),
    MetricData(title: 'Taxa de Ocupação', value: '72%', change: '-1.8%', icon: Icons.pie_chart, color: Colors.purple, isIncrease: false),
  ];

  static final List<FeedbackData> _feedbacks = [
    FeedbackData(user: 'Ana Clara', comment: 'A quadra nova ficou excelente! Iluminação perfeita.', rating: 5, avatarUrl: ''),
    FeedbackData(user: 'Ricardo Mendes', comment: 'O processo de agendamento pelo app é muito rápido.', rating: 5, avatarUrl: ''),
    FeedbackData(user: 'Lúcia Ferreira', comment: 'Sugestão: poderiam adicionar bebedouros perto da quadra B.', rating: 4, avatarUrl: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Define o número de colunas do grid com base na largura da tela
          final crossAxisCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 1200 ? 2 : 4);

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: DashboardHeader()),
              // Grid para os cards de métricas
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.5, // Proporção dos cards
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => MetricCard(metric: _metrics[index]),
                    childCount: _metrics.length,
                  ),
                ),
              ),
              // Gráfico de Lucro e Feedbacks
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverToBoxAdapter(
                  child: constraints.maxWidth < 900
                      ? Column( // Layout em coluna para telas menores
                    children: [
                      const ProfitChartCard(),
                      const SizedBox(height: 16),
                      FeedbackCard(feedbacks: _feedbacks),
                    ],
                  )
                      : Row( // Layout em linha para telas maiores
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Painel de Controle',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Resumo do desempenho do seu negócio.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
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
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  Text(metric.title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(metric.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(
                        metric.change,
                        style: TextStyle(
                          color: metric.isIncrease ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lucro por Dia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 1: return const Text('Seg');
                            case 3: return const Text('Qua');
                            case 5: return const Text('Sex');
                          }
                          return const Text('');
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
                      color: Colors.blue,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
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
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Feedbacks Recentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...feedbacks.map((feedback) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Text(feedback.user[0]),
                    backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)].withOpacity(0.2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(feedback.user, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            ...List.generate(5, (index) => Icon(
                              index < feedback.rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            )),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(feedback.comment, style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  )
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
