import 'package:flutter/material.dart';

enum CourseCategory { science, technique, health, heritage }

extension CourseCategoryMeta on CourseCategory {
  String get label => {
        CourseCategory.science: 'Running Science',
        CourseCategory.technique: 'Technique & Health',
        CourseCategory.health: 'Technique & Health',
        CourseCategory.heritage: 'Heritage & Culture',
      }[this]!;

  IconData get icon => {
        CourseCategory.science: Icons.science_rounded,
        CourseCategory.technique: Icons.accessibility_new_rounded,
        CourseCategory.health: Icons.favorite_rounded,
        CourseCategory.heritage: Icons.account_balance_rounded,
      }[this]!;

  Color get accent => {
        CourseCategory.science: const Color(0xFF4A90E2),
        CourseCategory.technique: const Color(0xFF2BB673),
        CourseCategory.health: const Color(0xFFFF5A1F),
        CourseCategory.heritage: const Color(0xFFFFD15C),
      }[this]!;
}

class Lesson {
  final String title;
  final int minutes;
  final String summary;
  final List<String> paragraphs;

  const Lesson({
    required this.title,
    required this.minutes,
    required this.summary,
    required this.paragraphs,
  });
}

class Course {
  final String slug;
  final String title;
  final String subtitle;
  final CourseCategory category;
  final String author;
  final List<Lesson> lessons;

  const Course({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.author,
    required this.lessons,
  });

  int get minutes => lessons.fold(0, (s, l) => s + l.minutes);
}

const List<Course> courses = [
  Course(
    slug: 'how-to-start-running',
    title: 'How to Start Running',
    subtitle: 'From the sofa to your first 5K, one walk-run at a time.',
    category: CourseCategory.technique,
    author: 'Mwendo Coaches',
    lessons: [
      Lesson(
        title: 'Why Run?',
        minutes: 3,
        summary: 'The case for building a running habit.',
        paragraphs: [
          'Running is the most accessible sport on earth. No court, no club, no expensive kit — just you, a pair of shoes, and the open road.',
          'Regular running strengthens your heart, clears your mind, and builds a kind of confidence that spills into every corner of life. In Kenya it is also community: a shared language spoken from Nairobi to Eldoret.',
        ],
      ),
      Lesson(
        title: 'Gear You Actually Need',
        minutes: 4,
        summary: 'Keep it simple and kind to your joints.',
        paragraphs: [
          'A proper pair of running shoes is the single best investment you can make. Visit a specialist shop and get fitted — the right shoe prevents most beginner injuries.',
          'Everything else — watches, vests, headphones — is optional. Start with what you have and add only what genuinely helps you show up.',
        ],
      ),
      Lesson(
        title: 'The Walk-Run Method',
        minutes: 5,
        summary: 'The gentle on-ramp to continuous running.',
        paragraphs: [
          'Run for one minute, walk for two. Repeat. This simple ratio builds aerobic base without overwhelming untrained legs.',
          'Over weeks, tip the balance toward more running and less walking. Most beginners reach a continuous 30 minutes within two months.',
        ],
      ),
      Lesson(
        title: 'Warming Up & Cooling Down',
        minutes: 4,
        summary: 'Protect your body before and after.',
        paragraphs: [
          'A brisk five-minute walk plus dynamic leg swings prepares muscles and joints for effort.',
          'Afterward, walk calmly and stretch the big muscle groups. Your future self — and your knees — will thank you.',
        ],
      ),
      Lesson(
        title: 'Your First 5K Plan',
        minutes: 6,
        summary: 'An eight-week path to 5 kilometres.',
        paragraphs: [
          'Three sessions a week is enough. Alternate walk-run days with rest, and add one longer weekend effort.',
          'By week eight, lace up for a measured 5K. Go easy, enjoy it, and celebrate — you are now a runner.',
        ],
      ),
      Lesson(
        title: 'Staying Motivated',
        minutes: 4,
        summary: 'Habits that survive the rainy season.',
        paragraphs: [
          'Habit beats motivation. Lay your kit out the night before and treat the run as a non-negotiable appointment.',
          'Track every step in Mwendo, chase a streak, and let the heritage of East African champions pull you forward on the hard days.',
        ],
      ),
    ],
  ),
  Course(
    slug: 'heart-rate-zones',
    title: 'Heart Rate Zones',
    subtitle: 'Train smarter by listening to your pulse.',
    category: CourseCategory.science,
    author: 'Dr. A. Were',
    lessons: [
      Lesson(
        title: 'The Five Zones',
        minutes: 5,
        summary: 'What each intensity band does for you.',
        paragraphs: [
          'Zone 1–2 (recovery, aerobic) build the engine. Zone 3 (tempo) raises threshold. Zone 4–5 (threshold, anaerobic) sharpen speed.',
          'Most of your weekly volume should sit comfortably in Zones 1–2. The famous Kenyan "easy days easy" rule is built on this.',
        ],
      ),
      Lesson(
        title: 'Finding Your Max',
        minutes: 4,
        summary: 'A safe estimate without a lab.',
        paragraphs: [
          'A rough max is 220 minus your age, but individual variety is large. Use feel and the talk test: in Zone 2 you can hold a conversation.',
          'Over time, the same pace will drop your heart rate — the clearest sign your fitness is climbing.',
        ],
      ),
    ],
  ),
  Course(
    slug: 'running-form',
    title: 'Effortless Running Form',
    subtitle: 'Posture, cadence and foot strike.',
    category: CourseCategory.technique,
    author: 'Mwendo Coaches',
    lessons: [
      Lesson(
        title: 'Posture & Relaxation',
        minutes: 4,
        summary: 'Run tall, relax the shoulders.',
        paragraphs: [
          'A slight forward lean from the ankles, a soft knee, and relaxed arms keep you efficient and injury-free.',
          'Tension in the neck and fists wastes energy. Check in every few minutes and shake it out.',
        ],
      ),
      Lesson(
        title: 'Cadence & Stride',
        minutes: 5,
        summary: 'Why ~180 steps per minute matters.',
        paragraphs: [
          'A quicker, shorter stride reduces braking forces and landing impact. Aim for around 170–180 steps per minute.',
          'Don\'t force it overnight — let cadence rise naturally as your fitness and strength improve.',
        ],
      ),
    ],
  ),
  Course(
    slug: 'nutrition-for-runners',
    title: 'Fuel for the Run',
    subtitle: 'Eat like a champion, the Kenyan way.',
    category: CourseCategory.health,
    author: 'Mwendo Coaches',
    lessons: [
      Lesson(
        title: 'Everyday Nutrition',
        minutes: 5,
        summary: 'Carbs are your friend.',
        paragraphs: [
          'The staple of many champion training camps is simple: ugali, vegetables, rice, beans and tea. Plenty of carbohydrates, modest protein, little processed food.',
          'Fuel the day around your runs — a light carbohydrate snack an hour before, a balanced meal after.',
        ],
      ),
      Lesson(
        title: 'Hydration',
        minutes: 3,
        summary: 'Drink to thirst, plan for heat.',
        paragraphs: [
          'For most runs, water to thirst is enough. In heat or on long efforts, add a little salt and carbohydrate.',
        ],
      ),
    ],
  ),
  Course(
    slug: 'injury-prevention',
    title: 'Stay Injury-Free',
    subtitle: 'Strength, rest and listening to pain.',
    category: CourseCategory.health,
    author: 'Dr. A. Were',
    lessons: [
      Lesson(
        title: 'The 10% Rule',
        minutes: 4,
        summary: 'Grow volume gradually.',
        paragraphs: [
          'Increase weekly distance by no more than about 10%. Most injuries come from doing too much, too soon.',
        ],
      ),
      Lesson(
        title: 'Strength for Runners',
        minutes: 5,
        summary: 'A little goes a long way.',
        paragraphs: [
          'Two short sessions a week of squats, calf raises and single-leg work protect knees, ankles and hips.',
          'Strong feet and hips are the unsung heroes behind every sub-2:05 marathon.',
        ],
      ),
    ],
  ),
  Course(
    slug: 'women-in-running',
    title: 'Women in Running',
    subtitle: 'Strength, physiology and community.',
    category: CourseCategory.health,
    author: 'Mwendo Community',
    lessons: [
      Lesson(
        title: 'Training Through Life',
        minutes: 5,
        summary: 'Adapting to the female body.',
        paragraphs: [
          'Hormonal cycles affect energy and recovery. Track how you feel and adjust hard days accordingly — there is no single right answer.',
          'From Tegla Loroupe to Faith Kipyegon, women have rewritten the record books. Your run is part of that lineage.',
        ],
      ),
    ],
  ),
  Course(
    slug: 'altitude-training',
    title: 'The Altitude Advantage',
    subtitle: 'Why the Rift Valley makes champions.',
    category: CourseCategory.heritage,
    author: 'Mwendo Heritage',
    lessons: [
      Lesson(
        title: 'Life at 2,400 Metres',
        minutes: 6,
        summary: 'Erythropoiesis and red dirt.',
        paragraphs: [
          'Training at altitude stimulates extra red-blood-cell production, boosting oxygen delivery when athletes return to sea level.',
          'The red-dirt roads of Iten and Kaptagat are soft and forgiving on joints, and the close-knit camps turn training into a shared ritual.',
        ],
      ),
      Lesson(
        title: 'Can You Train Like Them?',
        minutes: 5,
        summary: 'What travels, and what doesn\'t.',
        paragraphs: [
          'You can borrow the discipline, the easy-day patience, and the community mindset anywhere. True altitude camps are a bonus, not a prerequisite.',
        ],
      ),
    ],
  ),
  Course(
    slug: 'history-of-east-african-running',
    title: 'A History of Greatness',
    subtitle: 'From pre-colonial traditions to global dominance.',
    category: CourseCategory.heritage,
    author: 'Mwendo Heritage',
    lessons: [
      Lesson(
        title: 'The First Steps',
        minutes: 6,
        summary: 'Roots of a running culture.',
        paragraphs: [
          'Long before world records, running was woven into community life across the Rift Valley — messages carried on foot, cattle trails turned to races.',
          'Independence-era athletes carried national pride onto the world stage, laying the foundation for everything that followed.',
        ],
      ),
      Lesson(
        title: 'Mexico 1968 & Beyond',
        minutes: 7,
        summary: 'Kipchoge Keino ignites an era.',
        paragraphs: [
          'Kipchoge Keino\'s 1968 Olympic gold announced East Africa as a distance-running powerhouse and inspired generations.',
          'Decades later the torch passed to Tergat, then Kipchoge and Kipyegon — a continuous relay of excellence.',
        ],
      ),
    ],
  ),
  Course(
    slug: 'the-thursday-fartlek',
    title: 'The Thursday Fartlek',
    subtitle: 'The group workout that built an empire.',
    category: CourseCategory.heritage,
    author: 'Mwendo Heritage',
    lessons: [
      Lesson(
        title: '15 km, Effort Over Pace',
        minutes: 6,
        summary: 'The legendary session, decoded.',
        paragraphs: [
          'Every Thursday, champions gather for a 15 km effort built on 3/1, 2/1 and 1/1 minute surges. The pace is dictated by feel, never the watch.',
          'The philosophy — clear lactate, build resilience, and suffer together — is the soul of Kenyan training.',
        ],
      ),
    ],
  ),
  Course(
    slug: 'training-camps',
    title: 'The Valley of Champions',
    subtitle: 'Iten, Kaptagat, Eldoret and Ngong.',
    category: CourseCategory.heritage,
    author: 'Mwendo Heritage',
    lessons: [
      Lesson(
        title: 'A Map of Camps',
        minutes: 5,
        summary: 'Where legends are made.',
        paragraphs: [
          'Iten sits high above the Great Rift Valley and calls itself the "City of Champions". Nearby Kaptagat hosts the famous forest tempo runs.',
          'Eldoret and Ngong each add their own chapters to the story — proof that place, community and purpose shape performance as much as training plans.',
        ],
      ),
    ],
  ),
];

Course courseForSlug(String slug) =>
    courses.firstWhere((c) => c.slug == slug, orElse: () => courses.first);
