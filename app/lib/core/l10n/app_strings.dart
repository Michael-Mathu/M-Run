import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLocale { english, swahili }

class LocaleNotifier extends Notifier<AppLocale> {
  @override
  AppLocale build() => AppLocale.english;

  void set(AppLocale l) => state = l;
  void toggle() =>
      state = state == AppLocale.english ? AppLocale.swahili : AppLocale.english;
}

final localeProvider = NotifierProvider<LocaleNotifier, AppLocale>(LocaleNotifier.new);

/// Lightweight i18n scaffold for the Phase 2 UI. English and Swahili are
/// provided for every key; missing keys fall back to English.
class L10n {
  static const Map<String, Map<String, String>> _strings = {
    'learn': {'en': 'Learn', 'sw': 'Jifunze'},
    'challenges': {'en': 'Challenges', 'sw': 'Changamoto'},
    'profile': {'en': 'Profile', 'sw': 'Wasifu'},
    'home': {'en': 'Home', 'sw': 'Mwanzo'},
    'run': {'en': 'Run', 'sw': 'Kimbia'},
    'academy': {'en': 'The Mwendo Academy', 'sw': 'Chuo cha Mwendo'},
    'academy_tag': {
      'en': 'Learn the science, the technique, and the heritage.',
      'sw': 'Jifunze sayansi, mbinu, na urithi.'
    },
    'running_science': {'en': 'Running Science', 'sw': 'Sayansi ya Kukimbia'},
    'technique_health': {'en': 'Technique & Health', 'sw': 'Mbinu na Afya'},
    'heritage': {'en': 'Heritage & Culture', 'sw': 'Urithi na Utamaduni'},
    'legends': {'en': 'East African Legends', 'sw': 'Mashujaa wa Afrika Mashariki'},
    'beat_the_legends': {'en': 'Beat the Legends', 'sw': 'Shindana na Mashujaa'},
    'continue_learning': {'en': 'Continue learning', 'sw': 'Endelea kujifunza'},
    'active_challenges': {'en': 'Active Challenges', 'sw': 'Changamoto Zilizo Hai'},
    'see_all': {'en': 'See all', 'sw': 'Tazama zote'},
    'recent_activity': {'en': 'Recent Activity', 'sw': 'Shughuli za Hivi Karibuni'},
    'your_streak': {'en': 'Your streak', 'sw': 'Msururu wako'},
    'level': {'en': 'Level', 'sw': 'Kiwango'},
    'leaderboard': {'en': 'Leaderboard', 'sw': 'Chati ya Wachezaji'},
    'achievements': {'en': 'Achievements', 'sw': 'Mafanikio'},
    'titles': {'en': 'Titles', 'sw': 'Majina'},
    'lessons': {'en': 'lessons', 'sw': 'masomo'},
    'mark_complete': {'en': 'Mark complete', 'sw': 'Weka alama ya kukamilika'},
    'completed': {'en': 'Completed', 'sw': 'Imekamilika'},
    'start_run': {'en': 'Go for a run', 'sw': 'Nenda ukimbi'},
    'challenge_me': {'en': 'Challenge me', 'sw': 'Nishindanishe'},
    'race_this_ghost': {'en': 'Race this ghost', 'sw': 'Shindana na mzuka'},
    'knowledge_streak': {'en': 'Knowledge streak', 'sw': 'Msururu wa Elimu'},
    'language': {'en': 'Language', 'sw': 'Lugha'},
    'english': {'en': 'English', 'sw': 'Kiingereza'},
    'swahili': {'en': 'Swahili', 'sw': 'Kiswahili'},
    'no_badges': {
      'en': 'Complete challenges and lessons to earn badges.',
      'sw': 'Kamilisha changamoto na masomo kupata beji.'
    },
    'rank': {'en': 'Rank', 'sw': 'Nafasi'},
    'activity': {'en': 'Activity', 'sw': 'Shughuli'},
    'all': {'en': 'All', 'sw': 'Zote'},
    'cat_starter': {'en': 'Starter', 'sw': 'Mwanzo'},
    'cat_milestone': {'en': 'Milestones', 'sw': 'Hatua'},
    'cat_performance': {'en': 'Performance', 'sw': 'Utendaji'},
    'cat_fun': {'en': 'Fun', 'sw': 'Mchezo'},
    'cat_school': {'en': 'School', 'sw': 'Shule'},
    'cat_knowledge': {'en': 'Learn', 'sw': 'Jifunze'},
    'go_for_a_run': {'en': 'Go for a run', 'sw': 'Nenda ukimbi'},
    'open_academy': {'en': 'Open the Academy', 'sw': 'Fungua Chuo'},
    'reward': {'en': 'Reward', 'sw': 'Tuzo'},
    'badge': {'en': 'Badge', 'sw': 'Beji'},
    'goal': {'en': 'Goal', 'sw': 'Lengo'},
    'challenge_complete': {'en': 'Challenge complete!', 'sw': 'Changamoto imekamilika!'},
    'pace_per_segment': {'en': 'Pace per segment', 'sw': 'Kasi kwa sehemu'},
    'seconds_per_km': {'en': 'Seconds per ~1 km · lower is faster', 'sw': 'Sekunde kwa ~1 km · chini ni haraka'},
    'during_a_run': {'en': 'During a run, hold the ghost\'s average pace to stay ahead. Their target: ', 'sw': 'Wakati wa kukimbia, shikilia kasi ya wastani ya mzuka. Lengo lao: '},
    'delete_activity': {'en': 'Delete activity?', 'sw': 'Futa shughuli?'},
    'delete_activity_body': {'en': 'This run will be removed from your history.', 'sw': 'Mbio hii itaondolewa kwenye historia yako.'},
    'delete': {'en': 'Delete', 'sw': 'Futa'},
    'cancel': {'en': 'Cancel', 'sw': 'Ghairi'},
    'nothing_recorded': {'en': 'Nothing recorded yet', 'sw': 'Hakuna kilichorekodiwa bado'},
    'first_run_prompt': {'en': 'Head out for your first run.', 'sw': 'Tokea kwa mbio yako ya kwanza.'},
    'runner': {'en': 'Runner', 'sw': 'Mkimbiaji'},
    'distance': {'en': 'Distance', 'sw': 'Umbali'},
    'runs': {'en': 'Runs', 'sw': 'Mbio'},
    'time': {'en': 'Time', 'sw': 'Muda'},
    'streak': {'en': 'Streak', 'sw': 'Msururu'},
    'units': {'en': 'Units', 'sw': 'Vipimo'},
    'appearance': {'en': 'Appearance', 'sw': 'Mwonekano'},
    'dark': {'en': 'Dark', 'sw': 'Giza'},
    'light': {'en': 'Light', 'sw': 'Mwangaza'},
    'system': {'en': 'System', 'sw': 'Mfumo'},
    'emergency_contacts': {'en': 'Emergency contacts', 'sw': 'Anwani za dharura'},
    'not_set': {'en': 'Not set', 'sw': 'Haijaseti'},
    'export_data': {'en': 'Export data', 'sw': 'Hamisha data'},
    'no_runs_yet': {'en': 'No runs yet', 'sw': 'Hakuna mbio bado'},
    'routes_will_show': {'en': 'Your routes will show up here.', 'sw': 'Njia zako zitaonekana hapa.'},
    'all_caught_up': {'en': 'All caught up!', 'sw': 'Umekwisha yote!'},
    'browse_more': {'en': 'Browse more challenges to keep the momentum.', 'sw': 'Tazama changamoto zaidi kuendelea.'},
    'this_week': {'en': 'This week', 'sw': 'Wiki hii'},
    'best': {'en': 'Best', 'sw': 'Bora'},
    'no_badges_yet': {'en': 'Complete challenges and lessons to earn badges.', 'sw': 'Kamilisha changamoto na masomo kupata beji.'},
    'metric': {'en': 'Metric (km)', 'sw': 'Metriki (km)'},
    'imperial': {'en': 'Imperial (mi)', 'sw': 'Imperial (mi)'},
    'filter': {'en': 'Filter', 'sw': 'Chuja'},
    'sort': {'en': 'Sort', 'sw': 'Panga'},
    'sort_date': {'en': 'Newest', 'sw': 'Mpya'},
    'sort_distance': {'en': 'Distance', 'sw': 'Umbali'},
    'sort_duration': {'en': 'Duration', 'sw': 'Muda'},
    'export_gpx': {'en': 'Export GPX', 'sw': 'Hamisha GPX'},
    'export_json': {'en': 'Export JSON', 'sw': 'Hamisha JSON'},
    'exported': {'en': 'Exported', 'sw': 'Imehamishwa'},
    'get_started': {'en': 'Start your first run', 'sw': 'Anza mbio yako ya kwanza'},
    'first_run_hint': {'en': 'Your weekly stats are empty. Tap below to record your first run and start your streak!', 'sw': 'Takwimu zako za wiki ni tupu. Gusa hapa chini kurekodi mbio yako ya kwanza na kuanisha msururu wako!'},
    'weekly_distance': {'en': 'Weekly distance', 'sw': 'Umbali wa wiki'},
    'weekly_runs': {'en': 'Weekly runs', 'sw': 'Mbio za wiki'},
    'weekly_best': {'en': 'Weekly best pace', 'sw': 'Kasi bora ya wiki'},
    'elevation': {'en': 'Elevation', 'sw': 'Mwinuko'},
    'calories': {'en': 'Calories', 'sw': 'Kalori'},
    'elev_gain': {'en': 'Elev. Gain', 'sw': 'Mwinuko'},
    'avg_hr': {'en': 'Avg HR', 'sw': 'HR ya Wastani'},
    'add_contact': {'en': 'Add contact', 'sw': 'Ongeza anwani'},
    'edit_contact': {'en': 'Edit contact', 'sw': 'Hariri anwani'},
    'name': {'en': 'Name', 'sw': 'Jina'},
    'phone': {'en': 'Phone', 'sw': 'Simu'},
    'relationship': {'en': 'Relationship', 'sw': 'Uhusiano'},
    'save': {'en': 'Save', 'sw': 'Hifadhi'},
    'no_contacts_yet': {'en': 'No contacts yet. Tap Add to include someone.', 'sw': 'Hakuna anwani bado. Gusa Ongeza kuongeza mtu.'},
    'create_account': {'en': 'Create account', 'sw': 'Fungua akaunti'},
    'sign_in': {'en': 'Sign in', 'sw': 'Ingia'},
    'email': {'en': 'Email', 'sw': 'Barua pepe'},
    'password': {'en': 'Password', 'sw': 'Nenosiri'},
    'have_account': {'en': 'Already have an account? Sign in', 'sw': 'Tayari una akaunti? Ingia'},
    'need_account': {'en': 'Need an account? Register', 'sw': 'Unahitaji akaunti? Jisajili'},
    'continue_anonymous': {'en': 'Continue anonymously', 'sw': 'Endelea bila jina'},
    'account': {'en': 'Account', 'sw': 'Akaunti'},
    'sign_out': {'en': 'Sign out', 'sw': 'Toka'},
    'submitted': {'en': 'Run synced to leaderboard', 'sw': 'Mbio imesawazishwa kwenye ubao'},
  };

  static String tr(String key, AppLocale locale) {
    final lang = locale == AppLocale.swahili ? 'sw' : 'en';
    return _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
  }
}

extension L10nRef on WidgetRef {
  String tr(String key) => L10n.tr(key, read(localeProvider));
}
