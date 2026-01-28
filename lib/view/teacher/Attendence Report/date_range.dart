import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TimeframeScreen extends StatefulWidget {
  const TimeframeScreen({super.key});

  @override
  State<TimeframeScreen> createState() => _TimeframeScreenState();
}

class _TimeframeScreenState extends State<TimeframeScreen> with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  
  // Animation for the entry of elements
  late AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return DateFormat('EEEE,\nMMMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // 1. Animated Header
                _buildFadeSlideEffect(
                  index: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text("Select Timeframe",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Animated Date Display Cards
                _buildFadeSlideEffect(
                  index: 1,
                  child: Row(
                    children: [
                      _buildAnimatedDateCard("From", _formatDate(_rangeStart), _rangeStart != null),
                      const SizedBox(width: 10),
                      _buildAnimatedDateCard("To", _formatDate(_rangeEnd), _rangeEnd != null),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Animated Calendar Container
                _buildFadeSlideEffect(
                  index: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      rangeStartDay: _rangeStart,
                      rangeEndDay: _rangeEnd,
                      rangeSelectionMode: RangeSelectionMode.enforced,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      calendarStyle: const CalendarStyle(
                        rangeStartDecoration: BoxDecoration(color: Color(0xFF4A69BB), shape: BoxShape.circle),
                        rangeEndDecoration: BoxDecoration(color: Color(0xFF4A69BB), shape: BoxShape.circle),
                        rangeHighlightColor: Color(0xFFE8EFFF),
                        todayDecoration: BoxDecoration(color: Color(0x334A69BB), shape: BoxShape.circle),
                        todayTextStyle: TextStyle(color: Color(0xFF4A69BB), fontWeight: FontWeight.bold),
                      ),
                      onRangeSelected: (start, end, focusedDay) {
                        setState(() {
                          _rangeStart = start;
                          _rangeEnd = end;
                          _focusedDay = focusedDay;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 4. Animated Confirm Button
                _buildFadeSlideEffect(
                  index: 3,
                  child: _buildAnimatedButton(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Animation Helper ---
  Widget _buildFadeSlideEffect({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, anim) {
        final double delay = index * 0.15;
        final double start = delay;
        final double end = (delay + 0.5).clamp(0.0, 1.0);
        final curve = CurvedAnimation(
          parent: _entryController,
          curve: Interval(start, end, curve: Curves.easeOutQuart),
        );

        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curve.value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDateCard(String title, String dateText, bool isSelected) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A69BB) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 5),
            Text(dateText, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 12, 
                height: 1.4,
                color: isSelected ? const Color(0xFF4A69BB) : Colors.black87,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton() {
    bool isReady = _rangeStart != null && _rangeEnd != null;
    return GestureDetector(
      onTap: () {
        if (isReady) {
          Navigator.pop(context, {'start': _rangeStart, 'end': _rangeEnd});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a complete range", textAlign: TextAlign.center))
          );
        }
      },
      child: AnimatedScale(
        scale: isReady ? 1.0 : 0.98,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            gradient: isReady 
              ? const LinearGradient(colors: [Color(0xFF6A91E8), Color(0xFF4A69BB)])
              : const LinearGradient(colors: [Colors.grey, Colors.blueGrey]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isReady ? [
              BoxShadow(color: const Color(0xFF4A69BB).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
            ] : [],
          ),
          child: const Center(
            child: Text("Confirm & Generate", 
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}