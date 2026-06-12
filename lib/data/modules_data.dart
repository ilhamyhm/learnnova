import '../models/module_model.dart';
import '../constants/app_colors.dart';

/// Returns a **fresh, independent** list of all learning modules.
///
/// Every call creates new [Module] and [SubModule] instances so that
/// progress mutations (`.progress`, `.isCompleted`) for one user never
/// bleed into another user's copy.
///
/// Use [ModuleStateService.instance.modules] throughout the app instead
/// of calling this directly — it caches the list for the current session.
List<Module> buildModules() => [
  // 1. CodeLab
  Module(
    name: 'CodeLab',
    description:
        'Master the art of programming. From web development to scripting, CodeLab covers everything you need to become a full-stack developer.',
    icon: '💻',
    colorValue: AppColors.moduleCodeLab.toARGB32(),
    category: 'Programming',
    apiKey: 'codelab',
    subModules: [
      SubModule(name: 'HTML', description: 'Learn the building blocks of the web.', icon: '🌐', totalLessons: 16, difficulty: 'Beginner', apiKey: 'codelab_html'),
      SubModule(name: 'CSS', description: 'Style the web beautifully.', icon: '🎨', totalLessons: 16, difficulty: 'Beginner', apiKey: 'codelab_css'),
      SubModule(name: 'PHP', description: 'Build dynamic server-side applications.', icon: '⚙️', totalLessons: 16, difficulty: 'Intermediate', apiKey: 'codelab_php'),
      SubModule(name: 'Python', description: 'The world\'s most versatile language.', icon: '🐍', totalLessons: 16, difficulty: 'Beginner', apiKey: 'codelab_python'),
      SubModule(name: 'JavaScript', description: 'The language of the web.', icon: '⚡', totalLessons: 16, difficulty: 'Intermediate', apiKey: 'codelab_js'),
    ],
  ),

  // 2. Creative Studio
  Module(
    name: 'Creative Studio',
    description:
        'Unleash your creativity. Learn professional design, video, and visual storytelling skills used by top creators worldwide.',
    icon: '🎭',
    colorValue: AppColors.moduleCreative.toARGB32(),
    category: 'Design',
    apiKey: 'creative_studio',
    subModules: [
      SubModule(name: 'UI/UX Design', description: 'Design experiences that users love.', icon: '🖥️', totalLessons: 16, difficulty: 'Beginner', apiKey: 'creative_studio_uiux'),
      SubModule(name: 'Graphic Design', description: 'Create stunning visuals.', icon: '🖌️', totalLessons: 16, difficulty: 'Beginner', apiKey: 'creative_studio_graphic'),
      SubModule(name: 'Video Editing', description: 'Tell stories through video.', icon: '🎬', totalLessons: 16, difficulty: 'Intermediate', apiKey: 'creative_studio_video'),
    ],
  ),

  // 3. Animation Lab
  Module(
    name: 'Animation Lab',
    description:
        'Bring your ideas to life with motion. From classic 2D to stunning 3D, learn animation skills used in films and games.',
    icon: '✨',
    colorValue: AppColors.moduleAnimation.toARGB32(),
    category: 'Animation',
    apiKey: 'animation_lab',
    subModules: [
      SubModule(name: '2D Animation', description: 'Master the timeless art of 2D animation.', icon: '🎞️', totalLessons: 16, difficulty: 'Intermediate', apiKey: 'animation_lab_2d'),
      SubModule(name: '3D Animation', description: 'Enter the world of 3D.', icon: '🌀', totalLessons: 16, difficulty: 'Advanced', apiKey: 'animation_lab_3d'),
    ],
  ),

  // 4. BizLab
  Module(
    name: 'BizLab',
    description:
        'Build the business skills of tomorrow. From marketing to leadership, BizLab prepares you for the modern professional world.',
    icon: '💼',
    colorValue: AppColors.moduleBiz.toARGB32(),
    category: 'Business',
    apiKey: 'bizlab',
    subModules: [
      SubModule(name: 'Digital Marketing', description: 'Grow businesses online.', icon: '📈', totalLessons: 16, difficulty: 'Beginner', apiKey: 'bizlab_marketing'),
      SubModule(name: 'Public Speaking', description: 'Speak with confidence.', icon: '🎤', totalLessons: 16, difficulty: 'Intermediate', apiKey: 'bizlab_speaking'),
      SubModule(name: 'Productivity', description: 'Work smarter, not harder.', icon: '⏱️', totalLessons: 16, difficulty: 'Beginner', apiKey: 'bizlab_productivity'),
    ],
  ),

  // 5. Language Hub
  Module(
    name: 'Language Hub',
    description:
        'Communicate with the world. Learn languages through immersive lessons, real conversations, and practical exercises.',
    icon: '🌍',
    colorValue: AppColors.moduleLanguage.toARGB32(),
    category: 'Languages',
    apiKey: 'language_hub',
    subModules: [
      SubModule(name: 'English', description: 'Master the global language.', icon: '🇬🇧', totalLessons: 16, difficulty: 'Beginner', apiKey: 'language_hub_english'),
      SubModule(name: 'Indonesian', description: 'Learn Bahasa Indonesia.', icon: '🇮🇩', totalLessons: 16, difficulty: 'Beginner', apiKey: 'language_hub_indonesian'),
    ],
  ),

  // 6. Smart Academy
  Module(
    name: 'Smart Academy',
    description:
        'Excel in core academics. Smart Academy makes complex subjects like Math, Science, and Physics engaging and understandable.',
    icon: '🎓',
    colorValue: AppColors.moduleAcademy.toARGB32(),
    category: 'Academic',
    apiKey: 'smart_academy',
    subModules: [
      SubModule(name: 'Mathematics', description: 'Build strong mathematical foundations.', icon: '📐', totalLessons: 16, difficulty: 'Beginner', apiKey: 'smart_academy_math'),
      SubModule(name: 'Physics', description: 'Understand the laws of the universe.', icon: '⚛️', totalLessons: 16, difficulty: 'Intermediate', apiKey: 'smart_academy_physics'),
      SubModule(name: 'Chemistry', description: 'Explore matter and reactions.', icon: '🧪', totalLessons: 16, difficulty: 'Intermediate', apiKey: 'smart_academy_chemistry'),
      SubModule(name: 'Biology', description: 'Discover the science of life.', icon: '🧬', totalLessons: 16, difficulty: 'Beginner', apiKey: 'smart_academy_biology'),
    ],
  ),

  // 7. Fun Skill
  Module(
    name: 'Fun Skill',
    description:
        'Learn skills that spark joy. Whether building games, writing stories, or creating content — fun skills turn passion into expertise.',
    icon: '🚀',
    colorValue: AppColors.moduleFunSkill.toARGB32(),
    category: 'Creative',
    apiKey: 'fun_skill',
    subModules: [
      SubModule(name: 'Unity Game Dev', description: 'Build your own games!', icon: '🎮', totalLessons: 16, difficulty: 'Advanced', apiKey: 'fun_skill_unity'),
      SubModule(name: 'Story Writing', description: 'Craft compelling narratives.', icon: '📝', totalLessons: 16, difficulty: 'Beginner', apiKey: 'fun_skill_writing'),
      SubModule(name: 'Content Creator', description: 'Build your online presence.', icon: '📱', totalLessons: 16, difficulty: 'Beginner', apiKey: 'fun_skill_content'),
    ],
  ),

  // 8. Sports
  Module(
    name: 'Sports',
    description:
        'Train like a champion. From football to fitness, our sports modules combine theory with practice to elevate your game.',
    icon: '⚽',
    colorValue: AppColors.moduleSports.toARGB32(),
    category: 'Sports & Fitness',
    apiKey: 'sports',
    subModules: [
      SubModule(name: 'Football Basics', description: 'Master the beautiful game.', icon: '⚽', totalLessons: 16, difficulty: 'Beginner', apiKey: 'sports_football'),
      SubModule(name: 'Basketball', description: 'Take your game to the court.', icon: '🏀', totalLessons: 16, difficulty: 'Beginner', apiKey: 'sports_basketball'),
      SubModule(name: 'Home Workout', description: 'Get fit without a gym.', icon: '💪', totalLessons: 16, difficulty: 'Beginner', apiKey: 'sports_fitness'),
    ],
  ),
];
