/// Interactive profiles of East African running legends (Pillar 3).
/// Avatars use emoji so the experience works fully offline.
library;

import 'package:flutter/material.dart';

const _kKenya = 'orange';
const _kEthiopia = 'gold';
const _kUganda = 'green';
const _kNetherlands = 'gold';

/// A categorized quote for a legend.
class LegendQuote {
  final String category; // 'training' | 'racing' | 'life' | 'legacy'
  final String text;
  const LegendQuote(this.category, this.text);

  static const Map<String, (IconData, String)> categoryMeta = {
    'training': (Icons.directions_run_rounded, 'Training'),
    'racing': (Icons.emoji_events_rounded, 'Racing'),
    'life': (Icons.psychology_rounded, 'Life'),
    'legacy': (Icons.auto_stories_rounded, 'Legacy'),
  };
}

class LegendMilestone {
  final String year;
  final String text;
  const LegendMilestone(this.year, this.text);
}

class Legend {
  final String slug;
  final String name;
  final String country;
  final String flag;
  final String discipline;
  final String tagline;
  final String bio;
  final List<LegendMilestone> timeline;
  final List<String> records;
  final List<String> quotes;
  final String emoji;
  final String accent; // hex-like color name resolved below
  final String? beatLegendId;

  // ---- New fields (Pillar 3 expansion) ----
  final Map<String, String>? personalBests;
  final String? trainingPhilosophy;
  final List<String>? rivalries; // rival legend slugs
  final List<String>? notableRaces;
  final String? funFact;
  final List<String>? relatedLegends; // related legend slugs
  final List<LegendQuote>? quotesExtra;
  final String? relatedCourseSlug;
  final int? eraStartYear;

  const Legend({
    required this.slug,
    required this.name,
    required this.country,
    required this.flag,
    required this.discipline,
    required this.tagline,
    required this.bio,
    required this.timeline,
    required this.records,
    required this.quotes,
    required this.emoji,
    required this.accent,
    this.beatLegendId,
    this.personalBests,
    this.trainingPhilosophy,
    this.rivalries,
    this.notableRaces,
    this.funFact,
    this.relatedLegends,
    this.quotesExtra,
    this.relatedCourseSlug,
    this.eraStartYear,
  });

  /// Era bucket label derived from the first career year.
  String get eraLabel {
    final year = eraStartYear ??
        int.tryParse(timeline.isNotEmpty ? timeline.first.year : '') ?? 2000;
    if (year <= 1979) return '1960s–70s';
    if (year <= 1999) return '1980s–90s';
    if (year <= 2019) return '2000s–10s';
    return '2020s+';
  }

  List<Legend> get rivals =>
      (rivalries ?? []).map(legendForSlug).toList();

  List<Legend> get related =>
      (relatedLegends ?? []).map(legendForSlug).toList();
}

const List<Legend> legends = [
  Legend(
    slug: 'eliud-kipchoge',
    name: 'Eliud Kipchoge',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Marathon',
    tagline: 'The philosopher of the marathon.',
    bio: 'Widely considered the greatest marathoner of all time, Kipchoge broke the 2-hour barrier in an exhibition and set the official world record of 2:01:09 in Berlin 2022. His calm, methodical approach turned racing into a craft.',
    timeline: [
      LegendMilestone('2003', 'World 5000m bronze in Paris'),
      LegendMilestone('2013', 'Transitions to the marathon'),
      LegendMilestone('2016', 'Olympic marathon gold, Rio'),
      LegendMilestone('2018', 'World record 2:01:39, Berlin'),
      LegendMilestone('2019', 'Runs 1:59:40 in Vienna (exhibition)'),
      LegendMilestone('2022', 'World record 2:01:09, Berlin'),
    ],
    records: ['Marathon WR 2:01:09 (Berlin 2022)', 'First sub-2 hour marathon (exhibition)'],
    quotes: ['No human is limited.', 'The will is what matters most.'],
    emoji: '🏃',
    accent: _kKenya,
    beatLegendId: 'kipchoge-marathon',
    eraStartYear: 2003,
    personalBests: {
      'Marathon': '2:01:09',
      'Half Marathon': '59:25',
      '10,000m': '27:36.55',
      '5000m': '12:46.53',
    },
    trainingPhilosophy:
        'Kipchoge trains at the high-altitude Kaptagat camp, where the week is built around a Tuesday tempo and the legendary Thursday fartlek. He preaches patience: easy days are genuinely easy, and every rep is run by feel, not by the watch. "Train your mind, and the body will follow," he says — discipline and joy, in equal measure, are the engine of his consistency.',
    rivalries: ['kelvin-kiptum'],
    notableRaces: [
      'Berlin 2022 — World record 2:01:09, a masterclass in controlled pacing.',
      'Vienna 2019 — 1:59:40, the first marathon ever run under two hours (exhibition).',
      'Rio 2016 — Olympic gold in his first marathon major.',
    ],
    funFact: 'Kipchoge\'s favourite pre-race breakfast is tea and chapati.',
    relatedLegends: ['kelvin-kiptum', 'paul-tergat', 'kipchoge-keino'],
    quotesExtra: [
      LegendQuote('training', 'Only the disciplined ones are free in life.'),
      LegendQuote('racing', 'I expect more from myself than anyone else could ever expect.'),
      LegendQuote('life', 'I don\'t know where the limit is, but I would like to go there.'),
      LegendQuote('legacy', 'I want to inspire the next generation of athletes.'),
    ],
    relatedCourseSlug: 'the-thursday-fartlek',
  ),
  Legend(
    slug: 'kelvin-kiptum',
    name: 'Kelvin Kiptum',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Marathon',
    tagline: 'The prodigy who rewrote the limits.',
    bio: 'Kiptum stormed onto the scene with a world record 2:00:35 at the 2023 Chicago Marathon, running an aggressive negative split that stunned the sport. His rise hinted at a new era of marathon speed.',
    timeline: [
      LegendMilestone('2022', 'Marathon debut, Valencia 2:01:53'),
      LegendMilestone('2023', 'London 2:01:25 — course record'),
      LegendMilestone('2023', 'World record 2:00:35, Chicago'),
    ],
    records: ['Marathon WR 2:00:35 (Chicago 2023)'],
    quotes: ['I just run my race.'],
    emoji: '⚡',
    accent: _kKenya,
    beatLegendId: 'kiptum-marathon',
    eraStartYear: 2022,
    personalBests: {
      'Marathon': '2:00:35',
      'Half Marathon': '58:42',
    },
    trainingPhilosophy:
        'Kiptum built his marathon strength on long, hilly runs around Chepsamo in the Rift Valley, complemented by fast track sessions. Coached by the late Gervais Hakizimana, he was known for high weekly volume and fearless negative-split racing — going harder in the second half than the first.',
    rivalries: ['eliud-kipchoge'],
    notableRaces: [
      'Chicago 2023 — World record 2:00:35, the fastest marathon in history.',
      'London 2023 — 2:01:25, a course record on debut at the event.',
      'Valencia 2022 — 2:01:53, the fastest-ever marathon debut.',
    ],
    funFact: 'As a teenager he would pace elite runners for free just to be part of the training.',
    relatedLegends: ['eliud-kipchoge', 'paul-tergat'],
    quotesExtra: [
      LegendQuote('racing', 'I knew I could run a fast time if I pushed in the second half.'),
      LegendQuote('training', 'The hills make you strong; the track makes you fast.'),
      LegendQuote('legacy', 'I want to show the young ones that anything is possible.'),
    ],
  ),
  Legend(
    slug: 'sabastian-sawe',
    name: 'Sabastian Sawe',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Marathon',
    tagline: 'A new name at the front of the pack.',
    bio: 'Sawe announced himself with a blistering run in London, joining the tiny group of men under 1:59:30. A reminder that the Kenyan pipeline never runs dry.',
    timeline: [
      LegendMilestone('2024', 'Half marathon breakthrough'),
      LegendMilestone('2026', 'London — 1:59:30 (verify ratification)'),
    ],
    records: ['London 1:59:30 (2026, pending ratification)'],
    quotes: ['One step, then the next.'],
    emoji: '🌟',
    accent: _kKenya,
    eraStartYear: 2024,
    personalBests: {
      'Marathon': '2:03:37',
      'Half Marathon': '59:05',
    },
    trainingPhilosophy:
        'Sawe rose through the half-marathon ranks before stepping up to the full distance, leaning on high-volume aerobic work and a strong finishing kick. His progress reflects the modern Kenyan pipeline of moving from road 21.1K to marathon with remarkable speed.',
    rivalries: ['kelvin-kiptum'],
    notableRaces: [
      'London 2026 — 1:59:30, a stunning run pending ratification.',
      'Valencia Half — a breakthrough that flagged him as one to watch.',
    ],
    funFact: 'He began as a cross-country runner before discovering he was even faster on the road.',
    relatedLegends: ['kelvin-kiptum', 'eliud-kipchoge'],
    quotesExtra: [
      LegendQuote('racing', 'When the pack slows, that is when I accelerate.'),
      LegendQuote('training', 'Consistency on the easy days builds the fast days.'),
    ],
  ),
  Legend(
    slug: 'haile-gebrselassie',
    name: 'Haile Gebrselassie',
    country: 'Ethiopia',
    flag: '🇪🇹',
    discipline: 'Marathon / 10,000m',
    tagline: 'The emperor of distance.',
    bio: 'A two-time Olympic 10,000m champion who later took the marathon world record to 2:03:59 in Berlin 2008. Haile combined elegance and fierce competitiveness across two decades.',
    timeline: [
      LegendMilestone('1996', 'Olympic 10,000m gold, Atlanta'),
      LegendMilestone('2000', 'Olympic 10,000m gold, Sydney'),
      LegendMilestone('2008', 'Marathon WR 2:03:59, Berlin'),
    ],
    records: ['Marathon WR 2:03:59 (Berlin 2008)', 'Multiple 10,000m Olympic golds'],
    quotes: ['I run with my heart, not my legs.'],
    emoji: '👑',
    accent: _kEthiopia,
    eraStartYear: 1993,
    personalBests: {
      'Marathon': '2:03:59',
      '10,000m': '26:22.75',
      '5000m': '12:39.36',
      '3000m': '7:25.09',
    },
    trainingPhilosophy:
        'Haile\'s signature was "running with the heart" — relaxed, rhythmic, and economical. He favoured high-altitude training in Ethiopia and long, smooth intervals, never wasting a movement. His famous arm-cylon (from childhood carrying books) became part of a near-perfect stride that carried him across two decades at the top.',
    rivalries: ['paul-tergat', 'kenenisa-bekele'],
    notableRaces: [
      'Berlin 2008 — Marathon world record 2:03:59 at age 35.',
      'Sydney 2000 — Olympic 10,000m gold in a classic duel.',
      'Multiple world records from 5000m to the hour run.',
    ],
    funFact: 'He ran with his left arm slightly bent from carrying schoolbooks as a child — and never changed it.',
    relatedLegends: ['paul-tergat', 'kenenisa-bekele', 'kipchoge-keino'],
    quotesExtra: [
      LegendQuote('training', 'If you don\'t have a plan, you will never reach your goal.'),
      LegendQuote('racing', 'I love the pressure. Pressure is a privilege.'),
      LegendQuote('life', 'Running is my medicine, my peace.'),
      LegendQuote('legacy', 'I want to be remembered as one who inspired.'),
    ],
    relatedCourseSlug: 'history-of-east-african-running',
  ),
  Legend(
    slug: 'paul-tergat',
    name: 'Paul Tergat',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: '10,000m / Marathon',
    tagline: 'The gentleman who broke 2:05 first.',
    bio: 'Five-time world cross-country champion and the first man under 2:05 in the marathon (2:04:55, Berlin 2003). His rivalry with Haile defined an era.',
    timeline: [
      LegendMilestone('1995', 'First of five XC world titles'),
      LegendMilestone('1997', 'World 10,000m champion'),
      LegendMilestone('2003', 'First marathon under 2:05, Berlin'),
    ],
    records: ['Marathon 2:04:55 (Berlin 2003)', '10,000m 26:27.85', 'Half marathon 59:17'],
    quotes: ['Pain is temporary, pride is forever.'],
    emoji: '🕊️',
    accent: _kKenya,
    beatLegendId: 'tergat-10k',
    eraStartYear: 1995,
    personalBests: {
      'Marathon': '2:04:55',
      '10,000m': '26:27.85',
      '5000m': '12:49.87',
      'Half Marathon': '59:17',
    },
    trainingPhilosophy:
        'Tergat built his engine on world-cross-country dominance, then translated that strength to the roads. He emphasized year-round aerobic base, disciplined long runs, and a calm, almost serene race temperament — "pain is temporary, pride is forever" was his creed.',
    rivalries: ['haile-gebrselassie'],
    notableRaces: [
      'Berlin 2003 — First marathon under 2:05 (2:04:55).',
      'Athens 1997 — World 10,000m champion.',
      'Five World Cross-Country titles across the 1990s.',
    ],
    funFact: 'He was a policeman before running full-time, and famously humble about his success.',
    relatedLegends: ['haile-gebrselassie', 'kenenisa-bekele'],
    quotesExtra: [
      LegendQuote('racing', 'I never feared the pain; I feared quitting.'),
      LegendQuote('training', 'The cross-country mud built the marathon lungs.'),
      LegendQuote('legacy', 'To be first under 2:05 was for all of Kenya.'),
    ],
    relatedCourseSlug: 'history-of-east-african-running',
  ),
  Legend(
    slug: 'kipchoge-keino',
    name: 'Kipchoge Keino',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: '1500m / 5000m',
    tagline: 'The father of Kenyan dominance.',
    bio: 'His 1968 Olympic gold ignited East Africa\'s distance-running era. Keino raced through illness and adversity with courage that became legend.',
    timeline: [
      LegendMilestone('1968', 'Olympic 1500m gold, Mexico City'),
      LegendMilestone('1972', 'Olympic 3000m steeplechase gold'),
    ],
    records: ['Olympic 1500m champion 1968'],
    quotes: ['Courage is not the absence of fear.'],
    emoji: '🦁',
    accent: _kKenya,
    beatLegendId: 'keino-1500',
    eraStartYear: 1968,
    personalBests: {
      '1500m': '3:34.91',
      '3000m': '7:39.6',
      '5000m': '13:24.2',
      '3000m SC': '8:23.6',
    },
    trainingPhilosophy:
        'Keino trained on the high farms around Eldoret, running long and hard at altitude long before altitude science was popular. He raced with a fearless front-running style and a stoic toughness — famously winning the 1968 1500m while battling a gall bladder infection.',
    rivalries: [],
    notableRaces: [
      'Mexico City 1968 — Olympic 1500m gold that launched an era.',
      'Munich 1972 — Olympic 3000m steeplechase gold.',
    ],
    funFact: 'After retiring he founded an orphanage and farm that has sheltered hundreds of children.',
    relatedLegends: ['eliud-kipchoge', 'paul-tergat', 'haile-gebrselassie'],
    quotesExtra: [
      LegendQuote('life', 'Sport can change the world, one child at a time.'),
      LegendQuote('legacy', 'We showed the world that Africans could rule the track.'),
      LegendQuote('racing', 'When the gun fires, fear must disappear.'),
    ],
    relatedCourseSlug: 'history-of-east-african-running',
  ),
  Legend(
    slug: 'kenenisa-bekele',
    name: 'Kenenisa Bekele',
    country: 'Ethiopia',
    flag: '🇪🇹',
    discipline: '10,000m / Marathon',
    tagline: 'The record-breaking maestro.',
    bio: 'Arguably the greatest 10,000m runner in history with multiple Olympic golds and world records, later a serious marathon threat in Berlin.',
    timeline: [
      LegendMilestone('2004', 'Olympic 10,000m gold, Athens'),
      LegendMilestone('2008', 'Olympic 10,000m gold, Beijing'),
      LegendMilestone('2019', 'Berlin Marathon 2:01:41'),
    ],
    records: ['10,000m WR 26:17.53', '5000m WR 12:37.35'],
    quotes: ['I run to express myself.'],
    emoji: '🎼',
    accent: _kEthiopia,
    eraStartYear: 2003,
    personalBests: {
      '10,000m': '26:17.53',
      '5000m': '12:37.35',
      'Marathon': '2:01:41',
      '3000m': '7:28.94',
    },
    trainingPhilosophy:
        'Bekele honed his devastating kick on the track before conquering the roads. He combined enormous aerobic capacity from high-altitude Ethiopian camps with precise, controlled tempo work — a metronomic 10,000m world-record holder who later came within two seconds of the marathon record.',
    rivalries: ['haile-gebrselassie', 'paul-tergat'],
    notableRaces: [
      'Beijing 2008 — Olympic 10,000m gold in WR-equalling style.',
      'Berlin 2019 — 2:01:41, the second-fastest marathon ever at the time.',
      'Multiple World Cross-Country and 10,000m world titles.',
    ],
    funFact: 'He is the only man to hold the 5000m and 10,000m world records simultaneously.',
    relatedLegends: ['haile-gebrselassie', 'eliud-kipchoge'],
    quotesExtra: [
      LegendQuote('training', 'The track teaches patience; the road rewards it.'),
      LegendQuote('racing', 'I let the kick decide, not the watch.'),
      LegendQuote('life', 'Running is how I speak to the world.'),
      LegendQuote('legacy', 'Records are borrowed from those who come next.'),
    ],
  ),
  Legend(
    slug: 'joshua-cheptegei',
    name: 'Joshua Cheptegei',
    country: 'Uganda',
    flag: '🇺🇬',
    discipline: '5000m / 10,000m',
    tagline: 'The Ugandan record machine.',
    bio: 'Olympic 5000m champion and world record holder at both 5000m and 10,000m, Cheptegei brought Ugandan distance running to the very front.',
    timeline: [
      LegendMilestone('2020', '10,000m world record'),
      LegendMilestone('2020', '5000m world record'),
      LegendMilestone('2021', 'Olympic 5000m gold, Tokyo'),
    ],
    records: ['5000m WR 12:35.36', '10,000m WR 26:11.00'],
    quotes: ['Dream big, work quietly.'],
    emoji: '🌍',
    accent: _kUganda,
    eraStartYear: 2017,
    personalBests: {
      '10,000m': '26:11.00',
      '5000m': '12:35.36',
      '15K': '41:05',
      '10K (road)': '26:38',
    },
    trainingPhilosophy:
        'Cheptegei trained under Addy Ruiter in the Netherlands and at altitude in Uganda, blending European structure with African endurance. He is renowned for meticulous pacing and a powerful, methodical build-up — "dream big, work quietly" summarises his low-key, high-output approach.',
    rivalries: ['kenenisa-bekele'],
    notableRaces: [
      'Monaco 2020 — 5000m world record 12:35.36.',
      'Valencia 2020 — 10,000m world record 26:11.00.',
      'Tokyo 2021 — Olympic 5000m gold.',
    ],
    funFact: 'He started as a 10,000m specialist and only later chased the 5000m record.',
    relatedLegends: ['kenenisa-bekele', 'stephen-kiprotich'],
    quotesExtra: [
      LegendQuote('training', 'The plan is nothing without the quiet work.'),
      LegendQuote('racing', 'Records fall when you respect the process.'),
      LegendQuote('legacy', 'I run for all of Uganda.'),
    ],
  ),
  Legend(
    slug: 'stephen-kiprotich',
    name: 'Stephen Kiprotich',
    country: 'Uganda',
    flag: '🇺🇬',
    discipline: 'Marathon',
    tagline: 'Uganda\'s Olympic marathon hero.',
    bio: 'Surprise Olympic marathon champion in 2012 and world champion in 2013, Kiprotich carried Ugandan hopes on a fearless final-kilometre surge.',
    timeline: [
      LegendMilestone('2012', 'Olympic marathon gold, London'),
      LegendMilestone('2013', 'World marathon champion'),
    ],
    records: ['Olympic marathon champion 2012'],
    quotes: ['Believe, then run.'],
    emoji: '🥇',
    accent: _kUganda,
    eraStartYear: 2012,
    personalBests: {
      'Marathon': '2:06:33',
      'Half Marathon': '1:02:00',
      '10,000m': '27:58',
    },
    trainingPhilosophy:
        'Kiprotich trained in the Kapchorwa highlands of eastern Uganda, a region now famous for its sprinters and distance runners alike. He built his races around a devastating finishing surge, often sitting back before unleashing a final-kilometre charge.',
    rivalries: ['joshua-cheptegei'],
    notableRaces: [
      'London 2012 — Olympic marathon gold in a shock upset.',
      'Moscow 2013 — World marathon champion.',
    ],
    funFact: 'He was a pacemaker early in his career before blossoming into a champion.',
    relatedLegends: ['joshua-cheptegei'],
    quotesExtra: [
      LegendQuote('racing', 'I waited, then I flew in the last kilometre.'),
      LegendQuote('life', 'Believe, then run — that is all I know.'),
    ],
  ),
  Legend(
    slug: 'geoffrey-kamworor',
    name: 'Geoffrey Kamworor',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Half Marathon / Cross Country',
    tagline: 'The undisputed king of the half.',
    bio: 'Multiple world half-marathon champion and a relentless trainer in the camps of Kaptagat. A bridge between the cross-country roots and modern road racing.',
    timeline: [
      LegendMilestone('2014', 'World half marathon champion'),
      LegendMilestone('2016', 'World half marathon champion'),
      LegendMilestone('2018', 'World half marathon champion'),
    ],
    records: ['Half marathon 58:01 (former world record)'],
    quotes: ['Consistency is the secret.'],
    emoji: '🔁',
    accent: _kKenya,
    eraStartYear: 2014,
    personalBests: {
      'Half Marathon': '58:01',
      '10,000m': '26:52.65',
      '15K': '41:13',
    },
    trainingPhilosophy:
        'Kamworor is a pillar of the Kaptagat camp alongside Kipchoge, famous for his unshakeable consistency. He credits group training, the Thursday fartlek, and a simple life for his longevity — "consistency is the secret" is practically his motto.',
    rivalries: ['joshua-cheptegei'],
    notableRaces: [
      'Three World Half-Marathon titles (2014, 2016, 2018).',
      'Copenhagen 2019 — Half marathon world record 58:01.',
    ],
    funFact: 'He often trains twice a day, every day, for years on end without a break.',
    relatedLegends: ['eliud-kipchoge', 'joshua-cheptegei'],
    quotesExtra: [
      LegendQuote('training', 'Show up every day and the results take care of themselves.'),
      LegendQuote('racing', 'The half is won in the camp, not on the start line.'),
      LegendQuote('legacy', 'I want to be the bridge to the next generation.'),
    ],
    relatedCourseSlug: 'the-thursday-fartlek',
  ),
  Legend(
    slug: 'faith-kipyegon',
    name: 'Faith Kipyegon',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: '1500m',
    tagline: 'The queen of the mile.',
    bio: 'Double Olympic 1500m champion and multiple world record holder, Kipyegon combines blistering speed with tactical brilliance. She pushed the 1500m to 3:48.68 in 2025.',
    timeline: [
      LegendMilestone('2016', 'Olympic 1500m gold, Rio'),
      LegendMilestone('2021', 'Olympic 1500m gold, Tokyo'),
      LegendMilestone('2023', '1500m world record 3:49.11'),
      LegendMilestone('2025', '1500m 3:48.68, Eugene'),
    ],
    records: ['1500m WR 3:48.68 (Eugene 2025)', '5000m 14:05.20 (2023)'],
    quotes: ['Hard work dream big.'],
    emoji: '👑',
    accent: _kKenya,
    beatLegendId: 'kipyegon-1500',
    eraStartYear: 2016,
    personalBests: {
      '1500m': '3:48.68',
      'Mile': '4:07.64',
      '5000m': '14:05.20',
    },
    trainingPhilosophy:
        'Kipyegon trains in the high Rift Valley and credits motherhood for a new mental edge. Her sessions blend raw speed (200m/400m repeats) with mileage, and she races with tactical patience before a blistering final-lap kick — the fastest closer in women\'s history.',
    rivalries: ['beatrice-chebet'],
    notableRaces: [
      'Eugene 2025 — 1500m world record 3:48.68.',
      'Paris 2023 — Double world record attempt, 1500m 3:49.11.',
      'Tokyo 2021 — Second Olympic 1500m gold.',
    ],
    funFact: 'She returned to world dominance after having her daughter, saying it made her "fearless."',
    relatedLegends: ['beatrice-chebet', 'mary-keitany'],
    quotesExtra: [
      LegendQuote('training', 'Speed is born in the repetitions, not the race.'),
      LegendQuote('racing', 'I let them lead, then I unleash the last lap.'),
      LegendQuote('life', 'Being a mother gave me a new kind of fire.'),
      LegendQuote('legacy', 'I want girls to see the 1500m and dream.'),
    ],
  ),
  Legend(
    slug: 'beatrice-chebet',
    name: 'Beatrice Chebet',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: '5000m',
    tagline: 'The new face of the long track.',
    bio: 'Olympic 5000m champion who lowered the world record to 13:58.06 in 2025, Chebet represents the next wave of Kenyan women on the track.',
    timeline: [
      LegendMilestone('2024', 'Olympic 5000m gold'),
      LegendMilestone('2025', '5000m world record 13:58.06'),
    ],
    records: ['5000m WR 13:58.06 (Eugene 2025)'],
    quotes: ['Run your own race.'],
    emoji: '🌸',
    accent: _kKenya,
    beatLegendId: 'chebet-5000',
    eraStartYear: 2024,
    personalBests: {
      '5000m': '13:58.06',
      '10,000m': '30:10',
    },
    trainingPhilosophy:
        'Chebet combines cross-country toughness with track precision, often training in large women\'s groups. She races with a calm, even stride and a punishing final kick, embodying the next generation of Kenyan women who now challenge the Ethiopians on the track.',
    rivalries: ['faith-kipyegon'],
    notableRaces: [
      'Eugene 2025 — 5000m world record 13:58.06.',
      'Paris 2024 — Olympic 5000m gold.',
    ],
    funFact: 'She comes from a family of runners and was a junior world cross-country champion.',
    relatedLegends: ['faith-kipyegon'],
    quotesExtra: [
      LegendQuote('racing', 'I don\'t watch the others; I run my own race.'),
      LegendQuote('training', 'The group pulls you when your legs say no.'),
      LegendQuote('legacy', 'I am just getting started.'),
    ],
  ),
  Legend(
    slug: 'brigid-kosgei',
    name: 'Brigid Kosgei',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Marathon',
    tagline: 'The woman who broke 2:15.',
    bio: 'Former marathon world record holder (2:14:04, Chicago 2019), Kosgei combined power and poise to dominate the women\'s marathon for years.',
    timeline: [
      LegendMilestone('2019', 'London Marathon win'),
      LegendMilestone('2019', 'Marathon WR 2:14:04, Chicago'),
    ],
    records: ['Marathon WR 2:14:04 (Chicago 2019)'],
    quotes: ['Stay patient, then strike.'],
    emoji: '💪',
    accent: _kKenya,
    eraStartYear: 2017,
    personalBests: {
      'Marathon': '2:14:04',
      'Half Marathon': '1:05:28',
    },
    trainingPhilosophy:
        'Kosgei trained under Gianni Mauri, combining long Kenyan runs with structured European-style speed work. She raced with patience, sitting in the pack before a decisive surge — the blueprint for the modern women\'s marathon breakthrough.',
    rivalries: ['ruth-chepngetich', 'tigist-assefa'],
    notableRaces: [
      'Chicago 2019 — Marathon world record 2:14:04.',
      'London 2019 & 2020 — back-to-back wins.',
    ],
    funFact: 'She is a mother of two who balanced training with family life in the camps.',
    relatedLegends: ['ruth-chepngetich', 'tigist-assefa', 'mary-keitany'],
    quotesExtra: [
      LegendQuote('racing', 'Patience in the first half buys the second.'),
      LegendQuote('training', 'Trust the plan, and the plan repays you.'),
      LegendQuote('legacy', 'I ran so my daughters would believe.'),
    ],
  ),
  Legend(
    slug: 'ruth-chepngetich',
    name: 'Ruth Chepngetich',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Marathon',
    tagline: 'The fearless front-runner.',
    bio: 'In 2024 she became the first woman under 2:10 with a stunning 2:09:56 in Chicago, redefining what was possible in the women\'s marathon.',
    timeline: [
      LegendMilestone('2019', 'World marathon champion'),
      LegendMilestone('2024', 'Marathon 2:09:56, Chicago'),
    ],
    records: ['Marathon 2:09:56 (Chicago 2024)'],
    quotes: ['Go for it. No fear.'],
    emoji: '🔥',
    accent: _kKenya,
    eraStartYear: 2019,
    personalBests: {
      'Marathon': '2:09:56',
      'Half Marathon': '1:05:39',
    },
    trainingPhilosophy:
        'Chepngetich is famous for audacious, fast-starting races — she often goes to the front early and dares others to follow. Her high-risk style, backed by big-mileage training, produced the first sub-2:10 women\'s marathon in history.',
    rivalries: ['brigid-kosgei', 'tigist-assefa'],
    notableRaces: [
      'Chicago 2024 — First women\'s marathon under 2:10 (2:09:56).',
      'World Championship marathon title (2019).',
    ],
    funFact: 'She dedicated her Chicago record to the late Kelvin Kiptum.',
    relatedLegends: ['brigid-kosgei', 'tigist-assefa', 'kelvin-kiptum'],
    quotesExtra: [
      LegendQuote('racing', 'If you wait, you lose. So I go.'),
      LegendQuote('training', 'Big weeks make brave races.'),
      LegendQuote('legacy', 'I moved the line for every woman behind me.'),
    ],
  ),
  Legend(
    slug: 'tigist-assefa',
    name: 'Tigist Assefa',
    country: 'Ethiopia',
    flag: '🇪🇹',
    discipline: 'Marathon',
    tagline: 'The Berlin blur.',
    bio: 'Assefa shattered the women\'s marathon record with 2:11:53 in Berlin 2023, an audacious solo run that reset the bar for the event.',
    timeline: [
      LegendMilestone('2022', 'Berlin Marathon win'),
      LegendMilestone('2023', 'Marathon WR 2:11:53, Berlin'),
    ],
    records: ['Marathon WR 2:11:53 (Berlin 2023)'],
    quotes: ['Push past the pain.'],
    emoji: '🌬️',
    accent: _kEthiopia,
    eraStartYear: 2015,
    personalBests: {
      'Marathon': '2:11:53',
      'Half Marathon': '1:06:28',
      '800m': '1:59.24',
    },
    trainingPhilosophy:
        'Assefa began as an 800m runner before reinventing herself as a marathoner. Coached by Gemedu Dedefo, she built unprecedented aerobic power and ran Berlin 2023 almost entirely alone off the front — a solo negative split that rewrote the women\'s record by more than two minutes.',
    rivalries: ['brigid-kosgei', 'ruth-chepngetich'],
    notableRaces: [
      'Berlin 2023 — Marathon world record 2:11:53.',
      'Berlin 2022 — Breakthrough win in 2:15:37.',
    ],
    funFact: 'She was a 1:59 800m runner before switching to the marathon.',
    relatedLegends: ['brigid-kosgei', 'ruth-chepngetich', 'haile-gebrselassie'],
    quotesExtra: [
      LegendQuote('racing', 'I ran my own race, alone, and the record came.'),
      LegendQuote('training', 'The track speed never left me; it just grew wings.'),
      LegendQuote('legacy', 'From 800m to the world record — anything is possible.'),
    ],
  ),
  Legend(
    slug: 'tegla-loroupe',
    name: 'Tegla Loroupe',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Marathon',
    tagline: 'Trailblazer and peacebuilder.',
    bio: 'The first African woman to hold a major marathon world record (2:20:43, Berlin 1999) and a tireless advocate for peace through sport across the region.',
    timeline: [
      LegendMilestone('1994', 'New York City Marathon win'),
      LegendMilestone('1999', 'Marathon WR 2:20:43, Berlin'),
      LegendMilestone('2003', 'Founded Peace Marathon'),
    ],
    records: ['Marathon WR 2:20:43 (Berlin 1999)'],
    quotes: ['Sport can build peace.'],
    emoji: '🕊️',
    accent: _kKenya,
    eraStartYear: 1994,
    personalBests: {
      'Marathon': '2:20:43',
      'Half Marathon': '1:06:44',
      '10,000m': '31:27',
    },
    trainingPhilosophy:
        'Loroupe was a pioneering force who proved African women belonged on the global stage. She trained with quiet determination and later turned her platform toward peace, using sport to reconcile communities across conflict lines in East Africa.',
    rivalries: [],
    notableRaces: [
      'Berlin 1999 — First African woman to hold the marathon world record.',
      'Three-time New York City Marathon champion.',
    ],
    funFact: 'She grew up in a family of 24 children and ran barefoot to school.',
    relatedLegends: ['mary-keitany', 'catherine-ndereba', 'brigid-kosgei'],
    quotesExtra: [
      LegendQuote('life', 'Peace is the greatest victory of all.'),
      LegendQuote('legacy', 'I ran so African women would be seen.'),
      LegendQuote('training', 'Strength comes from believing you belong.'),
    ],
  ),
  Legend(
    slug: 'mary-keitany',
    name: 'Mary Keitany',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Half / Marathon',
    tagline: 'The women-only world record holder.',
    bio: 'A dominant marathoner who set the women-only world record of 2:17:01 in London 2017 and won New York City four times.',
    timeline: [
      LegendMilestone('2012', 'London Marathon win'),
      LegendMilestone('2017', 'Women-only WR 2:17:01, London'),
    ],
    records: ['Women-only marathon WR 2:17:01 (London 2017)'],
    quotes: ['Work hard in silence.'],
    emoji: '🏅',
    accent: _kKenya,
    eraStartYear: 2010,
    personalBests: {
      'Marathon': '2:17:01',
      'Half Marathon': '1:05:50',
      '10K (road)': '30:38',
    },
    trainingPhilosophy:
        'Keitany was a ferocious competitor who often went for records alone off the front. She combined massive aerobic volume with fearless pacing, holding the women-only marathon world record for years and racking up four New York City titles.',
    rivalries: ['tegla-loroupe', 'brigid-kosgei'],
    notableRaces: [
      'London 2017 — Women-only marathon world record 2:17:01.',
      'Four-time New York City Marathon champion.',
    ],
    funFact: 'She ran the fastest marathon ever by a woman at the time — 2:17:01 — without male pacemakers.',
    relatedLegends: ['brigid-kosgei', 'tegla-loroupe', 'faith-kipyegon'],
    quotesExtra: [
      LegendQuote('racing', 'I do not need a rabbit; I am my own engine.'),
      LegendQuote('training', 'Silence and work — that is the formula.'),
      LegendQuote('legacy', 'Records are just invitations to the next woman.'),
    ],
  ),
  Legend(
    slug: 'peres-jepchirchir',
    name: 'Peres Jepchirchir',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Half / Marathon',
    tagline: 'The Olympic marathon champion.',
    bio: 'Olympic marathon gold medallist who also holds the women-only half marathon world record, a model of consistency on the biggest stages.',
    timeline: [
      LegendMilestone('2021', 'Olympic marathon gold, Tokyo'),
      LegendMilestone('2021', 'Half marathon WR 1:05:16'),
    ],
    records: ['Half marathon WR 1:05:16', 'Olympic marathon champion 2021'],
    quotes: ['Trust the process.'],
    emoji: '🌟',
    accent: _kKenya,
    eraStartYear: 2016,
    personalBests: {
      'Marathon': '2:17:43',
      'Half Marathon': '1:05:16',
      '10K (road)': '30:55',
    },
    trainingPhilosophy:
        'Jepchirchir built her career on the half marathon before conquering the full distance. She is a model of composure under pressure, winning Olympic gold and world-half titles with metronomic consistency and a calm, patient racing style.',
    rivalries: ['brigid-kosgei', 'ruth-chepngetich'],
    notableRaces: [
      'Tokyo 2021 — Olympic marathon gold.',
      'Mixed half marathon — women-only world record 1:05:16.',
    ],
    funFact: 'She won the Olympic marathon on her birthday month, calling it a gift.',
    relatedLegends: ['brigid-kosgei', 'mary-keitany'],
    quotesExtra: [
      LegendQuote('racing', 'Trust the process; the medal comes at the end.'),
      LegendQuote('training', 'Patience in training is patience in racing.'),
      LegendQuote('legacy', 'I want to be the steady one they remember.'),
    ],
  ),
  Legend(
    slug: 'hellen-obiri',
    name: 'Hellen Obiri',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: '5000m / Marathon',
    tagline: 'From track queen to marathon winner.',
    bio: 'A multiple world champion on the track who smoothly transitioned to marathons, winning Boston and New York City with tactical sharpness.',
    timeline: [
      LegendMilestone('2017', 'World 5000m champion'),
      LegendMilestone('2022', 'Boston Marathon win'),
      LegendMilestone('2023', 'New York City Marathon win'),
    ],
    records: ['Two-time world 5000m champion'],
    quotes: ['Be patient, be brave.'],
    emoji: '🏃‍♀️',
    accent: _kKenya,
    eraStartYear: 2012,
    personalBests: {
      '5000m': '14:18.37',
      '10,000m': '30:14.11',
      'Marathon': '2:21:38',
    },
    trainingPhilosophy:
        'Obiri was a tactical genius on the track, famous for a perfectly-timed final-lap kick. She carried that sharpness to the roads, winning Boston and New York with smart, brave racing rather than pure front-running.',
    rivalries: ['faith-kipyegon', 'beatrice-chebet'],
    notableRaces: [
      'Boston 2022 — Marathon debut win.',
      'New York City 2023 — Second major title.',
      'Multiple world 5000m titles.',
    ],
    funFact: 'She is one of the few athletes to win global titles on both track and major marathons.',
    relatedLegends: ['faith-kipyegon', 'beatrice-chebet'],
    quotesExtra: [
      LegendQuote('racing', 'Be patient, then be brave in the last kilometre.'),
      LegendQuote('training', 'The track kick never leaves you.'),
      LegendQuote('legacy', 'I proved the track and the road are one sport.'),
    ],
  ),
  Legend(
    slug: 'lornah-kiplagat',
    name: 'Lornah Kiplagat',
    country: 'Kenya / Netherlands',
    flag: '🇰🇪',
    discipline: 'Long Distance',
    tagline: 'Champion and academy founder.',
    bio: 'World cross-country champion and multiple world record holder who founded a high-altitude training centre for women in Kenya, giving back to the next generation.',
    timeline: [
      LegendMilestone('2007', 'World cross-country champion'),
      LegendMilestone('2008', 'Founded women\'s training centre'),
    ],
    records: ['Half marathon WR 1:06:25 (former)'],
    quotes: ['Lift as you climb.'],
    emoji: '🌷',
    accent: _kKenya,
    eraStartYear: 2000,
    personalBests: {
      'Half Marathon': '1:06:25',
      'Marathon': '2:23:43',
      '10K (road)': '31:00',
    },
    trainingPhilosophy:
        'Kiplagat balanced elite racing with a mission to uplift others, founding the High Altitude Training Centre in Iten. She believed in structured, science-backed training combined with community — "lift as you climb" defined both her racing and her academy.',
    rivalries: ['tegla-loroupe'],
    notableRaces: [
      '2007 World Cross-Country champion.',
      'Former half marathon world record holder (1:06:25).',
    ],
    funFact: 'She represented both Kenya and the Netherlands during her career.',
    relatedLegends: ['tegla-loroupe', 'mary-keitany'],
    quotesExtra: [
      LegendQuote('life', 'Lift as you climb — no one rises alone.'),
      LegendQuote('legacy', 'The academy is my greatest medal.'),
      LegendQuote('training', 'Science and sisterhood build champions.'),
    ],
    relatedCourseSlug: 'training-camps',
  ),

  // ---- New legends (Step 2) ----

  Legend(
    slug: 'david-rudisha',
    name: 'David Rudisha',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: '800m',
    tagline: 'The man who owned two minutes.',
    bio: 'The greatest 800m runner in history, Rudisha set the world record of 1:40.91 at the London 2012 Olympics — a front-running masterpiece many call the single greatest race ever run.',
    timeline: [
      LegendMilestone('2010', '800m world record 1:41.09'),
      LegendMilestone('2012', 'Olympic 800m gold, London — WR 1:40.91'),
      LegendMilestone('2016', 'Olympic 800m gold, Rio'),
    ],
    records: ['800m WR 1:40.91 (London 2012)', 'Only man under 1:41'],
    quotes: ['I just ran my own race and enjoyed it.'],
    emoji: '🥁',
    accent: _kKenya,
    beatLegendId: 'rudisha-800',
    eraStartYear: 2006,
    personalBests: {
      '800m': '1:40.91',
      '600m': '1:13.10',
      '400m': '45.50',
    },
    trainingPhilosophy:
        'Rudisha trained under Brother Colm O\'Connell in Iten, building enormous aerobic strength before adding speed. He raced from the front with a fearless, even pace — a tactic that produced the most dominant 800m performance in history at London 2012, where he led from gun to tape.',
    rivalries: [],
    notableRaces: [
      'London 2012 — Olympic 800m gold in a world record 1:40.91.',
      'Rio 2016 — Back-to-back Olympic gold.',
      '2010 — First broke 1:41 with 1:41.09.',
    ],
    funFact: 'His father won a silver medal for Kenya at the 1968 Mexico City Olympics.',
    relatedLegends: ['kipchoge-keino', 'faith-kipyegon'],
    quotesExtra: [
      LegendQuote('racing', 'When I lead, I run free — no one tells me the pace.'),
      LegendQuote('training', 'The 800m is a sprint that needs a marathoner\'s lungs.'),
      LegendQuote('life', 'I ran for joy before I ran for gold.'),
      LegendQuote('legacy', 'That London race was for my country.'),
    ],
    relatedCourseSlug: 'altitude-training',
  ),
  Legend(
    slug: 'tirunesh-dibaba',
    name: 'Tirunesh Dibaba',
    country: 'Ethiopia',
    flag: '🇪🇹',
    discipline: '5000m / 10,000m',
    tagline: 'The Baby-Faced Destroyer.',
    bio: 'A three-time Olympic gold medallist and multiple world champion on the track, Dibaba dominated the long distances with a deadly kick and relentless strength.',
    timeline: [
      LegendMilestone('2003', 'World 5000m champion (teenager)'),
      LegendMilestone('2008', 'Olympic 5000m & 10,000m double, Beijing'),
      LegendMilestone('2012', 'Olympic 10,000m gold, London'),
    ],
    records: ['3x Olympic gold', '10,000m 29:42.56', '5000m 14:11.15'],
    quotes: ['I believe in my strength.'],
    emoji: '💎',
    accent: _kEthiopia,
    eraStartYear: 2001,
    personalBests: {
      '10,000m': '29:42.56',
      '5000m': '14:11.15',
      '3000m': '8:29.55',
      '1500m': '4:05.23',
    },
    trainingPhilosophy:
        'Dibaba combined Ethiopian high-altitude endurance with a world-class finishing kick. She often sat back in championship races, then unleashed a searing final-lap surge that left rivals stranded — the hallmark of the great Ethiopian women of the 2000s.',
    rivalries: ['meseret-defar'],
    notableRaces: [
      'Beijing 2008 — 5000m and 10,000m Olympic double.',
      'London 2012 — Olympic 10,000m gold.',
      'Multiple world titles across 5000m and 10,000m.',
    ],
    funFact: 'She was just 18 when she became world 5000m champion.',
    relatedLegends: ['meseret-defar', 'kenenisa-bekele', 'sifan-hassan'],
    quotesExtra: [
      LegendQuote('racing', 'I wait, and then the last lap is mine.'),
      LegendQuote('training', 'The kick is earned in the quiet kilometres.'),
      LegendQuote('legacy', 'I opened the door for Ethiopian girls.'),
    ],
  ),
  Legend(
    slug: 'meseret-defar',
    name: 'Meseret Defar',
    country: 'Ethiopia',
    flag: '🇪🇹',
    discipline: '5000m',
    tagline: 'The queen of the 5000m kick.',
    bio: 'Olympic 5000m champion and multiple world-record holder, Defar was the supreme closer of her generation, feared for an unmatched final-lap acceleration.',
    timeline: [
      LegendMilestone('2004', 'Olympic 5000m gold, Athens'),
      LegendMilestone('2007', '5000m world record 14:16.63'),
      LegendMilestone('2012', 'Olympic 5000m gold, London'),
    ],
    records: ['5000m WR 14:12.88', 'Olympic 5000m champion x2'],
    quotes: ['The last 200 metres are my gift.'],
    emoji: '⚡',
    accent: _kEthiopia,
    eraStartYear: 2002,
    personalBests: {
      '5000m': '14:12.88',
      '3000m': '8:23.72',
      '2 Mile': '9:10.47',
      '1500m': '4:08.00',
    },
    trainingPhilosophy:
        'Defar specialized in the 5000m, building an aerobic base at altitude before sharpening a devastating kick with speed-endurance intervals. She raced tactically, often letting others set the pace before blowing past them in the final straight.',
    rivalries: ['tirunesh-dibaba'],
    notableRaces: [
      'Athens 2004 — First Olympic 5000m gold.',
      'London 2012 — Second Olympic 5000m title.',
      'Multiple 5000m world records.',
    ],
    funFact: 'She held the 5000m world record and had a famed rivalry with Tirunesh Dibaba.',
    relatedLegends: ['tirunesh-dibaba', 'sifan-hassan'],
    quotesExtra: [
      LegendQuote('racing', 'The last 200 metres are my gift to myself.'),
      LegendQuote('training', 'Speed-endurance is the whole secret.'),
      LegendQuote('legacy', 'I made the kick an Ethiopian art form.'),
    ],
  ),
  Legend(
    slug: 'sifan-hassan',
    name: 'Sifan Hassan',
    country: 'Ethiopia → Netherlands',
    flag: '🇳🇱',
    discipline: '1500m–Marathon',
    tagline: 'The distance chameleon.',
    bio: 'An Olympic champion from the 1500m to the marathon, Hassan stunned the world with a 5000m/10,000m/marathon triple at Paris 2024 — racing with audacious, unpredictable surges.',
    timeline: [
      LegendMilestone('2019', 'World 1500m & 10,000m champion'),
      LegendMilestone('2021', 'Olympic 5000m & 10,000m gold, Tokyo'),
      LegendMilestone('2023', 'Marathon debut 2:13:44, London'),
      LegendMilestone('2024', 'Olympic marathon gold, Paris'),
    ],
    records: ['Olympic champion 1500m/5000m/10,000m/Marathon', 'Marathon 2:13:44'],
    quotes: ['I just keep going, no matter what.'],
    emoji: '🌈',
    accent: _kNetherlands,
    eraStartYear: 2014,
    personalBests: {
      'Marathon': '2:13:44',
      '10,000m': '29:06.82',
      '5000m': '14:13.42',
      '1500m': '3:51.95',
      'Mile': '4:12.33',
    },
    trainingPhilosophy:
        'Hassan blends Ethiopian endurance roots with Dutch innovation under coach Tim Rowberry. She is famous for unpredictable, repeated surges that break opponents, and an almost cheerful willingness to do the impossible — running a championship marathon days after track finals.',
    rivalries: ['tirunesh-dibaba', 'faith-kipyegon'],
    notableRaces: [
      'Paris 2024 — Olympic marathon gold after a 5000m/10,000m double.',
      'Tokyo 2021 — 5000m and 10,000m Olympic gold.',
      'London 2023 — Marathon debut 2:13:44, fourth-fastest ever.',
    ],
    funFact: 'She fled Ethiopia as a refugee at 15 and learned to run in the Netherlands.',
    relatedLegends: ['tirunesh-dibaba', 'faith-kipyegon'],
    quotesExtra: [
      LegendQuote('racing', 'I smile in the pain because I chose this.'),
      LegendQuote('training', 'Surges are not tactics; they are who I am.'),
      LegendQuote('life', 'I run for every refugee who dared to dream.'),
      LegendQuote('legacy', 'One body, every distance — why choose?'),
    ],
  ),
  Legend(
    slug: 'catherine-ndereba',
    name: 'Catherine Ndereba',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Marathon',
    tagline: 'Catherine the Great.',
    bio: 'A two-time Olympic silver medallist and four-time Boston Marathon winner, Ndereba was the dominant women\'s marathoner of the early 2000s and a pioneer for Kenyan women.',
    timeline: [
      LegendMilestone('2000', 'Boston Marathon win'),
      LegendMilestone('2001', 'Marathon WR 2:18:47, Chicago'),
      LegendMilestone('2004', 'Olympic marathon silver, Athens'),
      LegendMilestone('2005', '4th Boston Marathon title'),
    ],
    records: ['Marathon 2:18:47 (former WR)', '4x Boston champion'],
    quotes: ['Run your own race, at your own pace.'],
    emoji: '👑',
    accent: _kKenya,
    eraStartYear: 1998,
    personalBests: {
      'Marathon': '2:18:47',
      'Half Marathon': '1:08:10',
    },
    trainingPhilosophy:
        'Ndereba was a model of steady, even-paced excellence, winning four Boston titles with relentless consistency. She carried the torch for Kenyan women before the modern wave, proving the marathon was theirs to own.',
    rivalries: ['tegla-loroupe'],
    notableRaces: [
      'Chicago 2001 — Marathon world record 2:18:47.',
      'Four Boston Marathon victories.',
      'Two Olympic marathon silver medals.',
    ],
    funFact: 'She was known as "Catherine the Great" for her calm, unshakeable dominance.',
    relatedLegends: ['tegla-loroupe', 'mary-keitany', 'brigid-kosgei'],
    quotesExtra: [
      LegendQuote('racing', 'Even pace, even heart — that wins Boston.'),
      LegendQuote('legacy', 'I was the bridge for Kenyan women at the marathon.'),
      LegendQuote('training', 'Steady miles, steady mind.'),
    ],
  ),
  Legend(
    slug: 'edna-kiplagat',
    name: 'Edna Kiplagat',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Marathon',
    tagline: 'The ageless champion.',
    bio: 'A two-time world marathon champion who won global titles deep into her thirties, Kiplagat became a symbol of longevity and smart, patient racing.',
    timeline: [
      LegendMilestone('2011', 'World marathon champion'),
      LegendMilestone('2013', 'World marathon champion'),
      LegendMilestone('2021', 'Boston Marathon win at age 41'),
    ],
    records: ['2x World marathon champion', 'Boston 2021 champion'],
    quotes: ['Age is just a number on the start line.'],
    emoji: '🌿',
    accent: _kKenya,
    eraStartYear: 2009,
    personalBests: {
      'Marathon': '2:19:50',
      'Half Marathon': '1:09:19',
    },
    trainingPhilosophy:
        'Kiplagat built a long, durable career on patient, intelligent training and racing. She proved that marathon success need not fade with age, winning a world title at 33 and Boston at 41 through smart pacing and experience.',
    rivalries: ['catherine-ndereba', 'mary-keitany'],
    notableRaces: [
      '2011 & 2013 — Back-to-back world marathon titles.',
      'Boston 2021 — Marathon major win at age 41.',
    ],
    funFact: 'She became a world champion at 31, relatively late for an elite marathoner.',
    relatedLegends: ['catherine-ndereba', 'mary-keitany'],
    quotesExtra: [
      LegendQuote('life', 'Age is just a number on the start line.'),
      LegendQuote('racing', 'Experience is the pace I trust most.'),
      LegendQuote('legacy', 'I showed women they can peak late.'),
    ],
  ),
  Legend(
    slug: 'moses-tanui',
    name: 'Moses Tanui',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Marathon / 10,000m',
    tagline: 'The first sub-60 half marathoner.',
    bio: 'A world 10,000m champion who became the first man to break 60 minutes for the half marathon (59:47, Milan 1993), Tanui helped usher in the era of road-racing speed.',
    timeline: [
      LegendMilestone('1991', 'World 10,000m champion'),
      LegendMilestone('1993', 'First half marathon under 60:00 (59:47)'),
      LegendMilestone('1996', 'Boston Marathon win'),
    ],
    records: ['Half marathon 59:47 (first sub-60)', 'Boston 1996 champion'],
    quotes: ['Break the barrier and others will follow.'],
    emoji: '⏱️',
    accent: _kKenya,
    eraStartYear: 1989,
    personalBests: {
      'Half Marathon': '59:47',
      'Marathon': '2:06:16',
      '10,000m': '27:22.46',
    },
    trainingPhilosophy:
        'Tanui was a pioneer of the road-racing revolution, translating track speed to the half and full marathon. His 59:47 half marathon proved Kenyans could dominate the roads with pace, not just endurance.',
    rivalries: [],
    notableRaces: [
      'Milan 1993 — First half marathon under 60 minutes.',
      'Boston 1996 — Marathon major victory.',
      '1991 World 10,000m champion.',
    ],
    funFact: 'His sub-60 half marathon stood as a Kenyan milestone for years.',
    relatedLegends: ['paul-tergat', 'eliud-kipchoge'],
    quotesExtra: [
      LegendQuote('racing', 'Sub-60 was a wall; I just ran through it.'),
      LegendQuote('legacy', 'I opened the road door for Kenya.'),
      LegendQuote('training', 'Track speed made my half marathon fast.'),
    ],
  ),
  Legend(
    slug: 'ibrahim-hussein',
    name: 'Ibrahim Hussein',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: 'Marathon',
    tagline: 'The first African Boston winner.',
    bio: 'The first African to win the Boston Marathon (1988), Hussein was a trailblazer who proved East Africans could conquer the world\'s oldest marathon.',
    timeline: [
      LegendMilestone('1988', 'Boston Marathon win (first African)'),
      LegendMilestone('1991', 'Boston Marathon win'),
      LegendMilestone('1992', 'Boston Marathon win'),
    ],
    records: ['3x Boston Marathon champion', 'First African Boston winner'],
    quotes: ['I ran for a continent.'],
    emoji: '🌍',
    accent: _kKenya,
    eraStartYear: 1985,
    personalBests: {
      'Marathon': '2:08:43',
      'Half Marathon': '1:02:00',
    },
    trainingPhilosophy:
        'Hussein was a bold, tactical racer who took on the hills of Boston with courage. His victories in the late 1980s and early 1990s broke a racial barrier and inspired the Kenyan marathon boom that followed.',
    rivalries: [],
    notableRaces: [
      'Boston 1988 — First African winner of the marathon.',
      'Boston 1991 & 1992 — Back-to-back titles.',
    ],
    funFact: 'He trained at the University of New Mexico before his Boston breakthrough.',
    relatedLegends: ['catherine-ndereba', 'paul-tergat'],
    quotesExtra: [
      LegendQuote('legacy', 'I ran for a continent, not just myself.'),
      LegendQuote('racing', 'Boston\'s hills frightened everyone but me.'),
      LegendQuote('life', 'Breaking the barrier was the real medal.'),
    ],
  ),
  Legend(
    slug: 'abel-mutai',
    name: 'Abel Mutai',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: '3000m SC',
    tagline: 'The steeplechase star.',
    bio: 'Olympic 3000m steeplechase bronze medallist and world champion, Mutai was a master of the barriers and water jump in the golden era of Kenyan steeplechasing.',
    timeline: [
      LegendMilestone('2009', 'World steeplechase silver'),
      LegendMilestone('2011', 'World steeplechase champion'),
      LegendMilestone('2012', 'Olympic steeplechase bronze, London'),
    ],
    records: ['World steeplechase champion 2011', 'Olympic bronze 2012'],
    quotes: ['Clear the barrier, then fly.'],
    emoji: '🚧',
    accent: _kKenya,
    eraStartYear: 2006,
    personalBests: {
      '3000m SC': '7:59.16',
      '1500m': '3:38',
    },
    trainingPhilosophy:
        'Mutai honed his barrier technique and water-jump rhythm through countless repetition on the track. He was part of Kenya\'s steeplechase dynasty, combining fluid hurdle clearance with the raw speed needed to break eight minutes.',
    rivalries: ['ezekiel-kemboi'],
    notableRaces: [
      'Daegu 2011 — World 3000m steeplechase champion.',
      'London 2012 — Olympic steeplechase bronze.',
    ],
    funFact: 'He famously misinterpreted the finish at a 2012 cross-country race, costing him a win — a rare stumble for a precise technician.',
    relatedLegends: ['ezekiel-kemboi', 'kipchoge-keino'],
    quotesExtra: [
      LegendQuote('racing', 'Clear the barrier, then fly to the line.'),
      LegendQuote('training', 'The water jump is rhythm, not courage.'),
      LegendQuote('legacy', 'I kept Kenya on top of the steeple.'),
    ],
  ),
  Legend(
    slug: 'ezekiel-kemboi',
    name: 'Ezekiel Kemboi',
    country: 'Kenya',
    flag: '🇰🇪',
    discipline: '3000m SC',
    tagline: 'The showman of the steeplechase.',
    bio: 'A four-time world 3000m steeplechase champion and Olympic gold medallist, Kemboi was as flamboyant as he was dominant, celebrating before the line.',
    timeline: [
      LegendMilestone('2004', 'Olympic steeplechase gold, Athens'),
      LegendMilestone('2009', 'World steeplechase champion'),
      LegendMilestone('2011', 'World steeplechase champion'),
      LegendMilestone('2015', '4th world title'),
    ],
    records: ['4x World steeplechase champion', 'Olympic gold 2004'],
    quotes: ['I am the steeplechase!'],
    emoji: '🏆',
    accent: _kKenya,
    eraStartYear: 2001,
    personalBests: {
      '3000m SC': '7:55.76',
      '1500m': '3:37',
    },
    trainingPhilosophy:
        'Kemboi trained with theatrical flair but deadly seriousness, famous for his signature celebration mid-race and his ferocious kick over the final barrier. He dominated the steeplechase for over a decade with sheer confidence and a perfectly timed final surge.',
    rivalries: ['abel-mutai'],
    notableRaces: [
      'Athens 2004 — Olympic steeplechase gold.',
      'Four world steeplechase titles (2009, 2011, 2013, 2015).',
    ],
    funFact: 'He often began his victory celebration before crossing the finish line.',
    relatedLegends: ['abel-mutai', 'kipchoge-keino'],
    quotesExtra: [
      LegendQuote('racing', 'I am the steeplechase — ask anyone!'),
      LegendQuote('training', 'Confidence is a muscle; I train it daily.'),
      LegendQuote('legacy', 'I made the steeple fun to watch.'),
    ],
  ),
];

Legend legendForSlug(String slug) =>
    legends.firstWhere((l) => l.slug == slug, orElse: () => legends.first);

Color legendAccent(Legend l) => {
      'orange': const Color(0xFFFF5A1F),
      'gold': const Color(0xFFFFD15C),
      'green': const Color(0xFF2BB673),
    }[l.accent] ?? const Color(0xFFFF5A1F);
