import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/material_model.dart';
import '../models/quiz_model.dart';

/// Central API service for LearnNova.
/// Fetches learning materials and quizzes from a REST API.
/// Falls back to rich built-in mock data when the backend is unreachable.
/// Persists all progress locally via shared_preferences.
class ApiService {
  static const String _baseUrl = 'https://learnnova-api.example.com';

  // ─── SharedPreferences Keys ──────────────────────────────────────────────
  static const String _keyViewedSlides = 'viewed_slides_';
  static const String _keyQuizScore   = 'quiz_score_';
  static const String _keyQuizPassed  = 'quiz_passed_';
  static const String _keyMatProgress = 'mat_progress_';

  // ─── Materials ───────────────────────────────────────────────────────────

  /// Fetches materials for [subModuleKey] (e.g. "codelab_html").
  /// Returns [ModuleMaterialsResponse] from API or falls back to mock data.
  Future<ModuleMaterialsResponse> fetchMaterials(String subModuleKey) async {
    try {
      final uri = Uri.parse('$_baseUrl/materials/$subModuleKey');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return ModuleMaterialsResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // Network unreachable — use mock data
    }
    return _mockMaterials(subModuleKey);
  }

  // ─── Quizzes ─────────────────────────────────────────────────────────────

  /// Fetches quiz questions for [moduleKey] (e.g. "codelab").
  /// Returns [ModuleQuizResponse] from API or falls back to mock data.
  Future<ModuleQuizResponse> fetchQuiz(String moduleKey) async {
    try {
      final uri = Uri.parse('$_baseUrl/quizzes/$moduleKey');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return ModuleQuizResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // Network unreachable — use mock data
    }
    return _mockQuiz(moduleKey);
  }

  // ─── Progress Persistence ─────────────────────────────────────────────────

  /// Returns the set of viewed slide IDs for [subModuleKey].
  Future<Set<int>> getViewedSlides(String subModuleKey) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('$_keyViewedSlides$subModuleKey') ?? [];
    return stored.map(int.parse).toSet();
  }

  /// Marks slide [slideId] as viewed for [subModuleKey].
  Future<void> markSlideViewed(String subModuleKey, int slideId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewed = await getViewedSlides(subModuleKey);
    viewed.add(slideId);
    await prefs.setStringList(
      '$_keyViewedSlides$subModuleKey',
      viewed.map((e) => e.toString()).toList(),
    );
  }

  /// Returns the material progress (0.0–1.0) for [subModuleKey].
  Future<double> getMaterialProgress(String subModuleKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_keyMatProgress$subModuleKey') ?? 0.0;
  }

  /// Updates material progress for [subModuleKey] given viewed count and total.
  Future<void> updateMaterialProgress(
    String subModuleKey,
    int viewedCount,
    int totalSlides,
  ) async {
    if (totalSlides == 0) return;
    final prefs = await SharedPreferences.getInstance();
    final progress = (viewedCount / totalSlides).clamp(0.0, 1.0);
    await prefs.setDouble('$_keyMatProgress$subModuleKey', progress);
  }

  /// Returns the saved quiz score for [moduleKey], or null if not attempted.
  Future<double?> getQuizScore(String moduleKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_keyQuizScore$moduleKey')
        ? prefs.getDouble('$_keyQuizScore$moduleKey')
        : null;
  }

  /// Returns whether [moduleKey] quiz was passed.
  Future<bool> isQuizPassed(String moduleKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyQuizPassed$moduleKey') ?? false;
  }

  /// Saves quiz result for [moduleKey].
  Future<void> saveQuizResult(
    String moduleKey,
    double scorePercent,
    bool passed,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_keyQuizScore$moduleKey', scorePercent);
    await prefs.setBool('$_keyQuizPassed$moduleKey', passed);
  }

  /// Clears all progress (for testing/reset).
  Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─── Mock Data ────────────────────────────────────────────────────────────

  ModuleMaterialsResponse _mockMaterials(String key) {
    final data = _allMockMaterials[key] ?? _allMockMaterials['codelab_html']!;
    return ModuleMaterialsResponse.fromJson(data);
  }

  ModuleQuizResponse _mockQuiz(String key) {
    final data = _allMockQuizzes[key] ?? _allMockQuizzes['codelab']!;
    return ModuleQuizResponse.fromJson(data);
  }

  // ─── Mock Material Data ──────────────────────────────────────────────────

  static final Map<String, Map<String, dynamic>> _allMockMaterials = {
    'codelab_html': {
      'module_id': 1,
      'title': 'HTML Fundamentals',
      'level': 'Beginner',
      'tujuan_pembelajaran':
          'Understand HTML structure, basic elements, and how web pages work.',
      'total_slide': 6,
      'materials': [
        {
          'material_id': 1,
          'title': 'What is HTML?',
          'content':
              'HTML (HyperText Markup Language) is the standard language for creating web pages. It describes the structure of web content using a series of elements that tell the browser how to display content.',
          'example': '<!DOCTYPE html>\n<html>\n  <head>\n    <title>My Page</title>\n  </head>\n  <body>\n    <h1>Hello World!</h1>\n  </body>\n</html>',
        },
        {
          'material_id': 2,
          'title': 'HTML Elements & Tags',
          'content':
              'HTML elements are represented by tags. Tags are keywords surrounded by angle brackets. Most HTML elements have an opening tag and a closing tag. The content sits between the two tags.',
          'example': '<h1>This is a Heading</h1>\n<p>This is a paragraph.</p>\n<a href="https://example.com">This is a link</a>',
        },
        {
          'material_id': 3,
          'title': 'Headings & Paragraphs',
          'content':
              'HTML defines six levels of headings from h1 (most important) to h6 (least important). Paragraphs are defined with the <p> tag. Browsers automatically add some space before and after paragraphs.',
          'example': '<h1>Main Title</h1>\n<h2>Section Title</h2>\n<h3>Subsection</h3>\n<p>This is a regular paragraph of text.</p>',
        },
        {
          'material_id': 4,
          'title': 'Links & Images',
          'content':
              'Links are created with the <a> anchor tag. The href attribute specifies the URL destination. Images are inserted with the <img> tag, which requires a src attribute for the image path and an alt attribute for accessibility.',
          'example': '<a href="https://flutter.dev">Visit Flutter</a>\n\n<img src="logo.png" alt="LearnNova Logo" width="200">',
        },
        {
          'material_id': 5,
          'title': 'Lists',
          'content':
              'HTML supports ordered lists (numbered) and unordered lists (bulleted). Ordered lists use <ol>, unordered lists use <ul>, and each list item uses the <li> tag.',
          'example': '<ul>\n  <li>HTML</li>\n  <li>CSS</li>\n  <li>JavaScript</li>\n</ul>\n\n<ol>\n  <li>Learn basics</li>\n  <li>Build projects</li>\n  <li>Get a job</li>\n</ol>',
        },
        {
          'material_id': 6,
          'title': 'HTML Forms',
          'content':
              'Forms allow user input to be collected and submitted. The <form> element wraps the form controls. Common input types include text, password, email, and submit.',
          'example': '<form action="/submit" method="post">\n  <label>Name:</label>\n  <input type="text" name="name"><br>\n  <label>Email:</label>\n  <input type="email" name="email"><br>\n  <input type="submit" value="Submit">\n</form>',
        },
      ],
    },

    'codelab_css': {
      'module_id': 2,
      'title': 'CSS Styling',
      'level': 'Beginner',
      'tujuan_pembelajaran': 'Style HTML pages with colors, layouts, and animations.',
      'total_slide': 5,
      'materials': [
        {
          'material_id': 1,
          'title': 'What is CSS?',
          'content':
              'CSS (Cascading Style Sheets) is used to control the visual presentation of HTML elements. It allows you to apply styles like colors, fonts, spacing, and layouts.',
          'example': 'body {\n  font-family: Arial, sans-serif;\n  background-color: #f0f0f0;\n  color: #333;\n}',
        },
        {
          'material_id': 2,
          'title': 'Selectors & Properties',
          'content':
              'CSS selectors target HTML elements to apply styles. You can select elements by tag name, class (.class), or ID (#id). Properties define what aspect to style and values define how.',
          'example': '/* Tag selector */\np { color: blue; }\n\n/* Class selector */\n.highlight { background: yellow; }\n\n/* ID selector */\n#header { font-size: 24px; }',
        },
        {
          'material_id': 3,
          'title': 'Box Model',
          'content':
              'Every HTML element is a box with four layers: content, padding, border, and margin. Understanding the box model is key to controlling layout and spacing.',
          'example': '.card {\n  width: 300px;\n  padding: 20px;\n  border: 1px solid #ccc;\n  margin: 10px;\n  border-radius: 8px;\n}',
        },
        {
          'material_id': 4,
          'title': 'Flexbox Layout',
          'content':
              'Flexbox is a one-dimensional layout system that makes it easy to align and distribute elements in a container. The parent becomes a flex container with display: flex.',
          'example': '.container {\n  display: flex;\n  justify-content: center;\n  align-items: center;\n  gap: 16px;\n}',
        },
        {
          'material_id': 5,
          'title': 'Responsive Design',
          'content':
              'Media queries allow CSS styles to change based on screen size, enabling responsive web design. Use breakpoints to adapt layouts for mobile, tablet, and desktop.',
          'example': '@media (max-width: 768px) {\n  .container {\n    flex-direction: column;\n  }\n  .card {\n    width: 100%;\n  }\n}',
        },
      ],
    },

    'codelab_python': {
      'module_id': 3,
      'title': 'Python Programming',
      'level': 'Beginner',
      'tujuan_pembelajaran': 'Learn Python fundamentals for scripting, data, and automation.',
      'total_slide': 5,
      'materials': [
        {
          'material_id': 1,
          'title': 'Introduction to Python',
          'content':
              'Python is a high-level, interpreted programming language known for its simplicity and readability. It is widely used in web development, data science, automation, and AI.',
          'example': '# Your first Python program\nprint("Hello, LearnNova!")\n\n# Python is easy to read\nname = "Student"\nprint(f"Welcome, {name}!")',
        },
        {
          'material_id': 2,
          'title': 'Variables & Data Types',
          'content':
              'Python has several built-in data types: integers, floats, strings, booleans, lists, tuples, and dictionaries. Variables do not need explicit type declarations.',
          'example': 'age = 25          # int\nprice = 9.99      # float\nname = "LearnNova" # str\nis_active = True   # bool\nscores = [90, 85, 92] # list',
        },
        {
          'material_id': 3,
          'title': 'Control Flow',
          'content':
              'Python uses if/elif/else for conditional logic, and for/while loops for iteration. Indentation (4 spaces) defines code blocks instead of curly braces.',
          'example': 'score = 85\n\nif score >= 90:\n    print("Grade: A")\nelif score >= 75:\n    print("Grade: B")\nelse:\n    print("Grade: C")\n\nfor i in range(5):\n    print(f"Count: {i}")',
        },
        {
          'material_id': 4,
          'title': 'Functions',
          'content':
              'Functions are reusable blocks of code defined with the def keyword. They can accept parameters and return values. Python also supports default parameter values and keyword arguments.',
          'example': 'def greet(name, greeting="Hello"):\n    return f"{greeting}, {name}!"\n\n# Call the function\nmessage = greet("Student")\nprint(message)  # Hello, Student!',
        },
        {
          'material_id': 5,
          'title': 'Lists & Dictionaries',
          'content':
              'Lists are ordered, mutable sequences. Dictionaries store key-value pairs and are perfect for structured data. Both support common operations like add, remove, and iterate.',
          'example': '# List operations\nfruits = ["apple", "banana", "cherry"]\nfruits.append("date")\nprint(fruits[0])  # apple\n\n# Dictionary\nstudent = {"name": "Ali", "score": 95}\nprint(student["name"])  # Ali',
        },
      ],
    },

    'creative_studio_uiux': {
      'module_id': 4,
      'title': 'UI/UX Design Fundamentals',
      'level': 'Beginner',
      'tujuan_pembelajaran': 'Learn user research, wireframing, and visual design principles.',
      'total_slide': 4,
      'materials': [
        {
          'material_id': 1,
          'title': 'What is UI/UX?',
          'content':
              'UI (User Interface) refers to the visual elements of a product — buttons, icons, typography, color. UX (User Experience) is about the overall feel of the experience, including how intuitive and efficient it is to use.',
          'example': null,
        },
        {
          'material_id': 2,
          'title': 'Design Principles',
          'content':
              'Great UI design follows key principles: Hierarchy (guiding the eye), Contrast (separating elements), Alignment (creating order), Repetition (creating consistency), and Proximity (grouping related items).',
          'example': null,
        },
        {
          'material_id': 3,
          'title': 'Color Theory',
          'content':
              'Color communicates emotion and hierarchy. Use primary colors sparingly. Choose a main brand color, a complementary accent, and neutral backgrounds. Ensure sufficient contrast for readability and accessibility.',
          'example': null,
        },
        {
          'material_id': 4,
          'title': 'Wireframing',
          'content':
              'Wireframes are low-fidelity blueprints of a UI layout. They focus on structure and content without visual styling. Wireframes help teams align on layout before spending time on design details.',
          'example': null,
        },
      ],
    },

    'bizlab_marketing': {
      'module_id': 5,
      'title': 'Digital Marketing',
      'level': 'Intermediate',
      'tujuan_pembelajaran': 'Master SEO, social media, and data-driven marketing strategies.',
      'total_slide': 4,
      'materials': [
        {
          'material_id': 1,
          'title': 'Introduction to Digital Marketing',
          'content':
              'Digital marketing encompasses all online marketing efforts. It includes SEO, social media marketing, email marketing, content marketing, and paid advertising. The goal is to reach and convert your target audience online.',
          'example': null,
        },
        {
          'material_id': 2,
          'title': 'Search Engine Optimization (SEO)',
          'content':
              'SEO improves your website visibility in organic search results. Key factors include keyword research, on-page optimization (title tags, meta descriptions, headings), link building, and technical performance.',
          'example': null,
        },
        {
          'material_id': 3,
          'title': 'Social Media Marketing',
          'content':
              'Social media platforms allow brands to connect directly with audiences. Each platform has unique characteristics — Instagram for visuals, LinkedIn for professional content, TikTok for short-form videos. Consistency and authenticity drive engagement.',
          'example': null,
        },
        {
          'material_id': 4,
          'title': 'Analytics & Metrics',
          'content':
              'Data-driven marketing uses analytics tools to measure campaign performance. Key metrics include CTR (click-through rate), conversion rate, CPA (cost per acquisition), and ROI. Use these insights to optimize campaigns continuously.',
          'example': null,
        },
      ],
    },
  };

  // ─── Mock Quiz Data ──────────────────────────────────────────────────────

  static final Map<String, Map<String, dynamic>> _allMockQuizzes = {
    'codelab': {
      'module_id': 1,
      'quiz_title': 'CodeLab — HTML & Web Basics Quiz',
      'questions': [
        {
          'question_id': 1,
          'question': 'What does HTML stand for?',
          'options': [
            'HyperText Markup Language',
            'HighText Machine Language',
            'Hyper Transfer Machine Language',
            'Home Tool Markup Language',
          ],
          'correct_answer': 'HyperText Markup Language',
        },
        {
          'question_id': 2,
          'question': 'Which HTML tag is used to define the largest heading?',
          'options': ['<h6>', '<head>', '<h1>', '<heading>'],
          'correct_answer': '<h1>',
        },
        {
          'question_id': 3,
          'question': 'What does CSS stand for?',
          'options': [
            'Computer Style Sheets',
            'Cascading Style Sheets',
            'Creative Style Sheets',
            'Colorful Style Sheets',
          ],
          'correct_answer': 'Cascading Style Sheets',
        },
        {
          'question_id': 4,
          'question': 'Which CSS property controls text color?',
          'options': ['font-color', 'text-color', 'color', 'text-style'],
          'correct_answer': 'color',
        },
        {
          'question_id': 5,
          'question': 'What is the correct Python syntax to print "Hello"?',
          'options': [
            'echo("Hello")',
            'printf("Hello")',
            'print("Hello")',
            'console.log("Hello")',
          ],
          'correct_answer': 'print("Hello")',
        },
      ],
    },

    'creative_studio': {
      'module_id': 2,
      'quiz_title': 'Creative Studio — Design Quiz',
      'questions': [
        {
          'question_id': 1,
          'question': 'What does UI stand for?',
          'options': [
            'User Interface',
            'Universal Input',
            'Unique Interaction',
            'User Index',
          ],
          'correct_answer': 'User Interface',
        },
        {
          'question_id': 2,
          'question': 'Which design principle groups related items together?',
          'options': ['Contrast', 'Alignment', 'Proximity', 'Repetition'],
          'correct_answer': 'Proximity',
        },
        {
          'question_id': 3,
          'question': 'What are wireframes used for?',
          'options': [
            'Adding colors to a design',
            'Creating low-fidelity layout blueprints',
            'Writing code for websites',
            'Testing animations',
          ],
          'correct_answer': 'Creating low-fidelity layout blueprints',
        },
        {
          'question_id': 4,
          'question': 'Which format is best for photos on the web?',
          'options': ['SVG', 'BMP', 'JPEG', 'EPS'],
          'correct_answer': 'JPEG',
        },
      ],
    },

    'bizlab': {
      'module_id': 3,
      'quiz_title': 'BizLab — Digital Marketing Quiz',
      'questions': [
        {
          'question_id': 1,
          'question': 'What does SEO stand for?',
          'options': [
            'Social Engagement Optimization',
            'Search Engine Optimization',
            'Sales Enhancement Online',
            'Site Exposure Operation',
          ],
          'correct_answer': 'Search Engine Optimization',
        },
        {
          'question_id': 2,
          'question': 'Which metric measures the percentage of users who click on a link?',
          'options': ['CPA', 'ROI', 'CTR', 'CPM'],
          'correct_answer': 'CTR',
        },
        {
          'question_id': 3,
          'question': 'Which platform is best known for professional networking?',
          'options': ['TikTok', 'Instagram', 'LinkedIn', 'Snapchat'],
          'correct_answer': 'LinkedIn',
        },
        {
          'question_id': 4,
          'question': 'What does ROI stand for?',
          'options': [
            'Rate of Interest',
            'Return on Investment',
            'Revenue Optimization Index',
            'Reach of Influence',
          ],
          'correct_answer': 'Return on Investment',
        },
      ],
    },

    'language_hub': {
      'module_id': 4,
      'quiz_title': 'Language Hub — English Quiz',
      'questions': [
        {
          'question_id': 1,
          'question': 'Which sentence is grammatically correct?',
          'options': [
            'She go to school every day.',
            'She goes to school every day.',
            'She going to school every day.',
            'She gone to school every day.',
          ],
          'correct_answer': 'She goes to school every day.',
        },
        {
          'question_id': 2,
          'question': 'What is the past tense of "run"?',
          'options': ['Runned', 'Running', 'Ran', 'Runs'],
          'correct_answer': 'Ran',
        },
        {
          'question_id': 3,
          'question': 'Which word is a synonym for "happy"?',
          'options': ['Sad', 'Joyful', 'Angry', 'Tired'],
          'correct_answer': 'Joyful',
        },
        {
          'question_id': 4,
          'question': 'What punctuation ends a question?',
          'options': ['Period (.)', 'Comma (,)', 'Question mark (?)', 'Exclamation (!)'],
          'correct_answer': 'Question mark (?)',
        },
      ],
    },

    'smart_academy': {
      'module_id': 5,
      'quiz_title': 'Smart Academy — Science & Math Quiz',
      'questions': [
        {
          'question_id': 1,
          'question': 'What is the value of π (pi) approximately?',
          'options': ['2.14', '3.14', '4.14', '1.14'],
          'correct_answer': '3.14',
        },
        {
          'question_id': 2,
          'question': 'What is the chemical symbol for water?',
          'options': ['O2', 'CO2', 'H2O', 'NaCl'],
          'correct_answer': 'H2O',
        },
        {
          'question_id': 3,
          'question': 'What force keeps planets in orbit around the Sun?',
          'options': ['Magnetic force', 'Friction', 'Gravity', 'Nuclear force'],
          'correct_answer': 'Gravity',
        },
        {
          'question_id': 4,
          'question': 'What is 15% of 200?',
          'options': ['25', '30', '35', '40'],
          'correct_answer': '30',
        },
      ],
    },

    'animation_lab': {
      'module_id': 6,
      'quiz_title': 'Animation Lab Quiz',
      'questions': [
        {
          'question_id': 1,
          'question': 'What is the standard frame rate for smooth animation?',
          'options': ['12 fps', '24 fps', '60 fps', '120 fps'],
          'correct_answer': '24 fps',
        },
        {
          'question_id': 2,
          'question': 'Which technique shows a slight over-movement before settling?',
          'options': ['Anticipation', 'Overshoot', 'Squash and Stretch', 'Follow-through'],
          'correct_answer': 'Follow-through',
        },
        {
          'question_id': 3,
          'question': 'What does "tweening" mean in animation?',
          'options': [
            'Duplicating frames',
            'Creating in-between frames automatically',
            'Adding sound to animation',
            'Exporting to video',
          ],
          'correct_answer': 'Creating in-between frames automatically',
        },
      ],
    },

    'fun_skill': {
      'module_id': 7,
      'quiz_title': 'Fun Skill Quiz',
      'questions': [
        {
          'question_id': 1,
          'question': 'Which engine is Unity primarily used to build games for?',
          'options': ['Web only', 'Mobile only', 'Console only', 'Multi-platform'],
          'correct_answer': 'Multi-platform',
        },
        {
          'question_id': 2,
          'question': 'What is the scripting language used in Unity?',
          'options': ['Python', 'Java', 'C#', 'Kotlin'],
          'correct_answer': 'C#',
        },
        {
          'question_id': 3,
          'question': 'What does "protagonist" mean in story writing?',
          'options': [
            'The villain of the story',
            'The main character',
            'The narrator',
            'A side character',
          ],
          'correct_answer': 'The main character',
        },
      ],
    },

    'sports': {
      'module_id': 8,
      'quiz_title': 'Sports & Fitness Quiz',
      'questions': [
        {
          'question_id': 1,
          'question': 'How many players are on a standard football (soccer) team?',
          'options': ['9', '10', '11', '12'],
          'correct_answer': '11',
        },
        {
          'question_id': 2,
          'question': 'What is the recommended daily water intake for an adult?',
          'options': ['1 liter', '2 liters', '4 liters', '500 ml'],
          'correct_answer': '2 liters',
        },
        {
          'question_id': 3,
          'question': 'Which macronutrient is the primary energy source for the body?',
          'options': ['Fat', 'Protein', 'Carbohydrates', 'Vitamins'],
          'correct_answer': 'Carbohydrates',
        },
      ],
    },
  };
}
