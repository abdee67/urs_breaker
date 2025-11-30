import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../providers/goal_provider.dart';
import 'widgets/goal_card.dart';
import '../models/goal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  Goal? _selectedGoal;

  // Sidebar state
  bool _sidebarOpen = false;
  final double _sidebarWidth = 260;

  final List<String> _sampleGoals = [
    "Launch a startup",
    "Learn Flutter",
    "Run a marathon",
    "Write a book",
    "Learn to cook",
    "Build a mobile app",
    "Travel to Japan",
  ];

  Future<void> _submitGoal() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(goalsProvider.notifier).addGoal(_controller.text);
      _controller.clear();

      // Auto-select the newly created goal (it will be first in the list)
      final goals = await ref.read(goalsProvider.future);
      if (goals.isNotEmpty) {
        setState(() {
          _selectedGoal = goals.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // --------------------------------------------
          // MAIN CONTENT
          // --------------------------------------------
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with toggle button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShadButton(
                        onPressed: () => setState(() => _sidebarOpen = true),
                        child: const Icon(Icons.menu),
                      ),
                      Text(
                        "URS Breaker",
                        style: ShadTheme.of(context).textTheme.h3,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _sampleGoals;
                            }
                            return _sampleGoals.where((String option) {
                              return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                            });
                          },
                          onSelected: (String selection) {
                            _controller.text = selection;
                          },
                          fieldViewBuilder:
                              (
                                context,
                                controller,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                // Sync with our main controller
                                _controller.addListener(() {
                                  if (_controller.text != controller.text) {
                                    controller.text = _controller.text;
                                  }
                                });
                                controller.addListener(() {
                                  if (_controller.text != controller.text) {
                                    _controller.text = controller.text;
                                  }
                                });

                                return ShadInput(
                                  controller: controller,
                                  focusNode: focusNode,
                                  placeholder: const Text(
                                    'Enter a vague goal (e.g., "Launch a startup")',
                                  ),
                                );
                              },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(8),
                                color: ShadTheme.of(context).colorScheme.card,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                    maxWidth: 300,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: ShadTheme.of(
                                        context,
                                      ).colorScheme.border,
                                    ),
                                  ),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(8.0),
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final String option = options
                                              .elementAt(index);
                                          return InkWell(
                                            onTap: () => onSelected(option),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              child: Text(option),
                                            ),
                                          );
                                        },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ShadButton(
                        onPressed: _isLoading ? null : _submitGoal,
                        child: Row(
                          children: [
                            if (_isLoading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              const Icon(Icons.auto_awesome, size: 16),
                            const SizedBox(width: 8),
                            const Text("Break it"),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Expanded(
                    child: _selectedGoal != null
                        ? SingleChildScrollView(
                            child: GoalCard(goal: _selectedGoal!),
                          )
                        : _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const Center(
                            child: Text("Select a goal to view details"),
                          ),
                  ),
                ],
              ),
            ),
          ),

          // --------------------------------------------
          // DIM BACKGROUND WHEN SIDEBAR IS OPEN
          // --------------------------------------------
          if (_sidebarOpen)
            AnimatedOpacity(
              opacity: _sidebarOpen ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => setState(() => _sidebarOpen = false),
                child: Container(color: Colors.black.withOpacity(0.35)),
              ),
            ),

          // --------------------------------------------
          // TELEGRAM STYLE SLIDING SIDEBAR
          // --------------------------------------------
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            left: _sidebarOpen ? 0 : -_sidebarWidth - 40,
            top: 0,
            bottom: 0,
            child: _buildSidebar(goalsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(AsyncValue<List<Goal>> goalsAsync) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: _sidebarWidth,
          color: ShadTheme.of(context).colorScheme.card.withOpacity(0.85),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(25.0),
                child: ShadButton(
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.arrow_back_ios_new, size: 16),
                  onPressed: () => setState(() => _sidebarOpen = false),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "History",
                  style: ShadTheme.of(context).textTheme.h4,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: goalsAsync.when(
                  data: (goals) {
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        final isSelected = goal.id == _selectedGoal?.id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedGoal = goal;
                              _sidebarOpen = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ShadTheme.of(context).colorScheme.muted
                                  : Colors.transparent,
                            ),
                            child: Text(
                              goal.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text("Error: $err")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
