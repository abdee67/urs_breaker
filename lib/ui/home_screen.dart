import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../providers/goal_provider.dart';
import 'widgets/goal_card_wrapper.dart';
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          final padding = isDesktop ? 40.0 : 20.0;

          if (isDesktop) {
            // --------------------------------------------
            // DESKTOP LAYOUT (Row)
            // --------------------------------------------
            return Row(
              children: [
                // Permanent Sidebar
                Container(
                  width: _sidebarWidth,
                  decoration: BoxDecoration(
                    color: ShadTheme.of(context).colorScheme.card,
                    border: Border(
                      right: BorderSide(
                        color: ShadTheme.of(context).colorScheme.border,
                      ),
                    ),
                  ),
                  child: _buildSidebarContent(goalsAsync, isDesktop: true),
                ),
                // Main Content
                Expanded(
                  child: _buildMainContent(padding, showMenuButton: false),
                ),
              ],
            );
          } else {
            // --------------------------------------------
            // MOBILE LAYOUT (Stack)
            // --------------------------------------------
            return Stack(
              children: [
                // Main Content
                Positioned.fill(
                  child: _buildMainContent(padding, showMenuButton: true),
                ),

                // Dim background
                if (_sidebarOpen)
                  AnimatedOpacity(
                    opacity: _sidebarOpen ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: () => setState(() => _sidebarOpen = false),
                      child: Container(color: Colors.black.withOpacity(0.35)),
                    ),
                  ),

                // Sliding Sidebar
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  left: _sidebarOpen ? 0 : -_sidebarWidth - 40,
                  top: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        width: _sidebarWidth,
                        color: ShadTheme.of(
                          context,
                        ).colorScheme.card.withOpacity(0.85),
                        child: _buildSidebarContent(
                          goalsAsync,
                          isDesktop: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMainContent(double padding, {required bool showMenuButton}) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showMenuButton)
                ShadButton(
                  onPressed: () => setState(() => _sidebarOpen = true),
                  child: const Icon(Icons.menu),
                )
              else
                const SizedBox.shrink(), // Placeholder to keep alignment if needed, or remove
              const Spacer(),
              RichText(
                text: TextSpan(
                  text: "URS",
                  style: ShadTheme.of(context).textTheme.h3.copyWith(
                    color: Colors.white,
                    fontFamily: "Poppins",
                  ),
                  children: [
                    TextSpan(
                      text: "Breaker",
                      style: ShadTheme.of(context).textTheme.h3.copyWith(
                        color: Colors.orange,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
              ),

              // If we want the title centered in desktop, we might need Spacer()
              if (showMenuButton)
                const SizedBox(width: 40)
              else
                const SizedBox.shrink(),
            ],
          ),

          const SizedBox(height: 24),

          // Input Area
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
                      (context, controller, focusNode, onFieldSubmitted) {
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
                              color: ShadTheme.of(context).colorScheme.border,
                            ),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
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
                        child: SpinKitDancingSquare(
                          color: Colors.black,
                          size: 16,
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
                    child: GoalCardWrapper(goal: _selectedGoal!),
                  )
                : _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitDancingSquare(color: Colors.white, size: 80),
                        Text(
                          "Loading...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 50,
                          color: Colors.orange,
                        ),
                        Text(
                          "Select or Write down a goal to view details",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(
    AsyncValue<List<Goal>> goalsAsync, {
    required bool isDesktop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Close button (only for mobile)
        if (!isDesktop)
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(25.0),
            child: ShadButton(
              backgroundColor: Colors.orange,
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
              onPressed: () => setState(() => _sidebarOpen = false),
            ),
          )
        else
          const SizedBox(height: 24), // Spacing for desktop

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("History", style: ShadTheme.of(context).textTheme.h4),
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
                        if (!isDesktop) {
                          _sidebarOpen = false;
                        }
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
                        border: isSelected && isDesktop
                            ? Border(
                                right: BorderSide(
                                  color: ShadTheme.of(
                                    context,
                                  ).colorScheme.primary,
                                  width: 3,
                                ),
                              )
                            : null,
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
            loading: () => const Center(
              child: SpinKitDancingSquare(color: Colors.white, size: 50),
            ),
            error: (err, stack) => Center(child: Text("Error: $err")),
          ),
        ),
      ],
    );
  }
}
